import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:p2lantransfer/models/p2p_models.dart';
import 'package:p2lantransfer/services/app_logger.dart';
import 'package:p2lantransfer/services/isar_service.dart';
import 'package:p2lantransfer/services/p2p_services/p2p_discovery_service.dart';
import 'package:p2lantransfer/services/p2p_services/p2p_network_service.dart';
import 'package:p2lantransfer/services/p2p_services/p2p_notification_service.dart';
import 'package:p2lantransfer/services/p2p_services/p2p_transfer_service.dart';

/// P2P Service Manager - Facade pattern that coordinates all P2P services
/// Provides a unified API that replaces the monolithic P2PService
class P2PServiceManager extends ChangeNotifier {
  // Public getter for network service
  P2PNetworkService get networkService => _networkService;
  // Public getter for transfer service
  P2PTransferService get transferService => _transferService;
  static P2PServiceManager? _instance;

  // Services
  late final P2PNetworkService _networkService;
  late final P2PDiscoveryService _discoveryService;
  late final P2PTransferService _transferService;

  // State
  bool _isInitialized = false;

  // Private constructor
  P2PServiceManager._() {
    _networkService = P2PNetworkService();
    _discoveryService = P2PDiscoveryService(_networkService);
    _transferService = P2PTransferService(_networkService);

    // Set up cross-service connections
    _setupServiceConnections();
  }

  // Public getter for the instance
  static P2PServiceManager get instance {
    _instance ??= P2PServiceManager._();
    return _instance!;
  }

  // Initialization method
  static Future<void> init() async {
    await instance.initialize();
  }

  // Getters - Network Service
  bool get isEnabled => _networkService.isEnabled;
  ConnectionStatus get connectionStatus => _networkService.connectionStatus;
  NetworkInfo? get currentNetworkInfo => _networkService.currentNetworkInfo;
  P2PUser? get currentUser => _networkService.currentUser;

  // Getters - Discovery Service
  bool get isDiscovering => _discoveryService.isDiscovering;
  bool get isBroadcasting => _discoveryService.isBroadcasting;
  List<P2PUser> get discoveredUsers => _discoveryService.discoveredUsers;
  List<P2PUser> get pairedUsers => _discoveryService.pairedUsers;
  List<P2PUser> get connectedUsers => _discoveryService.connectedUsers;
  List<P2PUser> get unconnectedUsers => _discoveryService.unconnectedUsers;
  List<PairingRequest> get pendingRequests => _discoveryService.pendingRequests;
  DateTime? get lastDiscoveryTime => _discoveryService.lastDiscoveryTime;

  // Getters - Transfer Service
  P2PDataTransferSettings? get transferSettings =>
      _transferService.transferSettings;
  List<FileTransferRequest> get pendingFileTransferRequests =>
      _transferService.pendingFileTransferRequests;
  List<DataTransferTask> get activeTransfers =>
      _transferService.activeTransfers;

  // Đã xóa hoàn toàn mọi tham chiếu đến P2PFileStorageSettings

  /// Initialize P2P service manager
  Future<void> initialize() async {
    if (_isInitialized) {
      logInfo('P2PServiceManager: Already initialized, skipping.');
      return;
    }

    try {
      logInfo('P2PServiceManager: Initializing...');

      // Initialize notification service first
      try {
        await P2PNotificationService.init();
        logInfo('P2PServiceManager: P2P notification service initialized');
      } catch (e) {
        logError(
            'P2PServiceManager: Failed to initialize P2P notification service: $e');
      }

      // Initialize all services
      await _discoveryService.initialize();
      await _transferService.initialize();

      _isInitialized = true;
      logInfo('P2PServiceManager: Initialized successfully');
    } catch (e) {
      _isInitialized = false;
      logError('P2PServiceManager: Failed to initialize: $e');
      rethrow;
    }
  }

  /// Enable P2P networking
  Future<void> enable() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Enable network service
      final success = await _networkService.enable();
      if (!success) {
        throw Exception('Failed to enable network service');
      }

