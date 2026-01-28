import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:p2lan/models/settings_models.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/isar_service.dart';
import 'package:p2lan/services/p2p_services/p2p_service_manager.dart';

/// Service for managing ExtensibleSettings with extensible architecture
class ExtensibleSettingsService {
  // Model codes for different settings types
  // Data & Storage (replaces global settings)
  static const String dataAndStorageSettingsCode = 'data_and_storage_settings';
  static const String userInterfaceSettingsCode = 'user_interface_settings';
  // Legacy aggregate P2P settings
  static const String p2pTransferSettingsCode = 'p2p_transfer_settings';
  // Old split codes (for migration)
  static const String _oldGeneralSettingsCode = 'p2p_general_settings';
  static const String _oldReceiverSettingsCode = 'p2p_receiver_settings';
  static const String _oldNetworkSettingsCode = 'p2p_network_settings';
  static const String _oldAdvancedSettingsCode = 'p2p_advanced_settings';
  // New split settings codes per section (without 'p2p')
  static const String generalSettingsCode = 'general_settings';
  static const String receiverSettingsCode = 'receiver_settings';
  static const String networkSettingsCode = 'network_settings';
  static const String advancedSettingsCode = 'advanced_settings';

  /// Initialize the settings system and create defaults if needed
  /// Internal beta v0.5.0 - No migration needed
  static Future<void> initialize() async {
    logInfo("ExtensibleSettingsService: Initializing settings system...");

    // Ensure all default settings exist
    await _ensureDefaultSettings();

    // Migrate legacy aggregate P2P settings to split models if needed
    await _migrateLegacyP2PToSplit();
    // Rename old split codes to new simple codes if needed
    await _migrateOldSplitCodesToNew();

    logInfo("ExtensibleSettingsService: Initialization completed.");
  }

  /// Alias for initialize() for backward compatibility
  static Future<void> performMigration() async {
    await initialize();
  }

  /// Ensure all default settings exist
  static Future<void> _ensureDefaultSettings() async {
    await _ensureDataAndStorageSettings();
    await _ensureUserInterfaceSettings();
    // Ensure new split settings exist
    await _ensureReceiverSettings();
    await _ensureNetworkSettings();
    await _ensureAdvancedSettings();
    await _ensureGeneralSettings();
  }

  /// Ensure Data & Storage settings exist with defaults
  static Future<void> _ensureDataAndStorageSettings() async {
    final existing = await getSettingsModel(dataAndStorageSettingsCode);
    if (existing == null) {
      const defaultData = DataAndStorageSettingsData();
      await saveSettingsModel(
        dataAndStorageSettingsCode,
        defaultData.toJson(),
      );
    }
  }

  /// Ensure user interface settings exist with defaults
  static Future<void> _ensureUserInterfaceSettings() async {
    final existing = await getSettingsModel(userInterfaceSettingsCode);
    if (existing == null) {
      final defaultData = UserInterfaceSettingsData();
      await saveSettingsModel(
        userInterfaceSettingsCode,
        defaultData.toJson(),
      );
    }
  }

  // Legacy aggregate defaults are no longer created

  static Future<void> _ensureGeneralSettings() async {
    final existing = await getSettingsModel(generalSettingsCode);
    if (existing == null) {
      final defaultData = P2PGeneralSettingsData();
      await saveSettingsModel(generalSettingsCode, defaultData.toJson());
    }
  }

  static Future<void> _ensureReceiverSettings() async {
    final existing = await getSettingsModel(receiverSettingsCode);
    if (existing == null) {
      final defaultData = P2PReceiverSettingsData();
      await saveSettingsModel(receiverSettingsCode, defaultData.toJson());
    }
  }

  static Future<void> _ensureNetworkSettings() async {
    final existing = await getSettingsModel(networkSettingsCode);
    if (existing == null) {
      final defaultData = P2PNetworkSettingsData();
      await saveSettingsModel(networkSettingsCode, defaultData.toJson());
    }
  }

