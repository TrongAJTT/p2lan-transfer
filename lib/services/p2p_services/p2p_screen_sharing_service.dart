import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/p2p_services/p2p_network_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// P2P Screen Sharing Service
/// Handles screen sharing functionality between devices
class P2PScreenSharingService extends ChangeNotifier {
  final P2PNetworkService _networkService;

  // State management
  bool _isSharing = false;
  bool _isReceiving = false;
  ScreenSharingSession? _currentSession;
  List<ScreenSharingRequest> _pendingRequests = [];
  List<ScreenInfo> _availableScreens = [];

  // WebRTC components
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  // Callbacks
  Function(ScreenSharingRequest)? _newRequestCallback;
  Function(ScreenSharingSession)? _sessionStartedCallback;
  Function()? _sessionEndedCallback;
  Function(String)? _userDisconnectedCallback;

  // Network callback
  Function(String)? _userLookupCallback;

  P2PScreenSharingService(this._networkService) {
    _setupNetworkListeners();
  }

  // Getters
  bool get isSharing => _isSharing;
  bool get isReceiving => _isReceiving;
  bool get isActive => _isSharing || _isReceiving;
  ScreenSharingSession? get currentSession => _currentSession;
  List<ScreenSharingRequest> get pendingRequests =>
      List.unmodifiable(_pendingRequests);
  List<ScreenInfo> get availableScreens => List.unmodifiable(_availableScreens);
  P2PUser? get sharingUser => _currentSession?.senderUser;
  P2PUser? get receivingUser => _currentSession?.receiverUser;
  MediaStream? get remoteStream => _remoteStream;

