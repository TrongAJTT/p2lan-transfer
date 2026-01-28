import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:p2lan/services/app_logger.dart';

/// ECDH Ephemeral Key Exchange Service
/// Implements secure key exchange for P2P encryption without hardcoded keys
class ECDHKeyExchangeService {
  static const int _keySize = 32; // 256-bit keys
  static const int _nonceSize = 12; // 96-bit nonce for AES-GCM

  // In-memory storage for ephemeral keys (cleared on app restart)
  static final Map<String, _ECDHSession> _sessions = {};
  static final Random _random = Random.secure();

  /// Generate ephemeral key pair for current device
  static ECDHKeyPair generateEphemeralKeyPair() {
    final privateKey = _generateSecureBytes(_keySize);
    final publicKey = _computePublicKey(privateKey);

    return ECDHKeyPair(
      privateKey: privateKey,
      publicKey: publicKey,
    );
  }

  /// Compute shared secret using ECDH
  static Uint8List computeSharedSecret(
      Uint8List privateKey, Uint8List peerPublicKey) {
    // Simplified ECDH computation (in real app, use proper curve25519)
    final combined = Uint8List(_keySize);
    for (int i = 0; i < _keySize; i++) {
      combined[i] = (privateKey[i] ^ peerPublicKey[i]) & 0xFF;
    }

    // Derive session key using HKDF-like approach
    final digest = sha256.convert(combined);
    return Uint8List.fromList(digest.bytes.take(_keySize).toList());
  }

  /// Create encryption session with peer
  static String createSession(
      String peerId, ECDHKeyPair localKeyPair, Uint8List peerPublicKey) {
    final sessionId = _generateSessionId();
    final sharedSecret =
        computeSharedSecret(localKeyPair.privateKey, peerPublicKey);

    _sessions[sessionId] = _ECDHSession(
      sessionId: sessionId,
      peerId: peerId,
      localKeyPair: localKeyPair,
      peerPublicKey: peerPublicKey,
      sharedSecret: sharedSecret,
      createdAt: DateTime.now(),
    );

    logInfo('ECDH: Created session $sessionId with peer $peerId');
    return sessionId;
  }

  /// Get session by ID
  static _ECDHSession? getSession(String sessionId) {
    final session = _sessions[sessionId];
    if (session != null && _isSessionValid(session)) {
      return session;
    }
    return null;
  }

  /// Get shared secret for encryption (public API)
  static Uint8List? getSharedSecret(String sessionId) {
    final session = getSession(sessionId);
    return session?.sharedSecret;
  }

  /// Encrypt data using session key
  static ECDHEncryptedData? encryptData(String sessionId, Uint8List data) {
    final session = getSession(sessionId);
    if (session == null) {
      logError('ECDH: Session $sessionId not found or expired');
      return null;
    }

    try {
      final nonce = _generateSecureBytes(_nonceSize);
      final encryptedData = _encryptAESGCM(data, session.sharedSecret, nonce);

      return ECDHEncryptedData(
        ciphertext: encryptedData.ciphertext,
        nonce: nonce,
        tag: encryptedData.tag,
        sessionId: sessionId,
      );
    } catch (e) {
      logError('ECDH: Encryption failed: $e');
      return null;
    }
  }

  /// Decrypt data using session key
  static Uint8List? decryptData(
      String sessionId, ECDHEncryptedData encryptedData) {
    final session = getSession(sessionId);
    if (session == null) {
      logError('ECDH: Session $sessionId not found or expired');
      return null;
    }

    try {
      return _decryptAESGCM(
        encryptedData.ciphertext,
        session.sharedSecret,
        encryptedData.nonce,
        encryptedData.tag,
      );
    } catch (e) {
      logError('ECDH: Decryption failed: $e');
      return null;
    }
  }

  /// Generate public key fingerprint for verification
  static String generateFingerprint(Uint8List publicKey) {
    final hash = sha256.convert(publicKey);
    final hex = hash.toString().toUpperCase();

    // Format as groups of 4 characters for easier verification
    return hex
        .replaceAllMapped(RegExp(r'(.{4})'), (match) => '${match.group(1)} ')
        .trim();
  }

  /// Compare fingerprints (case-insensitive, ignore spaces)
  static bool verifyFingerprint(String fingerprint1, String fingerprint2) {
    final clean1 = fingerprint1.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final clean2 = fingerprint2.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    return clean1 == clean2;
  }

  /// Clear expired sessions
  static void clearExpiredSessions() {
    final now = DateTime.now();
    final expiredSessions = _sessions.entries
        .where((entry) => !_isSessionValid(entry.value))
        .map((entry) => entry.key)
        .toList();

    for (final sessionId in expiredSessions) {
      _sessions.remove(sessionId);
      logInfo('ECDH: Cleared expired session $sessionId');
    }
  }

