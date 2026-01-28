import 'package:flutter_test/flutter_test.dart';
import 'package:p2lan/services/encryption_service.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  group('AES-GCM Encryption Transfer Tests', () {
    test('AES-GCM basic functionality', () {
      final key = EncryptionService.generateKey();
      expect(key.length, equals(32));

      final testData = Uint8List.fromList(utf8.encode('Hello AES-GCM!'));

      // Encrypt
      final encryptedData = EncryptionService.encryptGCM(testData, key);
      expect(encryptedData['ciphertext'], isNotNull);
      expect(encryptedData['iv'], isNotNull);
      expect(encryptedData['tag'], isNotNull);
      expect(encryptedData['iv']!.length, equals(16));
      expect(encryptedData['tag']!.length, equals(16));

      // Decrypt
      final decrypted = EncryptionService.decryptGCM(encryptedData, key);

      expect(decrypted, isNotNull);
      expect(decrypted, equals(testData));
    });

    test('AES-GCM decryption should fail with wrong key', () {
      final key1 = EncryptionService.generateKey();
      final key2 = EncryptionService.generateKey();
      final testData = Uint8List.fromList(utf8.encode('Sensitive data'));

      final encrypted = EncryptionService.encryptGCM(testData, key1);
      final decrypted = EncryptionService.decryptGCM(encrypted, key2);

      expect(decrypted, isNull);
    });

    test('AES-GCM decryption should fail with tampered ciphertext', () {
      final key = EncryptionService.generateKey();
      final testData = Uint8List.fromList(utf8.encode('Important message'));

      final encrypted = EncryptionService.encryptGCM(testData, key);

      // Tamper with the ciphertext
      encrypted['ciphertext']![0] ^= 0xFF;

      final decrypted = EncryptionService.decryptGCM(encrypted, key);
      expect(decrypted, isNull);
    });

    test('AES-GCM decryption should fail with tampered tag', () {
      final key = EncryptionService.generateKey();
      final testData =
          Uint8List.fromList(utf8.encode('Another important message'));

      final encrypted = EncryptionService.encryptGCM(testData, key);

      // Tamper with the authentication tag
      encrypted['tag']![0] ^= 0xFF;

      final decrypted = EncryptionService.decryptGCM(encrypted, key);
      expect(decrypted, isNull);
    });

    test('FileTransferRequest with encryption flag remains correct', () {
      final request = FileTransferRequest.create(
        fromUserId: 'user_456',
        fromUserName: 'Test User',
        files: [FileTransferInfo(fileName: 'test.txt', fileSize: 1024)],
        totalSize: 1024,
        useEncryption: true,
      );

      expect(request.useEncryption, isTrue);
      final json = request.toJson();
      expect(json['useEncryption'], isTrue);
      final fromJson = FileTransferRequest.fromJson(json);
      expect(fromJson.useEncryption, isTrue);
    });
  });
}
