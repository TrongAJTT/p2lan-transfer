import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/native_control_service.dart';
import 'package:p2lan/services/p2p_services/p2p_network_service.dart';
import 'package:win32/win32.dart';

/// P2P Remote Control Service
/// Handles remote desktop control functionality
class P2PRemoteControlService extends ChangeNotifier {
  // Services
  final P2PNetworkService _networkService;

  // State
  bool _isControlling = false;
  bool _isBeingControlled = false;
  String? _activeSessionId;
  P2PUser? _controllingUser;
  P2PUser? _controlledUser;

  // Pending requests
  final List<RemoteControlRequest> _pendingRequests = [];

  // Callbacks
  Function(RemoteControlRequest)? _onNewRemoteControlRequest;
  Function(P2PUser)? _onRemoteControlAccepted;
  Function(String)? _getUserCallback;
  Function(P2PUser, P2PUser, String)?
      _onSessionStarted; // controller, controlled, sessionId
  Function()? _onSessionEnded;
  Function(String)? _onUserDisconnected; // userId

  // Request timeout timers
  final Map<String, Timer> _requestTimers = {};

  // Gesture debouncing
  DateTime? _lastGestureTime;
  static const int _gestureDebounceMs = 300; // Prevent rapid gesture conflicts

  P2PRemoteControlService(this._networkService);

  // =============================================================================
  // GETTERS
  // =============================================================================

  /// Whether this device is currently controlling another device
  bool get isControlling => _isControlling;

  /// Whether this device is being controlled by another device
  bool get isBeingControlled => _isBeingControlled;

  /// Active session ID if in a remote control session
  String? get activeSessionId => _activeSessionId;

  /// User that is controlling this device (if being controlled)
  P2PUser? get controllingUser => _controllingUser;

  /// User that this device is controlling (if controlling)
  P2PUser? get controlledUser => _controlledUser;

  /// Pending remote control requests
  List<RemoteControlRequest> get pendingRequests => _pendingRequests;

  /// Check if user can be controlled (Windows only for now)
  bool canControlUser(P2PUser user) {
    return user.platform == UserPlatform.windows &&
        user.isPaired &&
        user.isOnline;
  }

  /// Check if this device can be controlled
  bool get canBeControlled {
    return Platform.isWindows;
  }

  /// Check if user is still available for remote control
  bool isUserAvailableForRemoteControl(P2PUser user) {
    return user.isOnline && user.isPaired;
  }

  /// Clear remote control session if user is no longer available
  void checkAndClearSessionIfUserUnavailable() {
    if (_isControlling && _controlledUser != null) {
      if (!isUserAvailableForRemoteControl(_controlledUser!)) {
        logInfo(
            'P2PRemoteControlService: Controlled user ${_controlledUser!.displayName} is no longer available, clearing session');
        _stopRemoteControl(triggerCallback: true);
      }
    } else if (_isBeingControlled && _controllingUser != null) {
      if (!isUserAvailableForRemoteControl(_controllingUser!)) {
        logInfo(
            'P2PRemoteControlService: Controlling user ${_controllingUser!.displayName} is no longer available, clearing session');
        _stopRemoteControl(triggerCallback: true);
      }
    }
  }

  /// Notify that a user has been disconnected
  void notifyUserDisconnected(String userId) {
    // Check if this user is involved in our remote control session
    if (_isControlling && _controlledUser?.id == userId) {
      logInfo(
          'P2PRemoteControlService: Controlled user ${_controlledUser!.displayName} disconnected, clearing session');
      _stopRemoteControl(triggerCallback: true);
    } else if (_isBeingControlled && _controllingUser?.id == userId) {
      logInfo(
          'P2PRemoteControlService: Controlling user ${_controllingUser!.displayName} disconnected, clearing session');
      _stopRemoteControl(triggerCallback: true);
    }

    // Notify callback if set
    _onUserDisconnected?.call(userId);
  }

  // =============================================================================
  // INITIALIZATION
  // =============================================================================

  /// Initialize the service
  Future<void> initialize() async {
    logInfo('P2PRemoteControlService: Initializing...');
    // No special initialization needed for now
    logInfo('P2PRemoteControlService: Initialized successfully');
  }

  // =============================================================================
  // PUBLIC METHODS - REQUEST MANAGEMENT
  // =============================================================================

