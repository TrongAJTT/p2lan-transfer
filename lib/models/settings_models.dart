import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:p2lan/models/p2p_models.dart';

part 'settings_models.g.dart';

@Collection()
class ExtensibleSettings {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String modelCode; // Unique identifier for each settings type

  String settingsJson; // JSON string containing the actual settings data

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  ExtensibleSettings({
    required this.modelCode,
    required this.settingsJson,
  });

  ExtensibleSettings copyWith({
    String? modelCode,
    String? settingsJson,
  }) {
    final result = ExtensibleSettings(
      modelCode: modelCode ?? this.modelCode,
      settingsJson: settingsJson ?? this.settingsJson,
    );
    result.id = id;
    result.updatedAt = DateTime.now();
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelCode': modelCode,
      'settingsJson': settingsJson,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ExtensibleSettings.fromJson(Map<String, dynamic> json) {
    final result = ExtensibleSettings(
      modelCode: json['modelCode'] ?? '',
      settingsJson: json['settingsJson'] ?? '{}',
    );
    result.id = json['id'] ?? Isar.autoIncrement;
    result.createdAt =
        DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();
    result.updatedAt =
        DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now();
    return result;
  }

  /// Parse the settings JSON and return as a Map
  Map<String, dynamic> getSettingsAsMap() {
    try {
      final decoded =
          Map<String, dynamic>.from(const JsonDecoder().convert(settingsJson));
      return decoded;
    } catch (e) {
      // Return empty map if JSON parsing fails
      return <String, dynamic>{};
    }
  }
}

/// Data & Storage settings (replaces GlobalSettingsData)
class DataAndStorageSettingsData {
  final int logRetentionDays; // -1 means keep forever

  const DataAndStorageSettingsData({
    this.logRetentionDays = 5,
  });

  Map<String, dynamic> toJson() {
    return {
      'logRetentionDays': logRetentionDays,
    };
  }

  factory DataAndStorageSettingsData.fromJson(Map<String, dynamic> json) {
    return DataAndStorageSettingsData(
      logRetentionDays: json['logRetentionDays'] ?? 5,
    );
  }

  DataAndStorageSettingsData copyWith({
    int? logRetentionDays,
  }) {
    return DataAndStorageSettingsData(
      logRetentionDays: logRetentionDays ?? this.logRetentionDays,
    );
  }
}

/// User Interface settings data structure
class UserInterfaceSettingsData {
  final String themeMode; // 'system', 'light', 'dark'
  final String languageCode; // 'en', 'vi', etc.
  final bool
      useCompactLayoutOnMobile; // Use compact mode for mobile tab layouts
  final bool showShortcutsInTooltips; // Show keyboard shortcuts in tooltips

  UserInterfaceSettingsData({
    this.themeMode = 'system',
    this.languageCode = 'en',
    this.useCompactLayoutOnMobile = false,
    this.showShortcutsInTooltips = false, // Match ShortcutTooltipUtils default
  });

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'languageCode': languageCode,
      'useCompactLayoutOnMobile': useCompactLayoutOnMobile,
      'showShortcutsInTooltips': showShortcutsInTooltips,
    };
  }

  factory UserInterfaceSettingsData.fromJson(Map<String, dynamic> json) {
    return UserInterfaceSettingsData(
      themeMode: json['themeMode'] ?? 'system',
      languageCode: json['languageCode'] ?? 'en',
      useCompactLayoutOnMobile: json['useCompactLayoutOnMobile'] ?? false,
      showShortcutsInTooltips: json['showShortcutsInTooltips'] ?? false,
    );
  }

  UserInterfaceSettingsData copyWith({
    String? themeMode,
    String? languageCode,
    bool? useCompactLayoutOnMobile,
    bool? showShortcutsInTooltips,
  }) {
    return UserInterfaceSettingsData(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      useCompactLayoutOnMobile:
          useCompactLayoutOnMobile ?? this.useCompactLayoutOnMobile,
      showShortcutsInTooltips:
          showShortcutsInTooltips ?? this.showShortcutsInTooltips,
    );
  }
}

