import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:p2lan/services/p2p_services/p2p_navigation_service.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/models/p2p_models.dart';

/// P2P notification types for different events
enum P2PNotificationType {
  fileTransferRequest('file_transfer_request', 'File Transfer Request'),
  fileTransferProgress('file_transfer_progress', 'File Transfer Progress'),
  fileTransferCompleted('file_transfer_completed', 'File Transfer Completed'),
  pairingRequest('pairing_request', 'Pairing Request'),
  deviceOnline('device_online', 'Device Online'),
  deviceOffline('device_offline', 'Device Offline'),
  p2lanStatus('p2lan_status', 'P2LAN Status'),
  fileTransferStatus('file_transfer_status', 'File Transfer Status'),
  newMessage('new_message', 'New Message');

  const P2PNotificationType(this.id, this.displayName);
  final String id;
  final String displayName;
}

/// P2P notification action that can be performed
enum P2PNotificationAction {
  approveTransfer('approve_transfer', 'Approve'),
  rejectTransfer('reject_transfer', 'Reject'),
  acceptPairing('accept_pairing', 'Accept'),
  rejectPairing('reject_pairing', 'Reject'),
  openP2Lan('open_p2lan', 'Open P2LAN');

  const P2PNotificationAction(this.id, this.label);
  final String id;
  final String label;
}

/// P2P notification data payload
class P2PNotificationPayload {
  final P2PNotificationType type;
  final String? userId;
  final String? userName;
  final String? requestId;
  final String? batchId;
  final String? taskId;
  final Map<String, dynamic>? extra;

  const P2PNotificationPayload({
    required this.type,
    this.userId,
    this.userName,
    this.requestId,
    this.batchId,
    this.taskId,
    this.extra,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.id,
      'userId': userId,
      'userName': userName,
      'requestId': requestId,
      'batchId': batchId,
      'taskId': taskId,
      'extra': extra,
    };
  }

  factory P2PNotificationPayload.fromJson(Map<String, dynamic> json) {
    return P2PNotificationPayload(
      type: P2PNotificationType.values.firstWhere(
        (t) => t.id == json['type'],
        orElse: () => P2PNotificationType.deviceOnline,
      ),
      userId: json['userId'],
      userName: json['userName'],
      requestId: json['requestId'],
      batchId: json['batchId'],
      taskId: json['taskId'],
      extra: json['extra'],
    );
  }
}

/// P2P Notification Service for cross-platform notifications
class P2PNotificationService {
  static P2PNotificationService? _instance;

  // Private constructor
  P2PNotificationService._();

  // Public getter for the instance
  static P2PNotificationService get instance {
    if (_instance == null) {
      throw Exception(
          'P2PNotificationService not initialized. Call P2PNotificationService.init() first.');
    }
    return _instance!;
  }

  // Safe getter that returns null if not initialized
  static P2PNotificationService? get instanceOrNull => _instance;

  // Initialization method
  static Future<void> init() async {
    if (_instance == null) {
      _instance = P2PNotificationService._();
      await _instance!.initialize();
    }
  }

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool _permissionsGranted = false;

  // Notification channels
  static const String _fileTransferChannelId = 'p2p_file_transfer';
  static const String _pairingChannelId = 'p2p_pairing';
  static const String _deviceChannelId = 'p2p_device';
  static const String _p2lanStatusChannelId = 'p2p_status';
  static const String _fileTransferStatusChannelId = 'p2p_file_status';
  static const String _chatChannelId = 'p2p_chat';

  // Notification IDs
  static const int _p2lanStatusNotificationId = 12345;

  // Notification callbacks
  Function(P2PNotificationPayload)? _onNotificationTapped;
  Function(P2PNotificationAction, P2PNotificationPayload)? _onActionPressed;

  /// Initialize the notification service
  Future<bool> initialize() async {
    if (_isInitialized) {
      logInfo('P2P Notification Service already initialized');
      return true;
    }

    try {
      logInfo('Initializing P2P Notification Service...');

      // Android initialization
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, // Don't request permission during init
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // Windows/Linux initialization
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open P2LAN',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        linux: linuxSettings,
      );

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            _onBackgroundNotificationResponse,
      );

      if (initialized == true) {
        await _createNotificationChannels();
        _isInitialized = true;
        logInfo('P2P Notification Service initialized successfully');

        // Auto-check permissions after initialization
        await checkPermissions();
        logInfo('Initial permission check completed: $_permissionsGranted');

        return true;
      }

