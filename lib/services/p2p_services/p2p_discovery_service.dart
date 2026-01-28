import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/isar_service.dart';
import 'package:p2lan/services/p2p_services/p2p_network_service.dart';
import 'package:p2lan/utils/isar_utils.dart';
import 'package:p2lan/utils/platform_detection_utils.dart';
import 'package:uuid/uuid.dart';

/// P2P Discovery Service - Handles device discovery, pairing, broadcast, and trust management
/// Extracted from monolithic P2PService for better modularity
class P2PDiscoveryService extends ChangeNotifier {
  final P2PNetworkService _networkService;

  // State management
  bool _isDiscovering = false;
  bool _isBroadcasting = false;

  // User management
  final Map<String, P2PUser> _discoveredUsers = {};

  // Pairing management
  final List<PairingRequest> _pendingRequests = [];

  // Callbacks
  Function(PairingRequest)? _onNewPairingRequest;
  Function(Socket, Map<String, dynamic>)? _onRemoteControlMessage;
  Function(Socket, Map<String, dynamic>)? _onScreenSharingMessage;
  Function(String)? _onUserDisconnected; // userId

  // Timers
  Timer? _broadcastTimer;
  Timer? _autoDiscoveryTimer;

  // Discovery state
  DateTime? lastDiscoveryTime;

  // Getters
  bool get isDiscovering => _isDiscovering;
  bool get isBroadcasting => _isBroadcasting;
  List<P2PUser> get discoveredUsers => _discoveredUsers.values.toList();
  List<P2PUser> get pairedUsers =>
      _discoveredUsers.values.where((u) => u.isPaired).toList();
  List<P2PUser> get connectedUsers =>
      _discoveredUsers.values.where((u) => u.isStored).toList();
  List<P2PUser> get unconnectedUsers =>
      _discoveredUsers.values.where((u) => !u.isStored).toList();
  List<PairingRequest> get pendingRequests =>
      List.unmodifiable(_pendingRequests);

  P2PDiscoveryService(this._networkService) {
    // Set up message handlers
    _networkService.setUdpMessageHandler(_handleUdpMessage);
  }

  /// Initialize discovery service
  Future<void> initialize() async {
    // Load stored users and pending requests
    await _loadStoredUsers();
    await _loadPendingRequests();

    logInfo('P2PDiscoveryService: Initialized successfully');
  }

  /// Start discovery process with limited duration for battery saving
  Future<void> startDiscovery() async {
    if (!_networkService.isEnabled) {
      logError(
          'P2PDiscoveryService: Cannot start discovery - network not enabled');
      return;
    }

    _isDiscovering = true;

    // 🔥 NEW: Limited discovery for 5 seconds only when enabling network
    logInfo(
        'P2PDiscoveryService: Starting limited 5-second discovery period...');

    // Auto scan immediately when network starts
    await Future.delayed(const Duration(seconds: 1)); // Wait for network ready
    await manualDiscovery();

    // Schedule auto-stop after 5 seconds to save battery and feel faster
    Timer(const Duration(seconds: 5), () {
      if (_isDiscovering) {
        logInfo(
            'P2PDiscoveryService: Stopping automatic discovery after 5 seconds (battery optimization)');
        _isDiscovering = false;

        // Notify network service that discovery is complete
        _networkService.onDiscoveryComplete();

        notifyListeners();
      }
    });

    logInfo('P2PDiscoveryService: Discovery started (will auto-stop in 5s)');
    notifyListeners();
  }

  /// Stop discovery process
  Future<void> stopDiscovery() async {
    _isDiscovering = false;
    _isBroadcasting = false;

    _broadcastTimer?.cancel();
    _autoDiscoveryTimer?.cancel();

    // Mark all non-stored users as offline
    _cleanupUsersOnStop();

    logInfo('P2PDiscoveryService: Discovery stopped');
    notifyListeners();
  }

  /// Manual discovery scan
  Future<void> manualDiscovery() async {
    if (!_networkService.isEnabled || _networkService.currentUser == null) {
      return;
    }

    lastDiscoveryTime = DateTime.now();
    logInfo('P2PDiscoveryService: Starting manual discovery scan...');

    // Set status to discovering for manual discovery
    _networkService.setConnectionStatus(ConnectionStatus.discovering);

    await _sendDiscoveryScanRequest();

    // Schedule status change back to connected after a short delay
    Timer(const Duration(seconds: 3), () {
      _networkService.setConnectionStatus(ConnectionStatus.connected);
      logInfo(
          'P2PDiscoveryService: Manual discovery completed, status changed to connected');
    });

    logInfo('P2PDiscoveryService: Manual discovery scan completed');
    notifyListeners();
  }