/// P2P transfer settings data structure (replaces P2PDataTransferSettings and P2PFileStorageSettings)
class P2PTransferSettingsData {
  final String downloadPath;
  final bool createDateFolders;
  final bool createSenderFolders;
  final int maxReceiveFileSize; // In bytes
  final int maxTotalReceiveSize; // In bytes
  final int maxConcurrentTasks;
  final String sendProtocol; // e.g., 'TCP', 'UDP'
  final int maxChunkSize; // In kilobytes
  final String? customDisplayName;
  final int uiRefreshRateSeconds;
  final bool enableNotifications;
  final EncryptionType encryptionType;
  final bool enableCompression;
  final String compressionAlgorithm; // 'auto', 'gzip', 'deflate', 'none'
  final double compressionThreshold; // Only compress if ratio > this value
  final bool adaptiveCompression; // Let system choose best algorithm
  final bool autoCleanupCompletedTasks; // Auto cleanup completed transfer tasks
  final bool autoCleanupCancelledTasks; // Auto cleanup cancelled transfer tasks
  final bool autoCleanupFailedTasks; // Auto cleanup failed transfer tasks
  final int autoCleanupDelaySeconds; // Delay before auto cleanup (seconds)
  final bool clearTransfersAtStartup; // Clear stale transfers at app startup
  final bool autoCheckUpdatesDaily; // Check for app updates once per day

  P2PTransferSettingsData({
    this.downloadPath = '',
    this.createDateFolders = false,
    this.createSenderFolders = true,
    this.maxReceiveFileSize = 1073741824, // 1GB in bytes
    this.maxTotalReceiveSize = 5368709120, // 5GB in bytes
    this.maxConcurrentTasks = 3,
    this.sendProtocol = 'TCP',
    this.maxChunkSize = 1024, // 1MB in KB
    this.customDisplayName,
    this.uiRefreshRateSeconds = 0,
    this.enableNotifications =
        false, // Default to false to reduce notification spam
    this.encryptionType =
        EncryptionType.none, // Default to no encryption for stability
    this.enableCompression = false, // Default to false to avoid Android crashes
    this.compressionAlgorithm = 'none', // Default to no compression
    this.compressionThreshold = 1.1, // Only compress if 10% or better reduction
    this.adaptiveCompression = false, // Disable adaptive compression by default
    this.autoCleanupCompletedTasks =
        false, // Default: do not auto cleanup completed tasks
    this.autoCleanupCancelledTasks =
        true, // Auto cleanup cancelled tasks by default
    this.autoCleanupFailedTasks = true, // Auto cleanup failed tasks by default
    this.autoCleanupDelaySeconds =
        5, // Default 5 seconds delay for completed tasks
    this.clearTransfersAtStartup = false, // Default: keep stale tasks
    this.autoCheckUpdatesDaily = true, // Default: check updates daily
  });

  Map<String, dynamic> toJson() {
    return {
      'downloadPath': downloadPath,
      'createDateFolders': createDateFolders,
      'createSenderFolders': createSenderFolders,
      'maxReceiveFileSize': maxReceiveFileSize,
      'maxTotalReceiveSize': maxTotalReceiveSize,
      'maxConcurrentTasks': maxConcurrentTasks,
      'sendProtocol': sendProtocol,
      'maxChunkSize': maxChunkSize,
      'customDisplayName': customDisplayName,
      'uiRefreshRateSeconds': uiRefreshRateSeconds,
      'enableNotifications': enableNotifications,
      'encryptionType': encryptionType.name,
      'enableCompression': enableCompression,
      'compressionAlgorithm': compressionAlgorithm,
      'compressionThreshold': compressionThreshold,
      'adaptiveCompression': adaptiveCompression,
      'autoCleanupCompletedTasks': autoCleanupCompletedTasks,
      'autoCleanupCancelledTasks': autoCleanupCancelledTasks,
      'autoCleanupFailedTasks': autoCleanupFailedTasks,
      'autoCleanupDelaySeconds': autoCleanupDelaySeconds,
      'clearTransfersAtStartup': clearTransfersAtStartup,
      'autoCheckUpdatesDaily': autoCheckUpdatesDaily,
    };
  }