  /// Send remote control request to target user
  Future<bool> sendRemoteControlRequest(P2PUser targetUser,
      {String? reason}) async {
    try {
      if (!canControlUser(targetUser)) {
        logWarning(
            'P2PRemoteControlService: Cannot control user ${targetUser.displayName} (platform: ${targetUser.platform.name})');
        return false;
      }

      if (_isControlling) {
        logWarning(
            'P2PRemoteControlService: Already controlling another device');
        return false;
      }

      final currentUser = _networkService.currentUser;
      if (currentUser == null) {
        logError('P2PRemoteControlService: Current user is null');
        return false;
      }

      final request = RemoteControlRequest.create(
        fromUserId: currentUser.id,
        fromUserName: currentUser.displayName,
        reason: reason,
      );

      final message = {
        'type': P2PMessageTypes.remoteControlRequest,
        'fromUserId': currentUser.id,
        'toUserId': targetUser.id,
        'data': request.toJson(),
      };

      final success =
          await _networkService.sendMessageToUser(targetUser, message);
      if (success) {
        // Set up timeout timer
        _requestTimers[request.requestId] =
            Timer(const Duration(seconds: 60), () {
          _handleRemoteControlRequestTimeout(request.requestId);
        });

        logInfo(
            'P2PRemoteControlService: Sent remote control request to ${targetUser.displayName}');
        return true;
      } else {
        logError(
            'P2PRemoteControlService: Failed to send remote control request');
        return false;
      }
    } catch (e) {
      logError(
          'P2PRemoteControlService: Error sending remote control request: $e');
      return false;
    }
  }

  /// Respond to remote control request
  Future<bool> respondToRemoteControlRequest(String requestId, bool accept,
      {String? rejectReason}) async {
    try {
      final request =
          _pendingRequests.firstWhere((r) => r.requestId == requestId);

      // Cancel timeout timer
      _requestTimers[requestId]?.cancel();
      _requestTimers.remove(requestId);

      final response = RemoteControlResponse(
        requestId: requestId,
        accepted: accept,
        rejectReason: rejectReason,
      );

      final currentUser = _networkService.currentUser;
      if (currentUser == null) {
        logError('P2PRemoteControlService: Current user is null');
        return false;
      }

      final message = {
        'type': P2PMessageTypes.remoteControlResponse,
        'fromUserId': currentUser.id,
        'toUserId': request.fromUserId,
        'data': response.toJson(),
      };

      // Find target user
      final targetUser = _getTargetUser(request.fromUserId);
      // print('>>>>>>>>>>>>>> ${targetUser?.toJson()}');
      if (targetUser == null || !targetUser.isPaired) {
        logError('P2PRemoteControlService: Target user not found');
        return false;
      }

      final success =
          await _networkService.sendMessageToUser(targetUser, message);
      if (success) {
        // Remove from pending list
        _pendingRequests.removeWhere((r) => r.requestId == requestId);

        if (accept) {
          // Start being controlled
          _startBeingControlled(targetUser, requestId);
        }

        logInfo(
            'P2PRemoteControlService: Responded to remote control request: ${accept ? "accepted" : "rejected"}');
        notifyListeners();
        return true;
      } else {
        logError(
            'P2PRemoteControlService: Failed to send remote control response');
        return false;
      }
    } catch (e) {
      logError(
          'P2PRemoteControlService: Error responding to remote control request: $e');
      return false;
    }
  }

  /// Send remote control event (mouse movement, clicks, etc.)
  Future<bool> sendRemoteControlEvent(RemoteControlEvent event) async {
    try {
      if (!_isControlling ||
          _controlledUser == null ||
          _activeSessionId == null) {
        logWarning('P2PRemoteControlService: Not in an active control session');
        return false;
      }

      final currentUser = _networkService.currentUser;
      if (currentUser == null) {
        logError('P2PRemoteControlService: Current user is null');
        return false;
      }

      final message = {
        'type': P2PMessageTypes.remoteControlEvent,
        'fromUserId': currentUser.id,
        'toUserId': _controlledUser!.id,
        'data': {
          'sessionId': _activeSessionId,
          'event': event.toJson(),
        },
      };

      final success =
          await _networkService.sendMessageToUser(_controlledUser!, message);
      if (!success) {
        logWarning(
            'P2PRemoteControlService: Failed to send remote control event');
      }
      return success;
    } catch (e) {
      logError(
          'P2PRemoteControlService: Error sending remote control event: $e');
      return false;
    }
  }

  /// Disconnect from remote control session
  Future<void> disconnectRemoteControl({bool isActiveDisconnect = true}) async {
    try {
      if (_isControlling && _controlledUser != null) {
        // Send disconnect event to controlled device
        await sendRemoteControlEvent(RemoteControlEvent.disconnect());

        // Send disconnect message
        final currentUser = _networkService.currentUser;
        if (currentUser != null) {
          final message = {
            'type': P2PMessageTypes.remoteControlDisconnect,
            'fromUserId': currentUser.id,
            'toUserId': _controlledUser!.id,
            'data': {'sessionId': _activeSessionId},
          };
          await _networkService.sendMessageToUser(_controlledUser!, message);
        }

        logInfo(
            'P2PRemoteControlService: Disconnected from controlling ${_controlledUser!.displayName}');
      } else if (_isBeingControlled && _controllingUser != null) {
        // Send disconnect message to controlling device
        final currentUser = _networkService.currentUser;
        if (currentUser != null) {
          final message = {
            'type': P2PMessageTypes.remoteControlDisconnect,
            'fromUserId': currentUser.id,
            'toUserId': _controllingUser!.id,
            'data': {'sessionId': _activeSessionId},
          };
          await _networkService.sendMessageToUser(_controllingUser!, message);
        }

        logInfo(
            'P2PRemoteControlService: Disconnected from being controlled by ${_controllingUser!.displayName}');
      }

      // For active disconnect: don't trigger callback (UI will clear immediately)
      // For passive disconnect: trigger callback (UI needs to be notified)
      _stopRemoteControl(triggerCallback: !isActiveDisconnect);
    } catch (e) {
      logError(
          'P2PRemoteControlService: Error disconnecting remote control: $e');
      _stopRemoteControl(
          triggerCallback: true); // Force stop on error with callback
    }
  }

