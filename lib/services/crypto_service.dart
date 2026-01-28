import 'dart:typed_data';
import 'dart:math';
import 'package:pointycastle/export.dart' as pointy;
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/app_logger.dart';

/// Comprehensive crypto service supporting multiple encryption algorithms
/// for P2P data transfer with enhanced performance on low-end Android devices
class CryptoService {
  static const int _keySize = 32; // 256 bits
  static const int _ivSize = 16; // 128 bits for AES-GCM
  static const int _nonceSize = 12; // 96 bits for ChaCha20-Poly1305
  static const int _tagSize = 16; // 128 bits for authentication tag

  // Singleton instances for cryptography algorithms
  static final _chacha20 = crypto.Chacha20.poly1305Aead();

  /// Generate a secure random key for encryption (256 bits)
  static Uint8List generateKey() {
    final random = Random.secure();
    final key = Uint8List(_keySize);
    for (int i = 0; i < _keySize; i++) {
      key[i] = random.nextInt(256);
    }
    return key;
  }

  /// Generate a secure random IV for AES-GCM (128 bits)
  static Uint8List generateIV() {
    final random = Random.secure();
    final iv = Uint8List(_ivSize);
    for (int i = 0; i < _ivSize; i++) {
      iv[i] = random.nextInt(256);
    }
    return iv;
  }

  /// Generate a secure random nonce for ChaCha20-Poly1305 (96 bits)
  static Uint8List generateNonce() {
    final random = Random.secure();
    final nonce = Uint8List(_nonceSize);
    for (int i = 0; i < _nonceSize; i++) {
      nonce[i] = random.nextInt(256);
    }
    return nonce;
  }

  /// Encrypt data using the specified encryption type
  /// Returns a map with encrypted data and metadata
  static Future<Map<String, dynamic>> encrypt(
    Uint8List data,
    Uint8List key,
    EncryptionType encryptionType,
  ) async {
    try {
      switch (encryptionType) {
        case EncryptionType.none:
          return {
            'data': data,
            'encryptionType': 'none',
          };
        case EncryptionType.aesGcm:
          return await _encryptAesGcm(data, key);
        case EncryptionType.chaCha20:
          return await _encryptChaCha20(data, key);
      }
    } catch (e) {
      logError(
          'CryptoService: Encryption failed with ${encryptionType.name}: $e');
      rethrow;
    }
  }

  /// Decrypt data using the specified encryption type
  /// Returns the decrypted data or null if decryption fails
  static Future<Uint8List?> decrypt(
    Map<String, dynamic> encryptedData,
    Uint8List key,
    EncryptionType encryptionType,
  ) async {
    try {
      switch (encryptionType) {
        case EncryptionType.none:
          return encryptedData['data'] as Uint8List?;
        case EncryptionType.aesGcm:
          return await _decryptAesGcm(encryptedData, key);
        case EncryptionType.chaCha20:
          return await _decryptChaCha20(encryptedData, key);
      }
    } catch (e) {
      logError(
          'CryptoService: Decryption failed with ${encryptionType.name}: $e');
      return null;
    }
  }

  /// Encrypt data using AES-256-GCM (using PointyCastle for compatibility)
  static Future<Map<String, dynamic>> _encryptAesGcm(
    Uint8List data,
    Uint8List key,
  ) async {
    final iv = generateIV();
    final cipher = pointy.GCMBlockCipher(pointy.AESEngine())
      ..init(
          true,
          pointy.AEADParameters(
              pointy.KeyParameter(key), _tagSize * 8, iv, Uint8List(0)));

    final encrypted = cipher.process(data);
    final ciphertext = encrypted.sublist(0, encrypted.length - _tagSize);
    final tag = encrypted.sublist(encrypted.length - _tagSize);

    return {
      'ciphertext': ciphertext,
      'iv': iv,
      'tag': tag,
      'encryptionType': 'aes-gcm',
    };
  }

  /// Decrypt data using AES-256-GCM (using PointyCastle for compatibility)
  static Future<Uint8List?> _decryptAesGcm(
    Map<String, dynamic> encryptedData,
    Uint8List key,
  ) async {
    try {
      final ciphertext = encryptedData['ciphertext'] as Uint8List;
      final iv = encryptedData['iv'] as Uint8List;
      final tag = encryptedData['tag'] as Uint8List;

      final cipher = pointy.GCMBlockCipher(pointy.AESEngine())
        ..init(
            false,
            pointy.AEADParameters(
                pointy.KeyParameter(key), _tagSize * 8, iv, Uint8List(0)));

      final encryptedWithTag = Uint8List.fromList([...ciphertext, ...tag]);
      final decrypted = cipher.process(encryptedWithTag);

      return decrypted;
    } catch (e) {
      logError('CryptoService: AES-GCM decryption failed: $e');
      return null;
    }
  }