  factory P2PTransferSettingsData.fromJson(Map<String, dynamic> json) {
    return P2PTransferSettingsData(
      downloadPath: json['downloadPath'] ?? '',
      createDateFolders: json['createDateFolders'] ?? false,
      createSenderFolders: json['createSenderFolders'] ?? true,
      maxReceiveFileSize: json['maxReceiveFileSize'] ?? 1073741824,
      maxTotalReceiveSize: json['maxTotalReceiveSize'] ?? 5368709120,
      maxConcurrentTasks: json['maxConcurrentTasks'] ?? 3,
      sendProtocol: json['sendProtocol'] ?? 'TCP',
      maxChunkSize:
          json['maxChunkSize'] ?? 2048, // 🚀 Tăng từ 1024KB lên 2048KB (2MB)
      customDisplayName: json['customDisplayName'],
      uiRefreshRateSeconds: json['uiRefreshRateSeconds'] ?? 0,
      enableNotifications: json['enableNotifications'] ?? false,
      encryptionType: EncryptionType.values.firstWhere(
        (e) => e.name == json['encryptionType'],
        orElse: () => EncryptionType.none, // Safe default
      ),
      enableCompression: json['enableCompression'] ?? false, // Safe default
      compressionAlgorithm:
          json['compressionAlgorithm'] ?? 'none', // Safe default
      compressionThreshold: (json['compressionThreshold'] as double?) ?? 1.1,
      adaptiveCompression: json['adaptiveCompression'] ?? false, // Safe default
      autoCleanupCompletedTasks: json['autoCleanupCompletedTasks'] ?? false,
      autoCleanupCancelledTasks: json['autoCleanupCancelledTasks'] ?? true,
      autoCleanupFailedTasks: json['autoCleanupFailedTasks'] ?? true,
      autoCleanupDelaySeconds: json['autoCleanupDelaySeconds'] ?? 5,
      clearTransfersAtStartup: json['clearTransfersAtStartup'] ?? false,
      autoCheckUpdatesDaily: json['autoCheckUpdatesDaily'] ?? true,
    );
  }

  P2PTransferSettingsData copyWith({
    String? downloadPath,
    bool? createDateFolders,
    bool? createSenderFolders,
    int? maxReceiveFileSize,
    int? maxTotalReceiveSize,
    int? maxConcurrentTasks,
    String? sendProtocol,
    int? maxChunkSize,
    String? customDisplayName,
    int? uiRefreshRateSeconds,
    bool? enableNotifications,
    EncryptionType? encryptionType,
    bool? enableCompression,
    String? compressionAlgorithm,
    double? compressionThreshold,
    bool? adaptiveCompression,
    bool? autoCleanupCompletedTasks,
    bool? autoCleanupCancelledTasks,
    bool? autoCleanupFailedTasks,
    int? autoCleanupDelaySeconds,
    bool? clearTransfersAtStartup,
    bool? autoCheckUpdatesDaily,
  }) {
    return P2PTransferSettingsData(
      downloadPath: downloadPath ?? this.downloadPath,
      createDateFolders: createDateFolders ?? this.createDateFolders,
      createSenderFolders: createSenderFolders ?? this.createSenderFolders,
      maxReceiveFileSize: maxReceiveFileSize ?? this.maxReceiveFileSize,
      maxTotalReceiveSize: maxTotalReceiveSize ?? this.maxTotalReceiveSize,
      maxConcurrentTasks: maxConcurrentTasks ?? this.maxConcurrentTasks,
      sendProtocol: sendProtocol ?? this.sendProtocol,
      maxChunkSize: maxChunkSize ?? this.maxChunkSize,
      customDisplayName: customDisplayName ?? this.customDisplayName,
      uiRefreshRateSeconds: uiRefreshRateSeconds ?? this.uiRefreshRateSeconds,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      encryptionType: encryptionType ?? this.encryptionType,
      enableCompression: enableCompression ?? this.enableCompression,
      compressionAlgorithm: compressionAlgorithm ?? this.compressionAlgorithm,
      compressionThreshold: compressionThreshold ?? this.compressionThreshold,
      adaptiveCompression: adaptiveCompression ?? this.adaptiveCompression,
      autoCleanupCompletedTasks:
          autoCleanupCompletedTasks ?? this.autoCleanupCompletedTasks,
      autoCleanupCancelledTasks:
          autoCleanupCancelledTasks ?? this.autoCleanupCancelledTasks,
      autoCleanupFailedTasks:
          autoCleanupFailedTasks ?? this.autoCleanupFailedTasks,
      autoCleanupDelaySeconds:
          autoCleanupDelaySeconds ?? this.autoCleanupDelaySeconds,
      clearTransfersAtStartup:
          clearTransfersAtStartup ?? this.clearTransfersAtStartup,
      autoCheckUpdatesDaily:
          autoCheckUpdatesDaily ?? this.autoCheckUpdatesDaily,
    );
  }
}

