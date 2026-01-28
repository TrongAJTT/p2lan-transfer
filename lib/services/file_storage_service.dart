import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/variables.dart';

class FileStorageService {
  static FileStorageService? _instance;
  static FileStorageService get instance =>
      _instance ??= FileStorageService._();

  FileStorageService._();

  /// Get app-specific downloads directory (no permission required)
  Future<String> getAppDownloadsDirectory() async {
    try {
      if (Platform.isAndroid) {
        final appDir = await getExternalStorageDirectory();
        if (appDir != null) {
          final downloadsDir = Directory('${appDir.path}/Downloads');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          return downloadsDir.path;
        }
      }

      // Fallback for other platforms or if getExternalStorageDirectory fails
      final appDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDir.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      return downloadsDir.path;
    } catch (e) {
      logError('Failed to get app downloads directory: $e');
      return _getFallbackDirectory();
    }
  }

  /// Get default public downloads directory
  String getPublicDownloadsDirectory() {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download/$appName';
    } else if (Platform.isWindows) {
      return '${Platform.environment['USERPROFILE']}\\Downloads\\$appName';
    } else if (Platform.isMacOS) {
      return '${Platform.environment['HOME']}/Downloads/$appName';
    } else if (Platform.isLinux) {
      return '${Platform.environment['HOME']}/Downloads/$appName';
    }
    return '/Downloads/$appName';
  }

  String _getFallbackDirectory() {
    if (Platform.isWindows) {
      return '${Platform.environment['USERPROFILE']}\\Downloads\\$appName';
    } else {
      return '${Platform.environment['HOME'] ?? '/tmp'}/Downloads/$appName';
    }
  }

  /// Check if we have storage permission for custom paths
  Future<bool> hasStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;

      if (sdkInt >= 30) {
        // Android 11+ - Check MANAGE_EXTERNAL_STORAGE
        return await Permission.manageExternalStorage.isGranted;
      } else {
        // Android 10 and below - Check legacy storage permission
        return await Permission.storage.isGranted;
      }
    } catch (e) {
      logError('Failed to check storage permission: $e');
      return false;
    }
  }

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;

      PermissionStatus status;

      if (sdkInt >= 30) {
        // Android 11+ - Request MANAGE_EXTERNAL_STORAGE
        status = await Permission.manageExternalStorage.request();
      } else {
        // Android 10 and below - Request legacy storage permission
        status = await Permission.storage.request();
      }

      return status.isGranted;
    } catch (e) {
      logError('Failed to request storage permission: $e');
      return false;
    }
  }

  /// Create directory if it doesn't exist
  Future<bool> createDirectoryIfNeeded(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        logInfo('Created directory: $path');
      }
      return true;
    } catch (e) {
      logError('Failed to create directory $path: $e');
      return false;
    }
  }

  /// Get available download locations for user to choose from
  Future<List<DownloadLocation>> getAvailableDownloadLocations() async {
    final locations = <DownloadLocation>[];

    // App-specific directory (always available)
    final appDir = await getAppDownloadsDirectory();
    locations.add(DownloadLocation(
      name: 'App Downloads (Recommended)',
      path: appDir,
      requiresPermission: false,
      description: 'Files saved here are private to this app',
    ));

    // Public downloads directory (requires permission on Android)
    if (Platform.isAndroid) {
      final hasPermission = await hasStoragePermission();
      locations.add(DownloadLocation(
        name: 'Public Downloads',
        path: getPublicDownloadsDirectory(),
        requiresPermission: true,
        description: hasPermission
            ? 'Files saved here are accessible by other apps'
            : 'Requires storage permission - files accessible by other apps',
        isAvailable: hasPermission,
      ));
    } else {
      // Desktop platforms - no special permission needed
      locations.add(DownloadLocation(
        name: 'Downloads Folder',
        path: getPublicDownloadsDirectory(),
        requiresPermission: false,
        description: 'Default downloads folder',
      ));
    }

    return locations;
  }

  /// Validate if a path is writable
  Future<bool> isPathWritable(String path) async {
    try {
      final directory = Directory(path);

      // Check if directory exists or can be created
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Try to create a test file
      final testFile = File('${directory.path}/.write_test');
      await testFile.writeAsString('test');
      await testFile.delete();

      return true;
    } catch (e) {
      logWarning('Path not writable: $path - $e');
      return false;
    }
  }
}

class DownloadLocation {
  final String name;
  final String path;
  final bool requiresPermission;
  final String description;
  final bool isAvailable;

  DownloadLocation({
    required this.name,
    required this.path,
    required this.requiresPermission,
    required this.description,
    this.isAvailable = true,
  });
}