  static Future<void> _ensureAdvancedSettings() async {
    final existing = await getSettingsModel(advancedSettingsCode);
    if (existing == null) {
      final defaultData = P2PAdvancedSettingsData();
      await saveSettingsModel(advancedSettingsCode, defaultData.toJson());
    }
  }

  /// Get a settings model by its code
  static Future<ExtensibleSettings?> getSettingsModel(String modelCode) async {
    final isar = IsarService.isar;
    return await isar.extensibleSettings
        .where()
        .modelCodeEqualTo(modelCode)
        .findFirst();
  }

  /// Save a settings model
  static Future<void> saveSettingsModel(
    String modelCode,
    Map<String, dynamic> settingsData,
  ) async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      final existing = await isar.extensibleSettings
          .where()
          .modelCodeEqualTo(modelCode)
          .findFirst();

      if (existing != null) {
        // Update existing
        final updated = existing.copyWith(
          settingsJson: jsonEncode(settingsData),
        );
        await isar.extensibleSettings.put(updated);
      } else {
        // Create new
        final newModel = ExtensibleSettings(
          modelCode: modelCode,
          settingsJson: jsonEncode(settingsData),
        );
        await isar.extensibleSettings.put(newModel);
      }
    });

    logInfo("ExtensibleSettingsService: Settings saved for $modelCode");
  }

  /// Get Data & Storage settings
  static Future<DataAndStorageSettingsData> getDataAndStorageSettings() async {
    final model = await getSettingsModel(dataAndStorageSettingsCode);
    if (model == null) {
      await _ensureDataAndStorageSettings();
      return const DataAndStorageSettingsData();
    }

    final json = jsonDecode(model.settingsJson) as Map<String, dynamic>;
    return DataAndStorageSettingsData.fromJson(json);
  }

  /// Update Data & Storage settings
  static Future<void> updateDataAndStorageSettings(
      DataAndStorageSettingsData data) async {
    await saveSettingsModel(
      dataAndStorageSettingsCode,
      data.toJson(),
    );
  }

  /// Get user interface settings
  static Future<UserInterfaceSettingsData> getUserInterfaceSettings() async {
    final model = await getSettingsModel(userInterfaceSettingsCode);
    if (model == null) {
      await _ensureUserInterfaceSettings();
      return UserInterfaceSettingsData();
    }

    final json = jsonDecode(model.settingsJson) as Map<String, dynamic>;
    return UserInterfaceSettingsData.fromJson(json);
  }

  /// Update user interface settings
  static Future<void> updateUserInterfaceSettings(
      UserInterfaceSettingsData data) async {
    await saveSettingsModel(
      userInterfaceSettingsCode,
      data.toJson(),
    );
  }

  /// Get P2P transfer settings
  static Future<P2PTransferSettingsData> getP2PTransferSettings() async {
    // Combine from split models to provide a full view
    return await _combineP2PSettingsFromSplit();
  }

  /// Update P2P transfer settings
  static Future<void> updateP2PTransferSettings(
      P2PTransferSettingsData data) async {
    // Fan-out to split models and keep legacy aggregate in sync
    await saveSettingsModel(
        generalSettingsCode,
        P2PGeneralSettingsData(
          enableNotifications: data.enableNotifications,
          autoCleanupCompletedTasks: data.autoCleanupCompletedTasks,
          autoCleanupCancelledTasks: data.autoCleanupCancelledTasks,
          autoCleanupFailedTasks: data.autoCleanupFailedTasks,
          autoCleanupDelaySeconds: data.autoCleanupDelaySeconds,
          clearTransfersAtStartup: data.clearTransfersAtStartup,
          uiRefreshRateSeconds: data.uiRefreshRateSeconds,
          autoCheckUpdatesDaily: data.autoCheckUpdatesDaily,
        ).toJson());

    await saveSettingsModel(
        receiverSettingsCode,
        P2PReceiverSettingsData(
          downloadPath: data.downloadPath,
          createDateFolders: data.createDateFolders,
          createSenderFolders: data.createSenderFolders,
          maxReceiveFileSize: data.maxReceiveFileSize,
          maxTotalReceiveSize: data.maxTotalReceiveSize,
        ).toJson());

    await saveSettingsModel(
        networkSettingsCode,
        P2PNetworkSettingsData(
          sendProtocol: data.sendProtocol,
          maxConcurrentTasks: data.maxConcurrentTasks,
          maxChunkSize: data.maxChunkSize,
        ).toJson());

    await saveSettingsModel(
        advancedSettingsCode,
        P2PAdvancedSettingsData(
          encryptionType: data.encryptionType,
        ).toJson());

    // No longer persist legacy aggregate record
  }

  // Split P2P getters
  static Future<P2PGeneralSettingsData> getGeneralSettings() async {
    final model = await getSettingsModel(generalSettingsCode);
    if (model == null) {
      await _ensureGeneralSettings();
      return P2PGeneralSettingsData();
    }
    final json = jsonDecode(model.settingsJson) as Map<String, dynamic>;
    return P2PGeneralSettingsData.fromJson(json);
  }

  static Future<P2PReceiverSettingsData> getReceiverSettings() async {
    final model = await getSettingsModel(receiverSettingsCode);
    if (model == null) {
      await _ensureReceiverSettings();
      return P2PReceiverSettingsData();
    }
    final json = jsonDecode(model.settingsJson) as Map<String, dynamic>;
    return P2PReceiverSettingsData.fromJson(json);
  }

  static Future<P2PNetworkSettingsData> getNetworkSettings() async {
    final model = await getSettingsModel(networkSettingsCode);
    if (model == null) {
      await _ensureNetworkSettings();
      return P2PNetworkSettingsData();
    }
    final json = jsonDecode(model.settingsJson) as Map<String, dynamic>;
    return P2PNetworkSettingsData.fromJson(json);
  }

  static Future<P2PAdvancedSettingsData> getAdvancedSettings() async {
    final model = await getSettingsModel(advancedSettingsCode);
    if (model == null) {
      await _ensureAdvancedSettings();
      return P2PAdvancedSettingsData();
    }
    final json = jsonDecode(model.settingsJson) as Map<String, dynamic>;
    return P2PAdvancedSettingsData.fromJson(json);
  }

  // Split P2P updaters
  static Future<void> updateGeneralSettings(P2PGeneralSettingsData data) async {
    await saveSettingsModel(generalSettingsCode, data.toJson());
    // Also update current user's display name if provided
    try {
      if (data.displayName != null && data.displayName!.trim().isNotEmpty) {
        final manager = P2PServiceManager.instance;
        if (manager.currentUser != null &&
            manager.currentUser!.displayName != data.displayName) {
          manager.currentUser!.displayName = data.displayName!.trim();
          logInfo(
              'ExtensibleSettingsService: Updated current user displayName to ${data.displayName}');
        }
      }
    } catch (_) {}
  }

  static Future<void> updateReceiverSettings(
      P2PReceiverSettingsData data) async {
    await saveSettingsModel(receiverSettingsCode, data.toJson());
  }

  static Future<void> updateNetworkSettings(P2PNetworkSettingsData data) async {
    await saveSettingsModel(networkSettingsCode, data.toJson());
  }

  static Future<void> updateAdvancedSettings(
      P2PAdvancedSettingsData data) async {
    await saveSettingsModel(advancedSettingsCode, data.toJson());
  }

  /// Get all settings models
  static Future<List<ExtensibleSettings>> getAllSettingsModels() async {
    final isar = IsarService.isar;
    return await isar.extensibleSettings.where().findAll();
  }

  /// Delete a settings model by code
  static Future<void> deleteSettingsModel(String modelCode) async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      final existing = await isar.extensibleSettings
          .where()
          .modelCodeEqualTo(modelCode)
          .findFirst();

      if (existing != null) {
        await isar.extensibleSettings.delete(existing.id);
        logInfo("ExtensibleSettingsService: Deleted settings model $modelCode");
      }
    });
  }

  /// Clear all settings models (for debug/reset purposes)
  static Future<void> clearAllSettingsModels() async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      await isar.extensibleSettings.clear();
    });

    logInfo("ExtensibleSettingsService: All settings models cleared");
  }

  // Combine all split P2P models into the legacy aggregate representation
  static Future<P2PTransferSettingsData> _combineP2PSettingsFromSplit() async {
    final general = await getGeneralSettings();
    final receiver = await getReceiverSettings();
    final network = await getNetworkSettings();
    final advanced = await getAdvancedSettings();

    return P2PTransferSettingsData(
      downloadPath: receiver.downloadPath,
      createDateFolders: receiver.createDateFolders,
      createSenderFolders: receiver.createSenderFolders,
      maxReceiveFileSize: receiver.maxReceiveFileSize,
      maxTotalReceiveSize: receiver.maxTotalReceiveSize,
      maxConcurrentTasks: network.maxConcurrentTasks,
      sendProtocol: network.sendProtocol,
      maxChunkSize: network.maxChunkSize,
      uiRefreshRateSeconds: general.uiRefreshRateSeconds,
      enableNotifications: general.enableNotifications,
      encryptionType: advanced.encryptionType,
      autoCleanupCompletedTasks: general.autoCleanupCompletedTasks,
      autoCleanupCancelledTasks: general.autoCleanupCancelledTasks,
      autoCleanupFailedTasks: general.autoCleanupFailedTasks,
      autoCleanupDelaySeconds: general.autoCleanupDelaySeconds,
      clearTransfersAtStartup: general.clearTransfersAtStartup,
      autoCheckUpdatesDaily: general.autoCheckUpdatesDaily,
    );
  }

  // Legacy aggregate sync removed

  // One-time migration from legacy aggregate record to the split models
  static Future<void> _migrateLegacyP2PToSplit() async {
    final legacy = await getSettingsModel(p2pTransferSettingsCode);
    final hasGeneral = await getSettingsModel(generalSettingsCode) != null;
    final hasReceiver = await getSettingsModel(receiverSettingsCode) != null;
    final hasNetwork = await getSettingsModel(networkSettingsCode) != null;
    final hasAdvanced = await getSettingsModel(advancedSettingsCode) != null;

    if (legacy != null &&
        !(hasGeneral && hasReceiver && hasNetwork && hasAdvanced)) {
      try {
        final json = jsonDecode(legacy.settingsJson) as Map<String, dynamic>;
        final data = P2PTransferSettingsData.fromJson(json);

        await updateP2PTransferSettings(data);
        // Remove legacy aggregate after successful migration
        await deleteSettingsModel(p2pTransferSettingsCode);
        logInfo(
            'Migrated legacy P2P aggregate settings to split models and deleted legacy record');
      } catch (e) {
        logError('Migration of legacy P2P settings failed: $e');
      }
    }
  }

  /// Migrate old split codes (with 'p2p_' prefix) to new simplified codes
  static Future<void> _migrateOldSplitCodesToNew() async {
    Future<void> migrateCode(String oldCode, String newCode) async {
      final old = await getSettingsModel(oldCode);
      final hasNew = await getSettingsModel(newCode) != null;
      if (old != null && !hasNew) {
        final json = jsonDecode(old.settingsJson) as Map<String, dynamic>;
        await saveSettingsModel(newCode, json);
        await deleteSettingsModel(oldCode);
        logInfo('Migrated $oldCode -> $newCode');
      }
    }

    await migrateCode(_oldGeneralSettingsCode, generalSettingsCode);
    await migrateCode(_oldReceiverSettingsCode, receiverSettingsCode);
    await migrateCode(_oldNetworkSettingsCode, networkSettingsCode);
    await migrateCode(_oldAdvancedSettingsCode, advancedSettingsCode);
  }
}