      // Start discovery service
      await _discoveryService.startDiscovery();

      // Update P2LAN status notification
      if (currentUser != null) {
        await _safeNotificationCall(
            () => P2PNotificationService.instance.showP2LanStatus(
                  deviceName: currentUser!.displayName,
                  ipAddress: currentUser!.ipAddress,
                  connectedDevices: pairedUsers.length,
                ));
      }

      logInfo('P2PServiceManager: P2P networking enabled');
      notifyListeners();
    } catch (e) {
      logError('P2PServiceManager: Failed to enable P2P networking: $e');
      rethrow;
    }
  }

  /// Stop P2P networking
  Future<void> stopNetworking() async {
    try {
      // Hide status notification immediately
      await _safeNotificationCall(
          () => P2PNotificationService.instance.hideP2LanStatus());

      // Send disconnect notifications to paired users
      await _sendDisconnectNotifications();

      // Stop all services
      await _transferService.cancelAllTransfers();
      await _discoveryService.stopDiscovery();
      await _networkService.disable();

      logInfo('P2PServiceManager: P2P networking stopped');
      notifyListeners();
    } catch (e) {
      logError('P2PServiceManager: Failed to stop P2P networking: $e');
    }
  }

  /// Manual discovery scan
  Future<void> manualDiscovery() async {
    await _discoveryService.manualDiscovery();
  }

  /// Send pairing request to user
  Future<bool> sendPairingRequest(
      P2PUser targetUser, bool saveConnection) async {
    return await _discoveryService.sendPairingRequest(
        targetUser, saveConnection);
  }

  /// Respond to pairing request
  Future<bool> respondToPairingRequest(String requestId, bool accept,
      bool trustUser, bool saveConnection) async {
    final success = await _discoveryService.respondToPairingRequest(
        requestId, accept, trustUser, saveConnection);

    if (success && accept) {
      // Update P2LAN status notification with new connection count
      await _updateP2LanStatusNotification();
    }

    return success;
  }

  /// Unpair from user
  Future<bool> unpairUser(String userId) async {
    return await _discoveryService.unpairUser(userId);
  }

  /// Send trust request
  Future<bool> sendTrustRequest(P2PUser targetUser) async {
    return await _discoveryService.sendTrustRequest(targetUser);
  }

  /// Add trust to user
  Future<bool> addTrust(String userId) async {
    return await _discoveryService.addTrust(userId);
  }

  /// Remove trust from user
  Future<bool> removeTrust(String userId) async {
    return await _discoveryService.removeTrust(userId);
  }

  /// Toggle broadcast announcements
  Future<void> toggleBroadcast() async {
    await _discoveryService.toggleBroadcast();
  }

  /// Send multiple files to user
  Future<bool> sendMultipleFiles(
      {required List<String> filePaths,
      required P2PUser targetUser,
      bool transferOnly = true}) async {
    return await _transferService.sendMultipleFiles(
        filePaths, targetUser, transferOnly);
  }

  /// Send data to paired user (legacy method)
  Future<bool> sendData(String filePath, P2PUser targetUser) async {
    return await sendMultipleFiles(
        filePaths: [filePath], targetUser: targetUser);
  }

  /// Send multiple files to user (alias)
  Future<bool> sendMultipleFilesToUser(
      List<String> filePaths, P2PUser targetUser, bool transferOnly) async {
    return await sendMultipleFiles(
        filePaths: filePaths,
        targetUser: targetUser,
        transferOnly: transferOnly);
  }

  /// Cancel data transfer
  Future<bool> cancelDataTransfer(String taskId) async {
    return await _transferService.cancelDataTransfer(taskId);
  }

  /// Respond to file transfer request
  Future<bool> respondToFileTransferRequest(
      String requestId, bool accept, String? rejectMessage) async {
    return await _transferService.respondToFileTransferRequest(
        requestId, accept, rejectMessage);
  }

  /// Update transfer settings
  Future<bool> updateTransferSettings(P2PDataTransferSettings settings) async {
    final success = await _transferService.updateTransferSettings(settings);

    // Update current user's display name if it has changed
    if (success && currentUser != null && settings.customDisplayName != null) {
      if (currentUser!.displayName != settings.customDisplayName) {
        currentUser!.displayName = settings.customDisplayName!;
        logInfo(
            'P2PServiceManager: Updated current user display name to: ${settings.customDisplayName}');
        notifyListeners();
      }
    }

    return success;
  }

  /// Reload transfer settings from storage
  Future<void> reloadTransferSettings() async {
    await _transferService.reloadTransferSettings();
    notifyListeners();
  }

  /// Clear a transfer from the list
  void clearTransfer(String taskId) {
    _transferService.clearTransfer(taskId);
  }

  /// Clear a transfer and optionally delete the downloaded file
  Future<bool> clearTransferWithFile(String taskId, bool deleteFile) async {
    return await _transferService.clearTransferWithFile(taskId, deleteFile);
  }

  /// Set callback for new pairing requests
  void setNewPairingRequestCallback(Function(PairingRequest)? callback) {
    _discoveryService.setNewPairingRequestCallback(callback);
  }

  /// Set callback for new file transfer requests
  void setNewFileTransferRequestCallback(
      Function(FileTransferRequest)? callback) {
    _transferService.setNewFileTransferRequestCallback(callback);
  }

  /// Clear all pairing requests
  Future<void> clearPairingRequests() async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.pairingRequests.clear();
    });

    // Clear in-memory requests
    _discoveryService.clearInMemoryPairingRequests();

    logInfo('P2PServiceManager: All pairing requests have been cleared');
    notifyListeners();
  }

  /// Clear all transfer data (requests and tasks)
  Future<void> clearAllTransferData() async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.fileTransferRequests.clear();
      await isar.dataTransferTasks.clear();
    });

    // Clear in-memory transfer data
    _transferService.clearInMemoryTransferData();

    logInfo('P2PServiceManager: All transfer data has been cleared');
    notifyListeners();
  }

  /// Clear all P2P-related data
  Future<void> clearAllP2PData() async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.p2PUsers.clear();
      await isar.pairingRequests.clear();
      await isar.dataTransferTasks.clear();
      await isar.fileTransferRequests.clear();
    });

    logInfo('P2PServiceManager: All P2P data has been cleared');
    notifyListeners();
  }

  /// Cleanup expired messages from all chats
  Future<void> cleanupExpiredMessages() async {
    try {
      await _transferService.cleanupExpiredMessages();
    } catch (e) {
      logError('P2PServiceManager: Error during message cleanup: $e');
    }
  }

  /// Send emergency disconnect to all paired users
  Future<void> sendEmergencyDisconnectToAll() async {
    if (currentUser == null) return;

    final pairedUsers =
        this.pairedUsers.where((user) => user.isOnline).toList();

    if (pairedUsers.isEmpty) {
      logInfo(
          'P2PServiceManager: No paired users to send emergency disconnect');
      return;
    }

    logInfo(
        'P2PServiceManager: Sending emergency disconnect to ${pairedUsers.length} paired users');

    final disconnectFutures = pairedUsers.map((user) async {
      final message = {
        'type': P2PMessageTypes.disconnect,
        'fromUserId': currentUser!.id,
        'toUserId': user.id,
        'data': {
          'reason': 'app_termination',
          'message': 'App is closing',
          'fromUserName': currentUser!.displayName,
          'emergency': true,
        },
      };

      try {
        return await _networkService.sendMessageToUser(user, message);
      } catch (e) {
        logError(
            'P2PServiceManager: Failed to send emergency disconnect to ${user.displayName}: $e');
        return false;
      }
    });

    await Future.wait(disconnectFutures).timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        logWarning('P2PServiceManager: Emergency disconnect timeout');
        return pairedUsers.map((user) => false).toList();
      },
    );

    logInfo('P2PServiceManager: Emergency disconnect sequence completed');
  }

  /// Cleanup file picker cache if safe
  Future<void> cleanupFilePickerCacheIfSafe() async {
    await _transferService.cleanupFilePickerCacheIfSafe();
  }

  // Private methods

  void _setupServiceConnections() {
    // Set up listeners for service state changes
    _networkService.addListener(_onNetworkServiceChange);
    _discoveryService.addListener(_onDiscoveryServiceChange);
    _transferService.addListener(_onTransferServiceChange);

    // Set up cross-service method dependencies
    _setupTransferServiceDependencies();
  }

  void _setupTransferServiceDependencies() {
    // Transfer service needs access to discovered users from discovery service
    _transferService.setUserLookupCallback((String userId) {
      return _discoveryService.getUserById(userId);
    });

    // Transfer service should forward non-transfer messages to discovery service
    _transferService.setOtherMessageCallback((message, socket) {
      _discoveryService.handleTcpMessage(socket, message);
    });
  }

  void _onNetworkServiceChange() {
    notifyListeners();
  }

  void _onDiscoveryServiceChange() {
    notifyListeners();
  }

  void _onTransferServiceChange() {
    notifyListeners();
  }

  /// Send disconnect notifications to all paired users
  Future<void> _sendDisconnectNotifications() async {
    if (currentUser == null) return;

    for (final user in pairedUsers) {
      if (user.isOnline) {
        final message = {
          'type': P2PMessageTypes.disconnect,
          'fromUserId': currentUser!.id,
          'toUserId': user.id,
          'data': {
            'reason': 'network_stop',
            'message': 'Network stopping',
            'fromUserName': currentUser!.displayName,
          },
        };

        try {
          await _networkService.sendMessageToUser(user, message);
        } catch (e) {
          logWarning(
              'P2PServiceManager: Failed to send disconnect to ${user.displayName}: $e');
        }
      }
    }
  }

  /// Update P2LAN status notification with current connection count
  Future<void> _updateP2LanStatusNotification() async {
    if (!isEnabled || currentUser == null) return;

    final connectedDevices = pairedUsers.where((u) => u.isOnline).length;
    await _safeNotificationCall(
        () => P2PNotificationService.instance.showP2LanStatus(
              deviceName: currentUser!.displayName,
              ipAddress: currentUser!.ipAddress,
              connectedDevices: connectedDevices,
            ));
  }

  /// Safe wrapper for notification service calls
  Future<void> _safeNotificationCall(Future<void> Function() operation) async {
    if (transferSettings?.enableNotifications != true) {
      return;
    }

    final notificationService = P2PNotificationService.instanceOrNull;
    if (notificationService == null || !notificationService.isReady) {
      return;
    }

    try {
      await operation();
    } catch (e) {
      logWarning('P2PServiceManager: Notification service call failed: $e');
    }
  }

  /// Get user by ID (helper method for transfer service)
  P2PUser? getUserById(String userId) {
    return _discoveryService.getUserById(userId);
  }

  /// Update user's last seen time (helper method for transfer service)
  void updateUserLastSeen(String userId) {
    _discoveryService.updateUserLastSeen(userId);
  }

  /// Perform cleanup of offline users and expired requests
  Future<void> performCleanup() async {
    await _discoveryService.performCleanup();
  }

  @override
  void dispose() {
    logInfo('P2PServiceManager: Disposing service manager...');

    // Send emergency disconnect before disposing
    sendEmergencyDisconnectToAll();

    // Remove listeners
    _networkService.removeListener(_onNetworkServiceChange);
    _discoveryService.removeListener(_onDiscoveryServiceChange);
    _transferService.removeListener(_onTransferServiceChange);

    // Dispose all services
    _transferService.dispose();
    _discoveryService.dispose();
    _networkService.dispose();

    logInfo('P2PServiceManager: Service manager disposed');
    super.dispose();
  }
}
