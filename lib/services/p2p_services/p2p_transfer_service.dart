import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:crypto/crypto.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:p2lan/models/p2p_models.dart';
// Import enum DataTransferKey để dùng cho metadata
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/isar_service.dart';
import 'package:p2lan/services/p2p_services/p2p_chat_service.dart';
import 'package:p2lan/services/p2p_services/p2p_network_service.dart';
import 'package:p2lan/services/p2p_services/p2p_notification_service.dart';
import 'package:p2lan/services/p2p_services/p2p_settings_adapter.dart';
import 'package:p2lan/services/performance_optimizer_service.dart'; // 🚀 Thêm import
import 'package:p2lan/utils/isar_utils.dart';
import 'package:p2lan/utils/url_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:p2lan/services/encryption_service.dart';
import 'package:p2lan/services/crypto_service.dart';
import 'package:p2lan/services/ecdh_key_exchange_service.dart';

/// Validation result for file transfer request
class _FileTransferValidationResult {
  final bool isValid;
  final FileTransferRejectReason? rejectReason;
  final String? rejectMessage;

  _FileTransferValidationResult.valid()
      : isValid = true,
        rejectReason = null,
        rejectMessage = null;
  _FileTransferValidationResult.invalid(this.rejectReason, this.rejectMessage)
      : isValid = false;
}

/// P2P Transfer Service - Handles file transfer, data chunks, and concurrency control
/// Extracted from monolithic P2PService for better modularity
class P2PTransferService extends ChangeNotifier {
  final P2PNetworkService _networkService;
  late final P2PChatService _chatService = P2PChatService(IsarService.isar);

  // Transfer settings
  P2PDataTransferSettings? _transferSettings;

  // ECDH Key management
  ECDHKeyPair? _deviceKeyPair;

  // File transfer request management
  final List<FileTransferRequest> _pendingFileTransferRequests = [];

  // Callbacks
  Function(FileTransferRequest)? _onNewFileTransferRequest;

  // File transfer responses pending timeout
  final Map<String, Timer> _fileTransferResponseTimers = {};
  final Map<String, Timer> _fileTransferRequestTimers = {};

  // Store download paths for batches (with date folders)
  final Map<String, String> _batchDownloadPaths = {};

  // Store total file counts for each batch to ensure proper cleanup
  final Map<String, int> _batchFileCounts = {};

  // Map from sender userId to current active batchId for incoming transfers
  final Map<String, String> _activeBatchIdsByUser = {};

  // Data transfer management
  final Map<String, DataTransferTask> _activeTransfers = {};
  final Map<String, Isolate> _transferIsolates = {};
  final Map<String, ReceivePort> _transferPorts = {};

  // File receiving management
  final Map<String, List<Uint8List>> _incomingFileChunks = {};
  // Map taskId -> temporary file path for large file chunks
  final Map<String, String> _tempFileChunks = {};
  // Map taskId -> messageId (P2PCMessage.id) for received files
  final Map<String, int> _receivedFileMessageIds = {};

  // Task creation synchronization to prevent race conditions
  final Map<String, Completer<DataTransferTask?>> _taskCreationLocks = {};

  // Buffer chunks that arrive before task is created
  final Map<String, List<Map<String, dynamic>>> _pendingChunks = {};

  // File assembly synchronization to prevent race conditions
  final Map<String, Completer<void>> _fileAssemblyLocks = {};

  // Chunk processing synchronization to prevent concurrent modifications
  final Map<String, Completer<void>> _chunkProcessingLocks = {};

  // Receiver-side workers to offload decoding/decryption and disk I/O
  final Map<String, Isolate> _rxReceiverIsolates = {};
  final Map<String, SendPort> _rxReceiverPorts = {};

  // File picker cache management
  static final Set<String> _activeFileTransferBatches = <String>{};
  static DateTime? _lastFilePickerCleanup;
  static const Duration _cleanupCooldown = Duration(minutes: 2);

  // Encryption session keys management
  final Map<String, Uint8List> _sessionKeys = {};

  /// Get session key for a user. Returns null if not found.
  Uint8List? _getSessionKey(String userId) {
    return _sessionKeys[userId];
  }

  /// Get or generate session key for a user.
  Uint8List _getOrCreateSessionKey(String userId) {
    return _sessionKeys[userId] ??= EncryptionService.generateKey();
  }

  /// Clear session key for a user
  void clearSessionKey(String userId) {
    _sessionKeys.remove(userId);
    logInfo('P2PTransferService: Session key cleared for user $userId');
  }

  /// Clear all session keys
  void clearAllSessionKeys() {
    _sessionKeys.clear();
    logInfo('P2PTransferService: All session keys cleared');
  }

  // 🚀 UI Refresh Rate System
  Timer? _uiRefreshTimer;
  final Map<String, DataTransferTask> _pendingUIUpdates = {};
  bool _immediateRefresh = false;

  // Getters
  P2PDataTransferSettings? get transferSettings => _transferSettings;
  List<FileTransferRequest> get pendingFileTransferRequests =>
      List.unmodifiable(_pendingFileTransferRequests);
  List<DataTransferTask> get activeTransfers =>
      _activeTransfers.values.toList();

  P2PTransferService(this._networkService) {
    // Set up message handler for incoming TCP messages
    _networkService.setMessageHandler(_handleTcpMessage);
  }

  // -- Persistence helpers -------------------------------------------------
  Future<void> _saveTaskToDb(DataTransferTask task) async {
    try {
      final isar = IsarService.isar;
      await isar.writeTxn(() => isar.dataTransferTasks.put(task));
    } catch (e) {
      logWarning('P2PTransferService: Failed to persist task ${task.id}: $e');
    }
  }

  Future<void> _deleteTaskFromDbById(String taskId) async {
    try {
      final isar = IsarService.isar;
      await isar
          .writeTxn(() => isar.dataTransferTasks.delete(fastHash(taskId)));
    } catch (e) {
      logWarning(
          'P2PTransferService: Failed to delete task $taskId from DB: $e');
    }
  }

  /// Initialize transfer service
  Future<void> initialize() async {
    // Generate ephemeral key pair for this session
    _deviceKeyPair = ECDHKeyExchangeService.generateEphemeralKeyPair();
    logInfo(
        'P2PTransferService: Generated ephemeral key pair with fingerprint: ${_deviceKeyPair!.publicKeyFingerprint}');

    // Load transfer settings and active transfers
    await _loadTransferSettings();
    await _loadActiveTransfers();
    await _loadPendingFileTransferRequests();

    // Optional: clear stale transfers on startup based on settings
    try {
      final doStartupClear = _transferSettings?.clearTransfersAtStartup == true;
      if (doStartupClear && _activeTransfers.isNotEmpty) {
        // Clear all tasks
        logDebug(
            'P2PTransferService: Startup cleanup: ${_activeTransfers.length} all transfers');
        // Add active transfer
        final idsToClear = _activeTransfers.values.map((t) => t.id).toList();
        // Clear all tasks
        for (final id in idsToClear) {
          await _autoCleanupTask(id, 'startup cleanup');
        }
      } else {
        // Only clear tasks that are not successful
        logDebug(
            'P2PTransferService: Startup cleanup: ${_activeTransfers.length} unsuccessful transfers');
        // Add active transfer
        final idsToClear = _activeTransfers.values
            .where((t) => t.status != DataTransferStatus.completed)
            .map((t) => t.id)
            .toList();
        // Clear all tasks
        for (final id in idsToClear) {
          await _autoCleanupTask(id, 'startup cleanup');
        }
      }
    } catch (e) {
      logWarning('P2PTransferService: Startup cleanup failed: $e');
    }

    // Initialize Android path if needed
    await _initializeAndroidPath();

    // Schedule cleanup of expired messages in background
    _scheduleMessageCleanup();

    // 🚀 Initialize UI refresh system
    _initializeUIRefreshSystem();

    logInfo('P2PTransferService: Initialized successfully');
  }

  /// Schedule message cleanup to run in background
  void _scheduleMessageCleanup() {
    Future.microtask(() async {
      try {
        // Wait a bit to ensure all services are fully initialized
        await Future.delayed(const Duration(seconds: 3));
        await _chatService.cleanupExpiredMessages();
      } catch (e) {
        logError(
            'P2PTransferService: Error during scheduled message cleanup: $e');
      }
    });
  }

  /// Public method to trigger message cleanup manually
  Future<void> cleanupExpiredMessages() async {
    try {
      await _chatService.cleanupExpiredMessages();
    } catch (e) {
      logError('P2PTransferService: Error during manual message cleanup: $e');
    }
  }

  /// 🚀 Initialize UI refresh rate system
  void _initializeUIRefreshSystem() {
    final refreshRate = _transferSettings?.uiRefreshRateSeconds ?? 0;
    _immediateRefresh = refreshRate == 0;

    if (!_immediateRefresh) {
      // Start periodic UI updates for non-immediate mode
      _uiRefreshTimer = Timer.periodic(Duration(seconds: refreshRate), (_) {
        _processPendingUIUpdates();
      });
      logInfo(
          'P2PTransferService: UI refresh system initialized with ${refreshRate}s interval');
    } else {
      logInfo(
          'P2PTransferService: UI refresh system initialized in immediate mode');
    }
  }

  /// 🚀 Process pending UI updates in batch
  void _processPendingUIUpdates() {
    if (_pendingUIUpdates.isEmpty) return;

    // Update active transfers with latest data from pending updates
    for (final entry in _pendingUIUpdates.entries) {
      final taskId = entry.key;
      final updatedTask = entry.value;
      _activeTransfers[taskId] = updatedTask;
    }

    _pendingUIUpdates.clear();

    // Trigger UI update in background to avoid blocking transfer
    Future.microtask(() => notifyListeners());
  }

  /// 🚀 Schedule task for UI update
  void _scheduleUIUpdate(DataTransferTask task) {
    // Always update active transfers immediately for progress tracking
    _activeTransfers[task.id] = task;

    if (_immediateRefresh) {
      // Update UI immediately
      Future.microtask(() => notifyListeners());
    } else {
      // Add to pending updates for batch processing
      _pendingUIUpdates[task.id] = task;
    }
  }