  // WebRTC configuration
  static const Map<String, dynamic> _rtcConfiguration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
    'iceCandidatePoolSize': 10,
    'bundlePolicy': 'max-bundle',
    'rtcpMuxPolicy': 'require',
  };

  /// Initialize the service
  Future<void> initialize() async {
    try {
      logInfo('P2PScreenSharingService: Initializing...');

      // Detect available screens (Windows only)
      if (Platform.isWindows) {
        await _detectAvailableScreens();
      }

      logInfo('P2PScreenSharingService: Initialized successfully');
    } catch (e) {
      logError('P2PScreenSharingService: Failed to initialize: $e');
      rethrow;
    }
  }

  /// Set user lookup callback (from service manager)
  void setUserLookupCallback(Function(String)? callback) {
    _userLookupCallback = callback;
  }

  /// Set callback for new screen sharing requests
  void setNewRequestCallback(Function(ScreenSharingRequest)? callback) {
    _newRequestCallback = callback;
  }

  /// Clear callback for new screen sharing requests
  void clearNewRequestCallback() {
    _newRequestCallback = null;
  }

  /// Set callback for session started
  void setSessionStartedCallback(Function(ScreenSharingSession)? callback) {
    _sessionStartedCallback = callback;
  }

  /// Clear callback for session started
  void clearSessionStartedCallback() {
    _sessionStartedCallback = null;
  }

  /// Set callback for session ended
  void setSessionEndedCallback(Function()? callback) {
    _sessionEndedCallback = callback;
  }

  /// Clear callback for session ended
  void clearSessionEndedCallback() {
    _sessionEndedCallback = null;
  }

  /// Set callback for user disconnected
  void setUserDisconnectedCallback(Function(String)? callback) {
    _userDisconnectedCallback = callback;
  }

  /// Clear callback for user disconnected
  void clearUserDisconnectedCallback() {
    _userDisconnectedCallback = null;
  }

  /// Check if screen sharing is supported on current platform
  bool get isSupported {
    return Platform.isAndroid || Platform.isWindows;
  }

  /// Check if user can share screen (trusted users only)
  bool canShareScreenWith(P2PUser user) {
    return user.isPaired && user.isTrusted && !isActive;
  }

  /// Send screen sharing request to user
  Future<bool> sendScreenSharingRequest(
    P2PUser targetUser, {
    String? reason,
    ScreenSharingQuality quality = ScreenSharingQuality.medium,
  }) async {
    try {
      if (!canShareScreenWith(targetUser)) {
        logError(
            'P2PScreenSharingService: Cannot share screen with user ${targetUser.displayName}');
        return false;
      }

      // Check permissions first
      if (Platform.isAndroid) {
        final hasPermission = await _checkAndRequestNotificationPermission();
        if (!hasPermission) {
          return false;
        }
      }

      final currentUser = _networkService.currentUser;
      if (currentUser == null) {
        logError(
            'P2PScreenSharingService: Current user is null, cannot send request');
        return false;
      }

      logInfo(
          'P2PScreenSharingService: Creating request from user ${currentUser.id} (${currentUser.displayName})');

      final request = ScreenSharingRequest.create(
        fromUserId: currentUser.id,
        fromUserName: currentUser.displayName,
        reason: reason,
        quality: quality,
      );

      final message = {
        'type': P2PMessageTypes.screenSharingRequest,
        'fromUserId': currentUser.id,
        'toUserId': targetUser.id,
        'data': request.toJson(),
      };

      logInfo(
          'P2PScreenSharingService: Sending screen sharing request with payload: $message');

      final success =
          await _networkService.sendMessageToUser(targetUser, message);

      if (success) {
        // Create preliminary session (waiting for response)
        _currentSession = ScreenSharingSession(
          sessionId: 'ss_${DateTime.now().millisecondsSinceEpoch}',
          senderUser: currentUser,
          receiverUser: targetUser,
          startTime: DateTime.now(),
          quality: quality,
          selectedScreenIndex: null,
        );

        logInfo(
            'P2PScreenSharingService: Screen sharing request sent to ${targetUser.displayName}, waiting for response');
      }

      return success;
    } catch (e) {
      logError(
          'P2PScreenSharingService: Failed to send screen sharing request: $e');
      return false;
    }
  }

  /// Respond to screen sharing request
  Future<bool> respondToScreenSharingRequest(
    String requestId,
    bool accept, {
    String? rejectReason,
    ScreenSharingQuality? quality,
  }) async {
    try {
      logInfo(
          'P2PScreenSharingService: Responding to screen sharing request $requestId, accept=$accept');
      final request =
          _pendingRequests.where((r) => r.requestId == requestId).firstOrNull;
      if (request == null) {
        logError('P2PScreenSharingService: Request not found: $requestId');
        return false;
      }

      final response = ScreenSharingResponse(
        requestId: requestId,
        accepted: accept,
        rejectReason: rejectReason,
        quality: quality ?? request.quality,
      );

      final user = _userLookupCallback?.call(request.fromUserId);
      if (user == null) {
        logError(
            'P2PScreenSharingService: User not found: ${request.fromUserId}');
        return false;
      }

      final message = {
        'type': P2PMessageTypes.screenSharingResponse,
        'fromUserId': _networkService.currentUser?.id ?? '',
        'toUserId': user.id,
        'data': response.toJson(),
      };

      final success = await _networkService.sendMessageToUser(user, message);

      // Remove request from pending list
      _pendingRequests.removeWhere((r) => r.requestId == requestId);

      if (success && accept) {
        // Start receiving session
        await _startReceivingSession(user, quality ?? request.quality);
      }

      notifyListeners();
      return success;
    } catch (e) {
      logError(
          'P2PScreenSharingService: Failed to respond to screen sharing request: $e');
      return false;
    }
  }

  /// Start sharing screen
  Future<bool> startSharing(
    P2PUser targetUser, {
    ScreenSharingQuality quality = ScreenSharingQuality.medium,
    int? screenIndex, // For Windows multi-screen support
  }) async {
    try {
      if (_isSharing || _isReceiving) {
        logError('P2PScreenSharingService: Already in an active session');
        return false;
      }

      // For Windows, show screen selection dialog if multiple screens
      if (Platform.isWindows &&
          _availableScreens.length > 1 &&
          screenIndex == null) {
        // This should be handled by the UI layer
        logError(
            'P2PScreenSharingService: Screen index required for multi-screen setup');
        return false;
      }

      // Check permissions for Android
      if (Platform.isAndroid) {
        final hasPermission = await _checkAndRequestNotificationPermission();
        if (!hasPermission) {
          logError('P2PScreenSharingService: Notification permission required');
          return false;
        }
      }

      // Initialize WebRTC
      await _initializeWebRTC();

      // Create local stream (screen capture)
      _localStream = await _createScreenCaptureStream(quality, screenIndex);
      if (_localStream == null) {
        logError(
            'P2PScreenSharingService: Failed to create screen capture stream');
        return false;
      }

      logInfo(
          'P2PScreenSharingService: Screen capture stream created successfully with ${_localStream!.getVideoTracks().length} video tracks');

      // Add tracks to peer connection (Unified Plan)
      for (final track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }

      // Create session
      _currentSession = ScreenSharingSession(
        sessionId: 'ss_${DateTime.now().millisecondsSinceEpoch}',
        senderUser: _networkService.currentUser!,
        receiverUser: targetUser,
        startTime: DateTime.now(),
        quality: quality,
        selectedScreenIndex: screenIndex,
      );

      _isSharing = true;
      notifyListeners();

      // Create and send WebRTC offer
      await _createAndSendOffer();

      logInfo(
          'P2PScreenSharingService: Started sharing screen with ${targetUser.displayName}');
      _sessionStartedCallback?.call(_currentSession!);

      return true;
    } catch (e) {
      logError('P2PScreenSharingService: Failed to start screen sharing: $e');
      await stopSharing();
      return false;
    }
  }

  /// Stop sharing screen
  Future<void> stopSharing() async {
    try {
      if (!_isSharing) return;

      // Send disconnect message to receiver
      if (_currentSession != null) {
        final message = {
          'type': P2PMessageTypes.screenSharingDisconnect,
          'fromUserId': _networkService.currentUser?.id ?? '',
          'toUserId': _currentSession!.receiverUser.id,
          'data': {'sessionId': _currentSession!.sessionId},
        };

        await _networkService.sendMessageToUser(
          _currentSession!.receiverUser,
          message,
        );
      }

      // Stop Android foreground service
      await _stopAndroidForegroundService();

      await _cleanupWebRTC();
      _currentSession = null;
      _isSharing = false;
      notifyListeners();

      logInfo('P2PScreenSharingService: Stopped screen sharing');
      _sessionEndedCallback?.call();
    } catch (e) {
      logError('P2PScreenSharingService: Error stopping screen sharing: $e');
    }
  }

  /// Stop receiving screen
  Future<void> stopReceiving() async {
    try {
      if (!_isReceiving) return;

      // Send disconnect message to sender
      if (_currentSession != null) {
        final message = {
          'type': P2PMessageTypes.screenSharingDisconnect,
          'fromUserId': _networkService.currentUser?.id ?? '',
          'toUserId': _currentSession!.senderUser.id,
          'data': {'sessionId': _currentSession!.sessionId},
        };

        await _networkService.sendMessageToUser(
          _currentSession!.senderUser,
          message,
        );
      }

      await _cleanupWebRTC();
      _currentSession = null;
      _isReceiving = false;
      notifyListeners();

      logInfo('P2PScreenSharingService: Stopped receiving screen');
      _sessionEndedCallback?.call();
    } catch (e) {
      logError('P2PScreenSharingService: Error stopping receiving: $e');
    }
  }

  /// Disconnect from current session
  Future<void> disconnect() async {
    if (_isSharing) {
      await stopSharing();
    } else if (_isReceiving) {
      await stopReceiving();
    }
  }

  /// Get WebRTC connection state for debugging
  String? get connectionState {
    if (_peerConnection == null) return null;
    // Note: This is a simplified state - actual implementation would need
    // to track connection state through callbacks
    return _isSharing
        ? 'sharing'
        : _isReceiving
            ? 'receiving'
            : 'idle';
  }

  /// Check if WebRTC is properly initialized
  bool get isWebRTCInitialized => _peerConnection != null;

  /// Get detailed debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'isSharing': _isSharing,
      'isReceiving': _isReceiving,
      'isActive': isActive,
      'hasLocalStream': _localStream != null,
      'hasRemoteStream': _remoteStream != null,
      'isWebRTCInitialized': isWebRTCInitialized,
      'currentSession': _currentSession?.sessionId,
      'pendingRequests': _pendingRequests.length,
    };
  }

  /// Start Android foreground service for screen sharing
  Future<void> _startAndroidForegroundService() async {
    try {
      if (Platform.isAndroid) {
        // Use method channel to start foreground service
        const platform = MethodChannel('dev.trongajtt.p2lan/screen_sharing');
        await platform.invokeMethod('startScreenSharingService');
        logInfo('P2PScreenSharingService: Android foreground service started');
      }
    } catch (e) {
      logError(
          'P2PScreenSharingService: Failed to start Android foreground service: $e');
    }
  }

  /// Stop Android foreground service
  Future<void> _stopAndroidForegroundService() async {
    try {
      if (Platform.isAndroid) {
        // Use method channel to stop foreground service
        const platform = MethodChannel('dev.trongajtt.p2lan/screen_sharing');
        await platform.invokeMethod('stopScreenSharingService');
        logInfo('P2PScreenSharingService: Android foreground service stopped');
      }
    } catch (e) {
      logError(
          'P2PScreenSharingService: Failed to stop Android foreground service: $e');
    }
  }

  /// Notify that a user has disconnected
  void notifyUserDisconnected(String userId) {
    if (_currentSession != null) {
      final isRelatedUser = _currentSession!.senderUser.id == userId ||
          _currentSession!.receiverUser.id == userId;

      if (isRelatedUser) {
        logInfo('P2PScreenSharingService: User disconnected, ending session');
        disconnect();
        _userDisconnectedCallback?.call(userId);
      }
    }
  }

  /// Handle TCP message from network service
  void handleTcpMessage(Socket socket, Map<String, dynamic> messageData) {
    try {
      final messageType = messageData['type'] as String?;
      final payload = messageData['data'] as Map<String, dynamic>?;

      logInfo(
          'P2PScreenSharingService: Received TCP message of type $messageType from ${socket.remoteAddress.address}: $payload');

      if (payload == null) {
        logWarning(
            'P2PScreenSharingService: Message data is null for type $messageType');
        return;
      }

      switch (messageType) {
        case P2PMessageTypes.screenSharingRequest:
          _handleScreenSharingRequest(payload);
          break;
        case P2PMessageTypes.screenSharingResponse:
          _handleScreenSharingResponse(payload);
          break;
        case P2PMessageTypes.screenSharingData:
          _handleScreenSharingData(payload);
          break;
        case P2PMessageTypes.screenSharingDisconnect:
          _handleScreenSharingDisconnect(payload);
          break;
      }
    } catch (e) {
      logError('P2PScreenSharingService: Error handling TCP message: $e');
    }
  }

  // Private methods

  void _setupNetworkListeners() {
    // Listen for network state changes
    _networkService.addListener(() {
      if (!_networkService.isEnabled && isActive) {
        logInfo(
            'P2PScreenSharingService: Network disabled, stopping screen sharing');
        disconnect();
      }
    });
  }

  Future<void> _detectAvailableScreens() async {
    try {
      // This is a placeholder for Windows screen detection
      // In a real implementation, you would use win32 APIs or a native plugin
      _availableScreens = [
        const ScreenInfo(
          index: 0,
          name: 'Primary Display',
          width: 1920,
          height: 1080,
          isPrimary: true,
        ),
      ];
    } catch (e) {
      logError('P2PScreenSharingService: Failed to detect screens: $e');
    }
  }

  Future<bool> _checkAndRequestNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      if (status.isGranted) return true;

      final result = await Permission.notification.request();
      return result.isGranted;
    } catch (e) {
      logError(
          'P2PScreenSharingService: Error checking notification permission: $e');
      return false;
    }
  }

  Future<void> _initializeWebRTC() async {
    try {
      logInfo(
          'P2PScreenSharingService: Initializing WebRTC with config: $_rtcConfiguration');
      _peerConnection = await createPeerConnection(_rtcConfiguration);

      _peerConnection!.onIceCandidate = (candidate) {
        logInfo(
            'P2PScreenSharingService: ICE candidate generated: ${candidate.candidate}');
        if (candidate.candidate != null) {
          _sendSignalingData('ice-candidate', {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          });
        }
      };

      _peerConnection!.onTrack = (event) {
        logInfo(
            'P2PScreenSharingService: Remote track received: ${event.track.kind}');
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          logInfo(
              'P2PScreenSharingService: Remote stream received with ${_remoteStream!.getVideoTracks().length} video tracks');
          notifyListeners();
        }
      };

      // Add connection state monitoring
      _peerConnection!.onConnectionState = (state) {
        logInfo(
            'P2PScreenSharingService: WebRTC connection state changed to: $state');
      };

      _peerConnection!.onIceConnectionState = (state) {
        logInfo(
            'P2PScreenSharingService: ICE connection state changed to: $state');
      };

      _peerConnection!.onIceGatheringState = (state) {
        logInfo(
            'P2PScreenSharingService: ICE gathering state changed to: $state');
      };

      logInfo(
          'P2PScreenSharingService: WebRTC peer connection initialized successfully');
    } catch (e) {
      logError('P2PScreenSharingService: Failed to initialize WebRTC: $e');
      rethrow;
    }
  }

  Future<MediaStream?> _createScreenCaptureStream(
    ScreenSharingQuality quality,
    int? screenIndex,
  ) async {
    try {
      final constraints = <String, dynamic>{
        'video': {
          'width': quality.width > 0 ? quality.width : 1920,
          'height': quality.height > 0 ? quality.height : 1080,
          'frameRate': quality.fps > 0 ? quality.fps : 20,
        },
        'audio': false, // Screen sharing without audio for now
      };

      if (Platform.isAndroid) {
        // For Android, start foreground service first, then request screen capture
        logInfo(
            'P2PScreenSharingService: Starting foreground service for Android screen capture');
        await _startAndroidForegroundService();

        logInfo(
            'P2PScreenSharingService: Requesting screen capture on Android with constraints: $constraints');
        final stream =
            await navigator.mediaDevices.getDisplayMedia(constraints);
        logInfo(
            'P2PScreenSharingService: Screen capture stream obtained on Android');
        return stream;
      } else if (Platform.isWindows) {
        // For Windows, specify screen if multiple screens available
        if (screenIndex != null && _availableScreens.isNotEmpty) {
          constraints['video']['displaySurface'] = 'monitor';
          constraints['video']['cursor'] = 'always';
        }
        logInfo(
            'P2PScreenSharingService: Requesting screen capture on Windows with constraints: $constraints');
        final stream =
            await navigator.mediaDevices.getDisplayMedia(constraints);
        logInfo(
            'P2PScreenSharingService: Screen capture stream obtained on Windows');
        return stream;
      }

      return null;
    } catch (e) {
      logError(
          'P2PScreenSharingService: Failed to create screen capture stream: $e');
      return null;
    }
  }

  Future<void> _startReceivingSession(
      P2PUser senderUser, ScreenSharingQuality quality) async {
    try {
      await _initializeWebRTC();

      _currentSession = ScreenSharingSession(
        sessionId: 'ss_${DateTime.now().millisecondsSinceEpoch}',
        senderUser: senderUser,
        receiverUser: _networkService.currentUser!,
        startTime: DateTime.now(),
        quality: quality,
      );

      _isReceiving = true;
      notifyListeners();

      logInfo(
          'P2PScreenSharingService: Started receiving screen from ${senderUser.displayName}');

      logInfo(
          '[DEBUG] About to call _sessionStartedCallback, callback is ${_sessionStartedCallback != null ? "registered" : "NULL"}');
      _sessionStartedCallback?.call(_currentSession!);
      logInfo('[DEBUG] _sessionStartedCallback called');
    } catch (e) {
      logError(
          'P2PScreenSharingService: Failed to start receiving session: $e');
      rethrow;
    }
  }

  Future<void> _cleanupWebRTC() async {
    try {
      await _localStream?.dispose();
      await _remoteStream?.dispose();
      await _peerConnection?.close();

      _localStream = null;
      _remoteStream = null;
      _peerConnection = null;
    } catch (e) {
      logError('P2PScreenSharingService: Error cleaning up WebRTC: $e');
    }
  }

  void _handleScreenSharingRequest(Map<String, dynamic> payload) {
    try {
      logInfo(
          'P2PScreenSharingService: Received screen sharing request with payload: $payload');

      final request = ScreenSharingRequest.fromJson(payload);

      logInfo(
          'P2PScreenSharingService: Processing screen sharing request from ${request.fromUserId}');

      // Get sender user info
      final senderUser = _userLookupCallback?.call(request.fromUserId);
      if (senderUser == null) {
        logWarning(
            'P2PScreenSharingService: Unknown user ${request.fromUserId}');
        _sendRejectResponse(request, 'Unknown user');
        return;
      }

      // Check if user is paired
      if (!senderUser.isPaired) {
        logWarning(
            'P2PScreenSharingService: User ${senderUser.displayName} is not paired');
        _sendRejectResponse(request, 'User not paired');
        return;
      }

      // Add to pending requests
      _pendingRequests.add(request);
      notifyListeners();

      // Auto-accept if sender is trusted
      if (senderUser.isTrusted) {
        logInfo(
            'P2PScreenSharingService: Auto-accepting screen sharing request from trusted user ${senderUser.displayName}');
        // Use unawaited to not block, but handle errors
        respondToScreenSharingRequest(request.requestId, true).catchError((e) {
          logError('P2PScreenSharingService: Error auto-accepting request: $e');
          return false;
        });
      } else {
        // Show dialog for confirmation (user is paired but not trusted)
        logInfo(
            'P2PScreenSharingService: Showing confirmation dialog for request from ${senderUser.displayName}');
        _newRequestCallback?.call(request);
      }
    } catch (e) {
      logError(
          'P2PScreenSharingService: Error handling screen sharing request: $e');
    }
  }

  void _handleScreenSharingResponse(Map<String, dynamic> payload) {
    try {
      logInfo(
          'P2PScreenSharingService: Handling screen sharing response with payload: $payload');
      final response = ScreenSharingResponse.fromJson(payload);

      logInfo(
          'P2PScreenSharingService: Response parsed - accepted: ${response.accepted}');

      if (response.accepted) {
        // Response received, now start the actual screen sharing
        logInfo(
            'P2PScreenSharingService: Screen sharing request accepted, starting screen sharing');

        // Find the target user from current session (should be the receiver)
        if (_currentSession != null) {
          logInfo(
              'P2PScreenSharingService: Current session found, receiver: ${_currentSession!.receiverUser.displayName}');
          final targetUser = _currentSession!.receiverUser;

          // Start the actual screen sharing session
          logInfo(
              'P2PScreenSharingService: Calling _startActualScreenSharing...');
          _startActualScreenSharing(
            targetUser,
            quality: response.quality ?? ScreenSharingQuality.medium,
          );
        } else {
          logError(
              'P2PScreenSharingService: No current session found when handling response');
        }
      } else {
        logInfo(
            'P2PScreenSharingService: Screen sharing request rejected: ${response.rejectReason}');

        // Clean up if rejected
        _currentSession = null;
        _isSharing = false;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      logError(
          'P2PScreenSharingService: Error handling screen sharing response: $e\n$stackTrace');
    }
  }

  void _handleScreenSharingData(Map<String, dynamic> payload) {
    try {
      final type = payload['type'] as String?;
      final data = payload['data'] as Map<String, dynamic>?;

      if (type == null || data == null) {
        logError('P2PScreenSharingService: Invalid signaling data received');
        return;
      }

      switch (type) {
        case 'offer':
          _handleOffer(data);
          break;
        case 'answer':
          _handleAnswer(data);
          break;
        case 'ice-candidate':
          _handleIceCandidate(data);
          break;
        default:
          logWarning('P2PScreenSharingService: Unknown signaling type: $type');
      }
    } catch (e) {
      logError(
          'P2PScreenSharingService: Error handling screen sharing data: $e');
    }
  }

  Future<void> _handleOffer(Map<String, dynamic> data) async {
    try {
      final sdp = data['sdp'] as String?;
      if (sdp == null) {
        logError('P2PScreenSharingService: No SDP in offer');
        return;
      }

      logInfo(
          'P2PScreenSharingService: Received offer, setting remote description');
      logInfo(
          'P2PScreenSharingService: Offer SDP: ${sdp.substring(0, 100)}...');

      // Only initialize WebRTC if not already initialized
      if (_peerConnection == null) {
        logInfo(
            'P2PScreenSharingService: Initializing WebRTC for offer handling');
        await _initializeWebRTC();
      }

      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdp, 'offer'),
      );
      logInfo('P2PScreenSharingService: Remote description set');

      logInfo('P2PScreenSharingService: Creating answer');
      final answer = await _peerConnection!.createAnswer();
      logInfo(
          'P2PScreenSharingService: Answer created: ${answer.sdp?.substring(0, 100)}...');

      await _peerConnection!.setLocalDescription(answer);
      logInfo('P2PScreenSharingService: Local description set for answer');

      // Send answer back to sender
      await _sendSignalingData('answer', {
        'sdp': answer.sdp,
      });

      logInfo('P2PScreenSharingService: Answer sent');
    } catch (e) {
      logError('P2PScreenSharingService: Error handling offer: $e');
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    try {
      final sdp = data['sdp'] as String?;
      if (sdp == null) {
        logError('P2PScreenSharingService: No SDP in answer');
        return;
      }

      logInfo(
          'P2PScreenSharingService: Received answer, setting remote description');
      logInfo(
          'P2PScreenSharingService: Answer SDP: ${sdp.substring(0, 100)}...');

      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdp, 'answer'),
      );

      logInfo(
          'P2PScreenSharingService: Remote description set, WebRTC connection should be established');
    } catch (e) {
      logError('P2PScreenSharingService: Error handling answer: $e');
    }
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> data) async {
    try {
      final candidate = data['candidate'] as String?;
      final sdpMid = data['sdpMid'] as String?;
      final sdpMLineIndex = data['sdpMLineIndex'] as int?;

      if (candidate == null) {
        logError(
            'P2PScreenSharingService: No candidate in ICE candidate message');
        return;
      }

      logInfo('P2PScreenSharingService: Adding ICE candidate: $candidate');

      if (_peerConnection != null) {
        await _peerConnection!.addCandidate(
          RTCIceCandidate(candidate, sdpMid, sdpMLineIndex),
        );
        logInfo('P2PScreenSharingService: ICE candidate added successfully');
      } else {
        logWarning(
            'P2PScreenSharingService: Cannot add ICE candidate - peer connection is null');
      }
    } catch (e) {
      logError('P2PScreenSharingService: Error handling ICE candidate: $e');
    }
  }

  Future<void> _startActualScreenSharing(
    P2PUser targetUser, {
    ScreenSharingQuality quality = ScreenSharingQuality.medium,
    int? screenIndex,
  }) async {
    try {
      logInfo(
          'P2PScreenSharingService: ===== STARTING ACTUAL SCREEN SHARING =====');
      logInfo(
          'P2PScreenSharingService: Target user: ${targetUser.displayName}, Quality: $quality');

      // Initialize WebRTC
      logInfo('P2PScreenSharingService: Initializing WebRTC...');
      await _initializeWebRTC();
      logInfo('P2PScreenSharingService: WebRTC initialized');

      // Create local stream (screen capture)
      logInfo('P2PScreenSharingService: Creating screen capture stream...');
      _localStream = await _createScreenCaptureStream(quality, screenIndex);
      if (_localStream == null) {
        logError(
            'P2PScreenSharingService: Failed to create screen capture stream');
        return;
      }

      logInfo(
          'P2PScreenSharingService: Screen capture stream created successfully with ${_localStream!.getVideoTracks().length} video tracks');

      // Add tracks to peer connection (Unified Plan)
      logInfo('P2PScreenSharingService: Adding tracks to peer connection...');
      for (final track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }
      logInfo('P2PScreenSharingService: Tracks added to peer connection');

      _isSharing = true;
      notifyListeners();

      // Create and send WebRTC offer
      logInfo('P2PScreenSharingService: Creating and sending WebRTC offer...');
      await _createAndSendOffer();

      logInfo(
          'P2PScreenSharingService: ===== ACTUALLY STARTED SHARING SCREEN =====');
      _sessionStartedCallback?.call(_currentSession!);
    } catch (e, stackTrace) {
      logError(
          'P2PScreenSharingService: Failed to start actual screen sharing: $e\n$stackTrace');

      // Clean up on error
      _isSharing = false;
      _currentSession = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _createAndSendOffer() async {
    try {
      logInfo('P2PScreenSharingService: Creating WebRTC offer');

      final offer = await _peerConnection!.createOffer();
      logInfo(
          'P2PScreenSharingService: Offer created: ${offer.sdp?.substring(0, 100)}...');

      await _peerConnection!.setLocalDescription(offer);
      logInfo('P2PScreenSharingService: Local description set');

      // Send offer to receiver
      await _sendSignalingData('offer', {
        'sdp': offer.sdp,
      });

      logInfo('P2PScreenSharingService: Offer created and sent');
    } catch (e) {
      logError('P2PScreenSharingService: Error creating offer: $e');
      rethrow;
    }
  }

  Future<void> _sendSignalingData(
      String type, Map<String, dynamic> data) async {
    try {
      if (_currentSession == null) {
        logError('P2PScreenSharingService: No active session for signaling');
        return;
      }

      final targetUser = _isSharing
          ? _currentSession!.receiverUser
          : _currentSession!.senderUser;

      final message = {
        'type': P2PMessageTypes.screenSharingData,
        'fromUserId': _networkService.currentUser!.id,
        'toUserId': targetUser.id,
        'data': {
          'sessionId': _currentSession!.sessionId,
          'type': type,
          'data': data,
        },
      };

      await _networkService.sendMessageToUser(targetUser, message);
      logInfo(
          'P2PScreenSharingService: Sent $type signaling data to ${targetUser.displayName}');
    } catch (e) {
      logError('P2PScreenSharingService: Error sending signaling data: $e');
    }
  }

  void _handleScreenSharingDisconnect(Map<String, dynamic> payload) {
    try {
      final sessionId = payload['sessionId'] as String?;

      if (_currentSession?.sessionId == sessionId) {
        logInfo(
            'P2PScreenSharingService: Remote user disconnected from screen sharing');
        disconnect();
      }
    } catch (e) {
      logError(
          'P2PScreenSharingService: Error handling screen sharing disconnect: $e');
    }
  }

  Future<void> _sendRejectResponse(
      ScreenSharingRequest request, String reason) async {
    final response = ScreenSharingResponse(
      requestId: request.requestId,
      accepted: false,
      rejectReason: reason,
    );

    final currentUser = _networkService.currentUser;
    if (currentUser == null) return;

    final message = {
      'type': P2PMessageTypes.screenSharingResponse,
      'fromUserId': currentUser.id,
      'toUserId': request.fromUserId,
      'data': response.toJson(),
    };

    final targetUser = _userLookupCallback?.call(request.fromUserId);
    if (targetUser != null) {
      await _networkService.sendMessageToUser(targetUser, message);
    }
  }

  @override
  void dispose() {
    logInfo('P2PScreenSharingService: Disposing screen sharing service...');

    disconnect();

    // Clear callbacks
    _newRequestCallback = null;
    _sessionStartedCallback = null;
    _sessionEndedCallback = null;
    _userDisconnectedCallback = null;
    _userLookupCallback = null;

    super.dispose();
  }
}
