import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import 'package:p2lan/models/app_installation.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/isar_service.dart';

/// Service quản lý stable app installation ID
/// ID này chỉ thay đổi khi người dùng xóa toàn bộ dữ liệu ứng dụng
class AppInstallationService {
  static AppInstallationService? _instance;
  static AppInstallationService get instance =>
      _instance ??= AppInstallationService._();

  AppInstallationService._();

  String? _cachedInstallationId;
  String? _cachedInstallationWordId;
  bool _isInitialized = false;

  Future<AppInstallation> _getInstallationData() async {
    final isar = IsarService.isar;

    AppInstallation? installation =
        await isar.appInstallations.where().findFirst();
    if (installation == null) {
      installation = AppInstallation();
      await isar.writeTxn(() async {
        await isar.appInstallations.put(installation!);
      });
    }
    return installation;
  }

  /// Khởi tạo service và đảm bảo ID được tạo
  /// Returns true if this is first time setup (new installation)
  Future<bool> initialize() async {
    if (_isInitialized) return false;

    try {
      logDebug('AppInstallationService: Starting initialization...');

      final isar = IsarService.isar;
      logDebug('AppInstallationService: Got Isar instance');

      final installation = await _getInstallationData();
      logDebug('AppInstallationService: Got installation data');

      // Check if this is first time setup
      final isFirstTime = installation.firstTimeSetupCompleted != true ||
          installation.installationId == null;

      if (isFirstTime) {
        logInfo('AppInstallationService: First time setup detected');
        // Generate new IDs for first time
        await getAppInstallationId();
        await getAppInstallationWordId();

        // Mark setup as completed
        await isar.writeTxn(() async {
          final data = await _getInstallationData();
          data.firstTimeSetupCompleted = true;
          await isar.appInstallations.put(data);
        });
        logInfo('AppInstallationService: First time setup completed');
      } else {
        // Load existing IDs
        await getAppInstallationId();
        await getAppInstallationWordId();
        logDebug('AppInstallationService: Existing installation loaded');
      }

      _isInitialized = true;
      logInfo('AppInstallationService initialized successfully');
      return isFirstTime;
    } catch (e, stackTrace) {
      logError('Failed to initialize AppInstallationService', e, stackTrace);
      rethrow;
    }
  }

  /// Check if this is the first time the app is being used
  Future<bool> isFirstTimeSetup() async {
    try {
      final installation = await _getInstallationData();
      return installation.firstTimeSetupCompleted != true ||
          installation.installationId == null;
    } catch (e) {
      logError('Failed to check first time setup', e);
      return true; // Assume first time if error
    }
  }