  // =============================================================================
  // MESSAGE HANDLING
  // =============================================================================

  /// Handle incoming TCP message
  void handleTcpMessage(Socket socket, Map<String, dynamic> messageData) {
    try {
      final message = P2PMessage.fromJson(messageData);

      switch (message.type) {
        case P2PMessageTypes.remoteControlRequest:
          _handleRemoteControlRequest(message);
          break;
        case P2PMessageTypes.remoteControlResponse:
          _handleRemoteControlResponse(message);
          break;
        case P2PMessageTypes.remoteControlEvent:
          _handleRemoteControlEvent(message);
          break;
        case P2PMessageTypes.remoteControlDisconnect:
          _handleRemoteControlDisconnect(message);
          break;
      }
    } catch (e) {
      logError('P2PRemoteControlService: Failed to process TCP message: $e');
    }
  }

  // =============================================================================
  // PRIVATE METHODS - MESSAGE HANDLERS
  // =============================================================================

  void _handleRemoteControlRequest(P2PMessage message) async {
    try {
      final request = RemoteControlRequest.fromJson(message.data);
      logInfo(
          'P2PRemoteControlService: Processing remote control request from ${request.fromUserId}');

      // Check if we can be controlled
      if (!canBeControlled) {
        logWarning(
            'P2PRemoteControlService: Platform not supported for remote control');
        await _sendRejectResponse(
            request, 'Platform not supported for remote control');
        return;
      }

      // Check if already being controlled
      if (_isBeingControlled) {
        logWarning(
            'P2PRemoteControlService: Device is already being controlled');
        await _sendRejectResponse(
            request, 'Device is already being controlled');
        return;
      }

      // Check if sender exists (but allow non-paired users to show dialog)
      final fromUser = _getTargetUser(request.fromUserId);
      logInfo(
          'P2PRemoteControlService: Looking up user ${request.fromUserId}, found: ${fromUser?.displayName ?? "null"}');

      if (fromUser == null) {
        logWarning(
            'P2PRemoteControlService: Unknown user ${request.fromUserId}');
        await _sendRejectResponse(request, 'Unknown user');
        return;
      }

      // Check if user is paired
      if (!fromUser.isPaired) {
        logWarning(
            'P2PRemoteControlService: User ${fromUser.displayName} is not paired');
        await _sendRejectResponse(request, 'User not paired');
        return;
      }

      // Auto-accept if user is trusted (no need to show dialog)
      if (fromUser.isTrusted) {
        logInfo(
            'P2PRemoteControlService: Auto-accepting request from trusted user ${fromUser.displayName}');

        // Add to pending first (needed for respondToRemoteControlRequest)
        _pendingRequests.add(request);

        // Set up timeout timer
        _requestTimers[request.requestId] =
            Timer(const Duration(seconds: 60), () {
          _handleRemoteControlRequestTimeout(request.requestId);
        });

        // Auto-accept the request
        await respondToRemoteControlRequest(request.requestId, true);
        return;
      }

      logInfo('P2PRemoteControlService: Adding request to pending list');
      // Add to pending requests
      _pendingRequests.add(request);

      // Set up timeout timer
      _requestTimers[request.requestId] =
          Timer(const Duration(seconds: 60), () {
        _handleRemoteControlRequestTimeout(request.requestId);
      });

      // Notify UI about new request
      _onNewRemoteControlRequest?.call(request);

      logInfo(
          'P2PRemoteControlService: Received remote control request from ${request.fromUserName}');
      notifyListeners();
    } catch (e) {
      logError(
          'P2PRemoteControlService: Error handling remote control request: $e');
    }
  }

  void _handleRemoteControlResponse(P2PMessage message) async {
    try {
      final response = RemoteControlResponse.fromJson(message.data);

      // Cancel timeout timer
      _requestTimers[response.requestId]?.cancel();
      _requestTimers.remove(response.requestId);

      if (response.accepted) {
        // Find target user
        final targetUser = _getTargetUser(message.fromUserId);
        if (targetUser != null) {
          _startControlling(targetUser, response.requestId);
          logInfo(
              'P2PRemoteControlService: Remote control request accepted by ${targetUser.displayName}');

          // Notify UI about accepted session
          _onRemoteControlAccepted?.call(targetUser);
        }
      } else {
        logInfo(
            'P2PRemoteControlService: Remote control request rejected: ${response.rejectReason ?? "Unknown reason"}');
      }

      notifyListeners();
    } catch (e) {
      logError(
          'P2PRemoteControlService: Error handling remote control response: $e');
    }
  }