  /// Send pairing request to user
  Future<bool> sendPairingRequest(
      P2PUser targetUser, bool saveConnection) async {
    try {
      if (_networkService.currentUser == null) return false;

      final request = PairingRequest(
        id: const Uuid().v4(),
        fromUserId: _networkService.currentUser!.id,
        fromUserName: _networkService.currentUser!.displayName,
        fromProfileId: _networkService.currentUser!.appInstallationId,
        fromIpAddress: _networkService.currentUser!.ipAddress,
        fromPort: _networkService.currentUser!.port,
        wantsSaveConnection: saveConnection,
        requestTime: DateTime.now(),
      );

      final message = {
        'type': P2PMessageTypes.pairingRequest,
        'fromUserId': _networkService.currentUser!.id,
        'toUserId': targetUser.id,
        'data': request.toJson(),
      };

      return await _networkService.sendMessageToUser(targetUser, message);
    } catch (e) {
      logError('P2PDiscoveryService: Failed to send pairing request: $e');
      return false;
    }
  }

  /// Respond to pairing request
  Future<bool> respondToPairingRequest(String requestId, bool accept,
      bool trustUser, bool saveConnection) async {
    try {
      final request = _pendingRequests.firstWhere((r) => r.id == requestId);

      if (accept) {
        // Create or update user
        final existingUser = _discoveredUsers[request.fromUserId];
        final user = existingUser ??
            P2PUser(
              id: request.fromUserId,
              displayName: request.fromUserName,
              profileId: request.fromAppInstallationId,
              ipAddress: request.fromIpAddress,
              port: request.fromPort,
              lastSeen: DateTime.now(),
            );

        // Update pairing status
        user.isPaired = true;
        user.isTrusted = trustUser;
        user.pairedAt = DateTime.now();
        user.isStored = saveConnection;

        _discoveredUsers[user.id] = user;
        await _saveUser(user);
      }

      // Send response
      final message = {
        'type': P2PMessageTypes.pairingResponse,
        'fromUserId': _networkService.currentUser!.id,
        'toUserId': request.fromUserId,
        'data': {
          'requestId': requestId,
          'accepted': accept,
          'trusted': trustUser,
          'saveConnection': saveConnection,
        },
      };

      final targetUser = _discoveredUsers[request.fromUserId];
      if (targetUser != null) {
        await _networkService.sendMessageToUser(targetUser, message);
      }

      // Remove from pending list
      _pendingRequests.removeWhere((r) => r.id == requestId);
      request.isProcessed = true;
      await _removePairingRequest(requestId);

      notifyListeners();
      logInfo(
          'P2PDiscoveryService: Pairing request ${accept ? "accepted" : "rejected"}: $requestId');
      return true;
    } catch (e) {
      logError('P2PDiscoveryService: Failed to respond to pairing request: $e');
      return false;
    }
  }

  /// Unpair from user
  Future<bool> unpairUser(String userId) async {
    try {
      final user = _discoveredUsers[userId];
      if (user == null) return false;

      // Send unpair notification if user is online
      if (user.isOnline) {
        final message = {
          'type': P2PMessageTypes.disconnect,
          'fromUserId': _networkService.currentUser!.id,
          'toUserId': user.id,
          'data': {
            'reason': 'unpair_initiated',
            'message': 'User unpaired from you',
            'fromUserName': _networkService.currentUser!.displayName,
            'unpair': true,
          },
        };

        try {
          await _networkService.sendMessageToUser(user, message);
        } catch (e) {
          logWarning(
              'P2PDiscoveryService: Failed to send unpair notification: $e');
        }
      }

      // Remove from storage completely
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.p2PUsers.delete(fastHash(userId));
      });

      // Remove from discovered users
      _discoveredUsers.remove(userId);