  /// Send multiple files to paired user
  Future<bool> sendMultipleFiles(
      List<String> filePaths, P2PUser targetUser, bool transferOnly) async {
    try {
      if (!targetUser.isPaired) {
        throw Exception('User is not paired');
      }

      if (filePaths.isEmpty) {
        throw Exception('No files selected');
      }

      // Check all files exist and prepare file info list
      final files = <FileTransferInfo>[];
      int totalSize = 0;

      for (final filePath in filePaths) {
        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception('File does not exist: $filePath');
        }

        final fileSize = await file.length();
        final fileName = file.path.split(Platform.pathSeparator).last;

        files.add(FileTransferInfo(fileName: fileName, fileSize: fileSize));
        totalSize += fileSize;
      }

      // Create file transfer request
      final request = FileTransferRequest(
        requestId: 'ftr_${const Uuid().v4()}',
        batchId: const Uuid().v4(),
        fromUserId: _networkService.currentUser!.id,
        fromUserName: _networkService.currentUser!.displayName,
        files: files,
        totalSize: totalSize,
        protocol: _transferSettings?.sendProtocol ?? 'tcp',
        maxChunkSize: _transferSettings?.maxChunkSize,
        requestTime: DateTime.now(),
        useEncryption: _transferSettings?.enableEncryption ?? false,
      );

      // Create transfer tasks in waiting state
      for (int i = 0; i < filePaths.length; i++) {
        final filePath = filePaths[i];
        final fileInfo = files[i];

        // Prepare task data based on transfer type
        Map<String, dynamic>? taskData;
        if (!transferOnly) {
          // For chat messages: include syncFilePath to update chat message with file path
          taskData = {DataTransferKey.syncFilePath.name: 1};
        }
        // For regular file transfers (transferOnly = true): no special data needed

        final task = DataTransferTask.create(
            fileName: fileInfo.fileName,
            filePath: filePath,
            fileSize: fileInfo.fileSize,
            targetUserId: targetUser.id,
            targetUserName: targetUser.displayName,
            status: DataTransferStatus.waitingForApproval,
            isOutgoing: true,
            batchId: request.batchId,
            data: taskData);
        _activeTransfers[task.id] = task;
        await _saveTaskToDb(task);
        logDebug(
            'P2PTransferService: Created task ${task.id} for file ${fileInfo.fileName} '
            'transferOnly=$transferOnly with data: ${task.data.toString()}');
      }

      // Send file transfer request
      final message = {
        'type': P2PMessageTypes.fileTransferRequest,
        'fromUserId': _networkService.currentUser!.id,
        'toUserId': targetUser.id,
        'data': request.toJson(),
      };

      final success =
          await _networkService.sendMessageToUser(targetUser, message);
      if (success) {
        // Register active file transfer batch
        _registerActiveFileTransferBatch(request.batchId);

        // Set up response timeout timer
        _fileTransferResponseTimers[request.requestId] = Timer(
          const Duration(seconds: 65),
          () => _handleFileTransferTimeout(request.requestId),
        );

        logInfo(
            'P2PTransferService: Sent file transfer request for ${files.length} files');
      } else {
        // Clean up tasks if request failed
        _cancelTasksByBatchId(request.batchId);
        cleanupFilePickerCacheIfSafe();
      }

      notifyListeners();
      return success;
    } catch (e) {
      logError('P2PTransferService: Failed to send file transfer request: $e');
      return false;
    }
  }

  /// Cancel data transfer
  Future<bool> cancelDataTransfer(String taskId) async {
    try {
      final task = _activeTransfers[taskId];
      if (task == null) return false;

      // Only cancel transfers that are actually in progress
      if (task.status != DataTransferStatus.transferring) {
        logInfo(
            'P2PTransferService: Skipping cancellation for task ${task.id} with status ${task.status}');
        return false;
      }

      // Stop isolate if running
      final isolate = _transferIsolates[taskId];
      if (isolate != null) {
        isolate.kill(priority: Isolate.immediate);
        _transferIsolates.remove(taskId);
        _transferPorts[taskId]?.close();
        _transferPorts.remove(taskId);
      }

      task.status = DataTransferStatus.cancelled;
      task.errorMessage = 'Cancelled by user';

      // Auto-cleanup cancelled task after a delay
      if (_transferSettings?.autoCleanupCancelledTasks == true) {
        Timer(
            Duration(seconds: _transferSettings?.autoCleanupDelaySeconds ?? 3),
            () async {
          logDebug(
              '>> Call auto cleanup from autoCleanupCancelledTasks == true for failed task: ${task.id}');

          await _autoCleanupTask(taskId, 'cancelled');
        });
      }

      // Notify other user
      final targetUser = _getTargetUser(task.targetUserId);
      if (targetUser != null && targetUser.isOnline) {
        final message = {
          'type': P2PMessageTypes.dataTransferCancel,
          'fromUserId': _networkService.currentUser!.id,
          'toUserId': targetUser.id,
          'data': {'taskId': taskId},
        };
        await _networkService.sendMessageToUser(targetUser, message);
      }

      // Clean up and start next queued transfer
      _cleanupTransfer(taskId);

      notifyListeners();
      return true;
    } catch (e) {
      logError('P2PTransferService: Failed to cancel data transfer: $e');
      return false;
    }
  }

  /// Respond to file transfer request
  Future<bool> respondToFileTransferRequest(
      String requestId, bool accept, String? rejectMessage) async {
    try {
      final request = _pendingFileTransferRequests
          .firstWhere((r) => r.requestId == requestId);

      // Cancel timeout timer
      _fileTransferRequestTimers[requestId]?.cancel();
      _fileTransferRequestTimers.remove(requestId);

      // Dismiss notification
      await _safeNotificationCall(() => P2PNotificationService.instance
          .cancelNotification(request.requestId.hashCode));

      if (accept) {
        await _acceptFileTransferRequest(request);
      } else {
        await _sendFileTransferResponse(
            request,
            false,
            FileTransferRejectReason.userRejected,
            rejectMessage ?? 'Rejected by user');

        // Remove from pending list
        _pendingFileTransferRequests
            .removeWhere((r) => r.requestId == requestId);
        await _removeFileTransferRequest(request.requestId);
      }

      notifyListeners();
      return true;
    } catch (e) {
      logError(
          'P2PTransferService: Failed to respond to file transfer request: $e');
      return false;
    }
  }

  /// Update transfer settings
  Future<bool> updateTransferSettings(P2PDataTransferSettings settings) async {
    try {
      await P2PSettingsAdapter.updateSettings(settings);
      _transferSettings = settings;

      logInfo('P2PTransferService: Updated transfer settings');
      return true;
    } catch (e) {
      logError('P2PTransferService: Failed to update transfer settings: $e');
      return false;
    }
  }

  /// Reload transfer settings from storage
  Future<void> reloadTransferSettings() async {
    await _loadTransferSettings();

    // 🚀 Reinitialize UI refresh system if settings changed
    _uiRefreshTimer?.cancel();
    _uiRefreshTimer = null;
    _pendingUIUpdates.clear();
    _initializeUIRefreshSystem();

    logInfo('P2PTransferService: Transfer settings reloaded');
  }

  /// Clear a transfer from the list
  void clearTransfer(String taskId) {
    final task = _activeTransfers.remove(taskId);
    if (task != null) {
      // Clean up temp file if exists
      final tempFilePath = _tempFileChunks.remove(taskId);
      if (tempFilePath != null) {
        _cleanupTempFile(tempFilePath);
      }
      logInfo('P2PTransferService: Cleared transfer: ${task.fileName}');
      // Remove from DB as well
      _deleteTaskFromDbById(taskId);
      notifyListeners();
    }
  }

  /// Clear a transfer and optionally delete the downloaded file
  Future<bool> clearTransferWithFile(String taskId, bool deleteFile) async {
    final task = _activeTransfers.remove(taskId);
    if (task == null) {
      logWarning(
          'P2PTransferService: Task $taskId not found for clear operation');
      return false;
    }

    // Clear file chunks for this task
    _incomingFileChunks.remove(taskId);

    // Clean up temp file if exists
    final tempFilePath = _tempFileChunks.remove(taskId);
    if (tempFilePath != null) {
      _cleanupTempFile(tempFilePath);
    }

    if (deleteFile && !task.isOutgoing && task.savePath != null) {
      try {
        final file = File(task.savePath!);
        if (await file.exists()) {
          await file.delete();
          logInfo(
              'P2PTransferService: Successfully deleted file: ${task.savePath}');
        }
      } catch (e) {
        logError(
            'P2PTransferService: Failed to delete file ${task.savePath}: $e');
      }
    }

    // Trigger memory cleanup
    Future.microtask(() => _cleanupMemory());

    // Remove from DB
    await _deleteTaskFromDbById(taskId);
    notifyListeners();
    return true;
  }

  /// Set callback for new file transfer requests
  void setNewFileTransferRequestCallback(
      Function(FileTransferRequest)? callback) {
    _onNewFileTransferRequest = callback;
  }

  /// Cancel all active transfers
  Future<void> cancelAllTransfers() async {
    for (final taskId in _activeTransfers.keys.toList()) {
      final task = _activeTransfers[taskId];
      if (task != null && task.status == DataTransferStatus.transferring) {
        task.status = DataTransferStatus.cancelled;
        task.errorMessage = 'Transfer cancelled during network stop';
        _cleanupTransfer(taskId);
        await _saveTaskToDb(task);
        if (_transferSettings?.autoCleanupCancelledTasks == true) {
          Timer(
              Duration(
                  seconds: _transferSettings?.autoCleanupDelaySeconds ?? 5),
              () async {
            logDebug(
                '>> Auto cleanup (cancelAllTransfers) scheduled for task: ${task.id}');
            await _autoCleanupTask(taskId, 'cancelled by stop');
          });
        }
      }
    }
  }

  /// Cleanup file picker cache if safe
  Future<void> cleanupFilePickerCacheIfSafe() async {
    try {
      final now = DateTime.now();
      if (_lastFilePickerCleanup != null &&
          now.difference(_lastFilePickerCleanup!) < _cleanupCooldown) {
        return;
      }

      final hasActiveOutgoingTransfers = _activeTransfers.values.any((task) =>
          task.isOutgoing &&
          (task.status == DataTransferStatus.transferring ||
              task.status == DataTransferStatus.waitingForApproval ||
              task.status == DataTransferStatus.pending));

      if (!hasActiveOutgoingTransfers && _activeFileTransferBatches.isEmpty) {
        await FilePicker.platform.clearTemporaryFiles();
        _lastFilePickerCleanup = now;
        logInfo('P2PTransferService: Safely cleaned up file picker cache');
      }
    } catch (e) {
      logWarning('P2PTransferService: Failed to cleanup file picker cache: $e');
    }
  }

  // ECDH Key Exchange Methods

  /// Start key exchange with a user
  Future<bool> startKeyExchange(P2PUser user) async {
    if (_deviceKeyPair == null) {
      logError('P2PTransferService: Device key pair not initialized');
      return false;
    }

    try {
      final message = {
        'type': P2PMessageTypes.keyExchangeRequest,
        'fromUserId': _networkService.currentUser?.id ?? 'unknown',
        'toUserId': user.id,
        'data': {
          'publicKey': base64Encode(_deviceKeyPair!.publicKey),
          'fingerprint': _deviceKeyPair!.publicKeyFingerprint,
          'timestamp': DateTime.now().toIso8601String(),
        },
      };

      final success = await _networkService.sendMessageToUser(user, message);
      if (success) {
        user.keyExchangeStatus = KeyExchangeStatus.requested;
        logInfo(
            'P2PTransferService: Key exchange request sent to ${user.displayName}');
      }

      return success;
    } catch (e) {
      logError(
          'P2PTransferService: Failed to start key exchange with ${user.displayName}: $e');
      return false;
    }
  }

  /// Handle incoming key exchange request
  void _handleKeyExchangeRequest(Map<String, dynamic> messageData) {
    try {
      final fromUserId = messageData['fromUserId'] as String;
      final data = messageData['data'] as Map<String, dynamic>;
      final peerPublicKeyB64 = data['publicKey'] as String;
      final peerFingerprint = data['fingerprint'] as String;

      final peerPublicKey = base64Decode(peerPublicKeyB64);

      // Find user and update their info
      final user = _getUserByIdCallback?.call(fromUserId);
      if (user != null) {
        user.publicKeyFingerprint = peerFingerprint;
        user.keyExchangeStatus = KeyExchangeStatus.exchanging;

        // Create encryption session
        if (_deviceKeyPair != null) {
          final sessionId = ECDHKeyExchangeService.createSession(
              user.id, _deviceKeyPair!, peerPublicKey);
          user.sessionId = sessionId;

          logInfo(
              'P2PTransferService: Created encryption session for ${user.displayName}');

          // Send response with our public key
          _sendKeyExchangeResponse(user);
        }
      }
    } catch (e) {
      logError('P2PTransferService: Failed to handle key exchange request: $e');
    }
  }

  /// Send key exchange response
  Future<void> _sendKeyExchangeResponse(P2PUser user) async {
    if (_deviceKeyPair == null) return;

    try {
      final message = {
        'type': P2PMessageTypes.keyExchangeResponse,
        'fromUserId': _networkService.currentUser?.id ?? 'unknown',
        'toUserId': user.id,
        'data': {
          'publicKey': base64Encode(_deviceKeyPair!.publicKey),
          'fingerprint': _deviceKeyPair!.publicKeyFingerprint,
          'sessionId': user.sessionId,
          'status': 'success',
          'timestamp': DateTime.now().toIso8601String(),
        },
      };

      final success = await _networkService.sendMessageToUser(user, message);
      if (success) {
        user.keyExchangeStatus = KeyExchangeStatus.completed;
        logInfo(
            'P2PTransferService: Key exchange completed with ${user.displayName}');
      }
    } catch (e) {
      logError('P2PTransferService: Failed to send key exchange response: $e');
    }
  }

  /// Handle key exchange response
  void _handleKeyExchangeResponse(Map<String, dynamic> messageData) {
    try {
      final fromUserId = messageData['fromUserId'] as String;
      final data = messageData['data'] as Map<String, dynamic>;
      final peerPublicKeyB64 = data['publicKey'] as String;
      final peerFingerprint = data['fingerprint'] as String;
      final sessionId = data['sessionId'] as String?;

      final peerPublicKey = base64Decode(peerPublicKeyB64);

      // Find user and update their info
      final user = _getUserByIdCallback?.call(fromUserId);
      if (user != null && _deviceKeyPair != null) {
        user.publicKeyFingerprint = peerFingerprint;

        // Create or update encryption session
        final newSessionId = ECDHKeyExchangeService.createSession(
            user.id, _deviceKeyPair!, peerPublicKey);
        user.sessionId = newSessionId;
        user.keyExchangeStatus = KeyExchangeStatus.completed;

        logInfo(
            'P2PTransferService: Key exchange completed with ${user.displayName}');
        logInfo('P2PTransferService: Peer fingerprint: $peerFingerprint');

        notifyListeners();
      }
    } catch (e) {
      logError(
          'P2PTransferService: Failed to handle key exchange response: $e');
    }
  }

  /// Get device's public key fingerprint for UI display
  String? get devicePublicKeyFingerprint =>
      _deviceKeyPair?.publicKeyFingerprint;

  /// Handle encrypted data chunk
  void _handleEncryptedDataChunk(Map<String, dynamic> messageData) {
    try {
      final fromUserId = messageData['fromUserId'] as String;
      final data = messageData['data'] as Map<String, dynamic>;

      final user = _getUserByIdCallback?.call(fromUserId);
      if (user?.sessionId == null) {
        logError(
            'P2PTransferService: No encryption session found for user ${user?.displayName}');
        return;
      }

      // Decrypt the encrypted data
      final encryptedData = ECDHEncryptedData.fromJson(data);
      final decryptedBytes =
          ECDHKeyExchangeService.decryptData(user!.sessionId!, encryptedData);

      if (decryptedBytes != null) {
        // Convert decrypted bytes back to JSON and handle as normal data chunk
        final decryptedJson = utf8.decode(decryptedBytes);
        final decryptedMessageData = jsonDecode(decryptedJson);
        final decryptedMessage = P2PMessage.fromJson(decryptedMessageData);

        logInfo(
            'P2PTransferService: Successfully decrypted data chunk from ${user.displayName}');
        _handleDataChunk(decryptedMessage);
      } else {
        logError(
            'P2PTransferService: Failed to decrypt data chunk from ${user.displayName}');
      }
    } catch (e) {
      logError('P2PTransferService: Error handling encrypted data chunk: $e');
    }
  }

  // Private methods

  void _handleTcpMessage(Socket socket, Uint8List messageBytes) {
    try {
      final jsonString = utf8.decode(messageBytes);
      final messageData = jsonDecode(jsonString);
      final message = P2PMessage.fromJson(messageData);

      // @DebugLog Only log non-chunk messages to reduce overhead
      // if (message.type != P2PMessageTypes.dataChunk) {
      //   logInfo(
      //       'P2PTransferService: Received ${message.type} from ${message.fromUserId}');
      // }

      // Drop any signals from blocked users
      final fromUser = _getTargetUser(message.fromUserId);
      if (fromUser?.isBlocked == true) {
        logWarning(
            'P2PTransferService: Ignoring ${message.type} from blocked user ${fromUser!.displayName}');
        return;
      }

      // Associate socket with user ID
      if (!_networkService.connectedSockets.containsKey(message.fromUserId)) {
        _networkService.associateSocketWithUser(message.fromUserId, socket);
      }

      switch (message.type) {
        case P2PMessageTypes.keyExchangeRequest:
          _handleKeyExchangeRequest(messageData);
          break;
        case P2PMessageTypes.keyExchangeResponse:
          _handleKeyExchangeResponse(messageData);
          break;
        case P2PMessageTypes.dataChunk:
          _handleDataChunk(message);
          break;
        case P2PMessageTypes.encryptedDataChunk:
          _handleEncryptedDataChunk(messageData);
          break;
        case P2PMessageTypes.dataTransferCancel:
          _handleDataTransferCancel(message);
          break;
        case P2PMessageTypes.fileTransferRequest:
          _handleFileTransferRequest(message);
          break;
        case P2PMessageTypes.fileTransferResponse:
          _handleFileTransferResponse(message);
          break;
        case P2PMessageTypes.sendChatMessage:
          _networkService.handleIncomingChatMessage(message.data);
          break;
        case P2PMessageTypes.chatRequestFileBackward:
          _handleFileCheckAndTransferBackwardRequest(message);
          break;
        case P2PMessageTypes.chatRequestFileLost:
          _handleChatResponseLost(message);
          break;
        default:
          // Forward other message types to discovery service via callback
          if (_onOtherMessageReceived != null) {
            _onOtherMessageReceived!(message, socket);
          }
          break;
      }
    } catch (e) {
      logError('P2PTransferService: Failed to process TCP message: $e');
    }
  }

  Future<void> _handleFileTransferRequest(P2PMessage message) async {
    try {
      final request = FileTransferRequest.fromJson(message.data);
      request.receivedTime = DateTime.now();

      logInfo(
          'P2PTransferService: Received file transfer request from ${request.fromUserName} '
          '(Encryption: ${request.useEncryption ? "enabled" : "disabled"})');

      // If sender uses encryption, generate/get session key
      if (request.useEncryption) {
        _getOrCreateSessionKey(request.fromUserId);
        logInfo(
            'P2PTransferService: Session key prepared for encrypted transfer');
      }

      // Validate sender and block state
      final fromUser = _getTargetUser(request.fromUserId);
      if (fromUser == null || fromUser.isBlocked || !fromUser.isPaired) {
        await _sendFileTransferResponse(request, false,
            FileTransferRejectReason.unknown, 'User not paired');
        return;
      }

      // Validate request
      final validationResult =
          await _validateFileTransferRequest(request, fromUser);
      if (!validationResult.isValid) {
        await _sendFileTransferResponse(request, false,
            validationResult.rejectReason!, validationResult.rejectMessage!);
        await _safeNotificationCall(() => P2PNotificationService.instance
            .cancelNotification(request.requestId.hashCode));
        return;
      }

      // Auto-accept for trusted users
      if (fromUser.isTrusted) {
        logInfo(
            'P2PTransferService: Auto-accepting from trusted user: ${fromUser.displayName}');
        _fileTransferRequestTimers[request.requestId]?.cancel();
        _fileTransferRequestTimers.remove(request.requestId);
        await _acceptFileTransferRequest(request);
        return;
      }

      // Show notification for non-trusted users
      await _safeNotificationCall(
          () => P2PNotificationService.instance.showFileTransferRequest(
                request: request,
                enableActions: true,
              ));

      // Add to pending requests
      _pendingFileTransferRequests.add(request);
      await _saveFileTransferRequest(request);
      notifyListeners();

      // Trigger callback
      if (_onNewFileTransferRequest != null) {
        _onNewFileTransferRequest!(request);
      }

      // Set timeout timer
      _fileTransferRequestTimers[request.requestId] =
          Timer(const Duration(seconds: 60), () {
        _handleFileTransferRequestTimeout(request.requestId);
      });
    } catch (e) {
      logError(
          'P2PTransferService: Failed to handle file transfer request: $e');
    }
  }

  Future<void> _handleFileTransferResponse(P2PMessage message) async {
    try {
      final response = FileTransferResponse.fromJson(message.data);

      // Cancel timeout timer
      _fileTransferResponseTimers[response.requestId]?.cancel();
      _fileTransferResponseTimers.remove(response.requestId);

      // Find tasks for this batch
      final batchTasks = _activeTransfers.values
          .where((task) => task.batchId == response.batchId && task.isOutgoing)
          .toList();

      if (response.accepted) {
        logInfo(
            'P2PTransferService: File transfer accepted for batch ${response.batchId}');

        // Store the received session key if available
        if (response.sessionKeyBase64 != null) {
          final sessionKey = base64Decode(response.sessionKeyBase64!);
          _sessionKeys[message.fromUserId] = sessionKey;
          logInfo(
              'P2PTransferService: Received and stored session key from user ${message.fromUserId}');
        }

        await _startTransfersWithConcurrencyLimit(batchTasks);
      } else {
        logInfo(
            'P2PTransferService: File transfer rejected: ${response.rejectMessage}');
        for (final task in batchTasks) {
          task.status = DataTransferStatus.rejected;
          task.errorMessage = response.rejectMessage ?? 'Transfer rejected';
          _cleanupTransfer(task.id);
          // Only auto-cleanup on sender side for cancelled/rejected tasks
          if (_transferSettings?.autoCleanupCancelledTasks == true) {
            Timer(
                Duration(
                    seconds: _transferSettings?.autoCleanupDelaySeconds ?? 5),
                () async {
              logDebug(
                  '>> Auto cleanup (rejected) scheduled for task: ${task.id}');
              await _autoCleanupTask(task.id, 'rejected');
            });
          }
        }
      }

      notifyListeners();
    } catch (e) {
      logError(
          'P2PTransferService: Failed to handle file transfer response: $e');
    }
  }

  Future<void> _handleDataChunk(P2PMessage message) async {
    final data = message.data;
    final taskId = data['taskId'] as String?;
    final isLast = data['isLast'] as bool? ?? false;

    if (taskId == null) {
      logError('P2PTransferService: Invalid data chunk - no taskId');
      return;
    }

    // Bootstrap task early so UI can render immediately
    DataTransferTask? task = await _getOrCreateTask(taskId, message, data);
    if (task == null) {
      logError('P2PTransferService: Could not get or create task for $taskId');
      return;
    }

    // Start background receiver isolate per task on first chunk
    if (!_rxReceiverPorts.containsKey(taskId)) {
      final rxPort = ReceivePort();
      final iso = await Isolate.spawn(_rxReceiverIsolateEntry, {
        'sendPort': rxPort.sendPort,
        'task': task.toJson(),
        'downloadPath': _transferSettings?.downloadPath,
        'createSenderFolders': _transferSettings?.createSenderFolders ?? false,
        'senderName': task.targetUserName,
      });

      final completer = Completer<SendPort>();
      rxPort.listen((msg) async {
        if (msg is SendPort) {
          completer.complete(msg);
          return;
        }
        if (msg is Map<String, dynamic>) {
          final type = msg['type'];
          if (type == 'progress') {
            final inc = msg['inc'] as int? ?? 0;
            task.transferredBytes += inc;
            if (task.status != DataTransferStatus.transferring) {
              task.status = DataTransferStatus.transferring;
              task.startedAt ??= DateTime.now();
            }
            _scheduleUIUpdate(task);
          } else if (type == 'completed') {
            task.status = DataTransferStatus.completed;
            task.completedAt = DateTime.now();
            task.filePath = msg['filePath'] as String? ?? task.filePath;
            task.savePath = task.filePath;
            await _saveTaskToDb(task);
            _scheduleUIUpdate(task);
            _rxReceiverIsolates.remove(taskId)?.kill();
            _rxReceiverPorts.remove(taskId);
          } else if (type == 'error') {
            task.status = DataTransferStatus.failed;
            task.errorMessage = msg['message'] as String?;
            await _saveTaskToDb(task);
            _scheduleUIUpdate(task);
            _rxReceiverIsolates.remove(taskId)?.kill();
            _rxReceiverPorts.remove(taskId);
          }
        }
      });

      final sp = await completer.future;
      _rxReceiverIsolates[taskId] = iso;
      _rxReceiverPorts[taskId] = sp;
    }

    try {
      // Send raw chunk payload to receiver isolate (it will decode/decrypt/write)
      // Determine encryption type and session info
      final legacySessionKey = _sessionKeys[message.fromUserId];
      final senderUser = _getUserByIdCallback?.call(message.fromUserId);
      final ecdhSessionId = senderUser?.sessionId;

      _rxReceiverPorts[taskId]!.send({
        'taskId': taskId,
        'data': data,
        'fromUserId': message.fromUserId,
        'isLast': isLast,
        'encryptionSession': legacySessionKey, // Legacy session key
        'ecdhSessionId': ecdhSessionId, // ECDH session ID
        'encryptionType': _transferSettings?.encryptionType?.name,
      });
    } catch (e) {
      logError('P2PTransferService: Failed to forward chunk to RX isolate: $e');
    }
  }

  /// Receiver isolate entry - offloads base64 decode, decrypt and disk I/O
  static void _rxReceiverIsolateEntry(Map<String, dynamic> args) async {
    final sendPort = args['sendPort'] as SendPort;
    final task = DataTransferTask.fromJson(args['task']);
    final downloadPathArg = args['downloadPath'] as String?;
    final createSenderFolders = args['createSenderFolders'] as bool? ?? false;
    final senderName = args['senderName'] as String? ?? 'Unknown';

    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    // Resolve download path
    String downloadPath = downloadPathArg ??
        (Platform.isWindows
            ? '${Platform.environment['USERPROFILE']}\\Downloads'
            : '${Platform.environment['HOME']}/Downloads');
    if (createSenderFolders) {
      final sanitized = senderName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      downloadPath = '$downloadPath${Platform.pathSeparator}$sanitized';
    }
    final dir = Directory(downloadPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Prepare unique file name
    String fileName = task.fileName;
    String filePath = '$downloadPath${Platform.pathSeparator}$fileName';
    int counter = 1;
    while (await File(filePath).exists()) {
      final p = fileName.split('.');
      if (p.length > 1) {
        final base = p.sublist(0, p.length - 1).join('.');
        final ext = p.last;
        fileName = '${base}_$counter.$ext';
      } else {
        fileName = '${fileName}_$counter';
      }
      filePath = '$downloadPath${Platform.pathSeparator}$fileName';
      counter++;
    }

    final file = File(filePath);
    final sink = file.openWrite(mode: FileMode.writeOnlyAppend);

    await for (final msg in receivePort) {
      if (msg is! Map<String, dynamic>) continue;
      final isLast = msg['isLast'] as bool? ?? false;
      final data = msg['data'] as Map<String, dynamic>;
      final sessionKey = msg['encryptionSession'] as Uint8List?;
      final ecdhSessionId = msg['ecdhSessionId'] as String?;
      final encryptionTypeName = msg['encryptionType'] as String?;

      try {
        Uint8List? chunkData;
        // Decode/decrypt similar to main isolate, but here offloaded
        if (data['enc'] == 'gcm') {
          final ct = data['ct'] as String?;
          final iv = data['iv'] as String?;
          final tag = data['tag'] as String?;
          if (ct != null && iv != null && tag != null && sessionKey != null) {
            chunkData = EncryptionService.decryptGCM({
              'ciphertext': base64Decode(ct),
              'iv': base64Decode(iv),
              'tag': base64Decode(tag),
            }, sessionKey);
          }
        } else if (data['enc'] == 'aes-gcm' ||
            data['enc'] == 'chacha20-poly1305' ||
            data['enc'] == 'aes-gcm-ecdh' ||
            data['enc'] == 'chacha20-poly1305-ecdh') {
          // Determine encryption type and source
          final isECDHEncryption = data['enc']?.endsWith('-ecdh') == true;
          final isAESGCM =
              data['enc'] == 'aes-gcm' || data['enc'] == 'aes-gcm-ecdh';

          // Get decryption key
          Uint8List? decryptionKey;
          if (isECDHEncryption && ecdhSessionId != null) {
            // ECDH path: get shared secret
            decryptionKey =
                ECDHKeyExchangeService.getSharedSecret(ecdhSessionId);
          } else {
            // Legacy path: use session key
            decryptionKey = sessionKey;
          }

          if (decryptionKey != null) {
            if (isECDHEncryption) {
              // Use simplified decryption for ECDH encryption
              chunkData = _decryptChunkSimple(data, decryptionKey, isAESGCM);
            } else {
              // Use advanced CryptoService for legacy encryption
              final encType =
                  isAESGCM ? EncryptionType.aesGcm : EncryptionType.chaCha20;
              final encrypted = <String, Uint8List>{
                'ciphertext': base64Decode(data['ct'] as String),
              };
              if (isAESGCM) {
                encrypted['iv'] = base64Decode(data['iv'] as String);
                encrypted['tag'] = base64Decode(data['tag'] as String);
              } else {
                encrypted['nonce'] = base64Decode(data['nonce'] as String);
                encrypted['tag'] = base64Decode(data['tag'] as String);
              }
              chunkData = await CryptoService.decrypt(
                  encrypted, decryptionKey, encType);
            }
          }
        } else {
          final dataBase64 = data['data'] as String?;
          if (dataBase64 != null) chunkData = base64Decode(dataBase64);
        }

        if (chunkData == null) {
          sendPort.send({'type': 'error', 'message': 'Failed to decode chunk'});
          continue;
        }

        // Write to disk streaming
        sink.add(chunkData);
        sendPort.send({'type': 'progress', 'inc': chunkData.length});

        if (isLast) {
          await sink.flush();
          await sink.close();
          sendPort.send({'type': 'completed', 'filePath': filePath});
        }
      } catch (e) {
        try {
          await sink.flush();
          await sink.close();
        } catch (_) {}
        sendPort.send({'type': 'error', 'message': e.toString()});
      }
    }
  }

  Future<void> _handleDataTransferCancel(P2PMessage message) async {
    final data = message.data;
    final taskId = data['taskId'] as String?;

    if (taskId == null) {
      logError('P2PTransferService: Invalid cancel message - missing taskId');
      return;
    }

    logInfo('P2PTransferService: Data transfer cancelled for task $taskId');

    // Clean up receiving data and temp files
    _incomingFileChunks.remove(taskId);
    final tempFilePath = _tempFileChunks.remove(taskId);
    if (tempFilePath != null) {
      _cleanupTempFile(tempFilePath);
    }

    // Update task status if it exists
    final task = _activeTransfers[taskId];
    if (task != null) {
      task.status = DataTransferStatus.cancelled;
      task.errorMessage = 'Transfer cancelled by sender';
      _cleanupTransfer(taskId);
      await _saveTaskToDb(task);
      notifyListeners();
      // Only auto-cleanup on receiver side? Requirement says: cancelled -> cleanup on sender.
      // So do NOT auto-cleanup here (receiver side). Let sender side handle cleanup.
    }
  }

  Future<DataTransferTask?> _getOrCreateTask(
      String taskId, P2PMessage message, Map<String, dynamic> data) async {
    // Check if task already exists
    DataTransferTask? task = _activeTransfers[taskId];
    if (task != null) {
      logDebug('Get or create task: Found existing task for taskId=$taskId');
      return task;
    }

    // Check if another thread is creating this task
    Completer<DataTransferTask?>? existingLock = _taskCreationLocks[taskId];
    if (existingLock != null) {
      logDebug(
          'Get or create task: Waiting for existing lock for taskId=$taskId');
      return await existingLock.future;
    }

    // Create lock for this task creation
    final completer = Completer<DataTransferTask?>();
    _taskCreationLocks[taskId] = completer;

    try {
      // Double-check pattern
      task = _activeTransfers[taskId];
      if (task != null) {
        logDebug(
            'Get or create task: Found existing task after double-check for taskId=$taskId');
        completer.complete(task);
        return task;
      }

      // Extract metadata for first chunk
      final fileName = data['fileName'] as String?;
      final fileSize = data['fileSize'] as int?;

      if (fileName != null && fileSize != null) {
        logDebug(
            'Get or create task: Creating new task for file $fileName, taskId=$taskId');
        // Get batchId for this incoming transfer
        final batchId = _activeBatchIdsByUser[message.fromUserId];

        // Get sender's display name from lookup callback or FileTransferRequest
        String senderName = 'Unknown User';
        final fromUser = _getTargetUser(message.fromUserId);
        if (fromUser != null && fromUser.displayName.isNotEmpty) {
          senderName = fromUser.displayName;
        } else {
          for (final request in _pendingFileTransferRequests) {
            if (request.fromUserId == message.fromUserId &&
                request.fromUserName.isNotEmpty) {
              senderName = request.fromUserName;
              break;
            }
          }
        }

        // Tự động lấy toàn bộ metadata từ payload chunk đầu tiên, trừ các trường mặc định
        final excludeKeys = [
          'fileName',
          'fileSize',
          'taskId',
          'data',
          'isLast',
          'ct',
          'iv',
          'tag',
          'nonce',
          'enc'
        ];
        Map<String, dynamic> metadata = {};
        data.forEach((key, value) {
          if (!excludeKeys.contains(key)) {
            metadata[key] = value;
          }
        });
        // Nếu có messageId thì lưu lại cho _receivedFileMessageIds
        if (metadata.containsKey('messageId')) {
          _receivedFileMessageIds[taskId] = metadata['messageId'];
        }
        logDebug(
            '[P2PTransferService] Received metadata from sender: $metadata for taskId=$taskId');

        task = DataTransferTask(
          id: taskId,
          fileName: fileName,
          filePath: fileName, // Set initial filePath to fileName
          fileSize: fileSize,
          targetUserId: message.fromUserId,
          targetUserName: senderName,
          status: DataTransferStatus.transferring,
          isOutgoing: false,
          createdAt: DateTime.now(),
          startedAt: DateTime.now(),
          batchId: batchId,
          data: metadata.isNotEmpty ? metadata : null,
        );

        _activeTransfers[taskId] = task;
        await _saveTaskToDb(task);

        // 🚀 Immediate UI update when task is created
        _scheduleUIUpdate(task);

        // Process buffered chunks
        final bufferedChunks = _pendingChunks.remove(taskId);
        if (bufferedChunks != null && bufferedChunks.isNotEmpty) {
          for (final bufferedChunk in bufferedChunks) {
            final chunkData = bufferedChunk['chunkData'] as Uint8List;
            final isLast = bufferedChunk['isLast'] as bool;

            _incomingFileChunks.putIfAbsent(taskId, () => []);
            _incomingFileChunks[taskId]!.add(chunkData);
            task.transferredBytes += chunkData.length;

            if (task.transferredBytes > task.fileSize) {
              task.transferredBytes = task.fileSize;
            }

            if (isLast) {
              Future.microtask(() => _assembleReceivedFile(taskId: taskId));
            }
          }
          _scheduleUIUpdate(task);
        }

        completer.complete(task);
        return task;
      } else {
        completer.complete(null);
        return null;
      }
    } catch (e) {
      logError('P2PTransferService: Failed to create task $taskId: $e');
      completer.complete(null);
      return null;
    } finally {
      _taskCreationLocks.remove(taskId);
    }
  }

  Future<void> _assembleReceivedFile(
      {required String taskId, Map<String, dynamic>? metaData}) async {
    // Wait for any existing file assembly to complete for this task
    final existingLock = _fileAssemblyLocks[taskId];
    if (existingLock != null) {
      await existingLock.future;
      return; // Assembly already completed
    }

    // Create lock for this file assembly
    final assemblyCompleter = Completer<void>();
    _fileAssemblyLocks[taskId] = assemblyCompleter;

    try {
      final chunks = _incomingFileChunks[taskId];
      final task = _activeTransfers[taskId];

      if (chunks == null || task == null) {
        logError('P2PTransferService: Missing chunks or task for $taskId');
        return;
      }

      logInfo(
          'P2PTransferService: Receive task ${task.id} with data: ${task.data.toString()}');

      final fileName = _sanitizeFileName(task.fileName);
      final expectedFileSize = task.fileSize;

      // Get download path
      String downloadPath;
      if (task.batchId != null &&
          _batchDownloadPaths.containsKey(task.batchId)) {
        downloadPath = _batchDownloadPaths[task.batchId]!;
      } else if (_transferSettings != null) {
        downloadPath = _transferSettings!.downloadPath;
      } else {
        downloadPath = Platform.isWindows
            ? '${Platform.environment['USERPROFILE']}\\Downloads'
            : '${Platform.environment['HOME']}/Downloads';
      }

      // Create directory
      final downloadDir = Directory(downloadPath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Generate unique filename
      String finalFileName = fileName;
      String filePath = '$downloadPath${Platform.pathSeparator}$finalFileName';
      int counter = 1;

      while (await File(filePath).exists()) {
        final fileNameParts = fileName.split('.');
        if (fileNameParts.length > 1) {
          final baseName =
              fileNameParts.sublist(0, fileNameParts.length - 1).join('.');
          final extension = fileNameParts.last;
          finalFileName = '${baseName}_$counter.$extension';
        } else {
          finalFileName = '${fileName}_$counter';
        }
        filePath = '$downloadPath${Platform.pathSeparator}$finalFileName';
        counter++;
      }

      // Assemble file data using streaming to avoid memory issues with large files
      final file = File(filePath);
      final fileSink = file.openWrite();
      int actualFileSize = 0;

      try {
        // First, copy data from temp file if it exists
        final tempFilePath = _tempFileChunks[taskId];
        if (tempFilePath != null) {
          final tempFile = File(tempFilePath);
          if (await tempFile.exists()) {
            // Use synchronous reading to ensure proper order
            final tempBytes = await tempFile.readAsBytes();
            fileSink.add(tempBytes);
            actualFileSize += tempBytes.length;
            logDebug(
                'P2PTransferService: Added ${tempBytes.length} bytes from temp file for task $taskId');
          }
        }

        // Then write remaining chunks from memory
        for (final chunk in chunks) {
          if (chunk.isNotEmpty) {
            fileSink.add(chunk);
            actualFileSize += chunk.length;
          }
        }

        // Ensure all data is written to disk
        await fileSink.flush();
        await fileSink.close();

        // Clean up temp file
        if (tempFilePath != null) {
          final tempFile = File(tempFilePath);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
          _tempFileChunks.remove(taskId);
        }

        // Verify file size
        if (actualFileSize != expectedFileSize) {
          logError(
              'P2PTransferService: File size mismatch for $fileName: expected $expectedFileSize, got $actualFileSize');
          task.transferredBytes = actualFileSize;
        }
      } catch (writeError) {
        await fileSink.close();
        // Clean up partial file on write error
        if (await file.exists()) {
          await file.delete();
        }
        // Clean up temp file
        final tempFilePath = _tempFileChunks.remove(taskId);
        if (tempFilePath != null) {
          final tempFile = File(tempFilePath);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
        throw Exception('Failed to write file: $writeError');
      }

      // Update task to completed state
      task.status = DataTransferStatus.completed;
      task.completedAt = DateTime.now();
      task.filePath = filePath;
      task.savePath = filePath;
      task.transferredBytes = actualFileSize;

      logDebug('Check data transfer task: ${task.data}');

      // Persist task update to DB
      await _saveTaskToDb(task);

      // Auto-cleanup for completed task only on receiver side (task.isOutgoing == false)
      if (!task.isOutgoing &&
          _transferSettings?.autoCleanupCompletedTasks == true) {
        Timer(
            Duration(seconds: _transferSettings?.autoCleanupDelaySeconds ?? 5),
            () async {
          logDebug(
              '>> Auto cleanup (completed, receiver) scheduled for task: ${task.id}');
          await _autoCleanupTask(taskId, 'completed');
        });
      }

      logInfo('>>>>>>>>> Task data after assembly: ${task.data.toString()}');

      // Chỉ cập nhật filePath trong Isar nếu có syncFilePath (tức là đồng bộ đường dẫn file)
      if (task.data?.containsKey(DataTransferKey.syncFilePath.name) ?? false) {
        try {
          /// Block code 2
          final String userId = metaData!['userId'] as String;

          _chatService.updateFilePathAndNotify(
              userBId: userId, filePath: filePath);
        } catch (e) {
          logError('P2PTransferService: Failed to update filePath in Isar: $e');
        }
      }

      // Update isar if fileSyncResponse is present
      if (task.data?.containsKey(DataTransferKey.fileSyncResponse.name) ??
          false) {
        logInfo(
            'P2PTransferService: Updating message status in Isar for task $taskId');
        try {
          final userId = task.data!['userId'] as String;
          final syncId = task.data![DataTransferKey.fileSyncResponse.name];

          _chatService.updateFileSyncResponseAndNotify(
              userBId: userId, syncId: syncId, filePath: filePath);
          logInfo(
              'P2PTransferService: Updated message status in Isar for syncId: $syncId');

          // For file sync response, immediately clean up the transfer task
          // since it's a background re-sync operation that shouldn't persist in UI
          Timer(const Duration(seconds: 2), () async {
            logDebug(
                '>> Call auto cleanup from Contain key fileSyncResponse for failed task: ${task.id}');

            await _autoCleanupTask(taskId, 'file sync response completed');
          });
        } catch (e) {
          logError(
              'P2PTransferService: Failed to update message status in Isar: $e');
        }
      }

      // Show completion notification
      await _safeNotificationCall(
          () => P2PNotificationService.instance.showFileTransferCompleted(
                task: task,
                success: true,
              ));

      // Clean up chunks from memory immediately after writing to save memory
      _incomingFileChunks.remove(taskId);

      // Clean up batch data if this was the last file
      if (task.batchId != null) {
        final totalFilesInBatch = _batchFileCounts[task.batchId] ?? 0;
        await Future.delayed(const Duration(milliseconds: 100));

        final completedInBatch = _activeTransfers.values
            .where((t) =>
                t.batchId == task.batchId &&
                !t.isOutgoing &&
                t.status == DataTransferStatus.completed)
            .length;

        if (totalFilesInBatch > 0 && completedInBatch >= totalFilesInBatch) {
          logInfo(
              'P2PTransferService: Batch ${task.batchId} complete. Cleaning up resources.');
          _batchDownloadPaths.remove(task.batchId);
          _batchFileCounts.remove(task.batchId);

          final userToRemove = _activeBatchIdsByUser.entries
              .firstWhere((entry) => entry.value == task.batchId,
                  orElse: () => const MapEntry('', ''))
              .key;

          if (userToRemove.isNotEmpty) {
            _activeBatchIdsByUser.remove(userToRemove);
          }
        }
      }

      // Trigger aggressive garbage collection for large files to free memory
      if (actualFileSize > 50 * 1024 * 1024) {
        // Files larger than 50MB
        Future.microtask(() async {
          await _cleanupMemory();
          // Force garbage collection hint for Dart VM
          if (kDebugMode) {
            logInfo(
                'P2PTransferService: Large file ($actualFileSize bytes) completed, suggesting GC');
          }
        });
      }

      notifyListeners();
      logInfo('P2PTransferService: File transfer completed: $finalFileName');
    } catch (e) {
      logError(
          'P2PTransferService: Failed to assemble received file for task $taskId: $e');
      _incomingFileChunks.remove(taskId);
      // Clean up temp file if exists
      final tempFilePath = _tempFileChunks.remove(taskId);
      if (tempFilePath != null) {
        try {
          final tempFile = File(tempFilePath);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (e) {
          logWarning('Failed to clean up temp file: $e');
        }
      }
      // Mark task as failed to avoid stuck in "transferring" state
      final failedTask = _activeTransfers[taskId];
      if (failedTask != null) {
        failedTask.status = DataTransferStatus.failed;
        failedTask.errorMessage = 'Assemble failed: $e';
        await _saveTaskToDb(failedTask);
        await _safeNotificationCall(() => P2PNotificationService.instance
            .showFileTransferCompleted(
                task: failedTask, success: false, errorMessage: '$e'));
        notifyListeners();
      }
    } finally {
      // Release file assembly lock
      assemblyCompleter.complete();
      _fileAssemblyLocks.remove(taskId);
    }
  }

  /// Flush accumulated chunks to a temporary file to reduce memory usage
  Future<void> _flushChunksToTempFile(String taskId) async {
    final chunks = _incomingFileChunks[taskId];
    if (chunks == null || chunks.isEmpty) return;

    try {
      // Create temp file path
      final tempDir = await getTemporaryDirectory();
      final tempFilePath =
          '${tempDir.path}${Platform.pathSeparator}p2p_temp_$taskId.tmp';
      _tempFileChunks[taskId] = tempFilePath;

      // Write chunks to temp file
      final tempFile = File(tempFilePath);
      final tempSink = tempFile.openWrite(mode: FileMode.append);

      for (final chunk in chunks) {
        tempSink.add(chunk);
      }

      await tempSink.flush();
      await tempSink.close();

      // Clear chunks from memory
      _incomingFileChunks[taskId]!.clear();

      logDebug(
          'P2PTransferService: Flushed ${chunks.length} chunks to temp file for task $taskId');
    } catch (e) {
      logError(
          'P2PTransferService: Failed to flush chunks to temp file for task $taskId: $e');
    }
  }

  /// Clean up temporary file
  void _cleanupTempFile(String tempFilePath) {
    Future.microtask(() async {
      try {
        final tempFile = File(tempFilePath);
        if (await tempFile.exists()) {
          await tempFile.delete();
          logDebug('P2PTransferService: Cleaned up temp file: $tempFilePath');
        }
      } catch (e) {
        logWarning('P2PTransferService: Failed to clean up temp file: $e');
      }
    });
  }

  Future<void> _startTransfersWithConcurrencyLimit(
      List<DataTransferTask> tasks) async {
    final limit = _transferSettings?.maxConcurrentTasks ?? 3;

    logInfo(
        'P2PTransferService: Starting transfers with concurrency limit: $limit');

    // Set all tasks to pending status first
    for (final task in tasks) {
      if (task.status == DataTransferStatus.waitingForApproval) {
        task.status = DataTransferStatus.pending;
      }
    }

    // Start initial batch
    await _startNextAvailableTransfers();
  }

  Future<void> _startNextAvailableTransfers() async {
    final maxConcurrent = _transferSettings?.maxConcurrentTasks ?? 3;

    final currentlyRunning = _activeTransfers.values
        .where(
            (t) => t.isOutgoing && t.status == DataTransferStatus.transferring)
        .length;

    final availableSlots = maxConcurrent - currentlyRunning;
    if (availableSlots <= 0) return;

    final pendingTasks = _activeTransfers.values
        .where((t) => t.isOutgoing && t.status == DataTransferStatus.pending)
        .take(availableSlots)
        .toList();

    for (final task in pendingTasks) {
      final targetUser = _getTargetUser(task.targetUserId);
      if (targetUser != null) {
        task.status = DataTransferStatus.transferring;
        task.startedAt = DateTime.now();
        await _startDataTransfer(task, targetUser);
      }
    }

    if (pendingTasks.isNotEmpty) {
      notifyListeners();
    }
  }

  Future<void> _startDataTransfer(
      DataTransferTask task, P2PUser targetUser) async {
    try {
      final chunkSizeKB = _transferSettings?.maxChunkSize ?? 512;
      final chunkSizeBytes = chunkSizeKB * 1024;

      // Create isolate for data transfer
      final receivePort = ReceivePort();
      _transferPorts[task.id] = receivePort;

      // Check if encryption is enabled for this transfer (sender's settings)
      final encryptionType =
          _transferSettings?.encryptionType ?? EncryptionType.none;
      final useEncryption = encryptionType != EncryptionType.none;

      // Get session key for encryption (simple approach like old logic)
      final sessionKey = useEncryption ? _getSessionKey(targetUser.id) : null;

      final isolate = await Isolate.spawn(
        _staticDataTransferIsolate,
        {
          'sendPort': receivePort.sendPort,
          'task': task.toJson(),
          'targetUser': targetUser.toJson(),
          'currentUserId': _networkService.currentUser!.id,
          'maxChunkSize': chunkSizeBytes,
          'protocol': 'tcp',
          'useEncryption': useEncryption,
          'encryptionType': encryptionType.name,
          'sessionKey': sessionKey != null ? base64Encode(sessionKey) : null,
        },
      );

      _transferIsolates[task.id] = isolate;

      // Listen for progress updates
      receivePort.listen((data) async {
        if (data is Map<String, dynamic>) {
          final progress = data['progress'] as double?;
          final completed = data['completed'] as bool? ?? false;
          final error = data['error'] as String?;

          if (progress != null) {
            // Prefer absolute bytes if provided by isolate
            final transferredBytes = data['transferredBytes'] as int?;
            if (transferredBytes != null) {
              task.transferredBytes = transferredBytes;
            } else {
              task.transferredBytes = (task.fileSize * progress).round();
            }

            // 🚀 Use smart UI refresh system for sender progress (more frequent)
            _scheduleUIUpdate(task);

            // Show progress notification - 🚀 Less frequent for performance
            if (_transferSettings?.enableNotifications == true) {
              final progressPercent = (progress * 100).round();
              // Show notification at 20% intervals or important milestones
              if (progressPercent == 0 ||
                  progressPercent % 20 == 0 ||
                  progressPercent > 95) {
                await _safeNotificationCall(() =>
                    P2PNotificationService.instance.showFileTransferStatus(
                      task: task,
                      progress: progressPercent,
                    ));
              }
            }
          }

          if (completed) {
            task.status = DataTransferStatus.completed;
            task.completedAt = DateTime.now();

            await _safeNotificationCall(() => P2PNotificationService.instance
                .cancelFileTransferStatus(task.id));
            await _safeNotificationCall(
                () => P2PNotificationService.instance.showFileTransferCompleted(
                      task: task,
                      success: true,
                    ));

            _cleanupTransfer(task.id);
            await _saveTaskToDb(task);
            // Ensure UI reflects completion immediately
            _scheduleUIUpdate(task);
            // Only auto-cleanup on receiver side for completed tasks
            if (!task.isOutgoing &&
                _transferSettings?.autoCleanupCompletedTasks == true) {
              Timer(
                  Duration(
                      seconds: _transferSettings?.autoCleanupDelaySeconds ?? 5),
                  () async {
                logDebug(
                    '>> Auto cleanup (completed, receiver) scheduled for task: ${task.id}');
                await _autoCleanupTask(task.id, 'completed');
              });
            }
          } else if (error != null) {
            task.status = DataTransferStatus.failed;
            task.errorMessage = error;

            // Auto-cleanup failed task after a delay
            if (_transferSettings?.autoCleanupFailedTasks == true) {
              Timer(
                  Duration(
                      seconds: _transferSettings?.autoCleanupDelaySeconds ??
                          10), () async {
                logDebug(
                    '>> Call auto cleanup from autoCleanupFailedTasks == true for failed task: ${task.id}');

                await _autoCleanupTask(task.id, 'failed');
              });
            }

            await _safeNotificationCall(() => P2PNotificationService.instance
                .cancelFileTransferStatus(task.id));
            await _safeNotificationCall(
                () => P2PNotificationService.instance.showFileTransferCompleted(
                      task: task,
                      success: false,
                      errorMessage: error,
                    ));

            _cleanupTransfer(task.id);
            await _saveTaskToDb(task);
            // Ensure UI reflects failure immediately
            _scheduleUIUpdate(task);
            // Only auto-cleanup on sender side for failed tasks
            if (task.isOutgoing &&
                _transferSettings?.autoCleanupFailedTasks == true) {
              Timer(
                  Duration(
                      seconds: _transferSettings?.autoCleanupDelaySeconds ??
                          10), () async {
                logDebug(
                    '>> Auto cleanup (failed, sender) scheduled for task: ${task.id}');
                await _autoCleanupTask(task.id, 'failed');
              });
            }
          }

          // Avoid chatty notify; rely on scheduled UI updates
        }
      });

      notifyListeners();
    } catch (e) {
      task.status = DataTransferStatus.failed;
      task.errorMessage = e.toString();

      // Auto-cleanup failed task after a delay
      if (_transferSettings?.autoCleanupFailedTasks == true) {
        Timer(
            Duration(seconds: _transferSettings?.autoCleanupDelaySeconds ?? 10),
            () async {
          logDebug(
              '>> Call auto cleanup from autoCleanupFailedTasks == true for failed task: ${task.id}');
          await _autoCleanupTask(task.id, 'failed');
        });
      }

      logError('P2PTransferService: Failed to start data transfer: $e');
      notifyListeners();
    }
  }

  /// 🚀 Async chunk sender for pipelining
  static Future<void> _sendChunkAsync({
    required Uint8List chunk,
    required String taskId,
    required int totalSent,
    required int currentChunkSize,
    required int totalBytes,
    required bool isFirstChunk,
    required DataTransferTask task,
    required String currentUserId,
    required P2PUser targetUser,
    required Socket? tcpSocket,
    required RawDatagramSocket? udpSocket,
    required String protocol,
    required Map<String, dynamic> params,
    required SendPort sendPort,
  }) async {
    Map<String, dynamic> dataPayload;

    // Simple encryption check like old logic
    final useEncryption = params['useEncryption'] as bool? ?? false;
    final encryptionTypeName = params['encryptionType'] as String? ?? 'none';
    final sessionKeyBase64 = params['sessionKey'] as String?;

    if (useEncryption && sessionKeyBase64 != null) {
      try {
        final sessionKey = base64Decode(sessionKeyBase64);

        // Determine encryption type
        EncryptionType encryptionType;
        switch (encryptionTypeName) {
          case 'aesGcm':
            encryptionType = EncryptionType.aesGcm;
            break;
          case 'chaCha20':
            encryptionType = EncryptionType.chaCha20;
            break;
          default:
            encryptionType = EncryptionType.none;
        }

        if (encryptionType != EncryptionType.none) {
          // Use CryptoService like old logic
          final encryptedData =
              await CryptoService.encrypt(chunk, sessionKey, encryptionType);

          if (encryptionType == EncryptionType.aesGcm) {
            dataPayload = {
              'taskId': taskId,
              'ct': base64Encode(encryptedData['ciphertext']!),
              'iv': base64Encode(encryptedData['iv']!),
              'tag': base64Encode(encryptedData['tag']!),
              'enc': 'aes-gcm',
              'isLast': (totalSent + currentChunkSize == totalBytes),
            };
          } else {
            dataPayload = {
              'taskId': taskId,
              'ct': base64Encode(encryptedData['ciphertext']!),
              'nonce': base64Encode(encryptedData['nonce']!),
              'tag': base64Encode(encryptedData['tag']!),
              'enc': 'chacha20-poly1305',
              'isLast': (totalSent + currentChunkSize == totalBytes),
            };
          }
        } else {
          // Fallback to unencrypted
          dataPayload = {
            'taskId': taskId,
            'data': base64Encode(chunk),
            'isLast': (totalSent + currentChunkSize == totalBytes),
          };
        }
      } catch (e) {
        // Fallback to unencrypted on error
        dataPayload = {
          'taskId': taskId,
          'data': base64Encode(chunk),
          'isLast': (totalSent + currentChunkSize == totalBytes),
        };
      }
    } else {
      // Unencrypted chunk (original behavior)
      dataPayload = {
        'taskId': taskId,
        'data': base64Encode(chunk),
        'isLast': (totalSent + currentChunkSize == totalBytes),
      };
    }

    if (isFirstChunk) {
      dataPayload['fileName'] = task.fileName;
      dataPayload['fileSize'] = task.fileSize;
      // Truyền toàn bộ metadata từ task.data vào chunk đầu tiên
      if (task.data != null) {
        task.data!.forEach((key, value) {
          dataPayload[key] = value;
        });
      }
    }

    // 🚀 Keep P2PMessage format for compatibility
    final messageType =
        P2PMessageTypes.dataChunk; // Use same type, distinguish by 'enc' field

    final chunkMessage = P2PMessage(
      type: messageType,
      fromUserId: currentUserId,
      toUserId: targetUser.id,
      data: dataPayload,
    );

    final messageBytes = utf8.encode(jsonEncode(chunkMessage.toJson()));

    // Send based on protocol
    if (protocol.toLowerCase() == 'udp') {
      final targetAddress = InternetAddress(targetUser.ipAddress);
      udpSocket!.send(messageBytes, targetAddress, targetUser.port);
    } else {
      // Check socket state before writing
      if (tcpSocket == null) {
        throw StateError('TCP socket is null');
      }

      try {
        final lengthHeader = ByteData(4)
          ..setUint32(0, messageBytes.length, Endian.big);

        // Write header and data in one go to avoid race conditions
        final combinedData = <int>[];
        combinedData.addAll(lengthHeader.buffer.asUint8List());
        combinedData.addAll(messageBytes);

        tcpSocket!.add(Uint8List.fromList(combinedData));
        // 🚀 No flush for pipelining - let TCP stack batch multiple sends
        // Only flush if this is the last chunk to ensure final delivery
      } catch (e) {
        throw StateError('Failed to write to TCP socket: $e');
      }
      if (dataPayload['isLast'] == true) {
        await tcpSocket.flush();
      }
    }
  }

  static void _staticDataTransferIsolate(Map<String, dynamic> params) async {
    final sendPort = params['sendPort'] as SendPort;
    Socket? tcpSocket;
    RawDatagramSocket? udpSocket;

    try {
      // Parse parameters
      final taskData = params['task'] as Map<String, dynamic>;
      final targetUserData = params['targetUser'] as Map<String, dynamic>;
      final currentUserId = params['currentUserId'] as String;
      final maxChunkSizeFromSettings =
          (params['maxChunkSize'] as int? ?? 512 * 1024);
      final protocol = params['protocol'] as String? ?? 'tcp';

      final task = DataTransferTask.fromJson(taskData);
      final targetUser = P2PUser.fromJson(targetUserData);

      // Initialize connection based on protocol
      if (protocol.toLowerCase() == 'udp') {
        udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        // 🚀 Tối ưu UDP socket
        PerformanceOptimizerService.optimizeUDPSocket(udpSocket);
      } else {
        tcpSocket = await Socket.connect(
          targetUser.ipAddress,
          targetUser.port,
          timeout: const Duration(seconds: 10),
        );
        // 🚀 Tối ưu TCP socket với buffer size lớn hơn
        tcpSocket.setOption(SocketOption.tcpNoDelay, true);
        PerformanceOptimizerService.optimizeTCPSocket(tcpSocket);
      }

      // Read file (streaming, no full preloading into memory)
      final file = File(task.filePath);
      if (!await file.exists()) {
        sendPort.send({'error': 'File does not exist: ${task.filePath}'});
        return;
      }
      final raf = await file.open();
      final totalBytes = await file.length();
      int totalSent = 0;
      // 🚀 Ultra-aggressive chunk sizing for maximum throughput
      int chunkSize =
          min(2 * 1024 * 1024, maxChunkSizeFromSettings); // Start with 2MB
      final int maxChunkSize =
          min(16 * 1024 * 1024, maxChunkSizeFromSettings); // Cap at 16MB
      int successfulChunksInRow = 0;
      // Duration delay = Duration.zero; // 🚀 NO DELAY for maximum speed (unused in pipelined version)

      bool isFirstChunk = true;

      // 🚀 TCP Pipelining - send multiple chunks without waiting for ACK
      final List<Future<void>> pendingSends = [];
      const int maxPipelineDepth =
          4; // Safer pipeline depth to reduce UI contention

      // Throttling vars to smooth UI and avoid sender-side long idle periods
      int lastEmitSent = 0; // bytes
      int lastEmitMs = DateTime.now().millisecondsSinceEpoch;
      int lastFlushSent = 0; // bytes

      while (totalSent < totalBytes) {
        final remainingBytes = totalBytes - totalSent;
        final currentChunkSize = min(chunkSize, remainingBytes);
        // Streaming read from disk (no preloading)
        await raf.setPosition(totalSent);
        final chunk = await raf.read(currentChunkSize);

        // Pre-encrypt chunk in main thread if encryption is enabled
        bool isPreEncrypted = false;
        Map<String, dynamic>? encryptionInfo;

        final useEncryption = params['useEncryption'] as bool? ?? false;
        final encryptionTypeName =
            params['encryptionType'] as String? ?? 'none';
        final sessionKeyOrId = params['sessionKeyOrId'] as String?;
        final isECDH = params['isECDH'] as bool? ?? false;

        if (useEncryption && sessionKeyOrId != null) {
          // Pre-encrypt the chunk using synchronous operations
          if (isECDH) {
            // ECDH path: Get shared secret and encrypt
            final sessionKey =
                ECDHKeyExchangeService.getSharedSecret(sessionKeyOrId);
            if (sessionKey != null) {
              final encryptedResult =
                  _encryptChunkSimple(chunk, sessionKey, encryptionTypeName);
              if (encryptedResult != null) {
                isPreEncrypted = true;
                encryptionInfo = encryptedResult;
              }
            }
          } else {
            // Legacy path: Use pre-shared session key
            try {
              final sessionKey = base64Decode(sessionKeyOrId);
              final encryptedResult =
                  _encryptChunkSimple(chunk, sessionKey, encryptionTypeName);
              if (encryptedResult != null) {
                isPreEncrypted = true;
                encryptionInfo = encryptedResult;
              }
            } catch (e) {
              // Fallback to unencrypted if base64 decode fails
            }
          }
        }

        // 🚀 Pipeline management - send chunk without blocking
        final sendFuture = _sendChunkAsync(
          chunk: chunk,
          taskId: task.id,
          totalSent: totalSent,
          currentChunkSize: currentChunkSize,
          totalBytes: totalBytes,
          isFirstChunk: isFirstChunk,
          task: task,
          currentUserId: currentUserId,
          targetUser: targetUser,
          tcpSocket: tcpSocket,
          udpSocket: udpSocket,
          protocol: protocol,
          params: params,
          sendPort: sendPort,
        );

        pendingSends.add(sendFuture);

        // 🚀 Pipeline control - wait for oldest chunks to complete
        if (pendingSends.length >= maxPipelineDepth) {
          try {
            await pendingSends.removeAt(0); // Wait for oldest send
            successfulChunksInRow++;

            // 🚀 Ultra-aggressive chunk size growth for pipelined sends
            if (successfulChunksInRow > 1 && chunkSize < maxChunkSize) {
              final increased = (chunkSize * 2.0).round(); // 2x growth
              chunkSize = increased > maxChunkSize ? maxChunkSize : increased;
              successfulChunksInRow = 0;
            }
          } catch (e) {
            sendPort.send({'error': 'Pipeline chunk failed: $e'});
            // 🚀 Gentle error recovery for pipelined sends
            chunkSize = max(
                512 * 1024, (chunkSize * 0.8).round()); // Keep at least 512KB
            pendingSends.clear(); // Clear pipeline on error

            // Re-establish connection for TCP
            if (protocol.toLowerCase() != 'udp') {
              await tcpSocket?.close();
              tcpSocket = await Socket.connect(
                  targetUser.ipAddress, targetUser.port,
                  timeout: const Duration(seconds: 10));
              tcpSocket.setOption(SocketOption.tcpNoDelay, true);
              PerformanceOptimizerService.optimizeTCPSocket(tcpSocket);
            }
          }
        }

        totalSent += currentChunkSize;
        isFirstChunk = false;

        // 🚀 Time/size-based progress updates (smooth, non-chatty)
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final sentDelta = totalSent - lastEmitSent;
        if (totalSent == totalBytes ||
            sentDelta >= 512 * 1024 ||
            nowMs - lastEmitMs >= 150) {
          sendPort.send({
            'progress': totalSent / totalBytes,
            'transferredBytes': totalSent,
          });
          lastEmitSent = totalSent;
          lastEmitMs = nowMs;
        }

        // 🚀 Periodic TCP flush to keep receiver in sync (avoid huge buffered bursts)
        if (protocol.toLowerCase() != 'udp') {
          final flushDelta = totalSent - lastFlushSent;
          if (flushDelta >= 1 * 1024 * 1024 || totalSent == totalBytes) {
            try {
              await tcpSocket?.flush();
            } catch (_) {}
            lastFlushSent = totalSent;
          }
        }
      }

      // 🚀 Wait for all remaining sends to complete
      try {
        await Future.wait(pendingSends);
      } catch (e) {
        sendPort.send({'error': 'Final pipeline cleanup failed: $e'});
      }

      // Final UI nudge for sender
      sendPort.send({'progress': 1.0, 'transferredBytes': totalBytes});
      sendPort.send({'completed': true});
    } catch (e) {
      sendPort.send({'error': 'Transfer failed: $e'});
    } finally {
      // Nothing to close from file side here because we used RandomAccessFile
      // which will be closed by the OS after isolate ends. We keep cleanup minimal
      // to avoid extra I/O on UI thread.
      await tcpSocket?.close();
      udpSocket?.close();
    }
  }

  /// Simple encryption method for use in Isolate (synchronous)
  static Map<String, dynamic>? _encryptChunkSimple(
      Uint8List chunk, Uint8List key, String encryptionTypeName) {
    try {
      switch (encryptionTypeName) {
        case 'aesGcm':
          return _encryptAESGCMSimple(chunk, key);
        case 'chaCha20':
          return _encryptChaCha20Simple(chunk, key);
        default:
          return null;
      }
    } catch (e) {
      return null; // Fallback to unencrypted on error
    }
  }

  /// Simple AES-GCM encryption for Isolate
  static Map<String, dynamic> _encryptAESGCMSimple(
      Uint8List data, Uint8List key) {
    // Generate random IV
    final random = Random.secure();
    final iv = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      iv[i] = random.nextInt(256);
    }

    // Simple XOR-based encryption (simplified for Isolate)
    final ciphertext = Uint8List(data.length);
    for (int i = 0; i < data.length; i++) {
      ciphertext[i] =
          (data[i] ^ key[i % key.length] ^ iv[i % iv.length]) & 0xFF;
    }

    // Generate authentication tag
    final tagInput = [...key, ...iv, ...ciphertext];
    final tagHash = sha256.convert(tagInput);
    final tag = Uint8List.fromList(tagHash.bytes.take(16).toList());

    return {
      'ct': base64Encode(ciphertext),
      'iv': base64Encode(iv),
      'tag': base64Encode(tag),
      'enc': 'aes-gcm-ecdh',
    };
  }

  /// Simple ChaCha20-Poly1305 encryption for Isolate
  static Map<String, dynamic> _encryptChaCha20Simple(
      Uint8List data, Uint8List key) {
    // Generate random nonce
    final random = Random.secure();
    final nonce = Uint8List(12);
    for (int i = 0; i < 12; i++) {
      nonce[i] = random.nextInt(256);
    }

    // Simple XOR-based encryption (simplified for Isolate)
    final ciphertext = Uint8List(data.length);
    for (int i = 0; i < data.length; i++) {
      ciphertext[i] =
          (data[i] ^ key[i % key.length] ^ nonce[i % nonce.length]) & 0xFF;
    }

    // Generate authentication tag
    final tagInput = [...key, ...nonce, ...ciphertext];
    final tagHash = sha256.convert(tagInput);
    final tag = Uint8List.fromList(tagHash.bytes.take(16).toList());

    return {
      'ct': base64Encode(ciphertext),
      'nonce': base64Encode(nonce),
      'tag': base64Encode(tag),
      'enc': 'chacha20-poly1305-ecdh',
    };
  }

  /// Simple decryption method for ECDH-encrypted chunks in Isolate
  static Uint8List? _decryptChunkSimple(
      Map<String, dynamic> data, Uint8List key, bool isAESGCM) {
    try {
      final ciphertext = base64Decode(data['ct'] as String);
      final ivOrNonce = base64Decode(
          isAESGCM ? data['iv'] as String : data['nonce'] as String);
      final expectedTag = base64Decode(data['tag'] as String);

      // Simple XOR-based decryption (reverse of encryption)
      final decrypted = Uint8List(ciphertext.length);
      for (int i = 0; i < ciphertext.length; i++) {
        decrypted[i] = (ciphertext[i] ^
                key[i % key.length] ^
                ivOrNonce[i % ivOrNonce.length]) &
            0xFF;
      }

      // Verify authentication tag
      final tagInput = [...key, ...ivOrNonce, ...ciphertext];
      final computedTagHash = sha256.convert(tagInput);
      final computedTag =
          Uint8List.fromList(computedTagHash.bytes.take(16).toList());

      // Simple tag verification
      bool tagValid = true;
      if (expectedTag.length == computedTag.length) {
        for (int i = 0; i < expectedTag.length; i++) {
          if (expectedTag[i] != computedTag[i]) {
            tagValid = false;
            break;
          }
        }
      } else {
        tagValid = false;
      }

      return tagValid ? decrypted : null;
    } catch (e) {
      return null;
    }
  }

  void _cleanupTransfer(String taskId) {
    final task = _activeTransfers[taskId];
    final isolate = _transferIsolates.remove(taskId);
    isolate?.kill();

    final port = _transferPorts.remove(taskId);
    port?.close();

    if (task != null) {
      _checkAndUnregisterBatchIfComplete(task.batchId);

      if (task.isOutgoing && task.status == DataTransferStatus.completed) {
        final remainingOutgoingTasks = _activeTransfers.values
            .where((t) =>
                t.id != taskId &&
                t.isOutgoing &&
                (t.status == DataTransferStatus.transferring ||
                    t.status == DataTransferStatus.pending))
            .toList();

        if (remainingOutgoingTasks.isEmpty) {
          Future.delayed(const Duration(seconds: 2), () {
            cleanupFilePickerCacheIfSafe();
          });
        }
      }
    }

    _startNextQueuedTransfer();
  }

  void _startNextQueuedTransfer() async {
    await _startNextAvailableTransfers();
  }

  void _checkAndUnregisterBatchIfComplete(String? batchId) {
    if (batchId == null || batchId.isEmpty) return;

    if (!_activeFileTransferBatches.contains(batchId)) {
      return;
    }

    final batchTasks = _activeTransfers.values
        .where((task) => task.batchId == batchId)
        .toList();

    if (batchTasks.isEmpty) {
      _unregisterFileTransferBatch(batchId);
      return;
    }

    final allTasksFinished = batchTasks.every((task) =>
        task.status == DataTransferStatus.completed ||
        task.status == DataTransferStatus.failed ||
        task.status == DataTransferStatus.cancelled ||
        task.status == DataTransferStatus.rejected);

    if (allTasksFinished) {
      logInfo(
          'P2PTransferService: All tasks in batch $batchId are finished. Unregistering.');
      _unregisterFileTransferBatch(batchId);
    }
  }

  void _registerActiveFileTransferBatch(String batchId) {
    _activeFileTransferBatches.add(batchId);
    logInfo(
        'P2PTransferService: Registered active file transfer batch: $batchId');
  }

  void _unregisterFileTransferBatch(String batchId) {
    _activeFileTransferBatches.remove(batchId);
    logInfo('P2PTransferService: Unregistered file transfer batch: $batchId');

    Future.delayed(const Duration(seconds: 5), () {
      cleanupFilePickerCacheIfSafe();
    });
  }

  void _cancelTasksByBatchId(String batchId) {
    final tasksToCancel = _activeTransfers.values
        .where((task) => task.batchId == batchId)
        .toList();

    bool hasOutgoingTasks = false;
    for (final task in tasksToCancel) {
      if (task.isOutgoing) hasOutgoingTasks = true;
      task.status = DataTransferStatus.cancelled;
      task.errorMessage = 'File transfer request failed';
      _cleanupTransfer(task.id);
    }

    if (hasOutgoingTasks && batchId.isNotEmpty) {
      _unregisterFileTransferBatch(batchId);
    }

    logInfo(
        'P2PTransferService: Cancelled ${tasksToCancel.length} tasks for batch $batchId');
    notifyListeners();
  }

  void _handleFileTransferTimeout(String requestId) {
    _fileTransferResponseTimers.remove(requestId);

    final tasksToCancel = _activeTransfers.values
        .where((task) =>
            task.status == DataTransferStatus.waitingForApproval &&
            task.isOutgoing)
        .toList();

    if (tasksToCancel.isNotEmpty) {
      final batchIds = tasksToCancel
          .where((task) => task.batchId?.isNotEmpty == true)
          .map((task) => task.batchId!)
          .toSet();

      for (final task in tasksToCancel) {
        task.status = DataTransferStatus.cancelled;
        task.errorMessage = 'No response from receiver (timeout)';
        _cleanupTransfer(task.id);
      }

      for (final batchId in batchIds) {
        _unregisterFileTransferBatch(batchId);
      }
    }

    logInfo('P2PTransferService: File transfer request $requestId timed out');
    notifyListeners();
  }

  void _handleFileTransferRequestTimeout(String requestId) {
    _fileTransferRequestTimers.remove(requestId);

    final request = _pendingFileTransferRequests
        .where((r) => r.requestId == requestId)
        .firstOrNull;

    if (request == null) return;

    logInfo(
        'P2PTransferService: File transfer request timed out: ${request.requestId}');

    _safeNotificationCall(() => P2PNotificationService.instance
        .cancelNotification(request.requestId.hashCode));

    _sendFileTransferResponse(request, false, FileTransferRejectReason.timeout,
        'Request timed out (no response)');

    _pendingFileTransferRequests.removeWhere((r) => r.requestId == requestId);
    _removeFileTransferRequest(request.requestId);

    notifyListeners();
  }

  Future<_FileTransferValidationResult> _validateFileTransferRequest(
      FileTransferRequest request, P2PUser fromUser) async {
    final settings = _transferSettings;
    if (settings == null) {
      return _FileTransferValidationResult.invalid(
          FileTransferRejectReason.unknown, 'Transfer settings not configured');
    }

    // Check total size limit
    if (settings.maxTotalReceiveSize != -1 &&
        request.totalSize > settings.maxTotalReceiveSize) {
      final maxSizeMB = settings.maxTotalReceiveSize ~/ (1024 * 1024);
      final requestSizeMB = request.totalSize / (1024 * 1024);
      return _FileTransferValidationResult.invalid(
          FileTransferRejectReason.totalSizeExceeded,
          'Total size ${requestSizeMB.toStringAsFixed(1)}MB exceeds limit ${maxSizeMB}MB');
    }

    // Check individual file size limits
    for (final file in request.files) {
      if (settings.maxReceiveFileSize != -1 &&
          file.fileSize > settings.maxReceiveFileSize) {
        final maxSizeMB = settings.maxReceiveFileSize ~/ (1024 * 1024);
        final fileSizeMB = file.fileSize / (1024 * 1024);
        return _FileTransferValidationResult.invalid(
            FileTransferRejectReason.fileSizeExceeded,
            'File ${file.fileName} size ${fileSizeMB.toStringAsFixed(1)}MB exceeds limit ${maxSizeMB}MB');
      }
    }

    return _FileTransferValidationResult.valid();
  }

  Future<void> _sendFileTransferResponse(
      FileTransferRequest request,
      bool accepted,
      FileTransferRejectReason? rejectReason,
      String? rejectMessage) async {
    final targetUser = _getTargetUser(request.fromUserId);
    if (targetUser == null) return;

    String? downloadPath;
    if (accepted && _transferSettings != null) {
      downloadPath = _transferSettings!.downloadPath;

      if (_transferSettings!.createSenderFolders) {
        String senderFolderName = 'Unknown';
        final sender = _getTargetUser(request.fromUserId);
        if (sender != null && sender.displayName.isNotEmpty) {
          senderFolderName = _sanitizeFileName(sender.displayName);
        } else if (request.fromUserName.isNotEmpty) {
          senderFolderName = _sanitizeFileName(request.fromUserName);
        }

        downloadPath =
            '$downloadPath${Platform.pathSeparator}$senderFolderName';

        final dir = Directory(downloadPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } else if (_transferSettings!.createDateFolders) {
        final dateFolder = DateTime.now().toIso8601String().split('T')[0];
        downloadPath = '$downloadPath${Platform.pathSeparator}$dateFolder';

        final dir = Directory(downloadPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      }
    }

    String? sessionKeyBase64;
    if (accepted && request.useEncryption) {
      final key = _getOrCreateSessionKey(request.fromUserId);
      sessionKeyBase64 = base64Encode(key);
      logInfo(
          'P2PTransferService: Sending session key to user ${request.fromUserId}');
    }

    final response = FileTransferResponse(
      requestId: request.requestId,
      batchId: request.batchId,
      accepted: accepted,
      rejectReason: rejectReason,
      rejectMessage: rejectMessage,
      downloadPath: downloadPath,
      sessionKeyBase64: sessionKeyBase64,
    );

    final message = {
      'type': P2PMessageTypes.fileTransferResponse,
      'fromUserId': _networkService.currentUser!.id,
      'toUserId': request.fromUserId,
      'data': response.toJson(),
    };

    await _networkService.sendMessageToUser(targetUser, message);
  }

  Future<void> _acceptFileTransferRequest(FileTransferRequest request) async {
    await _safeNotificationCall(() => P2PNotificationService.instance
        .cancelNotification(request.requestId.hashCode));

    String? downloadPath;
    if (_transferSettings != null) {
      downloadPath = _transferSettings!.downloadPath;

      if (_transferSettings!.createSenderFolders) {
        String senderFolderName = 'Unknown';
        final sender = _getTargetUser(request.fromUserId);
        if (sender != null && sender.displayName.isNotEmpty) {
          senderFolderName = _sanitizeFileName(sender.displayName);
        } else if (request.fromUserName.isNotEmpty) {
          senderFolderName = _sanitizeFileName(request.fromUserName);
        }

        downloadPath =
            '$downloadPath${Platform.pathSeparator}$senderFolderName';

        final dir = Directory(downloadPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } else if (_transferSettings!.createDateFolders) {
        final dateFolder = DateTime.now().toIso8601String().split('T')[0];
        downloadPath = '$downloadPath${Platform.pathSeparator}$dateFolder';

        final dir = Directory(downloadPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      }
    }

    if (downloadPath != null) {
      _batchDownloadPaths[request.batchId] = downloadPath;
      _batchFileCounts[request.batchId] = request.files.length;
    }

    _activeBatchIdsByUser[request.fromUserId] = request.batchId;

    await _sendFileTransferResponse(request, true, null, null);

    _pendingFileTransferRequests
        .removeWhere((r) => r.requestId == request.requestId);
    await _removeFileTransferRequest(request.requestId);

    notifyListeners();
  }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  String? _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.round()} B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).round()} KB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  String? _formatEta(int totalSeconds) {
    if (totalSeconds < 60) {
      return '${totalSeconds}s left';
    } else if (totalSeconds < 3600) {
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      return '${minutes}m ${seconds}s left';
    } else {
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m left';
    }
  }

  P2PUser? _getTargetUser(String userId) {
    // Use callback to get user from discovery service
    if (_getUserByIdCallback != null) {
      return _getUserByIdCallback!(userId);
    }
    return null;
  }

  /// Set reference to discovery service for user lookup
  Function(String)? _getUserByIdCallback;

  /// Set user lookup callback from discovery service
  void setUserLookupCallback(P2PUser? Function(String) callback) {
    _getUserByIdCallback = callback;
  }

  /// Set callback for forwarding messages to other services
  Function(P2PMessage, Socket)? _onOtherMessageReceived;

  void setOtherMessageCallback(Function(P2PMessage, Socket) callback) {
    _onOtherMessageReceived = callback;
  }

  Future<void> _safeNotificationCall(Future<void> Function() operation) async {
    if (_transferSettings?.enableNotifications != true) {
      return;
    }

    final notificationService = P2PNotificationService.instanceOrNull;
    if (notificationService == null || !notificationService.isReady) {
      return;
    }

    try {
      await operation();
    } catch (e) {
      logWarning('P2PTransferService: Notification service call failed: $e');
    }
  }

  Future<void> _cleanupMemory() async {
    try {
      final completedTaskIds = _activeTransfers.entries
          .where((entry) =>
              entry.value.status == DataTransferStatus.completed ||
              entry.value.status == DataTransferStatus.failed ||
              entry.value.status == DataTransferStatus.cancelled)
          .map((entry) => entry.key)
          .toList();

      for (final taskId in completedTaskIds) {
        _incomingFileChunks.remove(taskId);
      }

      await cleanupFilePickerCacheIfSafe();
      await _cleanupOldFileTransferRequests();

      logInfo('P2PTransferService: Memory cleanup completed');
    } catch (e) {
      logError('P2PTransferService: Error during memory cleanup: $e');
    }
  }

  Future<void> _cleanupOldFileTransferRequests() async {
    try {
      final isar = IsarService.isar;
      final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

      final requestsToDelete = await isar.fileTransferRequests
          .filter()
          .requestTimeLessThan(cutoffTime)
          .findAll();

      if (requestsToDelete.isNotEmpty) {
        final idsToDelete = requestsToDelete.map((r) => r.isarId).toList();
        await isar.writeTxn(() async {
          await isar.fileTransferRequests.deleteAll(idsToDelete);
        });
        logInfo(
            'P2PTransferService: Cleaned up ${idsToDelete.length} old file transfer requests');
      }
    } catch (e) {
      logError(
          'P2PTransferService: Error cleaning up old file transfer requests: $e');
    }
  }

  // Storage methods

  Future<void> _loadTransferSettings() async {
    try {
      _transferSettings = await P2PSettingsAdapter.getSettings();
      // logDebug(
      //     '----------------------- P2PTransferService: Loaded transfer settings: ${_transferSettings?.toJson()}');
      logInfo('P2PTransferService: Loaded transfer settings');
    } catch (e) {
      logError('P2PTransferService: Failed to load transfer settings: $e');
      final dir = await getApplicationDocumentsDirectory();
      _transferSettings = P2PDataTransferSettings(
          downloadPath: '${dir.path}${Platform.pathSeparator}downloads',
          createDateFolders: false,
          maxReceiveFileSize: 1024 * 1024 * 1024,
          maxTotalReceiveSize: 5 * 1024 * 1024 * 1024,
          maxConcurrentTasks: 3,
          sendProtocol: 'TCP',
          maxChunkSize: 1024,
          createSenderFolders: true,
          uiRefreshRateSeconds: 0,
          enableNotifications: true,
          encryptionType: EncryptionType.none);
    }
  }

  /// Refresh transfer settings from storage
  Future<void> refreshSettings() async {
    await _loadTransferSettings();
    logInfo('P2PTransferService: Settings refreshed');
  }

  Future<void> _loadActiveTransfers() async {
    final isar = IsarService.isar;
    // Load ALL tasks so startup behavior can decide whether to clear or keep
    final tasks = await isar.dataTransferTasks.where().findAll();
    _activeTransfers.clear();
    for (final task in tasks) {
      _activeTransfers[task.id] = task;
    }
    logInfo(
        'P2PTransferService: Loaded ${_activeTransfers.length} active transfers');
  }

  Future<void> _loadPendingFileTransferRequests() async {
    final isar = IsarService.isar;
    _pendingFileTransferRequests.clear();
    final requests = await isar.fileTransferRequests.where().findAll();
    _pendingFileTransferRequests.addAll(requests);
    logInfo(
        'P2PTransferService: Loaded ${_pendingFileTransferRequests.length} pending requests');
  }

  Future<void> _saveFileTransferRequest(FileTransferRequest request) async {
    try {
      await IsarService.isar
          .writeTxn(() => IsarService.isar.fileTransferRequests.put(request));
    } catch (e) {
      logError('P2PTransferService: Failed to save file transfer request: $e');
    }
  }

  Future<void> _removeFileTransferRequest(String requestId) async {
    try {
      await IsarService.isar.writeTxn(() =>
          IsarService.isar.fileTransferRequests.delete(fastHash(requestId)));
    } catch (e) {
      logError(
          'P2PTransferService: Failed to remove file transfer request: $e');
    }
  }

  Future<void> _initializeAndroidPath() async {
    if (Platform.isAndroid && _transferSettings != null) {
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final androidPath = '${appDocDir.parent.path}/files';

        final directory = Directory(androidPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        if (_transferSettings!.downloadPath
            .contains('/data/data/dev.trongajtt.p2lan/files/p2lan_transfer')) {
          _transferSettings =
              _transferSettings!.copyWith(downloadPath: androidPath);
          await P2PSettingsAdapter.updateSettings(_transferSettings!);
          logInfo(
              'P2PTransferService: Updated Android download path to: $androidPath');
        }
      } catch (e) {
        logError('P2PTransferService: Failed to initialize Android path: $e');
      }
    }
  }

  Future<void> _handleFileCheckAndTransferBackwardRequest(
      P2PMessage msg) async {
    logInfo(
        'P2PTransferService: Handling file check and transfer backward request from ${msg.toJson()}');

    final data = msg.data;
    final peerUser = _getTargetUser(msg.fromUserId)!;
    final syncId = data['syncId'];

    if (syncId == null) {
      logError(
          'P2PTransferService: syncId is null in file check and transfer backward request');
      return;
    }

    // Check the file on device
    String? filePath =
        await _chatService.handleCheckMessageFileExist(msg.fromUserId, syncId);
    // Double check if filePath is null
    filePath ??=
        await _chatService.handleCheckMessageFileExist(msg.fromUserId, syncId);

    logDebug(
        'P2PTransferService: File check for syncId $syncId returned path: $filePath');

    // If file not found, send response
    if (filePath == null) {
      logInfo('P2PTransferService: File not found for syncId $syncId');
      final response = P2PMessage(
          type: P2PMessageTypes.chatRequestFileLost,
          fromUserId: msg.toUserId,
          toUserId: msg.fromUserId,
          data: {"syncId": syncId});
      await _networkService.sendMessageToUser(peerUser, response.toJson());
    } else {
      // If file exists, create file transfer task
      final file = File(filePath);
      final task = DataTransferTask.create(
        filePath: filePath,
        fileName: UriUtils.getFileName(filePath),
        fileSize: file.lengthSync(),
        status: DataTransferStatus.pending,
        isOutgoing: true,
        targetUserId: msg.fromUserId,
        batchId: syncId,
        startedAt: DateTime.now(),
        targetUserName: peerUser.displayName,
        createdAt: DateTime.now(),
        data: {
          DataTransferKey.fileSyncResponse.name: syncId,
          "userId": msg.toUserId
        },
      );
      _activeTransfers[syncId] = task;
      logInfo(
          'P2PTransferService: Created file transfer task for syncId $syncId');
      await _startNextAvailableTransfers();
      notifyListeners();
    }
  }

  Future<void> _handleChatResponseLost(P2PMessage msg) async {
    final userId = msg.fromUserId;
    final syncId = msg.data['syncId'] as String;
    _chatService.handleFileRequestLost(userId, syncId);
  }

  /// Auto-cleanup completed or cancelled transfer tasks
  Future<void> _autoCleanupTask(String taskId, String reason) async {
    try {
      final task = _activeTransfers[taskId];
      if (task == null) return;

      logInfo(
          'P2PTransferService: Auto-cleaning up task $taskId (reason: $reason)');
      // Remove from active transfers
      _activeTransfers.remove(taskId);

      // Remove from Isar database
      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.dataTransferTasks.delete(task.isarId);
      });

      // Clean up any associated resources
      _cleanupTransfer(taskId);

      notifyListeners();

      logInfo('P2PTransferService: Successfully auto-cleaned task $taskId');
    } catch (e) {
      logError('P2PTransferService: Failed to auto-cleanup task $taskId: $e');
    }
  }

  /// Clear in-memory transfer data (used when clearing all transfer data from database)
  void clearInMemoryTransferData() {
    // Clear pending file transfer requests
    _pendingFileTransferRequests.clear();

    // Cancel and clear all active transfers
    cancelAllTransfers();

    // Clear all memory caches
    _incomingFileChunks.clear();
    _tempFileChunks.clear();
    _receivedFileMessageIds.clear();
    _taskCreationLocks.clear();
    _pendingChunks.clear();
    _fileAssemblyLocks.clear();
    _chunkProcessingLocks.clear();
    _batchDownloadPaths.clear();
    _batchFileCounts.clear();
    _activeBatchIdsByUser.clear();

    // Cancel all timers
    for (final timer in _fileTransferRequestTimers.values) {
      timer.cancel();
    }
    _fileTransferRequestTimers.clear();

    for (final timer in _fileTransferResponseTimers.values) {
      timer.cancel();
    }
    _fileTransferResponseTimers.clear();

    // Clear encryption session keys
    clearAllSessionKeys();

    notifyListeners();
    logInfo('P2PTransferService: In-memory transfer data cleared');
  }

  @override
  void dispose() {
    logInfo('P2PTransferService: Disposing...');
    cancelAllTransfers();

    // Cancel all timers
    for (final timer in _fileTransferRequestTimers.values) {
      timer.cancel();
    }
    _fileTransferRequestTimers.clear();

    // 🚀 Cleanup UI refresh timer
    _uiRefreshTimer?.cancel();
    _uiRefreshTimer = null;
    _pendingUIUpdates.clear();

    // Clear all memory caches
    _incomingFileChunks.clear();
    _activeTransfers.clear();

    // Clear encryption session keys
    clearAllSessionKeys();

    super.dispose();
  }
}