  void _handleRemoteControlEvent(P2PMessage message) async {
    try {
      if (!_isBeingControlled || _controllingUser?.id != message.fromUserId) {
        logWarning(
            'P2PRemoteControlService: Received remote control event from unauthorized user');
        return;
      }

      final data = message.data;
      final sessionId = data['sessionId'] as String?;
      if (sessionId != _activeSessionId) {
        logWarning(
            'P2PRemoteControlService: Received remote control event with invalid session ID');
        return;
      }

      final event =
          RemoteControlEvent.fromJson(data['event'] as Map<String, dynamic>);

      // Process the remote control event
      await _processRemoteControlEvent(event);
    } catch (e) {
      logError(
          'P2PRemoteControlService: Error handling remote control event: $e');
    }
  }

  void _handleRemoteControlDisconnect(P2PMessage message) {
    try {
      final data = message.data;
      final sessionId = data['sessionId'] as String?;

      if (sessionId == _activeSessionId) {
        logInfo(
            'P2PRemoteControlService: Remote control session disconnected by remote user');
        _stopRemoteControl(
            triggerCallback:
                true); // This is passive disconnect, trigger callback
      }
    } catch (e) {
      logError(
          'P2PRemoteControlService: Error handling remote control disconnect: $e');
    }
  }

  // =============================================================================
  // PRIVATE METHODS - SESSION MANAGEMENT
  // =============================================================================

  void _startControlling(P2PUser targetUser, String sessionId) {
    _isControlling = true;
    _controlledUser = targetUser;
    _activeSessionId = sessionId;
    logInfo(
        'P2PRemoteControlService: Started controlling ${targetUser.displayName}');

    // Notify session started with current user as controller
    final currentUser = _networkService.currentUser;
    if (currentUser != null && _onSessionStarted != null) {
      _onSessionStarted!(currentUser, targetUser, sessionId);
    }

    notifyListeners();
  }

  void _startBeingControlled(P2PUser controllingUser, String sessionId) {
    _isBeingControlled = true;
    _controllingUser = controllingUser;
    _activeSessionId = sessionId;
    logInfo(
        'P2PRemoteControlService: Started being controlled by ${controllingUser.displayName}');

    // Notify session started with current user as controlled
    final currentUser = _networkService.currentUser;
    if (currentUser != null && _onSessionStarted != null) {
      _onSessionStarted!(controllingUser, currentUser, sessionId);
    }

    notifyListeners();
  }

  void _stopRemoteControl({bool triggerCallback = true}) {
    // Prevent multiple calls by checking if already stopped
    if (!_isControlling && !_isBeingControlled && _activeSessionId == null) {
      logInfo('P2PRemoteControlService: Session already stopped, skipping');
      return;
    }

    final wasActive = _isControlling || _isBeingControlled;

    _isControlling = false;
    _isBeingControlled = false;
    _activeSessionId = null;
    _controllingUser = null;
    _controlledUser = null;

    // Only trigger callback if session was actually active and callback is requested
    if (triggerCallback && wasActive && _onSessionEnded != null) {
      _onSessionEnded!();
    }

    logInfo(
        'P2PRemoteControlService: Remote control session stopped (was active: $wasActive, trigger callback: $triggerCallback)');
    notifyListeners();
  }

  // =============================================================================
  // PRIVATE METHODS - EVENT PROCESSING
  // =============================================================================

