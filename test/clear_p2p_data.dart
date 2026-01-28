import 'dart:io';
// import 'package:hive/hive.dart'; // Commented out during Hive to Isar migration

import 'package:p2lan/services/app_logger.dart';

void main() async {
  logInfo('Clearing P2P Hive data...');

  try {
    // P2P data no longer uses Hive - migration completed
    logInfo('P2P data clearing: Hive no longer used, no action needed');

    // P2P data is now managed by the app service directly
    // No Hive boxes to delete

    // Legacy box names for reference:
    final boxesToDelete = [
      'p2p_users',
      'pairing_requests',
      'p2p_storage_settings',
      'file_transfer_tasks'
    ];

    for (final boxName in boxesToDelete) {
      try {
        // P2P boxes no longer exist in Hive
        logInfo('Box cleanup skipped (no longer using Hive): $boxName');
      } catch (e) {
        logError('Error during P2P cleanup: $e');
      }
    }

    // Hive directory no longer relevant for P2P data
    logInfo('P2P data cleanup completed - no Hive data to remove');

    logInfo('P2P Hive data cleared successfully!');
  } catch (e) {
    logError('Error clearing P2P data: $e');
  }

  exit(0);
}