      notifyListeners();
      logInfo('P2PDiscoveryService: Unpaired from user: ${user.displayName}');
      return true;
    } catch (e) {
      logError('P2PDiscoveryService: Failed to unpair user: $e');
      return false;
    }
  }

  /// Send trust request
  Future<bool> sendTrustRequest(P2PUser targetUser) async {
    try {
      if (!targetUser.isPaired) {
        throw Exception('User must be paired first');
      }

      final message = {
        'type': P2PMessageTypes.trustRequest,
        'fromUserId': _networkService.currentUser!.id,
        'toUserId': targetUser.id,
        'data': {
          'fromUserName': _networkService.currentUser!.displayName,
        },
      };

      return await _networkService.sendMessageToUser(targetUser, message);
    } catch (e) {
      logError('P2PDiscoveryService: Failed to send trust request: $e');
      return false;
    }
  }

  /// Add trust to user
  Future<bool> addTrust(String userId) async {
    try {
      final user = _discoveredUsers[userId];
      if (user == null) return false;

      user.isTrusted = true;
      await _saveUser(user);

      notifyListeners();
      logInfo('P2PDiscoveryService: Added trust to user: ${user.displayName}');
      return true;
    } catch (e) {
      logError('P2PDiscoveryService: Failed to add trust: $e');
      return false;
    }
  }

  /// Remove trust from user
  Future<bool> removeTrust(String userId) async {
    try {
      final user = _discoveredUsers[userId];
      if (user == null) return false;

      user.isTrusted = false;
      await _saveUser(user);

      notifyListeners();
      logInfo(
          'P2PDiscoveryService: Removed trust from user: ${user.displayName}');
      return true;
    } catch (e) {
      logError('P2PDiscoveryService: Failed to remove trust: $e');
      return false;
    }
  }

  /// Toggle broadcast announcements
  Future<void> toggleBroadcast() async {
    if (!_networkService.isEnabled) {
      throw Exception('Networking must be enabled to toggle broadcast');
    }

    if (_isBroadcasting) {
      await _stopBroadcast();
    } else {
      await _startBroadcast();
    }
  }

  /// Set callback for new pairing requests
  void setNewPairingRequestCallback(Function(PairingRequest)? callback) {
    _onNewPairingRequest = callback;
  }

  /// Set callback for remote control messages
  void setRemoteControlMessageCallback(
      Function(Socket, Map<String, dynamic>)? callback) {
    _onRemoteControlMessage = callback;
  }

  /// Set callback for screen sharing messages
  void setScreenSharingMessageCallback(
      Function(Socket, Map<String, dynamic>)? callback) {
    _onScreenSharingMessage = callback;
  }

  /// Set callback for user disconnected
  void setUserDisconnectedCallback(Function(String)? callback) {
    _onUserDisconnected = callback;
  }

  /// Create or update a blocked user coming from the pairing dialog,
  /// mark as temp-stored if newly created, update in-memory map and persist.
  Future<void> blockUserFromPairing({
    required String userId,
    required String displayName,
    required String profileId,
    required String ipAddress,
    required int port,
  }) async {
    final isar = IsarService.isar;
    final existing = await isar.p2PUsers.get(fastHash(userId));
    final user = existing ??
        P2PUser(
          id: userId,
          displayName: displayName,
          profileId: profileId,
          ipAddress: ipAddress,
          port: port,
          lastSeen: DateTime.now(),
          isStored: false,
          isTempStored: true,
        );
    user.isBlocked = true;
    _discoveredUsers[userId] = user;
    await isar.writeTxn(() async => isar.p2PUsers.put(user));
    notifyListeners();
  }

  /// Get user by ID
  P2PUser? getUserById(String userId) {
    return _discoveredUsers[userId];
  }

  /// Update user's last seen time
  void updateUserLastSeen(String userId) {
    final user = _discoveredUsers[userId];
    if (user != null) {
      user.lastSeen = DateTime.now();
      user.isOnline = true;
    }
  }

  /// Perform cleanup of offline users
  Future<void> performCleanup() async {
    if (_networkService.currentUser == null) return;

    final now = DateTime.now();
    bool hasChanges = false;

    // Mark users offline if no activity for more than 150 seconds
    final usersToRemove = <String>[];

    for (final entry in _discoveredUsers.entries) {
      final user = entry.value;
      final timeSinceLastSeen = now.difference(user.lastSeen);

      // Mark offline if no activity for 150 seconds
      if (timeSinceLastSeen.inSeconds > 150 && user.isOnline) {
        user.isOnline = false;
        hasChanges = true;
        logInfo(
            'P2PDiscoveryService: Marked user ${user.displayName} as offline');
      }

      // Remove completely if offline for more than 5 minutes and not paired
      if (timeSinceLastSeen.inMinutes > 5 && !user.isPaired) {
        usersToRemove.add(entry.key);
        logInfo('P2PDiscoveryService: Removing stale user ${user.displayName}');
      }
    }

    // Remove stale users
    for (final userId in usersToRemove) {
      final user = _discoveredUsers[userId];
      if (user != null && (user.isBlocked || user.isTempStored)) {
        // Keep blocked or temp-stored users; only mark offline and persist
        user.isOnline = false;
        await _saveUser(user);
        continue;
      }
      _discoveredUsers.remove(userId);
      await _removeUser(userId);
      hasChanges = true;
    }

    // Remove old unprocessed pairing requests (older than 1 hour)
    final expiredRequests = <PairingRequest>[];
    _pendingRequests.removeWhere((request) {
      final isExpired = now.difference(request.requestTime).inHours > 1;
      if (isExpired) {
        expiredRequests.add(request);
      }
      return isExpired;
    });

    // Remove expired requests from storage
    if (expiredRequests.isNotEmpty) {
      for (final expiredRequest in expiredRequests) {
        await _removePairingRequest(expiredRequest.id);
      }
      logInfo(
          'P2PDiscoveryService: Removed ${expiredRequests.length} expired pairing requests');
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  // Message handling methods

  /// Handle TCP messages forwarded from transfer service
  void handleTcpMessage(Socket socket, P2PMessage message) {
    // @DebugLog
    // logDebug('P2PDiscoveryService: Processing TCP message: ${message.type}');

    // Drop any signals from blocked users
    final blockedUser = _discoveredUsers[message.fromUserId];
    if (blockedUser?.isBlocked == true) {
      logWarning(
          'P2PDiscoveryService: Ignoring ${message.type} from blocked user ${blockedUser!.displayName}');
      return;
    }

    switch (message.type) {
      case P2PMessageTypes.pairingRequest:
        _handlePairingRequest(message);
        break;
      case P2PMessageTypes.pairingResponse:
        _handlePairingResponse(message);
        break;
      case P2PMessageTypes.trustRequest:
        _handleTrustRequest(message);
        break;
      case P2PMessageTypes.trustResponse:
        _handleTrustResponse(message);
        break;
      case P2PMessageTypes.heartbeat:
        _handleHeartbeat(message);
        break;
      case P2PMessageTypes.disconnect:
        _handleDisconnectMessage(message);
        break;
      // Remote control messages - delegate to remote control service
      case P2PMessageTypes.remoteControlRequest:
      case P2PMessageTypes.remoteControlResponse:
      case P2PMessageTypes.remoteControlEvent:
      case P2PMessageTypes.remoteControlDisconnect:
        _delegateToRemoteControlService(socket, message.toJson());
        break;
      // Screen sharing messages - delegate to screen sharing service
      case P2PMessageTypes.screenSharingRequest:
      case P2PMessageTypes.screenSharingResponse:
      case P2PMessageTypes.screenSharingData:
      case P2PMessageTypes.screenSharingDisconnect:
        logDebug(
            'P2PDiscoveryService: Delegating ${message.type} with data: ${message.data}');
        _delegateToScreenSharingService(socket, message.toJson());
        break;
      default:
        logWarning(
            'P2PDiscoveryService: Unknown TCP message type: ${message.type}');
    }
  }

  // Private methods

  void _handleUdpMessage(Uint8List data, InternetAddress address, int port) {
    try {
      final messageJson = utf8.decode(data);
      final messageData = jsonDecode(messageJson) as Map<String, dynamic>;
      final messageType = messageData['type'] as String;

      logInfo(
          'P2PDiscoveryService: Received UDP $messageType from ${address.address}');

      switch (messageType) {
        case 'discovery_scan_request':
          _handleDiscoveryScanRequest(messageData, address);
          break;
        case 'discovery_response':
          _handleDiscoveryResponse(messageData);
          break;
        case 'profile_sync_request':
          _handleProfileSyncRequest(messageData);
          break;
        case 'force_profile_sync_request':
          _handleForceProfileSyncRequest(messageData);
          break;
        default:
          if (messageType == 'p2lantransfer_service_announcement') {
            _processEnhancedAnnouncement(messageData);
          }
      }
    } catch (e) {
      logWarning('P2PDiscoveryService: Failed to parse UDP message: $e');
    }
  }

  Future<void> _sendDiscoveryScanRequest() async {
    if (_networkService.currentUser == null) return;

    try {
      final scanRequest = DiscoveryScanRequest(
        fromUserId: _networkService.currentUser!.id,
        fromUserName: _networkService.currentUser!.displayName,
        fromAppInstallationId: _networkService.currentUser!.appInstallationId,
        ipAddress: _networkService.currentUser!.ipAddress,
        port: _networkService.currentUser!.port,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        platform: PlatformDetectionUtils.getCurrentPlatform(),
      );

      final requestData = {
        'type': 'discovery_scan_request',
        ...scanRequest.toJson(),
      };

      // Get broadcast addresses
      final broadcastAddresses = _getBroadcastAddresses();
      await _networkService.broadcastUdpMessage(
          requestData, broadcastAddresses, 8082);

      logInfo(
          'P2PDiscoveryService: Discovery scan request broadcast completed');
    } catch (e) {
      logError(
          'P2PDiscoveryService: Failed to send discovery scan request: $e');
    }
  }

  Future<void> _handleDiscoveryScanRequest(
      Map<String, dynamic> data, InternetAddress senderAddress) async {
    try {
      final request = DiscoveryScanRequest.fromJson(data);

      if (request.fromUserId == _networkService.currentUser!.id) {
        return; // Ignore our own requests
      }

      logInfo(
          'P2PDiscoveryService: Processing scan request from ${request.fromUserName}');

      // Ignore blocked users at scan stage
      final existingBlocked = _discoveredUsers[request.fromUserId];
      if (existingBlocked?.isBlocked == true) {
        logWarning(
            'P2PDiscoveryService: Ignoring discovery scan from blocked user ${existingBlocked!.displayName}');
        return;
      }

      // Check if device exists in storage
      final existingUserInStorage = await _loadStoredUser(request.fromUserId);
      final responseCode = existingUserInStorage != null
          ? DiscoveryResponseCode.deviceUpdate
          : DiscoveryResponseCode.deviceNew;

      // Update UI according to original spec
      await _processDeviceBScanRequest(
          request, existingUserInStorage, responseCode);

      // Send response
      final response = DiscoveryResponse(
        toUserId: request.fromUserId,
        responseCode: responseCode,
        userProfile: _networkService.currentUser!,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await _sendDiscoveryResponse(response, senderAddress);

      logInfo(
          'P2PDiscoveryService: Sent ${responseCode.name} response to ${request.fromUserName}');
    } catch (e) {
      logError(
          'P2PDiscoveryService: Error handling discovery scan request: $e');
    }
  }

  Future<void> _sendDiscoveryResponse(
      DiscoveryResponse response, InternetAddress targetAddress) async {
    try {
      final responseData = {
        'type': 'discovery_response',
        ...response.toJson(),
      };

      await _networkService.sendUdpMessage(responseData, targetAddress, 8082);
    } catch (e) {
      logError('P2PDiscoveryService: Failed to send discovery response: $e');
    }
  }

  Future<void> _processDeviceBScanRequest(
      DiscoveryScanRequest request,
      P2PUser? existingUserInStorage,
      DiscoveryResponseCode responseCode) async {
    try {
      logInfo(
          'P2PDiscoveryService: Processing scan request: ${request.fromUserName} -> ${responseCode.name}');

      switch (responseCode) {
        case DiscoveryResponseCode.deviceUpdate:
          // Device exists in storage - update offline → online
          if (existingUserInStorage != null) {
            existingUserInStorage.ipAddress = request.ipAddress;
            existingUserInStorage.port = request.port;
            existingUserInStorage.isOnline = true;
            existingUserInStorage.lastSeen = DateTime.now();

            if (request.fromUserName.isNotEmpty &&
                !request.fromUserName.startsWith('Device-')) {
              existingUserInStorage.displayName = request.fromUserName;
            }

            _discoveredUsers[existingUserInStorage.id] = existingUserInStorage;
            await _saveUser(existingUserInStorage);
            logInfo(
                'P2PDiscoveryService: Updated ${existingUserInStorage.displayName} to ONLINE');
          }
          break;

        case DiscoveryResponseCode.deviceNew:
          // Device is new - create new profile
          // If it exists in storage and is blocked, keep blocked and update online status
          if (existingUserInStorage != null &&
              existingUserInStorage.isBlocked) {
            existingUserInStorage.ipAddress = request.ipAddress;
            existingUserInStorage.port = request.port;
            existingUserInStorage.isOnline = true;
            existingUserInStorage.lastSeen = DateTime.now();
            _discoveredUsers[existingUserInStorage.id] = existingUserInStorage;
            await _saveUser(existingUserInStorage);
            logInfo(
                'P2PDiscoveryService: Rediscovered blocked device; kept blocked and marked online');
            break;
          }

          final newUser = P2PUser(
            id: request.fromUserId,
            displayName: request.fromUserName.isNotEmpty
                ? request.fromUserName
                : 'Device-${request.fromUserId.substring(0, 8)}',
            profileId: request.fromAppInstallationId,
            ipAddress: request.ipAddress,
            port: request.port,
            isOnline: true,
            lastSeen: DateTime.now(),
            isStored: false,
            platform: request.platform,
          );

          _discoveredUsers[newUser.id] = newUser;
          logInfo(
              'P2PDiscoveryService: Added new device ${newUser.displayName}');
          break;

        case DiscoveryResponseCode.error:
          logWarning(
              'P2PDiscoveryService: Error response code in scan request processing');
          break;
      }

      notifyListeners();
    } catch (e) {
      logError('P2PDiscoveryService: Error processing scan request: $e');
    }
  }

  Future<void> _handleDiscoveryResponse(Map<String, dynamic> data) async {
    try {
      final response = DiscoveryResponse.fromJson(data);

      if (response.toUserId != _networkService.currentUser!.id) {
        return; // Not for us
      }

      logInfo(
          'P2PDiscoveryService: Received discovery response: ${response.responseCode.name}');
      await _processDiscoveryResponse(response);
    } catch (e) {
      logError('P2PDiscoveryService: Error handling discovery response: $e');
    }
  }

  Future<void> _processDiscoveryResponse(DiscoveryResponse response) async {
    final receivedUser = response.userProfile;
    final storedUser = await _loadStoredUser(receivedUser.id);
    final isInStorage = storedUser != null;

    logInfo(
        'P2PDiscoveryService: Processing response from ${receivedUser.displayName}: '
        'code=${response.responseCode.name}, inStorage=$isInStorage');

    switch (response.responseCode) {
      case DiscoveryResponseCode.deviceNew:
        if (isInStorage && storedUser.isBlocked) {
          // Keep the blocked record, just refresh connectivity fields
          storedUser.ipAddress = receivedUser.ipAddress;
          storedUser.port = receivedUser.port;
          storedUser.isOnline = true;
          storedUser.lastSeen = DateTime.now();
          _discoveredUsers[storedUser.id] = storedUser;
          await _saveUser(storedUser);
        } else if (isInStorage) {
          // Remove old profile, create new one
          await _removeUser(receivedUser.id);
          _discoveredUsers.remove(receivedUser.id);
          await _createNewDeviceProfile(receivedUser);
        } else {
          // Create new profile
          await _createNewDeviceProfile(receivedUser);
        }
        break;

      case DiscoveryResponseCode.deviceUpdate:
        if (isInStorage) {
          // Update offline → online
          await _updateDeviceOnline(receivedUser);
        } else {
          // Create new + send force sync
          await _createNewDeviceProfile(receivedUser);
          await _sendForceProfileSyncRequest(receivedUser);
        }
        break;

      case DiscoveryResponseCode.error:
        logWarning(
            'P2PDiscoveryService: Discovery response error: ${response.errorMessage}');
        break;
    }

    notifyListeners();
  }

  Future<void> _createNewDeviceProfile(P2PUser user) async {
    user.isOnline = true;
    user.lastSeen = DateTime.now();
    user.isStored = false;
    // If a blocked record already exists in storage, keep it and update online
    final stored = await _loadStoredUser(user.id);
    if (stored != null && stored.isBlocked) {
      stored.ipAddress = user.ipAddress;
      stored.port = user.port;
      stored.isOnline = true;
      stored.lastSeen = DateTime.now();
      _discoveredUsers[stored.id] = stored;
      await _saveUser(stored);
      logInfo(
          'P2PDiscoveryService: Created view from stored blocked profile: ${stored.displayName}');
      return;
    }

    _discoveredUsers[user.id] = user;
    logInfo(
        'P2PDiscoveryService: Created new device profile: ${user.displayName}');
  }

  Future<void> _updateDeviceOnline(P2PUser receivedUser) async {
    P2PUser? user = _discoveredUsers[receivedUser.id];

    if (user == null) {
      user = await _loadStoredUser(receivedUser.id);
      if (user != null) {
        _discoveredUsers[receivedUser.id] = user;
      }
    }

    if (user != null) {
      user.ipAddress = receivedUser.ipAddress;
      user.port = receivedUser.port;
      user.isOnline = true;
      user.lastSeen = DateTime.now();
      user.platform = receivedUser.platform;

      if (receivedUser.displayName.isNotEmpty &&
          !receivedUser.displayName.startsWith('Device-')) {
        user.displayName = receivedUser.displayName;
      }

      await _saveUser(user);
      logInfo(
          'P2PDiscoveryService: Updated device to online: ${user.displayName}');
    } else {
      await _createNewDeviceProfile(receivedUser);
    }
  }

  Future<void> _sendForceProfileSyncRequest(P2PUser targetUser) async {
    try {
      final forceSync = {
        'type': 'force_profile_sync_request',
        'fromUserId': _networkService.currentUser!.id,
        'toUserId': targetUser.id,
        'updatedProfile': _networkService.currentUser!.toJson(),
        'reason': 'Device A received UPDATE response but device not in storage',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await _networkService.sendUdpMessage(
          forceSync, InternetAddress(targetUser.ipAddress), 8082);
      logInfo(
          'P2PDiscoveryService: Sent FORCE profile sync to ${targetUser.displayName}');
    } catch (e) {
      logError('P2PDiscoveryService: Failed to send force profile sync: $e');
    }
  }

  Future<void> _handleProfileSyncRequest(Map<String, dynamic> data) async {
    // Implementation for profile sync request handling
  }

  Future<void> _handleForceProfileSyncRequest(Map<String, dynamic> data) async {
    // Implementation for force profile sync request handling
  }

  Future<void> _processEnhancedAnnouncement(Map<String, dynamic> data) async {
    // Implementation for legacy announcement processing
  }

  Future<void> _startBroadcast() async {
    if (_isBroadcasting) return;

    _isBroadcasting = true;

    // Send initial announcement
    await _sendDiscoveryScanRequest();

    // Set up periodic announcements every 10 seconds
    _broadcastTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isBroadcasting && _networkService.currentUser != null) {
        _sendDiscoveryScanRequest();
      }
    });

    logInfo('P2PDiscoveryService: Broadcast started');
    notifyListeners();
  }

  Future<void> _stopBroadcast() async {
    _isBroadcasting = false;
    _broadcastTimer?.cancel();
    _broadcastTimer = null;

    logInfo('P2PDiscoveryService: Broadcast stopped');
    notifyListeners();
  }

  List<String> _getBroadcastAddresses() {
    final broadcastAddresses = <String>[
      '255.255.255.255', // Global broadcast
    ];

    if (_networkService.currentUser != null) {
      final currentIP = _networkService.currentUser!.ipAddress;
      final ipParts = currentIP.split('.');
      if (ipParts.length == 4) {
        final subnet = '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}.255';
        broadcastAddresses.add(subnet);
      }
    }

    // Add common subnets
    if (!broadcastAddresses.contains('192.168.1.255')) {
      broadcastAddresses.add('192.168.1.255');
    }
    if (!broadcastAddresses.contains('192.168.0.255')) {
      broadcastAddresses.add('192.168.0.255');
    }

    return broadcastAddresses;
  }

  void _cleanupUsersOnStop() {
    _discoveredUsers.removeWhere((key, user) => !user.isStored);
    for (final user in _discoveredUsers.values) {
      user.isOnline = false;
    }
  }

  // Storage methods

  Future<void> _loadStoredUsers() async {
    final isar = IsarService.isar;
    final users = await isar.p2PUsers.where().findAll();
    _discoveredUsers.clear();
    for (final user in users) {
      user.isOnline = false;
      _discoveredUsers[user.id] = user;
    }
    logInfo(
        'P2PDiscoveryService: Loaded ${_discoveredUsers.length} stored users');
  }

  Future<void> _loadPendingRequests() async {
    final isar = IsarService.isar;
    final reqs =
        await isar.pairingRequests.filter().isProcessedEqualTo(false).findAll();
    _pendingRequests.clear();
    _pendingRequests.addAll(reqs);
    logInfo(
        'P2PDiscoveryService: Loaded ${_pendingRequests.length} pending requests');
  }

  Future<void> _saveUser(P2PUser user) async {
    try {
      user.isStored = true;
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.p2PUsers.put(user);
      });
      logInfo('P2PDiscoveryService: Saved user: ${user.displayName}');
    } catch (e) {
      logError('P2PDiscoveryService: Failed to save user: $e');
    }
  }

  Future<void> _removeUser(String userId) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() => isar.p2PUsers.delete(fastHash(userId)));
  }

  Future<P2PUser?> _loadStoredUser(String userId) async {
    return await IsarService.isar.p2PUsers.get(fastHash(userId));
  }

  Future<void> _savePairingRequest(PairingRequest request) async {
    try {
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.pairingRequests.put(request);
      });
    } catch (e) {
      logError('P2PDiscoveryService: Failed to save pairing request: $e');
    }
  }

  Future<void> _removePairingRequest(String requestId) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() => isar.pairingRequests.delete(fastHash(requestId)));
  }

  // TCP Message Handlers

  Future<void> _handlePairingRequest(P2PMessage message) async {
    final request = PairingRequest.fromJson(message.data);
    if (!_pendingRequests.any((r) => r.id == request.id)) {
      _pendingRequests.add(request);
      await _savePairingRequest(request);
      notifyListeners();

      logInfo(
          'P2PDiscoveryService: Added pairing request from ${request.fromUserName}');

      // Trigger callback for auto-showing dialogs
      if (_onNewPairingRequest != null) {
        _onNewPairingRequest!(request);
      }
    }
  }

  Future<void> _handlePairingResponse(P2PMessage message) async {
    final data = message.data;
    final accepted = data['accepted'] as bool;

    if (accepted) {
      final user = _discoveredUsers[message.fromUserId];
      if (user != null) {
        user.isPaired = true;
        user.isTrusted = data['trusted'] ?? false;
        user.pairedAt = DateTime.now();
        user.isStored = data['saveConnection'] ?? false;

        await _saveUser(user);
        logInfo(
            'P2PDiscoveryService: Pairing accepted from ${user.displayName}');
      }
    } else {
      logInfo(
          'P2PDiscoveryService: Pairing rejected from user ${message.fromUserId}');
    }

    notifyListeners();
  }

  Future<void> _handleTrustRequest(P2PMessage message) async {
    final fromUserId = message.fromUserId;
    final user = _discoveredUsers[fromUserId];
    if (user != null) {
      user.isTrusted = true;
      await _saveUser(user);
      logInfo(
          'P2PDiscoveryService: Auto-approved trust for ${user.displayName}');

      final response = {
        'type': P2PMessageTypes.trustResponse,
        'fromUserId': _networkService.currentUser!.id,
        'toUserId': fromUserId,
        'data': {'approved': true}
      };
      await _networkService.sendMessageToUser(user, response);
    }
  }

  Future<void> _handleTrustResponse(P2PMessage message) async {
    final fromUserId = message.fromUserId;
    final approved = message.data['approved'] as bool? ?? false;

    if (approved) {
      final user = _discoveredUsers[fromUserId];
      if (user != null) {
        user.isTrusted = true;
        await _saveUser(user);
        logInfo('P2PDiscoveryService: Trust approved by ${user.displayName}');
      }
    }
  }

  Future<void> _handleHeartbeat(P2PMessage message) async {
    final user = _discoveredUsers[message.fromUserId];
    if (user != null) {
      user.lastSeen = DateTime.now();
      user.isOnline = true;
    }
  }

  Future<void> _handleDisconnectMessage(P2PMessage message) async {
    final fromUserId = message.fromUserId;
    final user = _discoveredUsers[fromUserId];
    if (user != null) {
      user.isOnline = false;
      await _saveUser(user);
      notifyListeners();
      logInfo('P2PDiscoveryService: ${user.displayName} has disconnected');

      // Notify callback about user disconnect
      _onUserDisconnected?.call(fromUserId);
    }
  }

  /// Clear in-memory pairing requests (used when clearing all requests from database)
  void clearInMemoryPairingRequests() {
    _pendingRequests.clear();
    notifyListeners();
    logInfo('P2PDiscoveryService: In-memory pairing requests cleared');
  }

  /// Delegate remote control messages to remote control service
  void _delegateToRemoteControlService(
      Socket socket, Map<String, dynamic> messageData) {
    _onRemoteControlMessage?.call(socket, messageData);
  }

  void _delegateToScreenSharingService(
      Socket socket, Map<String, dynamic> messageData) {
    logDebug(
        'P2PDiscoveryService: Delegating screen sharing message: $messageData');
    _onScreenSharingMessage?.call(socket, messageData);
  }

  @override
  void dispose() {
    logInfo('P2PDiscoveryService: Disposing...');
    stopDiscovery();
    super.dispose();
  }
}
