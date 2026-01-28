import 'package:p2lan/models/settings_models.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:p2lan/services/app_logger.dart';

/// Utility class for resetting settings to safe defaults
class SettingsResetUtils {
  /// Reset P2P settings to safe defaults (no encryption, no compression)
  static Future<void> resetP2PSettingsToSafeDefaults() async {
    try {
      logInfo('SettingsResetUtils: Resetting P2P settings to safe defaults');

      // Create safe default settings split by modules
      const general = P2PGeneralSettingsData(
        enableNotifications: false,
        autoCleanupCompletedTasks: false,
        autoCleanupCancelledTasks: true,
        autoCleanupFailedTasks: true,
        autoCleanupDelaySeconds: 5,
        clearTransfersAtStartup: false,
        uiRefreshRateSeconds: 0,
        autoCheckUpdatesDaily: true,
      );
      const receiver = P2PReceiverSettingsData(
        downloadPath: '',
        createDateFolders: false,
        createSenderFolders: true,
        maxReceiveFileSize: 1073741824,
        maxTotalReceiveSize: 5368709120,
      );
      const network = P2PNetworkSettingsData(
        sendProtocol: 'TCP',
        maxConcurrentTasks: 3,
        maxChunkSize: 1024,
      );
      const advanced = P2PAdvancedSettingsData(
        encryptionType: EncryptionType.none,
      );

      // Save the safe settings per module
      await ExtensibleSettingsService.updateGeneralSettings(general);
      await ExtensibleSettingsService.updateReceiverSettings(receiver);
      await ExtensibleSettingsService.updateNetworkSettings(network);
      await ExtensibleSettingsService.updateAdvancedSettings(advanced);

      logInfo(
          'SettingsResetUtils: P2P settings reset to safe defaults successfully');
    } catch (e) {
      logError('SettingsResetUtils: Failed to reset P2P settings: $e');
      rethrow;
    }
  }

  /// Reset only the performance-related settings while keeping user preferences
  static Future<void> resetPerformanceSettings() async {
    try {
      logInfo('SettingsResetUtils: Resetting performance settings only');

      // Update only performance-related fields
      const network = P2PNetworkSettingsData(
        maxChunkSize: 1024,
        maxConcurrentTasks: 3,
      );
      const advanced = P2PAdvancedSettingsData(
        encryptionType: EncryptionType.none,
      );

      await ExtensibleSettingsService.updateNetworkSettings(network);
      await ExtensibleSettingsService.updateAdvancedSettings(advanced);

      logInfo('SettingsResetUtils: Performance settings reset successfully');
    } catch (e) {
      logError('SettingsResetUtils: Failed to reset performance settings: $e');
      rethrow;
    }
  }

  /// Get current settings summary for debugging
  static Future<Map<String, dynamic>> getSettingsSummary() async {
    try {
      final settings = await ExtensibleSettingsService.getNetworkSettings();

      return {
        'maxChunkSize': settings.maxChunkSize,
        'maxConcurrentTasks': settings.maxConcurrentTasks,
        'sendProtocol': settings.sendProtocol,
      };
    } catch (e) {
      logError('SettingsResetUtils: Failed to get settings summary: $e');
      return {'error': e.toString()};
    }
  }
}
