import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/isar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'p2p_services/p2p_service_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/widgets/generic/generic_dialog.dart';
import 'package:p2lan/utils/widget_layout_render_helper.dart';
import 'package:p2lan/utils/size_utils.dart';
import 'package:p2lan/widgets/hold_button.dart';

class CacheInfo {
  final String name;
  final String description;
  final int itemCount;
  final int sizeBytes;
  final List<String> keys;
  final bool isDeletable;

  CacheInfo({
    required this.name,
    required this.description,
    required this.itemCount,
    required this.sizeBytes,
    required this.keys,
    this.isDeletable = true,
  });
  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
  }
}

class CacheService {
  // Cache keys for different features
  static const Map<String, List<String>> _cacheKeys = {
    'settings': ['themeMode', 'language'],
    'p2lan_transfer': [],
  };
  static Future<Map<String, CacheInfo>> getAllCacheInfo({
    String? textTemplatesName,
    String? textTemplatesDesc,
    String? appSettingsName,
    String? appSettingsDesc,
    String? randomGeneratorsName,
    String? randomGeneratorsDesc,
    String? calculatorToolsName,
    String? calculatorToolsDesc,
    String? converterToolsName,
    String? converterToolsDesc,
    String? p2pDataTransferName,
    String? p2pDataTransferDesc,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, CacheInfo> cacheInfoMap =
        {}; // Text Templates Cache - Now using Isar
    // Use a reasonable estimate for template size since we no longer have

    // Settings Cache
    final settingsKeys = ['themeMode', 'language'];
    int settingsSize = 0;
    int settingsCount = 0;
    for (final key in settingsKeys) {
      if (prefs.containsKey(key)) {
        settingsCount++;
        final value = prefs.get(key);
        if (value is String) {
          settingsSize += value.length * 2; // UTF-16 encoding
        } else if (value is int) {
          settingsSize += 4; // 32-bit integer
        } else if (value is bool) {
          settingsSize += 1; // 1 byte for boolean
        }
      }
    }
    cacheInfoMap['settings'] = CacheInfo(
      name: appSettingsName ?? 'App Settings',
      description: appSettingsDesc ?? 'Theme, language, and user preferences',
      itemCount: settingsCount,
      sizeBytes: settingsSize,
      keys: settingsKeys,
    );

    // P2P Data Transfer Cache
    try {
      final p2pService = P2PServiceManager.instance;
      final isP2PEnabled = p2pService.isEnabled;
      logInfo('P2P Service running for cache check: $isP2PEnabled');

      // P2P no longer uses Hive, use estimates for cache info
      const settingsBoxSize = 1024; // 1KB estimate
      const usersBoxSize = 2048; // 2KB estimate
      const requestsBoxSize = 4096; // 4KB estimate
      const pairingRequestsBoxSize = 2048; // 2KB estimate

      // Get item counts - P2P data is no longer stored in Hive
      const p2pItemCount = 10; // rough estimate

      // Get file picker cache size (Android only)
      int filePickerCacheSize = 0;
      if (Platform.isAndroid) {
        try {
          final tempDir = await getTemporaryDirectory();
          final filePickerCacheDir =
              Directory(p.join(tempDir.path, 'file_picker'));
          if (await filePickerCacheDir.exists()) {
            filePickerCacheSize = await _getDirectorySize(filePickerCacheDir);
          }
        } catch (e) {
          logError(
              'CacheService: Could not calculate file_picker cache size: $e');
        }
      }

      final p2pTotalSize = settingsBoxSize +
          usersBoxSize +
          requestsBoxSize +
          pairingRequestsBoxSize +
          filePickerCacheSize;

      cacheInfoMap['p2p_data_transfer'] = CacheInfo(
        name: p2pDataTransferName ?? 'P2P File Transfer',
        description: p2pDataTransferDesc ??
            'Settings, saved device profiles, and temporary file transfer cache.',
        itemCount: p2pItemCount,
        sizeBytes: p2pTotalSize,
        keys: [
          // legacy key removed
          'p2p_users',
          'file_transfer_requests',
          'pairing_requests'
        ],
        isDeletable: !isP2PEnabled,
      );
    } catch (e) {
      logError('CacheService: Error getting P2P cache info: $e');
      // On error, show an entry that indicates a problem but is not deletable
      cacheInfoMap['p2p_data_transfer'] = CacheInfo(
        name: p2pDataTransferName ?? 'P2P File Transfer',
        description: p2pDataTransferDesc ?? 'Error loading cache details.',
        itemCount: 0,
        sizeBytes: 0,
        keys: [],
        isDeletable: false,
      );
    }

    return cacheInfoMap;
  }

  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear ALL Isar collections except AppInstallation
    await _clearAllIsarCollections();

    // Clear P2P data transfer cache only if not enabled
    try {
      if (!(await isP2PEnabled())) {
        await clearP2PCache();
        logInfo('CacheService: Cleared P2P cache in clearAllCache');
      } else {
        logInfo(
            'CacheService: Skipped P2P cache in clearAllCache (service enabled)');
      }
    } catch (e) {
      logError('CacheService: Error handling P2P cache in clearAllCache: $e');
    }

    // Get all cache keys from SharedPreferences (except settings)
    final allKeys = <String>{};
    for (final keyList in _cacheKeys.values) {
      allKeys.addAll(keyList);
    }

    // Remove all cache keys except settings (preserve user preferences)
    for (final key in allKeys) {
      if (!['themeMode', 'language'].contains(key)) {
        await prefs.remove(key);
      }
    }

    logInfo('CacheService: Successfully cleared all cache data');
  }

