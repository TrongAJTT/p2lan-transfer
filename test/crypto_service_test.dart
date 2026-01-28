import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/crypto_service.dart';

void main() {
  group('CryptoService Tests', () {
    late Uint8List testData;
    late Uint8List testKey;

    setUp(() {
      testData = Uint8List.fromList(
          'Hello, World! This is a test message for encryption.'.codeUnits);
      testKey = CryptoService.generateKey();
    });

    test('should generate valid keys', () {
      final key = CryptoService.generateKey();
      expect(key.length, equals(32)); // 256 bits
    });

    test('should encrypt and decrypt with AES-256-GCM', () async {
      final encrypted =
          await CryptoService.encrypt(testData, testKey, EncryptionType.aesGcm);
      expect(encrypted['encryptionType'], equals('aes-gcm'));
      expect(encrypted['ciphertext'], isNotNull);
      expect(encrypted['iv'], isNotNull);
      expect(encrypted['tag'], isNotNull);

      final decrypted = await CryptoService.decrypt(
          encrypted, testKey, EncryptionType.aesGcm);
      expect(decrypted, isNotNull);
      expect(decrypted, equals(testData));
    });

    test('should encrypt and decrypt with ChaCha20-Poly1305', () async {
      final encrypted = await CryptoService.encrypt(
          testData, testKey, EncryptionType.chaCha20);
      expect(encrypted['encryptionType'], equals('chacha20-poly1305'));
      expect(encrypted['ciphertext'], isNotNull);
      expect(encrypted['nonce'], isNotNull);
      expect(encrypted['tag'], isNotNull);

      final decrypted = await CryptoService.decrypt(
          encrypted, testKey, EncryptionType.chaCha20);
      expect(decrypted, isNotNull);
      expect(decrypted, equals(testData));
    });

    test('should handle no encryption', () async {
      final encrypted =
          await CryptoService.encrypt(testData, testKey, EncryptionType.none);
      expect(encrypted['encryptionType'], equals('none'));
      expect(encrypted['data'], equals(testData));

      final decrypted =
          await CryptoService.decrypt(encrypted, testKey, EncryptionType.none);
      expect(decrypted, equals(testData));
    });

    test('should fail decryption with wrong key', () async {
      final encrypted =
          await CryptoService.encrypt(testData, testKey, EncryptionType.aesGcm);
      final wrongKey = CryptoService.generateKey();

      final decrypted = await CryptoService.decrypt(
          encrypted, wrongKey, EncryptionType.aesGcm);
      expect(decrypted, isNull);
    });

    test('should provide correct display names', () {
      expect(CryptoService.getEncryptionDisplayName(EncryptionType.none),
          equals('None'));
      expect(CryptoService.getEncryptionDisplayName(EncryptionType.aesGcm),
          equals('AES-256-GCM'));
      expect(CryptoService.getEncryptionDisplayName(EncryptionType.chaCha20),
          equals('ChaCha20-Poly1305'));
    });

    test('should provide correct descriptions', () {
      final l10n = AppLocalizations.of(Get.context!);
      expect(CryptoService.getEncryptionDescription(EncryptionType.none, l10n),
          contains('fastest'));
      expect(
          CryptoService.getEncryptionDescription(EncryptionType.aesGcm, l10n),
          contains('high-end'));
      expect(
          CryptoService.getEncryptionDescription(EncryptionType.chaCha20, l10n),
          contains('mobile'));
    });

    test('should report all encryption types as supported', () {
      expect(CryptoService.isEncryptionSupported(EncryptionType.none), isTrue);
      expect(
          CryptoService.isEncryptionSupported(EncryptionType.aesGcm), isTrue);
      expect(
          CryptoService.isEncryptionSupported(EncryptionType.chaCha20), isTrue);
    });

    test('should recommend ChaCha20 as default', () {
      expect(CryptoService.getRecommendedEncryption(),
          equals(EncryptionType.chaCha20));
    });
  });
}
