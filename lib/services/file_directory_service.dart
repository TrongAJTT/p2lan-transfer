import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:p2lan/utils/url_utils.dart' hide FileType;
import 'package:p2lan/services/app_logger.dart';
import 'package:path_provider/path_provider.dart';

class FileDirectoryService {
  static const String _tag = 'FileDirectoryService';

  /// Get the default directory path for a file category using path_provider.
  /// This is now an async function.
  static Future<String?> getDefaultDirectoryPath(FileCategory category) async {
    try {
      if (Platform.isAndroid) {
        // For Android, we need to get the default directory path from the device.
        return _getAndroidDefaultDirectoryPath(category);
      } else if (Platform.isWindows) {
        // For Windows, using environment variables is standard and reliable.
        return _getWindowsDefaultPath(category);
      }
      return null;
    } catch (e) {
      logError(
          '$_tag: Error getting default directory path with path_provider: $e');
      return null;
    }
  }

  static Future<String?> _getAndroidDefaultDirectoryPath(
      FileCategory category) async {
    final Directory? externalStorageDir = await getExternalStorageDirectory();
    if (externalStorageDir == null) return null;

    switch (category) {
      case FileCategory.downloads:
        // getDownloadsDirectory() is the most reliable for this.
        return (await getDownloadsDirectory())?.path;
      case FileCategory.videos:
        return '${externalStorageDir.path}/Movies';
      case FileCategory.images:
        return '${externalStorageDir.path}/Pictures';
      case FileCategory.documents:
        return '${externalStorageDir.path}/Documents';
      case FileCategory.audio:
        return '${externalStorageDir.path}/Music';
    }
  }

  /// Get Windows default directory paths
  static String? _getWindowsDefaultPath(FileCategory category) {
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile == null) return null;

    switch (category) {
      case FileCategory.downloads:
        return '$userProfile\\Downloads';
      case FileCategory.videos:
        return '$userProfile\\Videos';
      case FileCategory.images:
        return '$userProfile\\Pictures';
      case FileCategory.documents:
        return '$userProfile\\Documents';
      case FileCategory.audio:
        return '$userProfile\\Music';
    }
  }

  /// Get file type filter for file picker based on category
  static FileType getFileTypeFilter(FileCategory category) {
    switch (category) {
      case FileCategory.downloads:
        return FileType.any; // Downloads can contain any file type
      case FileCategory.videos:
        return FileType.video;
      case FileCategory.images:
        return FileType.image;
      case FileCategory.documents:
        return FileType.custom; // We'll specify extensions
      case FileCategory.audio:
        return FileType.audio;
    }
  }

  /// Get allowed extensions for document category
  static List<String>? getAllowedExtensions(FileCategory category) {
    switch (category) {
      case FileCategory.documents:
        return [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'rtf',
          'odt',
          'ods',
          'odp',
          'csv',
          'json',
          'xml'
        ];
      default:
        return null; // Other categories use built-in file type filters
    }
  }

  /// Open file picker with category-specific settings
  static Future<FilePickerResult?> pickFilesByCategory(
    FileCategory category, {
    bool allowMultiple = true,
  }) async {
    try {
      logInfo(
          '$_tag: Opening file picker for category: ${category.toString()}');

      final fileType = getFileTypeFilter(category);
      final allowedExtensions = getAllowedExtensions(category);

      // On Android, we should NOT set an initial directory for media types.
      // This allows the native file picker to open in the most appropriate
      // view (e.g., the gallery for videos), leveraging MediaStore.
      // For desktop, setting the initial directory is the correct approach.
      final String? initialDirectory =
          Platform.isAndroid ? null : await getDefaultDirectoryPath(category);

      logInfo('$_tag: Initial directory: $initialDirectory');
      logInfo('$_tag: File type: $fileType');
      logInfo('$_tag: Allowed extensions: $allowedExtensions');

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: fileType,
        allowedExtensions: allowedExtensions,
        initialDirectory: initialDirectory,
        dialogTitle: 'Select ${category.toString()}',
      );

      if (result != null) {
        logInfo(
            '$_tag: Selected ${result.files.length} files from ${category.toString()}');
      } else {
        logInfo(
            '$_tag: User cancelled file selection for ${category.toString()}');
      }

      return result;
    } catch (e) {
      logError(
          '$_tag: Error picking files for category ${category.toString()}: $e');
      return null;
    }
  }

  /// Check if a directory exists and is accessible
  static Future<bool> isDirectoryAccessible(String? path) async {
    if (path == null) return false;

    try {
      final directory = Directory(path);
      return await directory.exists();
    } catch (e) {
      logWarning('$_tag: Directory not accessible: $path - $e');
      return false;
    }
  }

  /// Get a user-friendly name for the file category
  static String getCategoryDisplayName(FileCategory category) {
    switch (category) {
      case FileCategory.downloads:
        return 'Downloads Folder';
      case FileCategory.videos:
        return 'Videos Folder';
      case FileCategory.images:
        return 'Images Folder';
      case FileCategory.documents:
        return 'Documents Folder';
      case FileCategory.audio:
        return 'Audio Files';
    }
  }

  /// Get category description for user guidance
  static String getCategoryDescription(FileCategory category) {
    switch (category) {
      case FileCategory.downloads:
        return 'Browse downloaded files and general documents';
      case FileCategory.videos:
        return 'Select video files (MP4, AVI, MOV, etc.)';
      case FileCategory.images:
        return 'Choose image files (JPG, PNG, GIF, etc.)';
      case FileCategory.documents:
        return 'Pick documents (PDF, DOC, XLS, etc.)';
      case FileCategory.audio:
        return 'Select audio files (MP3, WAV, FLAC, etc.)';
    }
  }
}