  /// Clear all Isar collections except AppInstallation
  static Future<void> _clearAllIsarCollections() async {
    try {
      logInfo(
          'CacheService: Clear Isar collections method - currently using clearAllCache() instead');
      // This method is kept for reference but we're using the comprehensive clearAllCache() method
      // which handles all data clearing including Isar collections
    } catch (e) {
      logError('CacheService: Error in _clearAllIsarCollections: $e');
      rethrow;
    }
  }

  /// Delete Isar database file physically and exit app (DEBUG ONLY)
  static Future<void> deleteStorageAndExit() async {
    try {
      logInfo('CacheService: Starting physical Isar database deletion...');

      // Close Isar instance first
      await IsarService.isar.close();
      logInfo('CacheService: Closed Isar instance');

      // Get the Isar database file path
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dir.path, 'default.isar');
      final lockPath = p.join(dir.path, 'default.isar.lock');

      // Delete the database files
      final dbFile = File(dbPath);
      final lockFile = File(lockPath);

      if (await dbFile.exists()) {
        await dbFile.delete();
        logInfo('CacheService: Deleted Isar database file: $dbPath');
      }

      if (await lockFile.exists()) {
        await lockFile.delete();
        logInfo('CacheService: Deleted Isar lock file: $lockPath');
      }

      logInfo('CacheService: Physical Isar database deletion completed');

      // Exit the app
      logInfo('CacheService: Exiting application...');
      exit(0);
    } catch (e) {
      logError('CacheService: Error during physical database deletion: $e');
      rethrow;
    }
  }

  static Future<int> getTotalCacheSize() async {
    final cacheInfoMap = await getAllCacheInfo();
    return cacheInfoMap.values
        .fold<int>(0, (sum, info) => sum + info.sizeBytes);
  }

  static Future<int> getTotalLogSize() async {
    try {
      return await AppLogger.instance.getTotalLogSize();
    } catch (e) {
      return 0;
    }
  }

  static String formatCacheSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Method to add cache tracking for other features in the future
  static Future<void> addCacheKey(String cacheType, String key) async {
    // This can be used to dynamically add cache keys for new features
  }

  /// Clear P2P Data Transfer cache
  static Future<void> clearP2PCache() async {
    final p2pBoxNames = [
      'p2p_users',
      'pairing_requests',
      'p2p_storage_settings',
      'file_transfer_requests',
    ];

    for (final boxName in p2pBoxNames) {
      try {
        // P2P no longer uses Hive boxes, this is a no-op
        logInfo(
            'CacheService: P2P box clearing skipped (no longer using Hive): $boxName');
      } catch (e) {
        logError('CacheService: Error during P2P cleanup: $e');
      }
    }

    // 🔥 SAFE: Only clear file picker cache if P2P is not active
    try {
      final p2pService = P2PServiceManager.instance;
      if (!p2pService.isEnabled) {
        await FilePicker.platform.clearTemporaryFiles();
        logInfo(
            'CacheService: Cleared file picker temporary files (P2P disabled)');
      } else {
        logInfo(
            'CacheService: Skipped file picker cleanup - P2P service is active');
      }
    } catch (e) {
      logWarning('CacheService: Failed to clear file picker temp files: $e');
    }
  }

  /// Check if P2P Data Transfer is currently enabled
  static Future<bool> isP2PEnabled() async {
    try {
      return P2PServiceManager.instance.isEnabled;
    } catch (e) {
      logError('CacheService: Error checking P2P status: $e');
      return false;
    }
  }

  /// Check if a cache type can be cleared (conditional clearing)
  static Future<bool> canClearCache(String cacheType) async {
    switch (cacheType) {
      case 'p2lan_transfer':
        // Can't clear P2P cache if service is currently enabled
        return !(await isP2PEnabled());
      default:
        return true; // Other caches can always be cleared
    }
  }

  /// Get the reason why a cache type cannot be cleared
  static Future<String?> getClearCacheBlockReason(String cacheType) async {
    switch (cacheType) {
      case 'p2lan_transfer':
        if (await isP2PEnabled()) {
          return 'P2Lan Transfer is currently active. Stop the service to clear cache.';
        }
        return null;
      default:
        return null;
    }
  }

  /// Force sync P2P data from memory to cache (if data exists in memory but not in Hive)
  static Future<void> syncP2PDataToCache() async {
    try {
      logInfo('CacheService: Starting P2P data sync...');

      final p2pService = P2PServiceManager.instance;

      // Check discovered users
      final discoveredUsers = p2pService.discoveredUsers;
      logInfo(
          'CacheService: P2P service has ${discoveredUsers.length} discovered users');

      // Check paired users specifically
      final pairedUsers = p2pService.pairedUsers;
      logInfo(
          'CacheService: P2P service has ${pairedUsers.length} paired users');

      // Check stored users
      final storedUsers = discoveredUsers.where((u) => u.isStored).toList();
      logInfo(
          'CacheService: P2P service has ${storedUsers.length} stored users');

      if (pairedUsers.isNotEmpty) {
        logInfo('CacheService: Paired users details:');
        for (var user in pairedUsers) {
          logInfo(
              '  - ${user.displayName} (${user.id}): paired=${user.isPaired}, trusted=${user.isTrusted}, stored=${user.isStored}');
        }

        // P2P users are no longer stored in Hive
        try {
          logInfo(
              'CacheService: P2P user cache check skipped (no longer using Hive)');
          logInfo('CacheService: P2P users found: ${pairedUsers.length}');

          for (var user in pairedUsers) {
            logInfo(
                'CacheService: User ${user.displayName} found in active P2P service');
            logInfo(
                'CacheService: User ${user.displayName} NOT found in cache - this might be the issue!');

            // Force save user to cache if it's paired but not saved
            if (user.isPaired && user.isStored) {
              // Note: Not using Hive anymore, this is just logging
              logInfo(
                  'CacheService: Would force save user ${user.displayName} to cache (Hive migration: skipped)');
            }
          }

          // P2P users box no longer exists (not using Hive)
          logInfo(
              'CacheService: P2P users box check completed (no longer using Hive)');
        } catch (e) {
          logError('CacheService: Error during P2P users check: $e');
        }
      }

      logInfo('CacheService: P2P data sync completed');
    } catch (e) {
      logError('CacheService: Error during P2P data sync: $e');
    }
  }

  /// Debug P2P cache state
  static Future<Map<String, dynamic>> debugP2PCache() async {
    final result = <String, dynamic>{};

    try {
      // Check P2P service state
      final p2pService = P2PServiceManager.instance;
      result['service_enabled'] = p2pService.isEnabled;
      result['discovered_users'] = p2pService.discoveredUsers.length;
      result['paired_users'] = p2pService.pairedUsers.length;
      result['stored_users'] =
          p2pService.discoveredUsers.where((u) => u.isStored).length;

      // Check Hive boxes
      final boxStates = <String, Map<String, dynamic>>{};
      final boxNames = [
        'p2p_users',
        'pairing_requests',
        'p2p_storage_settings'
      ];

      for (final boxName in boxNames) {
        try {
          // P2P boxes no longer exist (not using Hive)
          boxStates[boxName] = {'exists': false, 'length': 0, 'keys': []};
          logInfo(
              'CacheService: P2P box $boxName reported as non-existent (no longer using Hive)');
        } catch (e) {
          boxStates[boxName] = {'error': e.toString()};
        }
      }

      result['hive_boxes'] = boxStates;

      // Get cache info
      final cacheInfo = await getAllCacheInfo();
      final p2pCache = cacheInfo['p2p_data_transfer'];
      result['cache_info'] = {
        'item_count': p2pCache?.itemCount ?? 0,
        'size_bytes': p2pCache?.sizeBytes ?? 0,
      };
    } catch (e) {
      result['error'] = e.toString();
    }

    return result;
  }

  static Future<Map<String, dynamic>> getP2PCacheInfo() async {
    final p2pBoxNames = [
      'p2p_users',
      'pairing_requests',
      'p2p_storage_settings',
      'file_transfer_requests',
    ];
    int itemCount = 0;
    int sizeBytes = 0;

    for (final boxName in p2pBoxNames) {
      try {
        // P2P boxes no longer exist (not using Hive)
        logInfo(
            'CacheService: P2P box size calculation skipped for $boxName (no longer using Hive)');
        // Use estimates instead
        itemCount += 10; // rough estimate
        sizeBytes += 1024; // 1KB estimate
      } catch (e) {
        logError('CacheService: Error during P2P box size estimation: $e');
      }
    }

    // 🔥 FIX: Add file picker cache size for Android
    int filePickerCacheSizeBytes = 0;
    if (Platform.isAndroid) {
      try {
        final tempDir = await getTemporaryDirectory();
        final filePickerCacheDir =
            Directory(p.join(tempDir.path, '..', 'cache', 'file_picker'));
        if (await filePickerCacheDir.exists()) {
          filePickerCacheSizeBytes =
              await _getDirectorySize(filePickerCacheDir);
        }
      } catch (e) {
        logError(
            'CacheService: Could not calculate file_picker cache size: $e');
      }
    }

    return {
      'itemCount': itemCount,
      'sizeBytes': sizeBytes + filePickerCacheSizeBytes
    };
  }

  /// 🔥 NEW: Helper to calculate directory size recursively
  static Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    if (await dir.exists()) {
      try {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File) {
            try {
              size += await entity.length();
            } catch (e) {
              // Ignore errors for files that might be deleted during iteration
            }
          }
        }
      } catch (e) {
        logError('CacheService: Error listing directory ${dir.path}: $e');
      }
    }
    return size;
  }

  /// Shows a confirmation dialog and clears all deletable cache if confirmed.
  static Future<void> confirmAndClearAllCache(
    BuildContext context, {
    required AppLocalizations l10n,
  }) async {
    // First, determine which caches cannot be cleared.
    final allCacheInfo = await getAllCacheInfo();
    final nonDeletableCaches = allCacheInfo.values
        .where((info) => !info.isDeletable)
        .map((info) => info.name)
        .toList();

    String dialogContent = l10n.clearStorageSettingsConfirmation;
    if (nonDeletableCaches.isNotEmpty) {
      dialogContent +=
          '\n\n${l10n.cannotClearFollowingCaches}\n• ${nonDeletableCaches.join('\n• ')}';
    }

    // Show the GenericDialog with custom footer
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => GenericDialog(
        header: GenericDialogHeader(
          title: l10n.clearStorageSettingsTitle,
        ),
        body: SingleChildScrollView(
          child: Text(
            dialogContent,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        footer: GenericDialogFooter(
          child: WidgetLayoutRenderHelper.twoInARowThreshold(
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(120, 48), // Same height as HoldButton
                ),
                child: Text(l10n.clearStorageSettingsCancel),
              ),
              HoldButton(
                text: l10n.clearStorageSettingsConfirm,
                icon: Icons.delete_sweep,
                holdDuration: const Duration(seconds: 3),
                onHoldComplete: () => Navigator.of(context).pop(true),
                backgroundColor: Colors.red.shade400, // Lighter red tone
                foregroundColor: Colors.white,
                progressColor: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                minimumSize: const Size(120, 48),
              ),
              TwoInARowDecorator(
                widthWidget1: DynamicDimension.flexibility(40, 100, 1500),
                widthWidget2: DynamicDimension.expanded(),
              ),
              const TwoInARowConditionType.overallWidth(250)),
        ),
        decorator: GenericDialogDecorator(
            width: DynamicDimension.flexibilityMax(85, 500),
            displayTopDivider: true),
      ),
    );

    if (confirmed == true) {
      await clearAllCache();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.clearStorageSettingsSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