  Future<void> _processRemoteControlEvent(RemoteControlEvent event) async {
    if (!Platform.isWindows) {
      logWarning(
          'P2PRemoteControlService: Remote control events only supported on Windows');
      return;
    }

    // Check if service is disposed
    if (hasListeners == false) {
      logWarning(
          'P2PRemoteControlService: Service disposed, ignoring remote control event');
      return;
    }

    try {
      switch (event.type) {
        case RemoteControlEventType.mouseMove:
          if (event.x != null && event.y != null) {
            await _moveMouse(event.x!, event.y!);
          }
          break;
        case RemoteControlEventType.leftClick:
          await _leftClick();
          break;
        case RemoteControlEventType.rightClick:
          await _rightClick();
          break;
        case RemoteControlEventType.middleClick:
          await _middleClick();
          break;
        case RemoteControlEventType.startLeftLongClick:
          await _startLeftLongClick();
          break;
        case RemoteControlEventType.stopLeftLongClick:
          await _stopLeftLongClick();
          break;
        case RemoteControlEventType.startMiddleLongClick:
          await _startMiddleLongClick();
          break;
        case RemoteControlEventType.stopMiddleLongClick:
          await _stopMiddleLongClick();
          break;
        case RemoteControlEventType.startRightLongClick:
          await _startRightLongClick();
          break;
        case RemoteControlEventType.stopRightLongClick:
          await _stopRightLongClick();
          break;
        case RemoteControlEventType.scroll:
          if (event.deltaX != null && event.deltaY != null) {
            await _scroll(event.deltaX!, event.deltaY!);
          }
          break;
        case RemoteControlEventType.scrollUp:
          await _scrollUp();
          break;
        case RemoteControlEventType.scrollDown:
          await _scrollDown();
          break;
        case RemoteControlEventType.disconnect:
          _stopRemoteControl(triggerCallback: true);
          break;
        // New touchpad gestures
        case RemoteControlEventType.twoFingerScroll:
          if (event.deltaX != null && event.deltaY != null) {
            await _scroll(event.deltaX!, event.deltaY!);
          }
          break;
        case RemoteControlEventType.twoFingerTap:
          await _rightClick(); // Two finger tap = right click
          break;
        case RemoteControlEventType.twoFingerSlowTap:
          await _showContextMenu(); // Two finger slow tap = context menu
          break;
        case RemoteControlEventType.twoFingerDragDrop:
          if (event.x != null && event.y != null) {
            await _dragDrop(event.x!, event.y!);
          }
          break;
        case RemoteControlEventType.threeFingerSwipeUp:
          await _showTaskView(); // Three finger swipe up = Task View
          break;
        case RemoteControlEventType.threeFingerSwipeDown:
          await _showDesktop(); // Three finger swipe down = Show Desktop
          break;
        case RemoteControlEventType.threeFingerSwipeLeft:
          await _switchToNextApp(); // Three finger swipe left = Alt+Tab (previous)
          break;
        case RemoteControlEventType.threeFingerSwipeRight:
          await _switchToPrevApp(); // Three finger swipe right = Alt+Tab (next)
          break;
        case RemoteControlEventType.threeFingerTap:
          await _openActionCenter(); // Three finger tap = Action Center
          break;
        case RemoteControlEventType.fourFingerTap:
          await _switchVirtualDesktop(); // Four finger tap = Switch Virtual Desktop
          break;
        case RemoteControlEventType.keyDown:
          if (event.keyCode != null) {
            NativeControlService.sendKey(event.keyCode!, isDown: true);
          }
          break;
        case RemoteControlEventType.keyUp:
          if (event.keyCode != null) {
            NativeControlService.sendKey(event.keyCode!, isDown: false);
          }
          break;
        case RemoteControlEventType.sendText:
          if (event.text != null && event.text!.isNotEmpty) {
            await _sendText(event.text!);
          }
          break;
      }
    } catch (e) {
      logError(
          'P2PRemoteControlService: Error processing remote control event: $e');
    }
  }

  // =============================================================================
  // PRIVATE METHODS - WINDOWS API CALLS
  // =============================================================================

  Future<void> _moveMouse(double x, double y) async {
    try {
      // logDebug('P2PRemoteControlService: Move mouse by ($x, $y)');
      NativeControlService.moveMouse(x, y);
    } catch (e) {
      logError('P2PRemoteControlService: Error moving mouse: $e');
    }
  }

  Future<void> _leftClick() async {
    try {
      // logDebug('P2PRemoteControlService: Left click');
      NativeControlService.clickMouse(isLeft: true, isDown: true);
      await Future.delayed(const Duration(milliseconds: 50));
      NativeControlService.clickMouse(isLeft: true, isDown: false);
    } catch (e) {
      logError('P2PRemoteControlService: Error performing left click: $e');
    }
  }

  Future<void> _rightClick() async {
    try {
      // logDebug('P2PRemoteControlService: Right click');
      NativeControlService.clickMouse(isLeft: false, isDown: true);
      await Future.delayed(const Duration(milliseconds: 50));
      NativeControlService.clickMouse(isLeft: false, isDown: false);
    } catch (e) {
      logError('P2PRemoteControlService: Error performing right click: $e');
    }
  }

  Future<void> _middleClick() async {
    try {
      // logDebug('P2PRemoteControlService: Middle click');
      NativeControlService.clickMouse(
          isLeft: false, isDown: true, isMiddle: true);
      await Future.delayed(const Duration(milliseconds: 50));
      NativeControlService.clickMouse(
          isLeft: false, isDown: false, isMiddle: true);
    } catch (e) {
      logError('P2PRemoteControlService: Error performing middle click: $e');
    }
  }

  Future<void> _startLeftLongClick() async {
    try {
      // logDebug('P2PRemoteControlService: Start left long click');
      NativeControlService.clickMouse(
          isLeft: true, isDown: true, isMiddle: false);
    } catch (e) {
      logError('P2PRemoteControlService: Error starting left long click: $e');
    }
  }

