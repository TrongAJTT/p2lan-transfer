import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/isar_service.dart';
import 'package:p2lan/services/network_security_service.dart';
import 'package:p2lan/services/p2p_services/p2p_chat_service.dart';
import 'package:p2lan/services/p2p_services/p2p_service_manager.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/l10n/app_localizations.dart';

import 'package:p2lan/view_models/states/p2p_ui_state.dart';
import 'package:p2lan/view_models/commands/p2p_commands.dart';

/// Proper MVVM ViewModel for P2P functionality
/// - Contains business logic and coordinates services
/// - Manages UI state through P2PUIState
/// - Exposes commands for View to call
/// - No direct UI dependencies (except for localization)
class P2PViewModel with ChangeNotifier {
  // =============================================================================
  // PRIVATE FIELDS
  // =============================================================================

  // Services
  late final P2PChatService _p2pChatService = P2PChatService(IsarService.isar);
  final P2PServiceManager _p2pService = P2PServiceManager.instance;

  // UI State
  P2PUIState _uiState = P2PUIState.initial();

  // Business State
  bool _isInitialized = false;
  bool _showSecurityWarning = false;
  String? _errorMessage;
  NetworkInfo? _networkInfo;
  P2PUser? _selectedUser;
  String? _selectedFile;
  bool _isRefreshing = false;
  bool _hasPerformedInitialDiscovery = false;
  DateTime? _lastDiscoveryTime;
  final Completer<void> _initCompleter = Completer<void>();

  // Connectivity monitoring
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _wasPreviouslyEnabled = false;
  bool _isTemporarilyDisabled = false;

  // Session duration update timer
  Timer? _sessionDurationTimer;

  // Callbacks
  Function(FileTransferRequest)? _onNewFileTransferRequest;
  Function(RemoteControlRequest)? _onNewRemoteControlRequest;
  Function(P2PUser)? _onRemoteControlAccepted;

  // =============================================================================
  // PUBLIC GETTERS - UI STATE
  // =============================================================================

  /// Current UI state
  P2PUIState get uiState => _uiState;

  // =============================================================================
  // PUBLIC GETTERS - BUSINESS STATE
  // =============================================================================

  /// Whether the view model is initialized
  bool get isInitialized => _isInitialized;

  /// Future that completes when initialization is done
  Future<void> get initializationComplete => _initCompleter.future;

  /// Whether P2P networking is enabled
  bool get isEnabled => _p2pService.isEnabled;

  /// Whether currently discovering devices
  bool get isDiscovering => _p2pService.isDiscovering;

  /// Whether to show security warning
  bool get showSecurityWarning => _showSecurityWarning;

  /// Current error message
  String? get errorMessage => _errorMessage;

  /// Network information
  NetworkInfo? get networkInfo => _networkInfo;

  /// Connection status
  ConnectionStatus get connectionStatus => _p2pService.connectionStatus;

  /// Current user
  P2PUser? get currentUser => _p2pService.currentUser;

  /// All discovered users
  List<P2PUser> get discoveredUsers => _p2pService.discoveredUsers;

  /// Paired users
  List<P2PUser> get pairedUsers => _p2pService.pairedUsers;

  /// Chat service
  P2PChatService get p2pChatService => _p2pChatService;

  /// P2P service (for advanced operations)
  P2PServiceManager get p2pService => _p2pService;

  /// Online saved devices
  List<P2PUser> get onlineDevices {
    return discoveredUsers
        .where((user) => user.isOnlineSaved && !user.isBlocked)
        .toList();
  }

  /// New discovered devices
  List<P2PUser> get newDevices {
    return discoveredUsers
        .where((user) => user.isNewDevice && !user.isBlocked)
        .toList();
  }

  /// Offline saved devices
  List<P2PUser> get savedDevices {
    return discoveredUsers
        .where((user) => user.isOfflineSaved && !user.isBlocked)
        .toList();
  }

  /// Blocked devices
  List<P2PUser> get blockedUsers {
    return discoveredUsers.where((user) => user.isBlocked).toList();
  }

  /// Check if any device category has data
  bool get hasOnlineDevices => onlineDevices.isNotEmpty;
  bool get hasNewDevices => newDevices.isNotEmpty;
  bool get hasSavedDevices => savedDevices.isNotEmpty;
  bool get hasBlockedDevices => blockedUsers.isNotEmpty;

  /// Pending requests and transfers
  List<PairingRequest> get pendingRequests => _p2pService.pendingRequests;
  List<DataTransferTask> get activeTransfers => _p2pService.activeTransfers;
  List<FileTransferRequest> get pendingFileTransferRequests =>
      _p2pService.pendingFileTransferRequests;

  /// Current remote control session (if any)
  RemoteControlSession? get currentRemoteControlSession =>
      _uiState.currentRemoteControlSession;

  /// Current screen sharing session (if any)
  ScreenSharingSession? get currentScreenSharingSession =>
      _uiState.currentScreenSharingSession;

  /// End current remote control session (called from UI)
  Future<void> endCurrentRemoteControlSession() async {
    await endRemoteControlSession(isActiveDisconnect: true);
  }

  /// End current screen sharing session (called from UI)
  Future<void> endCurrentScreenSharingSession() async {
    await _p2pService.stopScreenSharing();
  }

  /// Selected items
  P2PUser? get selectedUser => _selectedUser;
  String? get selectedFile => _selectedFile;

  /// Discovery state
  bool get isRefreshing => _isRefreshing;
  bool get hasPerformedInitialDiscovery => _hasPerformedInitialDiscovery;
  DateTime? get lastDiscoveryTime => _lastDiscoveryTime;
  bool get isBroadcasting => _p2pService.isBroadcasting;
  bool get isTemporarilyDisabled => _isTemporarilyDisabled;

  /// Transfer settings
  P2PDataTransferSettings? get transferSettings => _p2pService.transferSettings;

