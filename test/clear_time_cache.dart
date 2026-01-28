import 'dart:io';
// import 'package:hive_flutter/hive_flutter.dart'; // Commented out during Hive to Isar migration
import 'package:path_provider/path_provider.dart';
import 'package:p2lan/services/app_logger.dart';

Future<void> main() async {
  try {
    // Get application documents directory
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    logInfo('Time cache clearing: Hive no longer used for time data');

    // Time converter data is now managed by Isar
    // No Hive initialization needed

    // Try to clear time converter data via services
    try {
      // Time data is now handled by TimeStateService with Isar backend
      logInfo('✅ Time data now managed by Isar - use app settings to clear');
    } catch (e) {
      logError('⚠️ Info: Time data management: $e');
    }

    try {
      // Time presets are now handled by GenericPresetService with Isar backend
      logInfo('✅ Time presets now managed by Isar - use app settings to clear');
    } catch (e) {
      logError('⚠️ Info: Time presets management: $e');
    }

    logInfo('🎉 Time data migration to Isar completed!');
    logInfo('Time converter now uses Isar database instead of Hive.');
  } catch (e) {
    logError('❌ Error during time cache info: $e');
  }
}