  Future<void> _startMiddleLongClick() async {
    try {
      NativeControlService.clickMouse(
          isLeft: false, isDown: true, isMiddle: true);
    } catch (e) {
      logError('P2PRemoteControlService: Error starting middle long click: $e');
    }
  }

  Future<void> _stopMiddleLongClick() async {
    try {
      NativeControlService.clickMouse(
          isLeft: false, isDown: false, isMiddle: true);
    } catch (e) {
      logError('P2PRemoteControlService: Error stopping middle long click: $e');
    }
  }

  Future<void> _stopLeftLongClick() async {
    try {
      // logDebug('P2PRemoteControlService: Stop left long click');
      NativeControlService.clickMouse(
          isLeft: true, isDown: false, isMiddle: false);
    } catch (e) {
      logError('P2PRemoteControlService: Error stopping left long click: $e');
    }
  }

  Future<void> _startRightLongClick() async {
    try {
      // logDebug('P2PRemoteControlService: Start right long click');
      NativeControlService.clickMouse(
          isLeft: false, isDown: true, isMiddle: false);
    } catch (e) {
      logError('P2PRemoteControlService: Error starting right long click: $e');
    }
  }

  Future<void> _stopRightLongClick() async {
    try {
      // logDebug('P2PRemoteControlService: Stop right long click');
      NativeControlService.clickMouse(
          isLeft: false, isDown: false, isMiddle: false);
    } catch (e) {
      logError('P2PRemoteControlService: Error stopping right long click: $e');
    }
  }

  Future<void> _scroll(double deltaX, double deltaY) async {
    try {
      // logDebug('P2PRemoteControlService: Scroll ($deltaX, $deltaY)');
      NativeControlService.scrollMouse(deltaX, deltaY);
    } catch (e) {
      logError('P2PRemoteControlService: Error scrolling: $e');
    }
  }

  Future<void> _scrollUp() async {
    try {
      // logDebug('P2PRemoteControlService: Scroll up');
      NativeControlService.scrollMouse(0, 1); // Positive Y for scroll up
    } catch (e) {
      logError('P2PRemoteControlService: Error scrolling up: $e');
    }
  }

  Future<void> _scrollDown() async {
    try {
      // logDebug('P2PRemoteControlService: Scroll down');
      NativeControlService.scrollMouse(0, -1); // Negative Y for scroll down
    } catch (e) {
      logError('P2PRemoteControlService: Error scrolling down: $e');
    }
  }

  // =============================================================================
  // PRIVATE METHODS - GESTURE DEBOUNCING
  // =============================================================================

  bool _isGestureTooFast() {
    final now = DateTime.now();
    if (_lastGestureTime != null &&
        now.difference(_lastGestureTime!).inMilliseconds < _gestureDebounceMs) {
      return true; // Too fast, ignore
    }
    _lastGestureTime = now;
    return false;
  }

  // =============================================================================
  // PRIVATE METHODS - NEW TOUCHPAD GESTURES
  // =============================================================================

  Future<void> _showContextMenu() async {
    try {
      // Right click to show context menu
      await _rightClick();
    } catch (e) {
      logError('P2PRemoteControlService: Error showing context menu: $e');
    }
  }

  Future<void> _dragDrop(double x, double y) async {
    try {
      // Simple drag and drop simulation - hold left mouse down, move, then release
      NativeControlService.clickMouse(isLeft: true, isDown: true);
      await Future.delayed(const Duration(milliseconds: 100));
      await _moveMouse(x, y);
      await Future.delayed(const Duration(milliseconds: 100));
      NativeControlService.clickMouse(isLeft: true, isDown: false);
    } catch (e) {
      logError('P2PRemoteControlService: Error performing drag drop: $e');
    }
  }

  Future<void> _showTaskView() async {
    if (_isGestureTooFast()) return; // Prevent rapid gestures

    try {
      // Windows + Tab to show Task View
      NativeControlService.sendKey(VK_LWIN, isDown: true);
      NativeControlService.sendKey(VK_TAB, isDown: true);
      await Future.delayed(const Duration(milliseconds: 50));
      NativeControlService.sendKey(VK_TAB, isDown: false);
      NativeControlService.sendKey(VK_LWIN, isDown: false);
    } catch (e) {
      logError('P2PRemoteControlService: Error showing task view: $e');
    }
  }

  Future<void> _showDesktop() async {
    if (_isGestureTooFast()) return; // Prevent rapid gestures

    try {
      // Windows + D to show desktop
      NativeControlService.sendKey(VK_LWIN, isDown: true);
      NativeControlService.sendKey(68, isDown: true); // D key
      await Future.delayed(const Duration(milliseconds: 50));
      NativeControlService.sendKey(68, isDown: false);
      NativeControlService.sendKey(VK_LWIN, isDown: false);
    } catch (e) {
      logError('P2PRemoteControlService: Error showing desktop: $e');
    }
  }