/// P2P General Settings (notifications, UI refresh, cleanup)
class P2PGeneralSettingsData {
  final String? displayName;
  final bool enableNotifications;
  final bool autoCleanupCompletedTasks;
  final bool autoCleanupCancelledTasks;
  final bool autoCleanupFailedTasks;
  final int autoCleanupDelaySeconds;
  final bool clearTransfersAtStartup;
  final int uiRefreshRateSeconds;
  final bool autoCheckUpdatesDaily;

  const P2PGeneralSettingsData({
    this.displayName,
    this.enableNotifications = false,
    this.autoCleanupCompletedTasks = false,
    this.autoCleanupCancelledTasks = true,
    this.autoCleanupFailedTasks = true,
    this.autoCleanupDelaySeconds = 5,
    this.clearTransfersAtStartup = false,
    this.uiRefreshRateSeconds = 0,
    this.autoCheckUpdatesDaily = true,
  });

  P2PGeneralSettingsData copyWith({
    String? displayName,
    bool? enableNotifications,
    bool? autoCleanupCompletedTasks,
    bool? autoCleanupCancelledTasks,
    bool? autoCleanupFailedTasks,
    int? autoCleanupDelaySeconds,
    bool? clearTransfersAtStartup,
    int? uiRefreshRateSeconds,
    bool? autoCheckUpdatesDaily,
  }) {
    return P2PGeneralSettingsData(
      displayName: displayName ?? this.displayName,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      autoCleanupCompletedTasks:
          autoCleanupCompletedTasks ?? this.autoCleanupCompletedTasks,
      autoCleanupCancelledTasks:
          autoCleanupCancelledTasks ?? this.autoCleanupCancelledTasks,
      autoCleanupFailedTasks:
          autoCleanupFailedTasks ?? this.autoCleanupFailedTasks,
      autoCleanupDelaySeconds:
          autoCleanupDelaySeconds ?? this.autoCleanupDelaySeconds,
      clearTransfersAtStartup:
          clearTransfersAtStartup ?? this.clearTransfersAtStartup,
      uiRefreshRateSeconds: uiRefreshRateSeconds ?? this.uiRefreshRateSeconds,
      autoCheckUpdatesDaily:
          autoCheckUpdatesDaily ?? this.autoCheckUpdatesDaily,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'enableNotifications': enableNotifications,
      'autoCleanupCompletedTasks': autoCleanupCompletedTasks,
      'autoCleanupCancelledTasks': autoCleanupCancelledTasks,
      'autoCleanupFailedTasks': autoCleanupFailedTasks,
      'autoCleanupDelaySeconds': autoCleanupDelaySeconds,
      'clearTransfersAtStartup': clearTransfersAtStartup,
      'uiRefreshRateSeconds': uiRefreshRateSeconds,
      'autoCheckUpdatesDaily': autoCheckUpdatesDaily,
    };
  }

  factory P2PGeneralSettingsData.fromJson(Map<String, dynamic> json) {
    return P2PGeneralSettingsData(
      displayName: json['displayName'],
      enableNotifications: json['enableNotifications'] ?? false,
      autoCleanupCompletedTasks: json['autoCleanupCompletedTasks'] ?? false,
      autoCleanupCancelledTasks: json['autoCleanupCancelledTasks'] ?? true,
      autoCleanupFailedTasks: json['autoCleanupFailedTasks'] ?? true,
      autoCleanupDelaySeconds: json['autoCleanupDelaySeconds'] ?? 5,
      clearTransfersAtStartup: json['clearTransfersAtStartup'] ?? false,
      uiRefreshRateSeconds: json['uiRefreshRateSeconds'] ?? 0,
      autoCheckUpdatesDaily: json['autoCheckUpdatesDaily'] ?? true,
    );
  }
}