      logError('Failed to initialize notification service');
      return false;
    } catch (e) {
      logError('P2P Notification Service initialization error: $e');
      return false;
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    // File Transfer Channel
    const fileTransferChannel = AndroidNotificationChannel(
      _fileTransferChannelId,
      'File Transfers',
      description: 'Notifications for file transfer requests and progress',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    // Pairing Channel
    const pairingChannel = AndroidNotificationChannel(
      _pairingChannelId,
      'Device Pairing',
      description: 'Notifications for device pairing requests',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    // Device Status Channel
    const deviceChannel = AndroidNotificationChannel(
      _deviceChannelId,
      'Device Status',
      description: 'Notifications for device online/offline status',
      importance: Importance.low,
      enableVibration: false,
      playSound: false,
    );

    // P2LAN Status Channel (persistent notification)
    const p2lanStatusChannel = AndroidNotificationChannel(
      _p2lanStatusChannelId,
      'P2LAN Status',
      description: 'Persistent notification when P2LAN is running',
      importance: Importance.low,
      enableVibration: false,
      playSound: false,
    );

    // File Transfer Status Channel (detailed progress)
    const fileTransferStatusChannel = AndroidNotificationChannel(
      _fileTransferStatusChannelId,
      'File Transfer Status',
      description: 'Detailed file transfer progress notifications',
      importance: Importance.low,
      enableVibration: false,
      playSound: false,
    );

    // Chat Messages Channel
    const chatChannel = AndroidNotificationChannel(
      _chatChannelId,
      'Chat Messages',
      description: 'Notifications for new chat messages',
      importance: Importance.defaultImportance,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(fileTransferChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(pairingChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(deviceChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(p2lanStatusChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(fileTransferStatusChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(chatChannel);
  }

  /// Check if notifications are enabled in user settings
  Future<bool> _isNotificationEnabledInSettings() async {
    try {
      final settings = await ExtensibleSettingsService.getGeneralSettings();
      return settings.enableNotifications;
    } catch (e) {
      logError('Failed to check notification settings: $e');
      return false; // Default to disabled if error
    }
  }

  /// Check if notifications should be shown (permissions + user settings)
  Future<bool> _shouldShowNotifications() async {
    if (!_isInitialized) return false;

    // Check user settings first
    final enabledInSettings = await _isNotificationEnabledInSettings();
    if (!enabledInSettings) {
      logInfo('Notifications disabled in user settings');
      return false;
    }

    // Auto-check permissions if not already granted
    if (!_permissionsGranted) {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        logInfo('Notifications disabled - no permissions');
        return false;
      }
    }

    return true;
  }

  /// Refresh notification settings (call when user changes notification preferences)
  Future<void> refreshSettings() async {
    if (!_isInitialized) return;

    logInfo('Refreshing notification settings...');

    // Re-check permissions
    await checkPermissions();

    // Check current settings
    final enabledInSettings = await _isNotificationEnabledInSettings();
    logInfo(
        'Notification settings refreshed - enabled: $enabledInSettings, permissions: $_permissionsGranted');

    // If notifications are disabled, clear all existing notifications
    if (!enabledInSettings) {
      await clearAllNotifications();
      logInfo('Cleared all notifications as they are disabled');
    }
  }

  /// Check if notifications are ready to use (initialized + permissions granted)
  bool get isReady => _isInitialized && _permissionsGranted;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if permissions are granted
  bool get hasPermissions => _permissionsGranted;

  /// Update permissions status (called when user enables/disables notifications)
  Future<bool> updatePermissions() async {
    if (!_isInitialized) {
      return false;
    }

    return await requestPermissions();
  }

  /// Request notification permissions (called when user enables notifications)
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      logWarning('Cannot request permissions: service not initialized');
      return false;
    }

    if (Platform.isIOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      _permissionsGranted = granted ?? false;
      logInfo('iOS notification permissions granted: $_permissionsGranted');
      return _permissionsGranted;
    }

    if (Platform.isAndroid) {
      try {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = deviceInfo.version.sdkInt;

        // For Android 13 (Tiramisu, SDK 33) and above
        if (sdkInt >= 33) {
          final androidPlugin =
              _notifications.resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
          final granted = await androidPlugin?.requestNotificationsPermission();
          _permissionsGranted = granted ?? false;
          logInfo(
              'Android 13+ notification permissions granted: $_permissionsGranted');
          return _permissionsGranted;
        } else {
          // For older Android versions, notifications are enabled by default
          // Just check if they are enabled in system settings
          final androidPlugin =
              _notifications.resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
          final granted = await androidPlugin?.areNotificationsEnabled();
          _permissionsGranted =
              granted ?? true; // Default to true for older versions
          logInfo(
              'Android <13 notification permissions status: $_permissionsGranted');
          return _permissionsGranted;
        }
      } catch (e) {
        logError('Error checking Android notification permissions: $e');
        _permissionsGranted = false;
        return false;
      }
    }

    // Desktop platforms typically don't require explicit permission
    _permissionsGranted = true;
    logInfo('Desktop notification permissions granted: $_permissionsGranted');
    return true;
  }

  /// Opens the application's notification settings page.
  Future<void> openNotificationSettings() async {
    await openAppSettings();
  }

  /// Check if permissions are already granted (without requesting)
  Future<bool> checkPermissions() async {
    if (!_isInitialized) {
      _permissionsGranted = false;
      return false;
    }

    if (Platform.isAndroid) {
      try {
        final androidPlugin =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidPlugin?.areNotificationsEnabled();
        _permissionsGranted = granted ?? false;
        logInfo('Android notification permissions check: $_permissionsGranted');
        return _permissionsGranted;
      } catch (e) {
        logError('Error checking Android notification permissions: $e');
        _permissionsGranted = false;
        return false;
      }
    }

    // For other platforms, assume granted if initialized
    _permissionsGranted = _isInitialized;
    logInfo('Non-Android notification permissions check: $_permissionsGranted');
    return _permissionsGranted;
  }

  /// Set notification callbacks
  void setCallbacks({
    Function(P2PNotificationPayload)? onNotificationTapped,
    Function(P2PNotificationAction, P2PNotificationPayload)? onActionPressed,
  }) {
    _onNotificationTapped = onNotificationTapped;
    _onActionPressed = onActionPressed;
    logInfo('P2P notification callbacks set');
  }

  /// Clear notification callbacks
  void clearCallbacks() {
    _onNotificationTapped = null;
    _onActionPressed = null;
    logInfo('P2P notification callbacks cleared');
  }

  /// Handle notification tap
  void _onNotificationResponse(NotificationResponse response) {
    try {
      final payloadString = response.payload;
      if (payloadString != null && payloadString.isNotEmpty) {
        final Map<String, dynamic> payloadMap = jsonDecode(payloadString);
        final data = P2PNotificationPayload.fromJson(payloadMap);

        if (response.actionId != null) {
          // Handle action button press
          final action = P2PNotificationAction.values.firstWhere(
            (a) => a.id == response.actionId,
            orElse: () => P2PNotificationAction.openP2Lan,
          );
          _onActionPressed?.call(action, data);
        } else {
          // Handle notification tap
          _handleNotificationTap(data);
        }
      }
    } catch (e, s) {
      logError('Error handling notification response: $e\n$s');
    }
  }

  /// Handle notification tap with special logic for P2LAN Status
  void _handleNotificationTap(P2PNotificationPayload data) {
    if (data.type == P2PNotificationType.p2lanStatus) {
      // For P2LAN Status notification, navigate to P2LAN screen
      _navigateToP2Lan();
    } else {
      // For other notifications, use the registered callback
      _onNotificationTapped?.call(data);
    }
  }

  /// Navigate to P2LAN screen using the global navigator key
  void _navigateToP2Lan() {
    try {
      // Use the global navigator key from main.dart for reliable navigation
      final navigator = _getGlobalNavigator();
      if (navigator != null) {
        navigator.pushNamed('/p2lan_transfer');
        logInfo(
            'Navigated to P2LAN from notification tap using global navigator');
      } else {
        // Fallback to navigation service
        final navService = P2PNavigationService.instance;
        navService.navigateToP2Lan();
        logInfo(
            'Navigated to P2LAN from notification tap using navigation service');
      }
    } catch (e) {
      logError('Failed to navigate to P2LAN from notification: $e');
    }
  }

  /// Get global navigator state from main.dart
  NavigatorState? _getGlobalNavigator() {
    try {
      // Import the global navigator key from main.dart
      // We'll need to make this accessible via a service or direct import
      return null; // Will be implemented after making navigatorKey accessible
    } catch (e) {
      return null;
    }
  }

  /// Handle background notification response
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    // Handle background notification - limited functionality
    logInfo('Background notification received: ${response.payload}');
  }

  /// Show file transfer request notification
  Future<void> showFileTransferRequest({
    required FileTransferRequest request,
    bool enableActions = true,
  }) async {
    if (!await _shouldShowNotifications()) {
      logInfo(
          'File transfer request notification skipped - notifications disabled');
      return;
    }

    final filesText = request.files.length == 1
        ? request.files.first.fileName
        : '${request.files.length} files';

    final payload = P2PNotificationPayload(
      type: P2PNotificationType.fileTransferRequest,
      userId: request.fromUserId,
      userName: request.fromUserName,
      requestId: request.requestId,
      batchId: request.batchId,
    );

    await _notifications.show(
      request.requestId.hashCode,
      'File Transfer Request',
      '${request.fromUserName} wants to send you $filesText',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _fileTransferChannelId,
          'File Transfers',
          channelDescription: 'Notifications for file transfer requests',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.message,
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'file_transfer_request',
        ),
        linux: LinuxNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      payload: _encodePayload(payload),
    );

    logInfo(
        'Showed file transfer request notification for ${request.fromUserName}');
  }

  /// Show file transfer progress notification
  Future<void> showFileTransferProgress({
    required DataTransferTask task,
    required int progress, // 0-100
  }) async {
    if (!await _shouldShowNotifications()) {
      logInfo(
          'File transfer progress notification skipped - notifications disabled');
      return;
    }

    final payload = P2PNotificationPayload(
      type: P2PNotificationType.fileTransferProgress,
      userId: task.targetUserId,
      userName: task.targetUserName,
      taskId: task.id,
      batchId: task.batchId,
    );

    final statusText = task.isOutgoing
        ? 'Sending to ${task.targetUserName}'
        : 'Receiving from ${task.targetUserName}';

    // Calculate speed and ETA if available
    String progressText = '$progress%';
    if (task.startedAt != null && progress > 0 && task.transferredBytes > 0) {
      final elapsed = DateTime.now().difference(task.startedAt!);
      if (elapsed.inSeconds > 0) {
        final speed = task.transferredBytes / elapsed.inSeconds;
        final speedKB = (speed / 1024).round();

        if (speedKB > 0) {
          progressText += ' • ${speedKB}KB/s';

          // Calculate ETA
          final remainingBytes = task.fileSize - task.transferredBytes;
          if (remainingBytes > 0) {
            final etaSeconds = (remainingBytes / speed).round();
            if (etaSeconds < 60) {
              progressText += ' • ${etaSeconds}s left';
            } else {
              final etaMinutes = (etaSeconds / 60).round();
              progressText += ' • ${etaMinutes}m left';
            }
          }
        }
      }
    }

    final fileName = task.fileName.length > 25
        ? '${task.fileName.substring(0, 22)}...'
        : task.fileName;

    logInfo(
        'Showing file transfer progress notification: $progress% for ${task.fileName}');

    await _notifications.show(
      task.id.hashCode,
      '$statusText: $fileName',
      progressText,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _fileTransferChannelId,
          'File Transfers',
          channelDescription: 'File transfer progress',
          importance: Importance.low,
          priority: Priority.low,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: 100,
          progress: progress,
          ongoing: progress < 100,
          autoCancel: false,
          // Add cancel action for Android
          actions: task.isOutgoing
              ? [
                  const AndroidNotificationAction(
                    'cancel_transfer',
                    'Cancel',
                    cancelNotification: false,
                  ),
                ]
              : null,
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'file_transfer_progress',
          subtitle: progressText,
        ),
        linux: LinuxNotificationDetails(
          category: LinuxNotificationCategory.transfer,
          // Add cancel action for Linux
          actions: task.isOutgoing
              ? [
                  const LinuxNotificationAction(
                    key: 'cancel_transfer',
                    label: 'Cancel',
                  ),
                ]
              : [],
        ),
        macOS: DarwinNotificationDetails(
          subtitle: progressText,
        ),
      ),
      payload: _encodePayload(payload),
    );
  }

  /// Show file transfer completed notification
  Future<void> showFileTransferCompleted({
    required DataTransferTask task,
    required bool success,
    String? errorMessage,
  }) async {
    if (!await _shouldShowNotifications()) {
      logInfo(
          'File transfer completion notification skipped - notifications disabled');
      return;
    }

    final payload = P2PNotificationPayload(
      type: P2PNotificationType.fileTransferCompleted,
      userId: task.targetUserId,
      userName: task.targetUserName,
      taskId: task.id,
      batchId: task.batchId,
    );

    final title = success ? 'File Transfer Complete' : 'File Transfer Failed';
    final statusText = task.isOutgoing
        ? (success
            ? 'Sent to ${task.targetUserName}'
            : 'Failed to send to ${task.targetUserName}')
        : (success
            ? 'Received from ${task.targetUserName}'
            : 'Failed to receive from ${task.targetUserName}');

    final body = success
        ? '$statusText: ${task.fileName}'
        : '$statusText: ${errorMessage ?? 'Unknown error'}';

    // Cancel progress notification
    await _notifications.cancel(task.id.hashCode);

    // Cancel status notification as well
    await _notifications.cancel('${task.id}_status'.hashCode);

    logInfo(
        'Cancelled progress and status notifications for completed task: ${task.id}');

    await _notifications.show(
      '${task.id}_complete'.hashCode,
      title,
      body,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          _fileTransferChannelId,
          'File Transfers',
          channelDescription: 'File transfer completion status',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'file_transfer_completed',
          subtitle: statusText,
        ),
        linux: const LinuxNotificationDetails(),
        macOS: DarwinNotificationDetails(
          subtitle: statusText,
        ),
      ),
      payload: _encodePayload(payload),
    );

    logInfo(
        'Showed file transfer ${success ? 'completed' : 'failed'} notification for ${task.fileName}');
  }

  /// Show pairing request notification
  Future<void> showPairingRequest({
    required PairingRequest request,
    bool enableActions = true,
  }) async {
    if (!await _shouldShowNotifications()) {
      logInfo('Pairing request notification skipped - notifications disabled');
      return;
    }

    final payload = P2PNotificationPayload(
      type: P2PNotificationType.pairingRequest,
      userId: request.fromUserId,
      userName: request.fromUserName,
      requestId: request.id,
    );

    await _notifications.show(
      request.id.hashCode,
      'Pairing Request',
      '${request.fromUserName} wants to pair with your device',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _pairingChannelId,
          'Device Pairing',
          channelDescription: 'Device pairing requests',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.social,
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'pairing_request',
        ),
        linux: LinuxNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      payload: _encodePayload(payload),
    );

    logInfo('Showed pairing request notification for ${request.fromUserName}');
  }

  /// Show device online notification
  Future<void> showDeviceOnline({
    required P2PUser user,
  }) async {
    if (!await _shouldShowNotifications()) {
      logInfo('Device online notification skipped - notifications disabled');
      return;
    }

    final payload = P2PNotificationPayload(
      type: P2PNotificationType.deviceOnline,
      userId: user.id,
      userName: user.displayName,
    );

    await _notifications.show(
      '${user.id}_online'.hashCode,
      'Device Online',
      '${user.displayName} is now available',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _deviceChannelId,
          'Device Status',
          channelDescription: 'Device online/offline notifications',
          importance: Importance.low,
          priority: Priority.low,
          icon: 'ic_device_online',
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'device_status',
        ),
      ),
      payload: _encodePayload(payload),
    );
  }

  /// Show P2LAN status notification (persistent when P2LAN is running)
  Future<void> showP2LanStatus({
    required String deviceName,
    required String ipAddress,
    int connectedDevices = 0,
  }) async {
    if (!await _shouldShowNotifications()) {
      logInfo('P2LAN status notification skipped - notifications disabled');
      return;
    }

    final payload = P2PNotificationPayload(
      type: P2PNotificationType.p2lanStatus,
      extra: {
        'deviceName': deviceName,
        'ipAddress': ipAddress,
        'connectedDevices': connectedDevices,
      },
    );

    final statusText = connectedDevices > 0
        ? '$connectedDevices device${connectedDevices > 1 ? 's' : ''} connected'
        : 'Ready for connections';

    await _notifications.show(
      _p2lanStatusNotificationId,
      'P2LAN Active',
      '$deviceName ($ipAddress) • $statusText',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _p2lanStatusChannelId,
          'P2LAN Status',
          channelDescription: 'Persistent notification when P2LAN is running',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          icon: 'ic_p2lan_active',
        ),
        linux: LinuxNotificationDetails(
          category: LinuxNotificationCategory.network,
          defaultActionName: 'Open P2LAN',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: false, // Don't show a banner
          categoryIdentifier: 'p2lan_status',
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
          presentSound: false,
        ),
      ),
      payload: _encodePayload(payload),
    );

    logInfo('Showed P2LAN status notification: $deviceName ($ipAddress)');
  }

  /// Hide P2LAN status notification
  Future<void> hideP2LanStatus() async {
    await _notifications.cancel(_p2lanStatusNotificationId);
    logInfo('Hidden P2LAN status notification');
  }

  /// Show file transfer status notification (enhanced progress with detailed info)
  Future<void> showFileTransferStatus({
    required DataTransferTask task,
    required int progress, // 0-100
    String? speed,
    String? eta,
    String? remainingFiles,
  }) async {
    if (!await _shouldShowNotifications()) {
      logInfo(
          'File transfer status notification skipped - notifications disabled');
      return;
    }

    final payload = P2PNotificationPayload(
      type: P2PNotificationType.fileTransferStatus,
      userId: task.targetUserId,
      userName: task.targetUserName,
      taskId: task.id,
      batchId: task.batchId,
      extra: {
        'progress': progress,
        'speed': speed,
        'eta': eta,
        'remainingFiles': remainingFiles,
      },
    );

    final statusText = task.isOutgoing
        ? 'Sending to ${task.targetUserName}'
        : 'Receiving from ${task.targetUserName}';

    // Build detailed progress text
    final progressParts = <String>['$progress%'];
    if (speed != null && speed.isNotEmpty) {
      progressParts.add(speed);
    }
    if (eta != null && eta.isNotEmpty) {
      progressParts.add(eta);
    }
    if (remainingFiles != null && remainingFiles.isNotEmpty) {
      progressParts.add(remainingFiles);
    }

    final progressText = progressParts.join(' • ');

    final fileName = task.fileName.length > 30
        ? '${task.fileName.substring(0, 27)}...'
        : task.fileName;

    await _notifications.show(
      '${task.id}_status'.hashCode,
      '$statusText: $fileName',
      progressText,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _fileTransferStatusChannelId,
          'File Transfer Status',
          channelDescription: 'Detailed file transfer progress notifications',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showProgress: true,
          maxProgress: 100,
          progress: progress,
          icon: task.isOutgoing ? 'ic_p2lan_active' : 'ic_p2lan_active',
        ),
        linux: LinuxNotificationDetails(
          category: LinuxNotificationCategory.transfer,
          resident: true,
          urgency: LinuxNotificationUrgency.low,
          actions: task.isOutgoing
              ? [
                  const LinuxNotificationAction(
                    key: 'cancel_transfer',
                    label: 'Cancel',
                  ),
                  const LinuxNotificationAction(
                    key: 'open_p2lan',
                    label: 'Open P2LAN',
                  ),
                ]
              : [
                  const LinuxNotificationAction(
                    key: 'open_p2lan',
                    label: 'Open P2LAN',
                  ),
                ],
        ),
        macOS: DarwinNotificationDetails(
          subtitle: progressText,
          presentAlert: false,
          presentBadge: false,
          presentSound: false,
        ),
      ),
      payload: _encodePayload(payload),
    );

    logInfo(
        'Showed file transfer status notification: $progress% for ${task.fileName}');
  }

  /// Show new chat message notification
  Future<void> showNewMessage({
    required String chatId,
    required String senderName,
    required String message,
    required String userId,
  }) async {
    logInfo(
        'showNewMessage called: chatId=$chatId, sender=$senderName, checking notifications...');

    if (!await _shouldShowNotifications()) {
      logInfo('Chat message notification skipped - notifications disabled');
      return;
    }

    final payload = P2PNotificationPayload(
      type: P2PNotificationType.newMessage,
      userId: userId,
      userName: senderName,
      extra: {
        'chatId': chatId,
        'message': message,
      },
    );

    // Truncate long messages for notification
    final displayMessage =
        message.length > 100 ? '${message.substring(0, 97)}...' : message;

    try {
      logInfo(
          'Attempting to show notification with title: "New message from $senderName"');

      await _notifications.show(
        '${chatId}_message'.hashCode,
        'New message from $senderName',
        displayMessage,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _chatChannelId,
            'Chat Messages',
            channelDescription: 'Notifications for new chat messages',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            category: AndroidNotificationCategory.message,
            actions: [
              const AndroidNotificationAction(
                'reply',
                'Reply',
                cancelNotification: false,
              ),
              const AndroidNotificationAction(
                'open_chat',
                'Open Chat',
                cancelNotification: true,
              ),
            ],
          ),
          iOS: DarwinNotificationDetails(
            categoryIdentifier: 'chat_message',
            subtitle: senderName,
          ),
          linux: LinuxNotificationDetails(
            category: LinuxNotificationCategory.imReceived,
            actions: [
              const LinuxNotificationAction(
                key: 'open_chat',
                label: 'Open Chat',
              ),
            ],
          ),
          macOS: DarwinNotificationDetails(
            subtitle: senderName,
          ),
        ),
        payload: _encodePayload(payload),
      );

      logInfo(
          'New message notification shown successfully from $senderName in chat $chatId');
    } catch (e) {
      logError('Failed to show new message notification: $e');
    }
  }

  /// Cancel a generic notification by its ID
  Future<void> cancelNotification(int notificationId) async {
    if (!_isInitialized) return;
    await _notifications.cancel(notificationId);
  }

  /// Show test notification (for debugging)
  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      logError('Notification service not initialized');
      return;
    }

    try {
      await _notifications.show(
        999999,
        'Test Notification',
        'This is a test notification from P2LAN',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            channelDescription: 'Test notifications for debugging',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          linux: LinuxNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
      );
      logInfo('Test notification sent successfully');
    } catch (e) {
      logError('Failed to show test notification: $e');
    }
  }

  /// Show test chat message notification (for debugging)
  Future<void> showTestChatNotification() async {
    if (!_isInitialized) {
      logError('Notification service not initialized');
      return;
    }

    try {
      await showNewMessage(
        chatId: 'test_chat_123',
        senderName: 'Test User',
        message: 'This is a test chat message notification from P2LAN',
        userId: 'test_user_456',
      );
      logInfo('Test chat notification sent successfully');
    } catch (e) {
      logError('Failed to show test chat notification: $e');
    }
  }

  /// Cancel notifications by type
  Future<void> cancelNotificationsByType(P2PNotificationType type) async {
    // This is platform dependent - for now just cancel all
    // In future, we could track notification IDs by type
    if (type == P2PNotificationType.fileTransferProgress) {
      // Cancel all progress notifications
      await _notifications.cancelAll();
    }
  }

  /// Cancel all file transfer progress notifications for a specific task
  Future<void> cancelFileTransferProgress(String taskId) async {
    if (!_isInitialized) return;
    await _notifications.cancel(taskId.hashCode);
    logInfo('Cancelled file transfer progress notification for task: $taskId');
  }

  /// Cancel all file transfer notifications for a specific task (progress + status)
  Future<void> cancelAllFileTransferNotifications(String taskId) async {
    if (!_isInitialized) return;

    // Cancel progress notification
    await _notifications.cancel(taskId.hashCode);

    // Cancel status notification
    await _notifications.cancel('${taskId}_status'.hashCode);

    logInfo('Cancelled all file transfer notifications for task: $taskId');
  }

  /// Cancel all progress notifications (useful when stopping all transfers)
  Future<void> cancelAllProgressNotifications() async {
    if (!_isInitialized) return;

    // Unfortunately, flutter_local_notifications doesn't provide filtering by channel
    // For now, we'll need to track notification IDs if we want precise cancellation
    logInfo('Progress notifications would be cancelled if we tracked IDs');
  }

  /// Clear all P2P notifications
  Future<void> clearAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Encode payload for notification
  String _encodePayload(P2PNotificationPayload payload) {
    return jsonEncode(payload.toJson());
  }

  /// Check if notifications are enabled
  bool get isEnabled => _isInitialized && _permissionsGranted;

  /// Get pending notifications (platform dependent)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Cancel a file transfer status notification by task ID
  Future<void> cancelFileTransferStatus(String taskId) async {
    if (!_isInitialized) return;
    await _notifications.cancel('${taskId}_status'.hashCode);
    logInfo('Cancelled file transfer status notification for task: $taskId');
  }
}
