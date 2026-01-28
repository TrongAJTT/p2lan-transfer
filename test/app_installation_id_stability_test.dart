import 'package:flutter_test/flutter_test.dart';
// import 'package:hive/hive.dart'; // Commented out during Hive to Isar migration
// import 'package:hive_flutter/hive_flutter.dart'; // Commented out during Hive to Isar migration
import 'package:p2lan/services/app_installation_service.dart';
import 'package:p2lan/services/app_logger.dart';

void main() {
  group('App Installation ID Stability Tests', () {
    setUpAll(() async {
      // Initialize test environment - Hive no longer used
      // Hive.init('test'); // Commented out during migration
    });

    tearDownAll(() async {
      // Clean up after tests - Hive no longer used
      // await Hive.deleteFromDisk(); // Commented out during migration
    });

    test('App Installation ID should remain stable across multiple calls',
        () async {
      // First call
      final service = AppInstallationService.instance;
      await service.initialize();
      final id1 = await service.getAppInstallationId();
      final wordId1 = await service.getAppInstallationWordId();

      logInfo('First call:');
      logInfo('  Installation ID: $id1');
      logInfo('  Installation Word ID: $wordId1');

      // Multiple subsequent calls should return same ID
      for (int i = 0; i < 5; i++) {
        final id = await service.getAppInstallationId();
        final wordId = await service.getAppInstallationWordId();

        expect(id, equals(id1),
            reason: 'App Installation ID should remain stable on call $i');
        expect(wordId, equals(wordId1),
            reason: 'App Installation Word ID should remain stable on call $i');
      }

      logInfo('All calls returned same IDs - stability confirmed!');
    });

    test('App Installation ID should be exactly 10 letters', () async {
      final service = AppInstallationService.instance;
      await service.initialize();
      final id = await service.getAppInstallationId();

      expect(id.length, equals(10),
          reason: 'Installation ID should be exactly 10 characters');
      expect(RegExp(r'^[A-Z]{10}$').hasMatch(id), isTrue,
          reason: 'Installation ID should be 10 uppercase letters');

      logInfo('Generated Installation ID: $id (length: ${id.length})');
    });

    test('App Installation Word ID should have correct format', () async {
      final service = AppInstallationService.instance;
      await service.initialize();
      final wordId = await service.getAppInstallationWordId();

      expect(RegExp(r'^[a-z]+-[a-z]+-\d{4}$').hasMatch(wordId), isTrue,
          reason: 'Installation Word ID should match format: word-word-1234');

      logInfo('Generated Installation Word ID: $wordId');
    });

    test('Service should handle storage correctly', () async {
      final service = AppInstallationService.instance;

      // Before initialization
      expect(service.isInitialized, isFalse,
          reason: 'Service should not be initialized initially');

      // After initialization
      await service.initialize();
      expect(service.isInitialized, isTrue,
          reason: 'Service should be initialized after initialize()');

      // Verify IDs are generated
      final id = await service.getAppInstallationId();
      final wordId = await service.getAppInstallationWordId();

      expect(id.isNotEmpty, isTrue,
          reason: 'Installation ID should not be empty');
      expect(wordId.isNotEmpty, isTrue,
          reason: 'Installation Word ID should not be empty');

      logInfo('Service correctly initialized with IDs:');
      logInfo('  Installation ID: $id');
      logInfo('  Installation Word ID: $wordId');
    });

    test('Reset functionality should work correctly', () async {
      final service = AppInstallationService.instance;
      await service.initialize();

      final originalId = await service.getAppInstallationId();
      final originalWordId = await service.getAppInstallationWordId();

      logInfo('Original IDs:');
      logInfo('  Installation ID: $originalId');
      logInfo('  Installation Word ID: $originalWordId');

      // Reset and reinitialize
      await service.resetAppInstallation();
      expect(service.isInitialized, isFalse,
          reason: 'Service should not be initialized after reset');

      await service.initialize();
      expect(service.isInitialized, isTrue,
          reason: 'Service should be initialized after re-initialization');

      final newId = await service.getAppInstallationId();
      final newWordId = await service.getAppInstallationWordId();

      logInfo('After reset:');
      logInfo('  Installation ID: $newId');
      logInfo('  Installation Word ID: $newWordId');

      expect(newId, isNot(equals(originalId)),
          reason: 'New ID should be different after reset');
      expect(newWordId, isNot(equals(originalWordId)),
          reason: 'New Word ID should be different after reset');
    });
  });
}