  Future<void> _switchToNextApp() async {
    if (_isGestureTooFast()) return; // Prevent rapid gestures

    try {
      // Alt + Tab to switch to next app
      NativeControlService.sendKey(VK_MENU, isDown: true);
      NativeControlService.sendKey(VK_TAB, isDown: true);
      await Future.delayed(const Duration(milliseconds: 50));
      NativeControlService.sendKey(VK_TAB, isDown: false);
      NativeControlService.sendKey(VK_MENU, isDown: false);
    } catch (e) {
      logError('P2PRemoteControlService: Error switching to next app: $e');
    }
  }

  Future<void> _switchToPrevApp() async {
    if (_isGestureTooFast()) return; // Prevent rapid gestures

    try {
      // Alt + Shift + Tab to switch to previous app
      NativeControlService.sendKey(VK_MENU, isDown: true);
      NativeControlService.sendKey(VK_SHIFT, isDown: true);
      NativeControlService.sendKey(VK_TAB, isDown: true);
      await Future.delayed(const Duration(milliseconds: 50));
      NativeControlService.sendKey(VK_TAB, isDown: false);
      NativeControlService.sendKey(VK_SHIFT, isDown: false);
      NativeControlService.sendKey(VK_MENU, isDown: false);
    } catch (e) {
      logError('P2PRemoteControlService: Error switching to prev app: $e');
    }
  }

  Future<void> _openActionCenter() async {
    if (_isGestureTooFast()) return; // Prevent rapid gestures

    try {
      // Windows + A to open Action Center
      NativeControlService.sendKey(VK_LWIN, isDown: true);
      NativeControlService.sendKey(65, isDown: true); // A key
      await Future.delayed(const Duration(milliseconds: 50));
      NativeControlService.sendKey(65, isDown: false);
      NativeControlService.sendKey(VK_LWIN, isDown: false);
    } catch (e) {
      logError('P2PRemoteControlService: Error opening action center: $e');
    }
  }

  Future<void> _switchVirtualDesktop() async {
    if (_isGestureTooFast()) return; // Prevent rapid gestures

    try {
      // Ctrl + Windows + Right Arrow to switch virtual desktop
      NativeControlService.sendKey(VK_CONTROL, isDown: true);
      NativeControlService.sendKey(VK_LWIN, isDown: true);
      NativeControlService.sendKey(VK_RIGHT, isDown: true);
      await Future.delayed(const Duration(milliseconds: 50));
      NativeControlService.sendKey(VK_RIGHT, isDown: false);
      NativeControlService.sendKey(VK_LWIN, isDown: false);
      NativeControlService.sendKey(VK_CONTROL, isDown: false);
    } catch (e) {
      logError('P2PRemoteControlService: Error switching virtual desktop: $e');
    }
  }

  Future<void> _sendText(String text) async {
    try {
      logInfo(
          'P2PRemoteControlService: Sending text: ${text.length} characters');

      // First, try to type text directly at cursor position
      bool directTypeSuccess = await _tryDirectType(text);

      if (!directTypeSuccess) {
        // Fallback: Copy text to clipboard and paste
        await Clipboard.setData(ClipboardData(text: text));

        // Send Ctrl+V to paste
        NativeControlService.sendKey(VK_CONTROL, isDown: true);
        await Future.delayed(const Duration(milliseconds: 50));
        NativeControlService.sendKey(VK_V, isDown: true);
        await Future.delayed(const Duration(milliseconds: 50));
        NativeControlService.sendKey(VK_V, isDown: false);
        await Future.delayed(const Duration(milliseconds: 50));
        NativeControlService.sendKey(VK_CONTROL, isDown: false);
      }
    } catch (e) {
      logError('P2PRemoteControlService: Error sending text: $e');
    }
  }

  Future<bool> _tryDirectType(String text) async {
    try {
      // Try to type each character directly
      for (int i = 0; i < text.length; i++) {
        final char = text[i];
        final keyCode = _getKeyCodeForChar(char);

        if (keyCode != null) {
          // Send key down
          NativeControlService.sendKey(keyCode, isDown: true);
          await Future.delayed(const Duration(milliseconds: 10));
          // Send key up
          NativeControlService.sendKey(keyCode, isDown: false);
          await Future.delayed(const Duration(milliseconds: 20));
        } else {
          // If we can't map a character, direct typing failed
          logWarning(
              'P2PRemoteControlService: Cannot map character "$char" to key code');
          return false;
        }
      }

      return true; // Direct typing succeeded
    } catch (e) {
      logError('P2PRemoteControlService: Error in direct typing: $e');
      return false;
    }
  }

