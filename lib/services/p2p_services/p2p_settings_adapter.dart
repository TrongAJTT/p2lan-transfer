import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/models/settings_models.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:p2lan/services/app_logger.dart';

/// Adapter service to bridge between old P2PDataTransferSettings and new ExtensibleSettings
/// This allows existing UI to work unchanged while using the new settings system underneath
class P2PSettingsAdapter {
  /// Convert P2PTransferSettingsData to P2PDataTransferSettings
  static P2PDataTransferSettings toOldSettings(
      P2PTransferSettingsData newSettings) {
    return P2PDataTransferSettings(
      downloadPath: newSettings.downloadPath,
      createDateFolders: newSettings.createDateFolders,
      createSenderFolders: newSettings.createSenderFolders,
      maxReceiveFileSize: newSettings.maxReceiveFileSize,
      maxTotalReceiveSize: newSettings.maxTotalReceiveSize,
      maxConcurrentTasks: newSettings.maxConcurrentTasks,
      sendProtocol: newSettings.sendProtocol,
      maxChunkSize: newSettings.maxChunkSize,
      customDisplayName: newSettings.customDisplayName,
      uiRefreshRateSeconds: newSettings.uiRefreshRateSeconds,
      enableNotifications: newSettings.enableNotifications,
      encryptionType: newSettings.encryptionType,
      autoCleanupCompletedTasks: newSettings.autoCleanupCompletedTasks,
      autoCleanupCancelledTasks: newSettings.autoCleanupCancelledTasks,
      autoCleanupFailedTasks: newSettings.autoCleanupFailedTasks,
      autoCleanupDelaySeconds: newSettings.autoCleanupDelaySeconds,
      clearTransfersAtStartup: newSettings.clearTransfersAtStartup,
    );
  }

  /// Convert P2PDataTransferSettings to P2PTransferSettingsData
  static P2PTransferSettingsData fromOldSettings(
      P2PDataTransferSettings oldSettings) {
    return P2PTransferSettingsData(
      downloadPath: oldSettings.downloadPath,
      createDateFolders: oldSettings.createDateFolders,
      createSenderFolders: oldSettings.createSenderFolders,
      maxReceiveFileSize: oldSettings.maxReceiveFileSize,
      maxTotalReceiveSize: oldSettings.maxTotalReceiveSize,
      maxConcurrentTasks: oldSettings.maxConcurrentTasks,
      sendProtocol: oldSettings.sendProtocol,
      maxChunkSize: oldSettings.maxChunkSize,
      customDisplayName: oldSettings.customDisplayName,
      uiRefreshRateSeconds: oldSettings.uiRefreshRateSeconds,
      enableNotifications: oldSettings.enableNotifications,
      encryptionType: oldSettings.encryptionType,
      autoCleanupCompletedTasks: oldSettings.autoCleanupCompletedTasks,
      autoCleanupCancelledTasks: oldSettings.autoCleanupCancelledTasks,
      autoCleanupFailedTasks: oldSettings.autoCleanupFailedTasks,
      autoCleanupDelaySeconds: oldSettings.autoCleanupDelaySeconds,
      clearTransfersAtStartup: oldSettings.clearTransfersAtStartup,
    );
  }

  /// Get settings in old format (for existing UI)
  static Future<P2PDataTransferSettings> getSettings() async {
    try {
      // Combine split models via service
      final combined = await ExtensibleSettingsService.getP2PTransferSettings();
      final oldSettings = toOldSettings(combined);

      // Ensure download path is initialized
      if (oldSettings.downloadPath.isEmpty) {
        final defaultPath = await _getDefaultDownloadPath();
        final updatedCombined = combined.copyWith(downloadPath: defaultPath);
        await ExtensibleSettingsService.updateP2PTransferSettings(
            updatedCombined);
        return toOldSettings(updatedCombined);
      }

      return oldSettings;
    } catch (e) {
      logError('Failed to get P2P settings: $e');
      return await _createDefaultOldSettings();
    }
  }

  /// Update settings from old format (for existing UI)
  static Future<void> updateSettings(
      P2PDataTransferSettings oldSettings) async {
    try {
      final newSettings = fromOldSettings(oldSettings);
      await ExtensibleSettingsService.updateP2PTransferSettings(newSettings);
      logInfo('Updated P2P settings through adapter');
    } catch (e) {
      logError('Failed to update P2P settings: $e');
      rethrow;
    }
  }

  /// Get default download path
  static Future<String> _getDefaultDownloadPath() async {
    if (Platform.isWindows) {
      return '${Platform.environment['USERPROFILE']}\\Downloads';
    } else if (Platform.isAndroid) {
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final androidPath = '${appDocDir.parent.path}/files';

        // Create directory if it doesn't exist
        final directory = Directory(androidPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        return androidPath;
      } catch (e) {
        logWarning('Failed to create Android path, using fallback: $e');
        return '/storage/emulated/0/Download';
      }
    } else {
      return '${Platform.environment['HOME']}/Downloads';
    }
  }

  /// Create default old settings
  static Future<P2PDataTransferSettings> _createDefaultOldSettings() async {
    final defaultPath = await _getDefaultDownloadPath();

    return P2PDataTransferSettings(
      downloadPath: defaultPath,
      createDateFolders: false,
      createSenderFolders: true,
      maxReceiveFileSize: 1073741824, // 1GB
      maxTotalReceiveSize: 5368709120, // 5GB
      maxConcurrentTasks: 3,
      sendProtocol: 'TCP',
      maxChunkSize: 1024, // 1MB in KB
      customDisplayName: null,
      uiRefreshRateSeconds: 0,
      enableNotifications:
          false, // Default to false to reduce notification spam
      encryptionType: EncryptionType.none, // Default to no encryption
    );
  }

  /// Migrate from old P2PDataTransferSettings to ExtensibleSettings (one-time migration)
  static Future<void> migrateFromOldSettings() async {
    try {
      // This would be called during app startup to migrate existing P2PDataTransferSettings
      // to the new ExtensibleSettings system
      logInfo(
          'P2P settings migration already handled by ExtensibleSettings initialization');
    } catch (e) {
      logError('Failed to migrate P2P settings: $e');
    }
  }

  /// Check if migration is needed
  static Future<bool> needsMigration() async {
    try {
      // Check if we have new settings
      final settings = await ExtensibleSettingsService.getP2PTransferSettings();
      return settings.downloadPath.isEmpty; // If empty, might need migration
    } catch (e) {
      return true; // If error, assume migration needed
    }
  }
}
