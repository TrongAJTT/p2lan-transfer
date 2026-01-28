import 'package:isar/isar.dart';
import 'package:p2lan/models/p2p_cache_models.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/isar_service.dart';

/// Service for managing P2P data cache using the unified P2PDataCache model
class P2PDataCacheService {
  /// Save a cache entry to Isar
  static Future<void> saveCache(P2PDataCache cache) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.p2PDataCaches.put(cache);
    });
  }

  /// Get a cache entry by ID
  static Future<P2PDataCache?> getCache(String id) async {
    final isar = IsarService.isar;
    return await isar.p2PDataCaches.where().idEqualTo(id).findFirst();
  }

  /// Update cache status
  static Future<void> updateStatus(String id, String status) async {
    final cache = await getCache(id);
    if (cache != null) {
      cache.updateStatus(status);
      await saveCache(cache);
      logInfo('Updated cache status: $id -> $status');
    }
  }

  /// Delete a cache entry by ID
  static Future<void> deleteCache(String id) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.p2PDataCaches.deleteByIndex('id', [id]);
    });
    logInfo('Deleted cache: $id');
  }

  /// Clear all P2P cache data
  static Future<void> clearAllCaches() async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.p2PDataCaches.clear();
    });
    logInfo('Cleared all P2P cache data');
  }
}