/// P2P Receiver Location & Size Limits
class P2PReceiverSettingsData {
  final String downloadPath;
  final bool createDateFolders;
  final bool createSenderFolders;
  final int maxReceiveFileSize;
  final int maxTotalReceiveSize;

  const P2PReceiverSettingsData({
    this.downloadPath = '',
    this.createDateFolders = false,
    this.createSenderFolders = true,
    this.maxReceiveFileSize = 1073741824,
    this.maxTotalReceiveSize = 5368709120,
  });

  P2PReceiverSettingsData copyWith({
    String? downloadPath,
    bool? createDateFolders,
    bool? createSenderFolders,
    int? maxReceiveFileSize,
    int? maxTotalReceiveSize,
  }) {
    return P2PReceiverSettingsData(
      downloadPath: downloadPath ?? this.downloadPath,
      createDateFolders: createDateFolders ?? this.createDateFolders,
      createSenderFolders: createSenderFolders ?? this.createSenderFolders,
      maxReceiveFileSize: maxReceiveFileSize ?? this.maxReceiveFileSize,
      maxTotalReceiveSize: maxTotalReceiveSize ?? this.maxTotalReceiveSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'downloadPath': downloadPath,
      'createDateFolders': createDateFolders,
      'createSenderFolders': createSenderFolders,
      'maxReceiveFileSize': maxReceiveFileSize,
      'maxTotalReceiveSize': maxTotalReceiveSize,
    };
  }

  factory P2PReceiverSettingsData.fromJson(Map<String, dynamic> json) {
    return P2PReceiverSettingsData(
      downloadPath: json['downloadPath'] ?? '',
      createDateFolders: json['createDateFolders'] ?? false,
      createSenderFolders: json['createSenderFolders'] ?? true,
      maxReceiveFileSize: json['maxReceiveFileSize'] ?? 1073741824,
      maxTotalReceiveSize: json['maxTotalReceiveSize'] ?? 5368709120,
    );
  }
}

/// P2P Network & Speed
class P2PNetworkSettingsData {
  final String sendProtocol; // 'TCP' | 'UDP'
  final int maxConcurrentTasks;
  final int maxChunkSize; // KB

  const P2PNetworkSettingsData({
    this.sendProtocol = 'TCP',
    this.maxConcurrentTasks = 3,
    this.maxChunkSize = 1024,
  });

  P2PNetworkSettingsData copyWith({
    String? sendProtocol,
    int? maxConcurrentTasks,
    int? maxChunkSize,
  }) {
    return P2PNetworkSettingsData(
      sendProtocol: sendProtocol ?? this.sendProtocol,
      maxConcurrentTasks: maxConcurrentTasks ?? this.maxConcurrentTasks,
      maxChunkSize: maxChunkSize ?? this.maxChunkSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sendProtocol': sendProtocol,
      'maxConcurrentTasks': maxConcurrentTasks,
      'maxChunkSize': maxChunkSize,
    };
  }

  factory P2PNetworkSettingsData.fromJson(Map<String, dynamic> json) {
    return P2PNetworkSettingsData(
      sendProtocol: json['sendProtocol'] ?? 'TCP',
      maxConcurrentTasks: json['maxConcurrentTasks'] ?? 3,
      maxChunkSize: json['maxChunkSize'] ?? 1024,
    );
  }
}

/// P2P Advanced (security, encryption & compression)
class P2PAdvancedSettingsData {
  final EncryptionType encryptionType;

  const P2PAdvancedSettingsData({
    this.encryptionType = EncryptionType.none,
  });

  P2PAdvancedSettingsData copyWith({
    EncryptionType? encryptionType,
  }) {
    return P2PAdvancedSettingsData(
      encryptionType: encryptionType ?? this.encryptionType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'encryptionType': encryptionType.name,
    };
  }

  factory P2PAdvancedSettingsData.fromJson(Map<String, dynamic> json) {
    return P2PAdvancedSettingsData(
      encryptionType: EncryptionType.values.firstWhere(
        (e) => e.name == json['encryptionType'],
        orElse: () => EncryptionType.none,
      ),
    );
  }
}