  /// Remote control state
  bool get isControlling => _p2pService.isControlling;
  bool get isBeingControlled => _p2pService.isBeingControlled;
  P2PUser? get controllingUser => _p2pService.controllingUser;
  P2PUser? get controlledUser => _p2pService.controlledUser;
  List<RemoteControlRequest> get pendingRemoteControlRequests =>
      _p2pService.pendingRemoteControlRequests;
  bool get canBeControlled => _p2pService.canBeControlled;

  // =============================================================================
  // CONSTRUCTOR
  // =============================================================================

  P2PViewModel() {
    _p2pService.addListener(_onP2PServiceChanged);
  }

  // =============================================================================
  // PUBLIC METHODS - INITIALIZATION
  // =============================================================================

  /// Initialize the view model
  Future<void> initialize() async {
    if (_isInitialized) return;

    _updateUIState(_uiState.loading());

    try {
      // Initialize P2P services
      await P2PServiceManager.init();

      // Setup remote control session callbacks
      _setupRemoteControlSessionCallbacks();

      // Setup screen sharing session callbacks
      _setupScreenSharingSessionCallbacks();

      // Load UI settings
      await _loadUISettings();

      // Check network status without requesting permissions
      await _checkInitialNetworkStatus();

      // Start connectivity monitoring
      _startConnectivityMonitoring();

      _isInitialized = true;
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }

      _updateUIState(_uiState.success());
    } catch (e) {
      final errorMsg = 'Failed to initialize P2P ViewModel: $e';
      logError(errorMsg);
      _updateUIState(_uiState.error(errorMsg));

      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e);
      }
    }
  }

  // =============================================================================
  // PUBLIC METHODS - COMMAND HANDLERS
  // =============================================================================

  /// Execute a command
  Future<void> executeCommand(P2PCommand command) async {
    if (command is P2PUICommand) {
      await _handleUICommand(command);
    } else if (command is P2PBusinessCommand) {
      await _handleBusinessCommand(command);
    }
  }

  // =============================================================================
  // PRIVATE METHODS - COMMAND HANDLERS
  // =============================================================================

  /// Handle UI commands
  Future<void> _handleUICommand(P2PUICommand command) async {
    switch (command.runtimeType) {
      case SwitchTabCommand:
        final cmd = command as SwitchTabCommand;
        _updateUIState(_uiState.copyWith(currentTabIndex: cmd.tabIndex));
        break;

      case ToggleDeviceSectionCommand:
        final cmd = command as ToggleDeviceSectionCommand;
        _toggleDeviceSection(cmd.sectionType);
        break;

      case ToggleTransferFilterCommand:
        _toggleTransferFilter();
        break;

      case ToggleStatusCardCommand:
        final cmd = command as ToggleStatusCardCommand;
        await _toggleStatusCard(cmd.cardKey);
        break;

      case UpdateCompactLayoutCommand:
        final cmd = command as UpdateCompactLayoutCommand;
        _updateUIState(
            _uiState.copyWith(useCompactLayout: cmd.useCompactLayout));
        break;

      case ToggleKeyboardShortcutsCommand:
        final cmd = command as ToggleKeyboardShortcutsCommand;
        _updateUIState(_uiState.copyWith(enableKeyboardShortcuts: cmd.enabled));
        break;
    }
  }

  /// Handle business commands
  Future<void> _handleBusinessCommand(P2PBusinessCommand command) async {
    try {
      switch (command.runtimeType) {
        case StartNetworkingCommand:
          await _startNetworking();
          break;

        case StopNetworkingCommand:
          await _stopNetworking();
          break;

        case ManualDiscoveryCommand:
          await _manualDiscovery();
          break;

        case SendPairingRequestCommand:
          final cmd = command as SendPairingRequestCommand;
          await _sendPairingRequest(
              cmd.targetUser, cmd.saveConnection, cmd.trustUser);
          break;

        case RespondToPairingRequestCommand:
          final cmd = command as RespondToPairingRequestCommand;
          await _respondToPairingRequest(
              cmd.requestId, cmd.accept, cmd.trustUser, cmd.saveConnection);
          break;

        case SendFilesToUserCommand:
          final cmd = command as SendFilesToUserCommand;
          await _sendFilesToUser(cmd.filePaths, cmd.targetUser);
          break;

        case CancelTransferCommand:
          final cmd = command as CancelTransferCommand;
          await _cancelTransfer(cmd.taskId);
          break;

        case ClearTransferCommand:
          final cmd = command as ClearTransferCommand;
          await _clearTransfer(cmd.taskId, cmd.deleteFile);
          break;

        case ClearAllTransfersCommand:
          final cmd = command as ClearAllTransfersCommand;
          await _clearAllTransfers(cmd.deleteFiles);
          break;

        case ClearBatchCommand:
          final cmd = command as ClearBatchCommand;
          await _clearBatch(cmd.batchId, cmd.deleteFiles);
          break;

        case AddTrustCommand:
          final cmd = command as AddTrustCommand;
          await _addTrust(cmd.userId);
          break;

        case RemoveTrustCommand:
          final cmd = command as RemoveTrustCommand;
          await _removeTrust(cmd.userId);
          break;

        case UnpairUserCommand:
          final cmd = command as UnpairUserCommand;
          await _unpairUser(cmd.userId);
          break;

        case BlockUserCommand:
          final cmd = command as BlockUserCommand;
          await _setBlocked(cmd.user, cmd.blocked);
          break;

        case RespondToFileTransferRequestCommand:
          final cmd = command as RespondToFileTransferRequestCommand;
          await _respondToFileTransferRequest(
              cmd.requestId, cmd.accept, cmd.rejectMessage);
          break;

        case ReloadCacheSizeCommand:
          await _reloadCacheSize();
          break;

        case ClearFileCacheCommand:
          await _clearFileCache();
          break;

        case ReloadTransferSettingsCommand:
          await _reloadTransferSettings();
          break;

        // Remote Control Commands
        case SendRemoteControlRequestCommand:
          final cmd = command as SendRemoteControlRequestCommand;
          await _sendRemoteControlRequest(cmd.targetUser);
          break;

        case RespondToRemoteControlRequestCommand:
          final cmd = command as RespondToRemoteControlRequestCommand;
          await _respondToRemoteControlRequest(cmd.requestId, cmd.accepted);
          break;

        case SendRemoteControlEventCommand:
          final cmd = command as SendRemoteControlEventCommand;
          await _sendRemoteControlEvent(cmd.eventType, cmd.eventData);
          break;

        case DisconnectRemoteControlCommand:
          await _disconnectRemoteControl();
          break;

        // Screen Sharing Commands
        case SendScreenSharingRequestCommand:
          final cmd = command as SendScreenSharingRequestCommand;
          await _sendScreenSharingRequest(
              cmd.targetUser, cmd.reason, cmd.quality);
          break;

        case RespondToScreenSharingRequestCommand:
          final cmd = command as RespondToScreenSharingRequestCommand;
          await _respondToScreenSharingRequest(
              cmd.requestId, cmd.accepted, cmd.rejectReason);
          break;

        case StartScreenSharingCommand:
          final cmd = command as StartScreenSharingCommand;
          await _startScreenSharing(
              cmd.targetUser, cmd.quality, cmd.screenIndex);
          break;

        case StopScreenSharingCommand:
          await _stopScreenSharing();
          break;

        case StopScreenReceivingCommand:
          await _stopScreenReceiving();
          break;

        case DisconnectScreenSharingCommand:
          await _disconnectScreenSharing();
          break;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // =============================================================================
  // PRIVATE METHODS - UI STATE MANAGEMENT
  // =============================================================================

  /// Update UI state and notify listeners
  void _updateUIState(P2PUIState newState) {
    if (_uiState != newState) {
      _uiState = newState;
      notifyListeners();
    }
  }

  /// Load UI settings from storage
  Future<void> _loadUISettings() async {
    try {
      // Load compact layout setting
      final settings =
          await ExtensibleSettingsService.getUserInterfaceSettings();

      // Load status card visibility
      final prefs = await SharedPreferences.getInstance();
      final visibilityList = prefs.getStringList('status_card_visibility');

      Map<String, bool> statusCardVisibility = {
        'thisDevice': true,
        'connectionStatus': true,
        'statistics': true,
      };

      if (visibilityList != null) {
        for (final cardKey in statusCardVisibility.keys) {
          statusCardVisibility[cardKey] = visibilityList.contains(cardKey);
        }
      }

      _updateUIState(_uiState.copyWith(
        useCompactLayout: settings.useCompactLayoutOnMobile,
        statusCardVisibility: statusCardVisibility,
      ));
    } catch (e) {
      logError('Failed to load UI settings: $e');
    }
  }

  /// Toggle device section expand/collapse
  void _toggleDeviceSection(String sectionType) {
    switch (sectionType) {
      case 'online':
        _updateUIState(_uiState.copyWith(
          expandedOnlineDevices: !_uiState.expandedOnlineDevices,
        ));
        break;
      case 'new':
        _updateUIState(_uiState.copyWith(
          expandedNewDevices: !_uiState.expandedNewDevices,
        ));
        break;
      case 'saved':
        _updateUIState(_uiState.copyWith(
          expandedSavedDevices: !_uiState.expandedSavedDevices,
        ));
        break;
      case 'blocked':
        _updateUIState(_uiState.copyWith(
          expandedBlockedDevices: !_uiState.expandedBlockedDevices,
        ));
        break;
    }
  }

  /// Toggle transfer filter mode
  void _toggleTransferFilter() {
    TransferFilterMode newMode;
    switch (_uiState.transferFilterMode) {
      case TransferFilterMode.all:
        newMode = TransferFilterMode.outgoing;
        break;
      case TransferFilterMode.outgoing:
        newMode = TransferFilterMode.incoming;
        break;
      case TransferFilterMode.incoming:
        newMode = TransferFilterMode.all;
        break;
    }
    _updateUIState(_uiState.copyWith(transferFilterMode: newMode));
  }

  /// Toggle status card visibility
  Future<void> _toggleStatusCard(String cardKey) async {
    final newVisibility = Map<String, bool>.from(_uiState.statusCardVisibility);
    newVisibility[cardKey] = !(newVisibility[cardKey] ?? true);

    _updateUIState(_uiState.copyWith(statusCardVisibility: newVisibility));

    // Save to preferences
    await _saveStatusCardVisibility(newVisibility);
  }

  /// Save status card visibility to preferences
  Future<void> _saveStatusCardVisibility(Map<String, bool> visibility) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visibleCards = visibility.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      await prefs.setStringList('status_card_visibility', visibleCards);
    } catch (e) {
      logError('Failed to save status card visibility: $e');
    }
  }

  // =============================================================================
  // PRIVATE METHODS - BUSINESS LOGIC
  // =============================================================================

  /// Check initial network status
  Future<void> _checkInitialNetworkStatus() async {
    try {
      _networkInfo = await NetworkSecurityService.checkNetworkSecurity();
      logInfo('Initial network status checked');
    } catch (e) {
      _errorMessage = 'Failed to check network status: $e';
      logError(_errorMessage!);
    }
  }

  /// Start P2P networking
  Future<void> _startNetworking() async {
    try {
      _errorMessage = null;

      _networkInfo = await NetworkSecurityService.checkNetworkSecurity();
      if (_networkInfo == null || !_networkInfo!.isSecure) {
        _showSecurityWarning = true;
        notifyListeners();
        return;
      }

      _showSecurityWarning = false;
      await _p2pService.enable();

      if (_p2pService.isEnabled && !_hasPerformedInitialDiscovery) {
        await _refreshDiscoveredUsers();
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to start networking: $e';
      logError(_errorMessage!);
      notifyListeners();
    }
  }

  /// Stop P2P networking
  Future<void> _stopNetworking() async {
    try {
      await _p2pService.stopNetworking();
      _showSecurityWarning = false;
      _errorMessage = null;
      _isTemporarilyDisabled = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to stop networking: $e';
      logError(_errorMessage!);
      notifyListeners();
    }
  }

  /// Perform manual discovery
  Future<void> _manualDiscovery() async {
    if (_isRefreshing) return;

    try {
      _isRefreshing = true;
      notifyListeners();

      await _p2pService.manualDiscovery();
      _lastDiscoveryTime = DateTime.now();

      await Future.delayed(const Duration(seconds: 10));
    } catch (e) {
      _errorMessage = 'Discovery failed: $e';
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Refresh discovered users
  Future<void> _refreshDiscoveredUsers() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    _lastDiscoveryTime = DateTime.now();
    notifyListeners();

    try {
      if (_p2pService.isEnabled) {
        await _p2pService.stopNetworking();
      }
      await _p2pService.enable();
      _hasPerformedInitialDiscovery = true;
    } catch (e) {
      _errorMessage = 'Failed to refresh discovered users: $e';
      logError(_errorMessage!);
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Send pairing request
  Future<void> _sendPairingRequest(
      P2PUser targetUser, bool saveConnection, bool trustUser) async {
    _errorMessage = null;
    final success =
        await _p2pService.sendPairingRequest(targetUser, saveConnection);
    if (!success) {
      _errorMessage = 'Failed to send pairing request';
    }
    notifyListeners();
  }

  /// Respond to pairing request
  Future<void> _respondToPairingRequest(String requestId, bool accept,
      bool trustUser, bool saveConnection) async {
    _errorMessage = null;
    final success = await _p2pService.respondToPairingRequest(
        requestId, accept, trustUser, saveConnection);
    if (!success) {
      _errorMessage = 'Failed to respond to pairing request';
    }
    notifyListeners();
  }

  /// Send files to user
  Future<void> _sendFilesToUser(
      List<String> filePaths, P2PUser targetUser) async {
    _errorMessage = null;
    final success =
        await _p2pService.sendMultipleFilesToUser(filePaths, targetUser, true);
    if (!success) {
      _errorMessage = 'Failed to send files';
    }
    notifyListeners();
  }

  /// Cancel transfer
  Future<void> _cancelTransfer(String taskId) async {
    _errorMessage = null;
    final success = await _p2pService.cancelDataTransfer(taskId);
    if (!success) {
      _errorMessage = 'Failed to cancel transfer';
    }
    notifyListeners();
  }

  /// Clear transfer
  Future<void> _clearTransfer(String taskId, bool deleteFile) async {
    if (deleteFile) {
      final success = await _p2pService.clearTransferWithFile(taskId, true);
      if (!success) {
        _errorMessage = 'Failed to clear transfer with file';
        notifyListeners();
      }
    } else {
      _p2pService.clearTransfer(taskId);
    }
  }

  /// Clear all transfers
  Future<void> _clearAllTransfers(bool deleteFiles) async {
    final transferIds = activeTransfers.map((t) => t.id).toList();
    int successCount = 0;
    int failureCount = 0;

    for (final taskId in transferIds) {
      try {
        if (deleteFiles) {
          final success = await _p2pService.clearTransferWithFile(taskId, true);
          if (success) {
            successCount++;
          } else {
            failureCount++;
          }
        } else {
          _p2pService.clearTransfer(taskId);
          successCount++;
        }
      } catch (e) {
        failureCount++;
        logError('Failed to clear transfer $taskId: $e');
      }
    }

    // Note: Batch expand states feature has been removed

    if (failureCount > 0) {
      _errorMessage = 'Cleared $successCount transfers, $failureCount failed';
    }
    notifyListeners();
  }

  /// Clear batch
  Future<void> _clearBatch(String? batchId, bool deleteFiles) async {
    if (batchId == null) return;

    final tasksInBatch =
        activeTransfers.where((task) => task.batchId == batchId).toList();

    for (final task in tasksInBatch) {
      if (deleteFiles) {
        await _p2pService.clearTransferWithFile(task.id, true);
      } else {
        _p2pService.clearTransfer(task.id);
      }
    }

    // Note: Batch expand states feature has been removed
  }

  /// Add trust to user
  Future<void> _addTrust(String userId) async {
    _errorMessage = null;
    final success = await _p2pService.addTrust(userId);
    if (!success) {
      _errorMessage = 'Failed to add trust';
    }
    notifyListeners();
  }

  /// Remove trust from user
  Future<void> _removeTrust(String userId) async {
    _errorMessage = null;
    final success = await _p2pService.removeTrust(userId);
    if (!success) {
      _errorMessage = 'Failed to remove trust';
    }
    notifyListeners();
  }

  /// Unpair user
  Future<void> _unpairUser(String userId) async {
    _errorMessage = null;
    final success = await _p2pService.unpairUser(userId);
    if (!success) {
      _errorMessage = 'Failed to unpair user';
    }
    notifyListeners();
  }

  /// Set user blocked/unblocked
  Future<void> _setBlocked(P2PUser user, bool blocked) async {
    user.isBlocked = blocked;
    await IsarService.isar.writeTxn(() async {
      if (!blocked && user.isTempStored) {
        await IsarService.isar.p2PUsers.delete(user.isarId);
      } else {
        await IsarService.isar.p2PUsers.put(user);
      }
    });
    notifyListeners();
  }

  /// Respond to file transfer request
  Future<void> _respondToFileTransferRequest(
      String requestId, bool accept, String? rejectMessage) async {
    _errorMessage = null;
    final success = await _p2pService.respondToFileTransferRequest(
        requestId, accept, rejectMessage);
    if (!success) {
      _errorMessage = 'Failed to respond to file transfer request';
    }
    notifyListeners();
  }

  /// Reload cache size
  Future<void> _reloadCacheSize() async {
    if (_uiState.isCalculatingCacheSize) return;

    _updateUIState(_uiState.copyWith(isCalculatingCacheSize: true));

    try {
      final cacheSize = await _getP2LanFileCacheSize();
      _updateUIState(_uiState.copyWith(
        isCalculatingCacheSize: false,
        cachedFileCacheSize: cacheSize,
      ));
    } catch (e) {
      _updateUIState(_uiState.copyWith(
        isCalculatingCacheSize: false,
        cachedFileCacheSize: 'Error: $e',
      ));
    }
  }

  /// Get P2Lan file cache size
  Future<String> _getP2LanFileCacheSize() async {
    if (!Platform.isAndroid) {
      return '0 B';
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final filePickerCacheDir = Directory('${tempDir.path}/file_picker');

      int totalSize = 0;
      if (await filePickerCacheDir.exists()) {
        totalSize = await _calculateDirectorySize(filePickerCacheDir);
      }

      return _formatBytes(totalSize);
    } catch (e) {
      logError('Error calculating cache size: $e');
      return 'Unknown';
    }
  }

  /// Calculate directory size recursively
  Future<int> _calculateDirectorySize(Directory directory) async {
    int totalSize = 0;
    try {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            totalSize += stat.size;
          } catch (e) {
            // Skip files we can't read
          }
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
    return totalSize;
  }

  /// Format bytes to human readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Clear file cache
  Future<void> _clearFileCache() async {
    try {
      await _p2pService.cleanupFilePickerCacheIfSafe();
      await _reloadCacheSize();
    } catch (e) {
      _errorMessage = 'Failed to clear cache: $e';
      notifyListeners();
    }
  }

  /// Reload transfer settings
  Future<void> _reloadTransferSettings() async {
    try {
      await _p2pService.reloadTransferSettings();
      logInfo('Transfer settings reloaded');
    } catch (e) {
      _errorMessage = 'Failed to reload transfer settings: $e';
      logError(_errorMessage!);
    }
    notifyListeners();
  }

  // =============================================================================
  // PRIVATE METHODS - REMOTE CONTROL
  // =============================================================================

  /// Send remote control request to target user
  Future<void> _sendRemoteControlRequest(P2PUser targetUser) async {
    try {
      await _p2pService.sendRemoteControlRequest(targetUser);
      logInfo('Remote control request sent to ${targetUser.displayName}');
    } catch (e) {
      _errorMessage = 'Failed to send remote control request: $e';
      logError(_errorMessage!);
      notifyListeners();
    }
  }

  /// Respond to remote control request
  Future<void> _respondToRemoteControlRequest(
      String requestId, bool accepted) async {
    try {
      await _p2pService.respondToRemoteControlRequest(requestId, accepted);
      logInfo(
          'Responded to remote control request: $requestId (accepted: $accepted)');
    } catch (e) {
      _errorMessage = 'Failed to respond to remote control request: $e';
      logError(_errorMessage!);
      notifyListeners();
    }
  }

  /// Send remote control event
  Future<void> _sendRemoteControlEvent(
      RemoteControlEventType eventType, Map<String, dynamic> eventData) async {
    try {
      // Create RemoteControlEvent from type and data
      RemoteControlEvent event;
      switch (eventType) {
        case RemoteControlEventType.keyDown:
          event = RemoteControlEvent.keyDown(eventData['keyCode'] ?? 0);
          break;
        case RemoteControlEventType.keyUp:
          event = RemoteControlEvent.keyUp(eventData['keyCode'] ?? 0);
          break;
        case RemoteControlEventType.startMiddleLongClick:
          event = RemoteControlEvent.startMiddleLongClick();
          break;
        case RemoteControlEventType.stopMiddleLongClick:
          event = RemoteControlEvent.stopMiddleLongClick();
          break;
        case RemoteControlEventType.mouseMove:
          event = RemoteControlEvent.mouseMove(
            eventData['x']?.toDouble() ?? 0.0,
            eventData['y']?.toDouble() ?? 0.0,
          );
          break;
        case RemoteControlEventType.leftClick:
          event = RemoteControlEvent.leftClick();
          break;
        case RemoteControlEventType.rightClick:
          event = RemoteControlEvent.rightClick();
          break;
        case RemoteControlEventType.middleClick:
          event = RemoteControlEvent.middleClick();
          break;
        case RemoteControlEventType.startLeftLongClick:
          event = RemoteControlEvent.startLeftLongClick();
          break;
        case RemoteControlEventType.stopLeftLongClick:
          event = RemoteControlEvent.stopLeftLongClick();
          break;
        case RemoteControlEventType.startRightLongClick:
          event = RemoteControlEvent.startRightLongClick();
          break;
        case RemoteControlEventType.stopRightLongClick:
          event = RemoteControlEvent.stopRightLongClick();
          break;
        case RemoteControlEventType.scroll:
          event = RemoteControlEvent.scroll(
            eventData['deltaX']?.toDouble() ?? 0.0,
            eventData['deltaY']?.toDouble() ?? 0.0,
          );
          break;
        case RemoteControlEventType.scrollUp:
          event = RemoteControlEvent.scrollUp();
          break;
        case RemoteControlEventType.scrollDown:
          event = RemoteControlEvent.scrollDown();
          break;
        case RemoteControlEventType.disconnect:
          event = RemoteControlEvent.disconnect();
          break;
        // New touchpad gestures
        case RemoteControlEventType.twoFingerScroll:
          event = RemoteControlEvent.twoFingerScroll(
            eventData['deltaX']?.toDouble() ?? 0.0,
            eventData['deltaY']?.toDouble() ?? 0.0,
          );
          break;
        case RemoteControlEventType.twoFingerTap:
          event = RemoteControlEvent.twoFingerTap();
          break;
        case RemoteControlEventType.twoFingerSlowTap:
          event = RemoteControlEvent.twoFingerSlowTap();
          break;
        case RemoteControlEventType.twoFingerDragDrop:
          event = RemoteControlEvent.twoFingerDragDrop(
            eventData['x']?.toDouble() ?? 0.0,
            eventData['y']?.toDouble() ?? 0.0,
          );
          break;
        case RemoteControlEventType.threeFingerSwipeUp:
          event = RemoteControlEvent.threeFingerSwipe('up');
          break;
        case RemoteControlEventType.threeFingerSwipeDown:
          event = RemoteControlEvent.threeFingerSwipe('down');
          break;
        case RemoteControlEventType.threeFingerSwipeLeft:
          event = RemoteControlEvent.threeFingerSwipe('left');
          break;
        case RemoteControlEventType.threeFingerSwipeRight:
          event = RemoteControlEvent.threeFingerSwipe('right');
          break;
        case RemoteControlEventType.threeFingerTap:
          event = RemoteControlEvent.threeFingerTap();
          break;
        case RemoteControlEventType.fourFingerTap:
          event = RemoteControlEvent.fourFingerTap();
          break;
        case RemoteControlEventType.sendText:
          event = RemoteControlEvent.sendText(eventData['text'] ?? '');
          break;
      }

      await _p2pService.sendRemoteControlEvent(event);
      // Don't log every mouse move to avoid spam
      if (eventType != RemoteControlEventType.mouseMove) {
        logInfo('Sent remote control event: $eventType');
      }
    } catch (e) {
      _errorMessage = 'Failed to send remote control event: $e';
      logError(_errorMessage!);
      notifyListeners();
    }
  }

  /// Disconnect remote control session
  Future<void> _disconnectRemoteControl() async {
    try {
      await _p2pService.disconnectRemoteControl();

      // Clear the session from UI state
      _updateUIState(_uiState.copyWith(currentRemoteControlSession: null));

      logInfo('Remote control session disconnected');
    } catch (e) {
      _errorMessage = 'Failed to disconnect remote control: $e';
      logError(_errorMessage!);
      notifyListeners();
    }
  }

  /// Setup remote control session callbacks
  void _setupRemoteControlSessionCallbacks() {
    _p2pService.setSessionStartedCallback((controller, controlled, sessionId) {
      _startRemoteControlSession(controller, controlled, sessionId);
    });

    _p2pService.setSessionEndedCallback(() {
      _clearRemoteControlSession();
    });
  }

  void _setupScreenSharingSessionCallbacks() {
    // Don't setup request callback here - it will be set by the screen
    // Only setup session lifecycle callbacks

    _p2pService.setScreenSharingSessionStartedCallback((session) {
      _startScreenSharingSession(session);
    });

    _p2pService.setScreenSharingSessionEndedCallback(() {
      _clearScreenSharingSession();
    });
  }

  /// Start a new remote control session (called when request is accepted)
  void _startRemoteControlSession(
      P2PUser controllerUser, P2PUser controlledUser, String sessionId) {
    final session = RemoteControlSession(
      sessionId: sessionId,
      controllerUser: controllerUser,
      controlledUser: controlledUser,
      startTime: DateTime.now(),
    );

    _updateUIState(_uiState.copyWith(currentRemoteControlSession: session));

    // Start timer to update session duration every second
    _sessionDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_uiState.currentRemoteControlSession != null) {
        notifyListeners(); // Trigger UI rebuild to update duration display
      } else {
        timer.cancel(); // Cancel timer if session ended
      }
    });

    logInfo(
        'Remote control session started: ${controllerUser.displayName} -> ${controlledUser.displayName} (Session: $sessionId)');
  }

  /// Clear remote control session UI state (called by service callback)
  void _clearRemoteControlSession() {
    // Only clear if there's actually a session to avoid unnecessary state updates
    if (_uiState.currentRemoteControlSession == null) {
      return;
    }

    // Cancel duration update timer
    _sessionDurationTimer?.cancel();
    _sessionDurationTimer = null;

    // Clear the session from UI state
    _updateUIState(_uiState.copyWith(currentRemoteControlSession: null));
  }

  /// Show screen sharing request dialog
  void _showScreenSharingRequestDialog(ScreenSharingRequest request) {
    // This method is kept for potential future use
    // Currently, request dialogs are handled directly by the UI layer
    notifyListeners();
  }

  /// Start a new screen sharing session
  void _startScreenSharingSession(ScreenSharingSession session) {
    _updateUIState(_uiState.copyWith(currentScreenSharingSession: session));

    logInfo(
        'Screen sharing session started: ${session.senderUser.displayName} -> ${session.receiverUser.displayName}');
  }

  /// Clear screen sharing session
  void _clearScreenSharingSession() {
    if (_uiState.currentScreenSharingSession == null) {
      return;
    }

    _updateUIState(_uiState.copyWith(currentScreenSharingSession: null));
    logInfo('Screen sharing session ended');
  }

  /// End remote control session (called by controlled device)
  Future<void> endRemoteControlSession({bool isActiveDisconnect = true}) async {
    final session = _uiState.currentRemoteControlSession;
    if (session == null) return;

    try {
      if (isActiveDisconnect) {
        // This device is actively ending the session, send signal to controller
        // Clear UI state immediately for better UX
        _clearRemoteControlSession();

        // Send signal to remote device
        await _p2pService.disconnectRemoteControl(isActiveDisconnect: true);
      } else {
        // Passive disconnect (already received signal), just clear UI state
        _clearRemoteControlSession();
      }
    } catch (e) {
      _errorMessage = 'Failed to end remote control session: $e';
      logError(_errorMessage!);
      notifyListeners();
    }
  }

  // =============================================================================
  // PRIVATE METHODS - SCREEN SHARING
  // =============================================================================

  /// Send screen sharing request to target user
  Future<void> _sendScreenSharingRequest(
      P2PUser targetUser, String? reason, ScreenSharingQuality quality) async {
    try {
      await _p2pService.sendScreenSharingRequest(targetUser,
          reason: reason, quality: quality);
      logInfo('Screen sharing request sent to ${targetUser.displayName}');
    } catch (e) {
      _errorMessage = 'Failed to send screen sharing request: $e';
      logError(_errorMessage!);
      notifyListeners();
    }
  }

  /// Respond to screen sharing request
  Future<void> _respondToScreenSharingRequest(
      String requestId, bool accepted, String? rejectReason) async {
    try {
      await _p2pService.respondToScreenSharingRequest(requestId, accepted,
          rejectReason: rejectReason);
      logInfo(
          'Responded to screen sharing request: $requestId (accepted: $accepted)');
    } catch (e) {
      _errorMessage = 'Failed to respond to screen sharing request: $e';
      logError(_errorMessage!);
      notifyListeners();
    }
  }

  /// Start screen sharing
  Future<void> _startScreenSharing(P2PUser targetUser,
      ScreenSharingQuality quality, int? screenIndex) async {
    try {
      await _p2pService.startScreenSharing(targetUser,
          quality: quality, screenIndex: screenIndex);
      logInfo('Screen sharing started with ${targetUser.displayName}');
    } catch (e) {
      _errorMessage = 'Failed to start screen sharing: $e';
      logError(_errorMessage!);
      notifyListeners();
    }
  }

  /// Stop screen sharing
  Future<void> _stopScreenSharing() async {
    try {
      await _p2pService.stopScreenSharing();
      logInfo('Screen sharing stopped');
    } catch (e) {
      _errorMessage = 'Failed to stop screen sharing: $e';
      logError(_errorMessage!);
      notifyListeners();
    }
  }

  /// Stop screen receiving
  Future<void> _stopScreenReceiving() async {
    try {
      await _p2pService.stopScreenReceiving();
      logInfo('Screen receiving stopped');
    } catch (e) {
      _errorMessage = 'Failed to stop screen receiving: $e';
      logError(_errorMessage!);
      notifyListeners();
    }
  }

  /// Disconnect screen sharing session
  Future<void> _disconnectScreenSharing() async {
    try {
      await _p2pService.disconnectScreenSharing();
      logInfo('Screen sharing session disconnected');
    } catch (e) {
      _errorMessage = 'Failed to disconnect screen sharing: $e';
      logError(_errorMessage!);
      notifyListeners();
    }
  }

  // =============================================================================
  // PRIVATE METHODS - CONNECTIVITY
  // =============================================================================

  /// Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });
    logInfo('Connectivity monitoring started');
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(List<ConnectivityResult> results) async {
    final hasConnection =
        results.any((result) => result != ConnectivityResult.none);

    if (!hasConnection) {
      if (_p2pService.isEnabled) {
        _wasPreviouslyEnabled = true;
        _isTemporarilyDisabled = true;

        try {
          await _p2pService.stopNetworking();
          _showSecurityWarning = false;
          _errorMessage = 'P2P temporarily disabled - no internet connection';
          _resetDiscoveryState();
          notifyListeners();
        } catch (e) {
          logError('Error stopping P2P on connectivity loss: $e');
        }
      }
    } else {
      if (_wasPreviouslyEnabled && _isTemporarilyDisabled) {
        _isTemporarilyDisabled = false;
        _wasPreviouslyEnabled = false;

        try {
          await Future.delayed(const Duration(seconds: 2));
          await _p2pService.enable();

          if (_p2pService.isEnabled) {
            _errorMessage = null;
            await _checkInitialNetworkStatus();
          } else {
            _errorMessage = 'Failed to restore P2P networking automatically';
          }
          notifyListeners();
        } catch (e) {
          _errorMessage = 'Error restoring P2P networking: $e';
          logError(_errorMessage!);
          notifyListeners();
        }
      }
    }
  }

  /// Reset discovery state
  void _resetDiscoveryState() {
    _hasPerformedInitialDiscovery = false;
    _isRefreshing = false;
  }

  // =============================================================================
  // PRIVATE METHODS - EVENT HANDLERS
  // =============================================================================

  /// Handle P2P service changes
  void _onP2PServiceChanged() {
    if (hasListeners) {
      notifyListeners();
    }
  }

  // =============================================================================
  // PUBLIC METHODS - UTILITIES
  // =============================================================================

  /// Get user by ID
  P2PUser? getUserById(String userId) {
    try {
      return discoveredUsers.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is online
  bool isUserOnline(String userId) {
    final user = getUserById(userId);
    return user?.isOnline ?? false;
  }

  /// Check if user name is duplicated
  bool isUserNameDuplicated(P2PUser user) {
    return discoveredUsers
        .any((u) => u.displayName == user.displayName && u.id != user.id);
  }

  /// Check if we can send remote control request to this user
  bool canSendRemoteControlRequest(P2PUser user) {
    // Check if current user is Android and target user is Windows
    final currentUser = this.currentUser;
    if (currentUser == null) return false;

    return currentUser.platform == UserPlatform.android &&
        user.platform == UserPlatform.windows &&
        user.isOnline &&
        user.isPaired &&
        !isControlling &&
        !isBeingControlled;
  }

  bool canSendScreenSharingRequest(P2PUser user) {
    // Screen sharing is available for both directions (Android<->Windows)
    final currentUser = this.currentUser;
    if (currentUser == null) return false;

    return (currentUser.platform == UserPlatform.android ||
            currentUser.platform == UserPlatform.windows) &&
        (user.platform == UserPlatform.android ||
            user.platform == UserPlatform.windows) &&
        user.isOnline &&
        user.isPaired &&
        _uiState.currentScreenSharingSession == null;
  }

  /// Get user platform icon
  IconData getUserStatusIcon(P2PUser user) {
    // Use platform icon instead of status icon
    switch (user.platform) {
      case UserPlatform.android:
        return Icons.android;
      case UserPlatform.ios:
        return Icons.phone_iphone;
      case UserPlatform.windows:
        return Icons.computer;
      case UserPlatform.macos:
        return Icons.laptop_mac;
      case UserPlatform.linux:
        return Icons.laptop;
      case UserPlatform.web:
        return Icons.web;
      case UserPlatform.unknown:
        return Icons.device_unknown;
    }
  }

  /// Get user status color
  Color getUserStatusColor(P2PUser user) {
    switch (user.connectionDisplayStatus) {
      case ConnectionDisplayStatus.discovered:
        return Colors.blue;
      case ConnectionDisplayStatus.connectedOnline:
        return Colors.green;
      case ConnectionDisplayStatus.connectedOffline:
        return Colors.grey;
    }
  }

  /// Get network status description
  String getNetworkStatusDescription(AppLocalizations l10n) {
    if (_isTemporarilyDisabled) {
      return l10n.p2pTemporarilyDisabled;
    }

    if (_networkInfo == null) return l10n.checkingNetwork;

    if (_networkInfo!.isMobile) {
      return l10n.connectedViaMobileData;
    } else if (_networkInfo!.isWiFi) {
      final securityText = _networkInfo!.isSecure ? l10n.secure : l10n.unsecure;
      final wifiName = _networkInfo!.wifiName?.isNotEmpty == true
          ? _networkInfo!.wifiName!
          : "WiFi";
      return l10n.connectedToWifi(wifiName, securityText);
    } else if (_networkInfo!.securityType == 'ETHERNET') {
      return l10n.connectedViaEthernet;
    } else {
      return l10n.noNetworkConnection;
    }
  }

  /// Get connection status description
  String getConnectionStatusDescription(AppLocalizations l10n) {
    switch (connectionStatus) {
      case ConnectionStatus.disconnected:
        return l10n.disconnected;
      case ConnectionStatus.discovering:
        return l10n.discoveringDevices;
      case ConnectionStatus.connected:
        return l10n.online;
      case ConnectionStatus.pairing:
        return l10n.pairing;
      case ConnectionStatus.paired:
        return l10n.paired;
    }
  }

  /// Process pending file transfer requests
  void processPendingFileTransferRequests() {
    final pendingRequests = _p2pService.pendingFileTransferRequests;

    for (final request in pendingRequests) {
      final elapsed = DateTime.now().difference(request.requestTime);
      final remainingSeconds = 60 - elapsed.inSeconds;

      if (remainingSeconds > 5 && _onNewFileTransferRequest != null) {
        _onNewFileTransferRequest!(request);
      }
    }
  }

  /// Set callbacks
  void setNewPairingRequestCallback(Function(PairingRequest)? callback) {
    _p2pService.setNewPairingRequestCallback(callback);
  }

  void clearNewPairingRequestCallback() {
    _p2pService.setNewPairingRequestCallback(null);
  }

  void setNewFileTransferRequestCallback(
      Function(FileTransferRequest)? callback) {
    _onNewFileTransferRequest = callback;
    _p2pService.setNewFileTransferRequestCallback(callback);
  }

  void clearNewFileTransferRequestCallback() {
    _onNewFileTransferRequest = null;
    _p2pService.setNewFileTransferRequestCallback(null);
  }

  /// Set callback for new remote control requests
  void setNewRemoteControlRequestCallback(
      Function(RemoteControlRequest)? callback) {
    _onNewRemoteControlRequest = callback;
    _p2pService.setNewRemoteControlRequestCallback(callback);
  }

  /// Clear callback for new remote control requests
  void clearNewRemoteControlRequestCallback() {
    _onNewRemoteControlRequest = null;
    _p2pService.setNewRemoteControlRequestCallback(null);
  }

  /// Set callback for new screen sharing requests
  void setNewScreenSharingRequestCallback(
      Function(ScreenSharingRequest)? callback) {
    _p2pService.setNewScreenSharingRequestCallback(callback);
  }

  /// Clear callback for new screen sharing requests
  void clearNewScreenSharingRequestCallback() {
    _p2pService.clearNewScreenSharingRequestCallback();
  }

  /// Set callback for remote control accepted (for navigation)
  void setRemoteControlAcceptedCallback(Function(P2PUser)? callback) {
    _onRemoteControlAccepted = callback;
    _p2pService.setRemoteControlAcceptedCallback(callback);
  }

  /// Clear callback for remote control accepted
  void clearRemoteControlAcceptedCallback() {
    _onRemoteControlAccepted = null;
    _p2pService.setRemoteControlAcceptedCallback(null);
  }

  /// Set callback for screen sharing session started (for navigation)
  void setScreenSharingSessionStartedCallback(
      Function(ScreenSharingSession)? callback) {
    _p2pService.setScreenSharingSessionStartedCallback(callback);
  }

  /// Clear callback for screen sharing session started
  void clearScreenSharingSessionStartedCallback() {
    _p2pService.clearScreenSharingSessionStartedCallback();
  }

  /// Dismiss security warning
  void dismissSecurityWarning() {
    _showSecurityWarning = false;
    notifyListeners();
  }

  /// Start networking with warning acknowledged
  Future<bool> startNetworkingWithWarning() async {
    try {
      _errorMessage = null;
      _showSecurityWarning = false;

      await _p2pService.enable();

      if (_p2pService.isEnabled && !_hasPerformedInitialDiscovery) {
        await _refreshDiscoveredUsers();
      }

      notifyListeners();
      return _p2pService.isEnabled;
    } catch (e) {
      _errorMessage = 'Failed to start networking with warning: $e';
      logError(_errorMessage!);
      notifyListeners();
      return false;
    }
  }

  /// Select user
  void selectUser(P2PUser user) {
    _selectedUser = user;
    notifyListeners();
  }

  /// Clear selected user
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  // =============================================================================
  // DISPOSE
  // =============================================================================

  @override
  void dispose() {
    logInfo('P2PViewModelNew disposed');
    _connectivitySubscription?.cancel();
    _sessionDurationTimer?.cancel();
    _p2pService.removeListener(_onP2PServiceChanged);
    clearNewPairingRequestCallback();
    clearNewFileTransferRequestCallback();
    super.dispose();
  }
}