  /// Encrypt data using ChaCha20-Poly1305 (using cryptography package for better performance)
  static Future<Map<String, dynamic>> _encryptChaCha20(
    Uint8List data,
    Uint8List key,
  ) async {
    final nonce = generateNonce();
    final secretKey = crypto.SecretKey(key);

    final secretBox = await _chacha20.encrypt(
      data,
      secretKey: secretKey,
      nonce: nonce,
    );

    return {
      'ciphertext': Uint8List.fromList(secretBox.cipherText),
      'nonce': nonce,
      'tag': Uint8List.fromList(secretBox.mac.bytes),
      'encryptionType': 'chacha20-poly1305',
    };
  }

  /// Decrypt data using ChaCha20-Poly1305 (using cryptography package for better performance)
  static Future<Uint8List?> _decryptChaCha20(
    Map<String, dynamic> encryptedData,
    Uint8List key,
  ) async {
    try {
      final ciphertext = encryptedData['ciphertext'] as Uint8List;
      final nonce = encryptedData['nonce'] as Uint8List;
      final tag = encryptedData['tag'] as Uint8List;

      final secretKey = crypto.SecretKey(key);
      final mac = crypto.Mac(tag);

      final secretBox = crypto.SecretBox(
        ciphertext,
        nonce: nonce,
        mac: mac,
      );

      final decrypted = await _chacha20.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      return Uint8List.fromList(decrypted);
    } catch (e) {
      logError('CryptoService: ChaCha20-Poly1305 decryption failed: $e');
      return null;
    }
  }

  /// Get display name for encryption type
  static String getEncryptionDisplayName(EncryptionType type) {
    switch (type) {
      case EncryptionType.none:
        return 'None';
      case EncryptionType.aesGcm:
        return 'AES-256-GCM';
      case EncryptionType.chaCha20:
        return 'ChaCha20-Poly1305';
    }
  }

  /// Get description for encryption type
  static String getEncryptionDescription(
      EncryptionType type, AppLocalizations l10n) {
    switch (type) {
      case EncryptionType.none:
        return l10n.p2lanOptionEncryptionNoneDesc;
      case EncryptionType.aesGcm:
        return l10n.p2lanOptionEncryptionAesGcmDesc;
      case EncryptionType.chaCha20:
        return l10n.p2lanOptionEncryptionChaCha20Desc;
    }
  }

  /// Get icon for encryption type
  static String getEncryptionIcon(EncryptionType type) {
    switch (type) {
      case EncryptionType.none:
        return 'no_encryption';
      case EncryptionType.aesGcm:
        return 'enhanced_encryption';
      case EncryptionType.chaCha20:
        return 'security';
    }
  }

  /// Check if encryption type is supported on current platform
  static bool isEncryptionSupported(EncryptionType type) {
    switch (type) {
      case EncryptionType.none:
        return true;
      case EncryptionType.aesGcm:
        return true; // PointyCastle is cross-platform
      case EncryptionType.chaCha20:
        return true; // cryptography package is cross-platform
    }
  }

  /// Get recommended encryption type for current platform
  static EncryptionType getRecommendedEncryption() {
    // For now, recommend ChaCha20 as it's optimized for mobile devices
    // In the future, we could detect device capabilities and recommend accordingly
    return EncryptionType.chaCha20;
  }

  /// Benchmark encryption performance (for future optimization)
  static Future<Map<String, int>> benchmarkEncryption(
      Uint8List testData) async {
    final key = generateKey();
    final results = <String, int>{};

    // Benchmark AES-GCM
    final aesStart = DateTime.now();
    await _encryptAesGcm(testData, key);
    final aesTime = DateTime.now().difference(aesStart).inMilliseconds;
    results['aes-gcm'] = aesTime;

    // Benchmark ChaCha20-Poly1305
    final chachaStart = DateTime.now();
    await _encryptChaCha20(testData, key);
    final chachaTime = DateTime.now().difference(chachaStart).inMilliseconds;
    results['chacha20-poly1305'] = chachaTime;

    logInfo(
        'CryptoService: Encryption benchmark - AES-GCM: ${aesTime}ms, ChaCha20: ${chachaTime}ms');
    return results;
  }
}