  int? _getKeyCodeForChar(String char) {
    if (char.length != 1) return null;

    final codeUnit = char.codeUnitAt(0);

    // Handle special characters
    switch (char) {
      case ' ':
        return VK_SPACE; // Space
      case '\n':
        return VK_RETURN; // Enter
      case '\t':
        return VK_TAB; // Tab
    }

    // Handle regular characters (A-Z, a-z, 0-9)
    if (codeUnit >= 65 && codeUnit <= 90) {
      // A-Z
      return codeUnit;
    } else if (codeUnit >= 97 && codeUnit <= 122) {
      // a-z
      return codeUnit - 32; // Convert to uppercase
    } else if (codeUnit >= 48 && codeUnit <= 57) {
      // 0-9
      return codeUnit;
    }

    // Handle common symbols
    switch (char) {
      case '!':
        return VK_1; // Shift + 1
      case '@':
        return VK_2; // Shift + 2
      case '#':
        return VK_3; // Shift + 3
      case '\$':
        return VK_4; // Shift + 4
      case '%':
        return VK_5; // Shift + 5
      case '^':
        return VK_6; // Shift + 6
      case '&':
        return VK_7; // Shift + 7
      case '*':
        return VK_8; // Shift + 8
      case '(':
        return VK_9; // Shift + 9
      case ')':
        return VK_0; // Shift + 0
      case '-':
        return VK_SUBTRACT;
      case '=':
        return VK_ADD;
      case '[':
        return VK_OEM_4;
      case ']':
        return VK_OEM_6;
      case '\\':
        return VK_OEM_5;
      case ';':
        return VK_OEM_1;
      case "'":
        return VK_OEM_7;
      case ',':
        return VK_OEM_COMMA;
      case '.':
        return VK_OEM_PERIOD;
      case '/':
        return VK_OEM_2;
    }

    // If we can't map the character, return null
    return null;
  }

  // =============================================================================
  // PRIVATE METHODS - UTILITIES
  // =============================================================================

  void _handleRemoteControlRequestTimeout(String requestId) {
    _pendingRequests.removeWhere((r) => r.requestId == requestId);
    _requestTimers.remove(requestId);
    logInfo(
        'P2PRemoteControlService: Remote control request timed out: $requestId');
    notifyListeners();
  }

  Future<void> _sendRejectResponse(
      RemoteControlRequest request, String reason) async {
    final response = RemoteControlResponse(
      requestId: request.requestId,
      accepted: false,
      rejectReason: reason,
    );

    final currentUser = _networkService.currentUser;
    if (currentUser == null) return;

    final message = {
      'type': P2PMessageTypes.remoteControlResponse,
      'fromUserId': currentUser.id,
      'toUserId': request.fromUserId,
      'data': response.toJson(),
    };

    final targetUser = _getTargetUser(request.fromUserId);
    if (targetUser != null) {
      await _networkService.sendMessageToUser(targetUser, message);
    }
  }

  P2PUser? _getTargetUser(String userId) {
    // Use callback from service manager to get user
    if (_getUserCallback != null) {
      return _getUserCallback!(userId);
    }
    return null;
  }

  // =============================================================================
  // PUBLIC METHODS - CALLBACKS
  // =============================================================================

  /// Set callback for new remote control requests
  void setNewRemoteControlRequestCallback(
      Function(RemoteControlRequest)? callback) {
    _onNewRemoteControlRequest = callback;
  }

  /// Clear callback for new remote control requests
  void clearNewRemoteControlRequestCallback() {
    _onNewRemoteControlRequest = null;
  }

  /// Set callback for remote control accepted (for navigation)
  void setRemoteControlAcceptedCallback(Function(P2PUser)? callback) {
    _onRemoteControlAccepted = callback;
  }

  /// Clear callback for remote control accepted
  void clearRemoteControlAcceptedCallback() {
    _onRemoteControlAccepted = null;
  }

  /// Set user lookup callback (provided by service manager)
  void setUserLookupCallback(P2PUser? Function(String) callback) {
    _getUserCallback = callback;
  }

  /// Set callback for session started (controller, controlled, sessionId)
  void setSessionStartedCallback(Function(P2PUser, P2PUser, String)? callback) {
    _onSessionStarted = callback;
  }

  /// Clear callback for session started
  void clearSessionStartedCallback() {
    _onSessionStarted = null;
  }

  /// Set callback for session ended
  void setSessionEndedCallback(Function()? callback) {
    _onSessionEnded = callback;
  }

  /// Clear callback for session ended
  void clearSessionEndedCallback() {
    _onSessionEnded = null;
  }

  /// Set callback for user disconnected
  void setUserDisconnectedCallback(Function(String)? callback) {
    _onUserDisconnected = callback;
  }

  /// Clear callback for user disconnected
  void clearUserDisconnectedCallback() {
    _onUserDisconnected = null;
  }

  // =============================================================================
  // CLEANUP
  // =============================================================================

  @override
  void dispose() {
    // Cancel all timers
    for (final timer in _requestTimers.values) {
      timer.cancel();
    }
    _requestTimers.clear();

    // Stop any active session
    if (_isControlling || _isBeingControlled) {
      disconnectRemoteControl();
    }

    logInfo('P2PRemoteControlService: Disposed');
    super.dispose();
  }
}