  /// Mark first time setup as completed
  Future<void> markFirstTimeSetupCompleted() async {
    try {
      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        final installation = await _getInstallationData();
        installation.firstTimeSetupCompleted = true;
        await isar.appInstallations.put(installation);
      });
      logInfo('First time setup marked as completed');
    } catch (e) {
      logError('Failed to mark first time setup completed', e);
    }
  }

  /// Lấy stable app installation ID (10 ký tự: chữ hoa, chữ thường, số)
  Future<String> getAppInstallationId() async {
    if (_cachedInstallationId != null) {
      return _cachedInstallationId!;
    }

    try {
      final isar = IsarService.isar;
      final installation = await _getInstallationData();
      String? installationId = installation.installationId;

      if (installationId == null || installationId.isEmpty) {
        // Tạo installation ID mới
        installationId = _generateStableInstallationId();
        await isar.writeTxn(() async {
          final data = await _getInstallationData();
          data.installationId = installationId;
          await isar.appInstallations.put(data);
        });
        logInfo('Generated new app installation ID: $installationId');
      } else {
        logInfo('Loaded existing app installation ID: $installationId');
      }

      _cachedInstallationId = installationId;
      return installationId;
    } catch (e) {
      logError('Failed to get app installation ID: $e');
      // Fallback: tạo installation ID tạm thời không lưu vào storage
      _cachedInstallationId ??= _generateStableInstallationId();
      return _cachedInstallationId!;
    }
  }

  /// Lấy app installation word ID (readable version, ví dụ: "swift-ocean-7834")
  Future<String> getAppInstallationWordId() async {
    if (_cachedInstallationWordId != null) {
      return _cachedInstallationWordId!;
    }

    try {
      final isar = IsarService.isar;
      final installation = await _getInstallationData();
      String? installationWordId = installation.installationWordId;

      if (installationWordId == null || installationWordId.isEmpty) {
        // Tạo installation word ID mới
        installationWordId = _generateReadableInstallationId();
        await isar.writeTxn(() async {
          final data = await _getInstallationData();
          data.installationWordId = installationWordId;
          await isar.appInstallations.put(data);
        });
        logInfo('Generated new app installation word ID: $installationWordId');
      } else {
        logInfo(
            'Loaded existing app installation word ID: $installationWordId');
      }

      _cachedInstallationWordId = installationWordId;
      return installationWordId;
    } catch (e) {
      logError('Failed to get app installation word ID: $e');
      // Fallback: tạo installation word ID tạm thời không lưu vào storage
      _cachedInstallationWordId ??= _generateReadableInstallationId();
      return _cachedInstallationWordId!;
    }
  }

  /// Tạo stable installation ID từ random data (10 ký tự: chữ hoa, chữ thường, số)
  String _generateStableInstallationId() {
    // Tạo dữ liệu random với nhiều nguồn entropy để đảm bảo unique
    final random = Random.secure();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final processId = DateTime.now().millisecondsSinceEpoch % 99999;

    // Thêm random bytes để tăng entropy
    final randomBytes = List.generate(32, (_) => random.nextInt(256));

    // Tạo chuỗi unique bằng cách kết hợp nhiều nguồn
    final uniqueData = {
      'timestamp': timestamp,
      'processId': processId,
      'randomBytes': randomBytes,
      'systemTime': DateTime.now().toIso8601String(),
      'randomSeed': random.nextDouble(),
      // Thêm một số dữ liệu khác để tăng độ unique
      'microTime': DateTime.now().microsecond,
      'extraRandom': List.generate(16, (_) => random.nextInt(1000000)),
    };

    // Chuyển thành JSON và hash
    final jsonString = jsonEncode(uniqueData);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);

    // Lấy hash string
    final hashString = digest.toString();

    // Tạo ID với mix của chữ hoa, chữ thường, và số
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    String result = '';

    // Sử dụng hash để tạo seed cho random
    int seed = 0;
    for (int i = 0; i < hashString.length && i < 8; i++) {
      seed += hashString.codeUnitAt(i);
    }
    final seededRandom = Random(seed);

    // Generate 10 characters with mix of uppercase, lowercase, and numbers
    for (int i = 0; i < 10; i++) {
      // Ensure we have a good mix by forcing certain positions
      if (i < 3) {
        // First 3: at least one uppercase
        const upperChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        result += upperChars[seededRandom.nextInt(upperChars.length)];
      } else if (i < 6) {
        // Next 3: at least one lowercase
        const lowerChars = 'abcdefghijklmnopqrstuvwxyz';
        result += lowerChars[seededRandom.nextInt(lowerChars.length)];
      } else if (i < 8) {
        // Next 2: at least one number
        const numbers = '0123456789';
        result += numbers[seededRandom.nextInt(numbers.length)];
      } else {
        // Last 2: random from all characters
        result += characters[seededRandom.nextInt(characters.length)];
      }
    }

    // Shuffle the result to avoid predictable patterns
    final resultList = result.split('');
    for (int i = resultList.length - 1; i > 0; i--) {
      final j = seededRandom.nextInt(i + 1);
      final temp = resultList[i];
      resultList[i] = resultList[j];
      resultList[j] = temp;
    }

    return resultList.join('');
  }

  /// Tạo readable installation ID (ví dụ: "swift-ocean-7834")
  String _generateReadableInstallationId() {
    final random = Random.secure();

    // Danh sách từ đẹp cho readable ID
    final adjectives = [
      'swift',
      'bright',
      'calm',
      'cool',
      'fast',
      'warm',
      'nice',
      'blue',
      'green',
      'smart',
      'brave',
      'quick',
      'clear',
      'fresh',
      'clean',
      'pure',
      'sharp',
      'smooth',
      'light',
      'dark',
      'soft',
      'hard',
      'wild',
      'free'
    ];

    final nouns = [
      'ocean',
      'mountain',
      'river',
      'forest',
      'cloud',
      'star',
      'moon',
      'sun',
      'wind',
      'fire',
      'earth',
      'water',
      'sky',
      'tree',
      'flower',
      'bird',
      'fish',
      'cat',
      'dog',
      'wolf',
      'eagle',
      'lion',
      'bear',
      'fox'
    ];

    final adjective = adjectives[random.nextInt(adjectives.length)];
    final noun = nouns[random.nextInt(nouns.length)];
    final number = random.nextInt(9000) + 1000; // 4 digit number

    return '$adjective-$noun-$number';
  }

  /// Reset app installation (xóa ID cũ, tạo ID mới)
  /// Chỉ sử dụng khi cần test hoặc user request reset
  Future<void> resetAppInstallation() async {
    try {
      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.appInstallations.clear();
      });

      _cachedInstallationId = null;
      _cachedInstallationWordId = null;
      _isInitialized = false;

      logInfo('App installation reset successfully');
    } catch (e) {
      logError('Failed to reset app installation: $e');
      rethrow;
    }
  }

  /// Kiểm tra xem service đã được khởi tạo chưa
  bool get isInitialized => _isInitialized;
}
