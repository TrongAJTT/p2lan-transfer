import 'dart:io';
import 'package:p2lan/utils/settings_reset_utils.dart';
import 'package:p2lan/services/app_logger.dart';

/// Quick test script to check and reset P2P settings
void main() async {
  print('=== P2P Settings Diagnostic Tool ===\n');

  try {
    // 1. Check current settings
    print('1. Current Settings:');
    final currentSettings = await SettingsResetUtils.getSettingsSummary();
    currentSettings.forEach((key, value) {
      print('   $key: $value');
    });
    print('');

    // 2. Ask user if they want to reset
    print('Current settings show:');
    print('   Encryption: ${currentSettings['encryptionType']}');
    print('   Compression: ${currentSettings['enableCompression']}');
    print('   Chunk Size: ${currentSettings['maxChunkSize']} KB');
    print('');

    if (currentSettings['encryptionType'] != 'none' ||
        currentSettings['enableCompression'] == true) {
      print(
          '⚠️  WARNING: These settings may cause crashes on some Android devices!');
      print('');

      stdout.write('Do you want to reset to safe defaults? (y/n): ');
      final input = stdin.readLineSync();

      if (input?.toLowerCase() == 'y' || input?.toLowerCase() == 'yes') {
        print('\n2. Resetting to safe defaults...');
        await SettingsResetUtils.resetP2PSettingsToSafeDefaults();
        print('✅ Settings reset successfully!');

        print('\n3. New Settings:');
        final newSettings = await SettingsResetUtils.getSettingsSummary();
        newSettings.forEach((key, value) {
          print('   $key: $value');
        });
      } else {
        print('\nReset cancelled. Settings unchanged.');
      }
    } else {
      print('✅ Settings are already at safe defaults!');
    }
  } catch (e) {
    print('❌ Error: $e');
    logError('Settings diagnostic failed: $e');
  }

  print('\n=== Done ===');
}
