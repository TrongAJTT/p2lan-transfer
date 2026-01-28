import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/utils/snackbar_utils.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum FileType { all, image, video, audio, document, archive, other }

enum FileCategory { downloads, images, audio, documents, videos }

class UriUtils {
  /// Opens a file with the OS using open_file package.
  static Future<void> openFile(
      {required String filePath, required BuildContext context}) async {
    final loc = AppLocalizations.of(context);
    try {
      // Special handling for APK files on Android
      if (Platform.isAndroid && filePath.toLowerCase().endsWith('.apk')) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(loc.notifications),
                content: Text(loc.apkNotSupportedDesc),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(loc.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      simpleExternalOperation(
                          context: context, sourcePath: filePath, isMove: true);
                    },
                    child: Text(loc.move),
                  ),
                ],
              );
            });
      } else {
        // Normal file handling
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          if (context.mounted) {
            SnackbarUtils.showTyped(
              context,
              '${loc.canNotOpenFile}: ${result.message}',
              SnackBarType.error,
            );
          }
          logError('Failed to open file: ${result.message}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showTyped(
          context,
          '${loc.errorOpeningFile}: ${e.toString()}',
          SnackBarType.error,
        );
      }
      logError('Error opening file: $e');
    }
  }

  static Future<void> launchInBrowserWithConfirm(
      {required BuildContext context,
      required String url,
      required String content}) async {
    final loc = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.aboutToOpenUrlOutsideApp),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.ccontinue),
          ),
        ],
      ),
    );

    if (context.mounted && confirm == true) {
      await launchInBrowser(url, context);
    }
  }

  static String getFileName(String filePath) {
    return filePath.contains('/')
        ? filePath.split('/').last
        : filePath.split('\\').last;
  }

  /// Opens a URL in the default browser.
  static Future<void> launchInBrowser(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        late String e;
        if (url.isEmpty) {
          e = "The URL is empty.";
        } else {
          e = "There is no handler available, or that the application does not have permission to check. For example:\nOn recent versions of Android and iOS, this will always return false unless the application has been configuration to allow querying the system for launch support. See the README for details.\nOn web, this will always return false except for a few specific schemes that are always assumed to be supported (such as http(s)), as web pages are never allowed to query installed applications.";
        }
        _handleErrorOpenUrl(e, url, context);
      }
    } catch (e) {
      // Handle error silently or show user-friendly message
      _handleErrorOpenUrl(e, url, context);
    }
  }

  static void _handleErrorOpenUrl(Object e, String url, BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(loc.errorOpeningUrl),
            content: SizedBox(
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(loc.canNotOpenUrl),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: url),
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'URL',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: e.toString()),
                      maxLines: null,
                      expands: true,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Detail error:',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Đóng'),
              ),
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (context.mounted) {
                    SnackbarUtils.showTyped(
                      context,
                      loc.linkCopiedToClipboard,
                      SnackBarType.success,
                    );
                  }
                },
                child: const Text('Copy link'),
              ),
            ],
          );
        },
      );
    }
  }

  /// Open folder in the file explorer
  static void openFolderInFileExplorer(String folderPath) {
    try {
      final folder = Directory(folderPath);
      if (!folder.existsSync()) {
        throw Exception('Folder does not exist: $folderPath');
      }

      if (Platform.isWindows) {
        // Open the folder in Explorer
        // Syntax: explorer "C:\\path\\to\\folder"
        Process.run('explorer', [folder.path]);
      }
    } catch (e) {
      logError('Error opening folder: $e');
    }
  }

  /// Open and select a file in the file explorer
  static void openInFileExplorer(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File does not exist: $filePath');
      }

      if (Platform.isWindows) {
        // Highlight the file in Explorer
        // Syntax: explorer /select,"C:\\path\\to\\file"
        Process.run('explorer', ['/select,${file.path}']);
        return;
      }

      if (Platform.isMacOS) {
        // Reveal the file in Finder
        // Syntax: open -R "/path/to/file"
        Process.run('open', ['-R', file.path]);
        return;
      }

      if (Platform.isLinux) {
        // Try common file managers with "select" capability; fallback to opening the folder
        final parentDir = file.parent.path;
        Future<ProcessResult> tryRun(String cmd, List<String> args) async {
          try {
            return await Process.run(cmd, args);
          } catch (_) {
            return ProcessResult(0, 1, null, null);
          }
        }

        () async {
          // Nautilus (GNOME)
          var res = await tryRun('nautilus', ['--select', file.path]);
          if (res.exitCode == 0) return;
          // Nemo (Cinnamon)
          res = await tryRun('nemo', ['--select', file.path]);
          if (res.exitCode == 0) return;
          // Dolphin (KDE)
          res = await tryRun('dolphin', ['--select', file.path]);
          if (res.exitCode == 0) return;
          // Thunar (XFCE)
          res = await tryRun('thunar', ['--select', file.path]);
          if (res.exitCode == 0) return;
          // Fallback
          await tryRun('xdg-open', [parentDir]);
        }();
        return;
      }
    } catch (e) {
      logError('Error opening file explorer: $e');
    }
  }

  static Future<void> createImageFileFromUint8List({
    required Uint8List data,
    required String fileName,
    String? directory,
  }) async {
    if (Platform.isWindows) {
      final directoryPath = directory ?? Directory.systemTemp.path;
      final filePath = '$directoryPath/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(data);
    } else if (Platform.isAndroid) {
      final directoryPath = directory ?? Directory.systemTemp.path;
      final filePath = '$directoryPath/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(data);
    } else {
      throw UnsupportedError('Unsupported platform for creating image files');
    }
  }

  static Future<void> deleteSystemTempFile({required String fileName}) async {
    final tempDir = Directory.systemTemp;
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    } else {
      logError('File does not exist: $filePath');
    }
  }

  /// Delete a directory recursively and return whether it succeeded
  static Future<bool> deleteDirectoryRecursive(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        return true;
      }
      return false;
    } catch (e) {
      logError('Failed to delete directory $dirPath: $e');
      return false;
    }
  }

  static Future<bool> shareFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final result = await SharePlus.instance
          .share(ShareParams(files: [XFile(file.path)]));
      return result.status == ShareResultStatus.success;
    } else {
      return false;
    }
  }

  static Future<bool> simpleExternalOperation(
      {required BuildContext context,
      required String sourcePath,
      required bool isMove}) async {
    Future<String> findUniqueFileName(
        {required String dirPath, required String originalFileName}) async {
      String destinationPath = path.join(dirPath, originalFileName);
      if (!await File(destinationPath).exists()) {
        return destinationPath;
      }

      String baseName = path.basenameWithoutExtension(originalFileName);
      String extension = path.extension(originalFileName);
      int counter = 1;

      while (true) {
        String newFileName = '$baseName ($counter)$extension';
        destinationPath = path.join(dirPath, newFileName);
        if (!await File(destinationPath).exists()) {
          return destinationPath;
        }
        counter++;
      }
    }

    try {
      final String? destinationDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: isMove ? 'Di chuyển file đến...' : 'Sao chép file đến...',
      );

      if (destinationDir == null) {
        if (context.mounted) {
          SnackbarUtils.showTyped(
            context,
            'Hành động đã bị hủy',
            SnackBarType.warning,
          );
        }
        return true;
      }

      final sourceFileName = basename(sourcePath);
      final destinationPath = await findUniqueFileName(
          dirPath: destinationDir, originalFileName: sourceFileName);
      final finalFileName = basename(destinationPath);

      final sourceFile = File(sourcePath);

      if (isMove) {
        await sourceFile.copy(destinationPath);
        await sourceFile.delete();
        if (context.mounted) {
          SnackbarUtils.showTyped(
            context,
            'Đã di chuyển file thành công thành "$finalFileName"',
            SnackBarType.success,
          );
        }
        return true;
      } else {
        await sourceFile.copy(destinationPath);
        if (context.mounted) {
          SnackbarUtils.showTyped(
            context,
            'Đã sao chép file thành công thành "$finalFileName"',
            SnackBarType.success,
          );
        }
        return true;
      }
    } catch (e) {
      logError('Lỗi khi thực hiện thao tác file đơn giản: $e');
      if (context.mounted) {
        SnackbarUtils.showTyped(
          context,
          'Đã xảy ra lỗi. Vui lòng kiểm tra quyền truy cập bộ nhớ.',
          SnackBarType.error,
        );
      }
      return false;
    }
  }

  static Future<void> openFileWithDefaultApp(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception('Failed to open file: ${result.message}');
      }
    } catch (e) {
      logError('Error opening file with default app: $e');
    }
  }

  static Future<FileStat> getFileStat(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.stat();
      } else {
        throw FileSystemException('File does not exist', filePath);
      }
    } catch (e) {
      logError('Error getting file stat: $e');
      rethrow;
    }
  }

  static Future<void> showDetailDialog(
      {required BuildContext context, required String filePath}) async {
    final stat = await getFileStat(filePath);
    final _loc = AppLocalizations.of(context);

    Widget fileInfoSection({required String title, required String detail}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(detail, style: Theme.of(context).textTheme.bodyMedium)
          ],
        ),
      );
    }

    String formatFileSize(int bytes) {
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }

    String formatDate(DateTime date) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }

    FileType getFileType(String filePath) {
      final extension = path.extension(filePath).toLowerCase();
      FileType fileType;

      if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
          .contains(extension)) {
        fileType = FileType.image;
      } else if (['.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv']
          .contains(extension)) {
        fileType = FileType.video;
      } else if (['.mp3', '.wav', '.flac', '.aac', '.ogg', '.m4a']
          .contains(extension)) {
        fileType = FileType.audio;
      } else if ([
        '.pdf',
        '.doc',
        '.docx',
        '.txt',
        '.xls',
        '.xlsx',
        '.ppt',
        '.pptx'
      ].contains(extension)) {
        fileType = FileType.document;
      } else if (['.zip', '.rar', '.7z', '.tar', '.gz'].contains(extension)) {
        fileType = FileType.archive;
      } else {
        fileType = FileType.other;
      }

      return fileType;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_loc.fileInfo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            fileInfoSection(title: _loc.path, detail: filePath),
            fileInfoSection(
                title: _loc.size, detail: formatFileSize(stat.size)),
            fileInfoSection(
                title: _loc.type, detail: getFileType(filePath).name),
            fileInfoSection(
                title: _loc.modified, detail: formatDate(stat.modified)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_loc.close),
          ),
        ],
      ),
    );
  }
}