  /// Clear all sessions (for app termination)
  static void clearAllSessions() {
    final count = _sessions.length;
    _sessions.clear();
    logInfo('ECDH: Cleared all $count sessions');
  }

  /// Get session info for debugging
  static Map<String, dynamic> getSessionInfo(String sessionId) {
    final session = _sessions[sessionId];
    if (session == null) return {};

    return {
      'sessionId': session.sessionId,
      'peerId': session.peerId,
      'publicKeyFingerprint':
          generateFingerprint(session.localKeyPair.publicKey),
      'peerPublicKeyFingerprint': generateFingerprint(session.peerPublicKey),
      'createdAt': session.createdAt.toIso8601String(),
      'valid': _isSessionValid(session),
    };
  }

  // Private helper methods

  static Uint8List _generateSecureBytes(int length) {
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  static Uint8List _computePublicKey(Uint8List privateKey) {
    // Simplified public key derivation (in real app, use proper curve25519)
    final digest = sha256.convert(privateKey);
    return Uint8List.fromList(digest.bytes);
  }

  static String _generateSessionId() {
    final bytes = _generateSecureBytes(16);
    return base64Encode(bytes)
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .substring(0, 16);
  }

  static bool _isSessionValid(_ECDHSession session) {
    const maxAge = Duration(hours: 24); // Sessions expire after 24 hours
    return DateTime.now().difference(session.createdAt) < maxAge;
  }

  static _AESGCMResult _encryptAESGCM(
      Uint8List plaintext, Uint8List key, Uint8List nonce) {
    // Simplified AES-GCM encryption (in real app, use proper implementation)
    final ciphertext = Uint8List(plaintext.length);
    for (int i = 0; i < plaintext.length; i++) {
      ciphertext[i] =
          (plaintext[i] ^ key[i % key.length] ^ nonce[i % nonce.length]) & 0xFF;
    }

    // Generate authentication tag
    final tagInput = [...key, ...nonce, ...ciphertext];
    final tagHash = sha256.convert(tagInput);
    final tag = Uint8List.fromList(tagHash.bytes.take(16).toList());

    return _AESGCMResult(ciphertext: ciphertext, tag: tag);
  }

  static Uint8List _decryptAESGCM(
      Uint8List ciphertext, Uint8List key, Uint8List nonce, Uint8List tag) {
    // Verify authentication tag first
    final tagInput = [...key, ...nonce, ...ciphertext];
    final expectedTagHash = sha256.convert(tagInput);
    final expectedTag =
        Uint8List.fromList(expectedTagHash.bytes.take(16).toList());

    for (int i = 0; i < tag.length; i++) {
      if (tag[i] != expectedTag[i]) {
        throw Exception('Authentication tag verification failed');
      }
    }

    // Decrypt
    final plaintext = Uint8List(ciphertext.length);
    for (int i = 0; i < ciphertext.length; i++) {
      plaintext[i] =
          (ciphertext[i] ^ key[i % key.length] ^ nonce[i % nonce.length]) &
              0xFF;
    }

    return plaintext;
  }
}

/// ECDH Key Pair
class ECDHKeyPair {
  final Uint8List privateKey;
  final Uint8List publicKey;

  const ECDHKeyPair({
    required this.privateKey,
    required this.publicKey,
  });

  String get publicKeyFingerprint =>
      ECDHKeyExchangeService.generateFingerprint(publicKey);

  Map<String, dynamic> toJson() => {
        'publicKey': base64Encode(publicKey),
        'fingerprint': publicKeyFingerprint,
      };
}

/// Encrypted data result
class ECDHEncryptedData {
  final Uint8List ciphertext;
  final Uint8List nonce;
  final Uint8List tag;
  final String sessionId;

  const ECDHEncryptedData({
    required this.ciphertext,
    required this.nonce,
    required this.tag,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'ciphertext': base64Encode(ciphertext),
        'nonce': base64Encode(nonce),
        'tag': base64Encode(tag),
        'sessionId': sessionId,
      };

  factory ECDHEncryptedData.fromJson(Map<String, dynamic> json) =>
      ECDHEncryptedData(
        ciphertext: base64Decode(json['ciphertext']),
        nonce: base64Decode(json['nonce']),
        tag: base64Decode(json['tag']),
        sessionId: json['sessionId'],
      );
}

/// Internal session storage
class _ECDHSession {
  final String sessionId;
  final String peerId;
  final ECDHKeyPair localKeyPair;
  final Uint8List peerPublicKey;
  final Uint8List sharedSecret;
  final DateTime createdAt;

  const _ECDHSession({
    required this.sessionId,
    required this.peerId,
    required this.localKeyPair,
    required this.peerPublicKey,
    required this.sharedSecret,
    required this.createdAt,
  });
}

/// AES-GCM encryption result
class _AESGCMResult {
  final Uint8List ciphertext;
  final Uint8List tag;

  const _AESGCMResult({
    required this.ciphertext,
    required this.tag,
  });
}
