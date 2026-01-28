import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/file_directory_service.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/utils/url_utils.dart' hide FileType;
import 'package:p2lan/widgets/buttons/index.dart';
import 'package:p2lan/widgets/p2p/local_file_manager_widget.dart'
    as local_manager;
import 'package:p2lan/widgets/generic/generic_context_menu.dart';
import 'package:p2lan/services/settings_models_service.dart';

class MultiFileSenderDialog extends StatefulWidget {
  final P2PUser targetUser;
  final Function(List<String> filePaths) onSendFiles;

  const MultiFileSenderDialog({
    super.key,
    required this.targetUser,
    required this.onSendFiles,
  });

  @override
  State<MultiFileSenderDialog> createState() => _MultiFileSenderDialogState();
}

class _MultiFileSenderDialogState extends State<MultiFileSenderDialog>
    with SingleTickerProviderStateMixin {
  final List<FileInfo> _selectedFiles = [];
  bool _isLoading = false;
  bool _filesSent = false;
  // bool _dragging = false; // Drag visual ignored for now

  // Remove unused loc field; use local variable via AppLocalizations.of(context)

  // Track file picker results for cleanup
  final List<FilePickerResult> _filePickerResults = [];

  @override
  void dispose() {
    // FIX: Only cleanup if dialog was cancelled (not sent)
    if (!_filesSent) {
      _cleanupFilePickerCache();
    }
    // CLEANUP: Clear selected files list to free memory
    _selectedFiles.clear();
    super.dispose();
  }

  didWidgetChangeDependencies() {
    super.didChangeDependencies();
  }

  /// Cleanup file picker temporary files
  Future<void> _cleanupFilePickerCache() async {
    try {
      // Clear file picker cache to free temporary files
      await FilePicker.platform.clearTemporaryFiles();

      // Clear our tracked results
      _filePickerResults.clear();

      logInfo(
          'MultiFileSenderDialog: Cleaned up file picker cache and temporary files');
    } catch (e) {
      logWarning(
          'MultiFileSenderDialog: Failed to cleanup file picker cache: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.send),
          const SizedBox(width: 8),
          Expanded(
              child: Text('Send Files to ${widget.targetUser.displayName}')),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 500,
        child: DropTarget(
          onDragDone: (detail) async {
            try {
              final List<FileInfo> newFiles = [];
              for (final file in detail.files) {
                if (file.path.isNotEmpty) {
                  try {
                    final fileInfo = await _createFileInfo(file.path);
                    final isAlreadySelected = _selectedFiles.any(
                      (existing) => existing.path == fileInfo.path,
                    );
                    if (!isAlreadySelected) {
                      newFiles.add(fileInfo);
                    }
                  } catch (e) {
                    logError('Error processing file ${file.path}: $e');
                  }
                }
              }
              if (newFiles.isNotEmpty && mounted) {
                setState(() {
                  _selectedFiles.addAll(newFiles);
                });
              }
            } catch (e) {
              logError('Error in onDragDone: $e');
            }
          },
          onDragEntered: (detail) {},
          onDragExited: (detail) {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedFiles.isNotEmpty)
                Row(
                  spacing: 8,
                  children: [
                    _buildEnhancedAddFilesButton(),
                    TextButton.icon(
                      onPressed: _clearAllFiles,
                      icon: const Icon(Icons.clear_all),
                      label: Text(l10n.clearAll),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              if (_selectedFiles.isNotEmpty) const SizedBox(height: 16),
              Expanded(
                child: _selectedFiles.isEmpty
                    ? _buildEmptyState()
                    : _buildFilesList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // 🔥 CLEANUP: Safe to clean cache when canceling - files won't be used
            _cleanupFilePickerCache();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _selectedFiles.isEmpty || _isLoading ? null : _sendFiles,
          icon: const Icon(Icons.send),
          label: Text(l10n.sendFiles),
        ),
      ],
    );
  }

  Widget _buildEnhancedAddFilesButton() {
    final l10n = AppLocalizations.of(context);
    return IconButtonX(
      icon: Icon(
        Icons.add,
        color: _isLoading
            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)
            : Theme.of(context).colorScheme.onPrimary,
        size: 18,
      ),
      text: l10n.addFiles,
      onTap: _isLoading ? null : _pickFiles,
      onLongPressStart: _isLoading
          ? null
          : (details) => _showContextMenu(details.globalPosition),
      onSecondaryTap: _isLoading
          ? null
          : (details) => _showContextMenu(details.globalPosition),
    );
  }

  void _showContextMenu(Offset position) {
    AppLocalizations.of(context);
    final options = [
      // Thêm Browse local files option trên Android
      if (Platform.isAndroid)
        OptionItem(
            label: 'Browse local files', // l10n.browseLocalFiles,
            icon: Icons.folder_open,
            onTap: () {
              _browseLocalFiles();
            }),
      OptionItem(
          label: 'Downloads',
          icon: Icons.delete_outline,
          onTap: () {
            _onCategorySelected(FileCategory.downloads);
          }),
      OptionItem(
          label: 'Videos',
          icon: Icons.videocam,
          onTap: () {
            _onCategorySelected(FileCategory.videos);
          }),
      OptionItem(
          label: 'Images',
          icon: Icons.image,
          onTap: () {
            _onCategorySelected(FileCategory.images);
          }),
      OptionItem(
          label: 'Documents',
          icon: Icons.document_scanner,
          onTap: () {
            _onCategorySelected(FileCategory.documents);
          }),
      OptionItem(
          label: 'Audio',
          icon: Icons.audiotrack,
          onTap: () {
            _onCategorySelected(FileCategory.audio);
          }),
    ];
    GenericContextMenu.show(
        context: context,
        actions: options,
        position: position,
        desktopDialogWidth: 240);
  }

  void _onCategorySelected(FileCategory? category) {
    if (category == null) {
      logInfo('Radial menu selection cancelled.');
      return;
    }
    logInfo('Category selected: ${category.toString()}');
    _pickFilesForCategory(category);
  }

  /// Browse local files using the file manager
  void _browseLocalFiles() async {
    try {
      // Get download path for browsing
      final settings = await ExtensibleSettingsService.getReceiverSettings();
      final basePath = settings.downloadPath;

      if (!mounted) return;

      // Navigate to file manager in selection mode
      final List<String>? selectedFiles =
          await Navigator.of(context).push<List<String>>(
        MaterialPageRoute(
          builder: (context) => local_manager.LocalFileManagerWidget(
            basePath: basePath,
            viewSubfolders: true,
            viewOnly: false,
            title: 'Select Files to Send',
            selectionMode: true, // Enable selection mode
          ),
        ),
      );

      if (selectedFiles != null && selectedFiles.isNotEmpty && mounted) {
        // Process selected files
        final List<FileInfo> newFiles = [];
        for (final filePath in selectedFiles) {
          try {
            final fileInfo = await _createFileInfo(filePath);
            final isAlreadySelected = _selectedFiles.any(
              (existing) => existing.path == fileInfo.path,
            );
            if (!isAlreadySelected) {
              newFiles.add(fileInfo);
            }
          } catch (e) {
            logError('Error processing selected file $filePath: $e');
          }
        }

        if (newFiles.isNotEmpty) {
          setState(() {
            _selectedFiles.addAll(newFiles);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Added ${newFiles.length} file(s) from local browser'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      logError('Error in _browseLocalFiles: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error browsing local files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _pickFilesForCategory(FileCategory category) async {
    // Show progress first
    final current = ValueNotifier<int>(0);
    final total = ValueNotifier<int>(0);
    _showProcessingDialog(current, total);

    try {
      // Use the file directory service to pick files for this category
      final result = await FileDirectoryService.pickFilesByCategory(
        category,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        // 🔥 TRACK: Store result for cleanup
        _filePickerResults.add(result);
        total.value = result.files.length;
        await _processResultWithProgress(result, current: current);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Added ${result.files.length} file(s) from ${FileDirectoryService.getCategoryDisplayName(category)}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      logError('Error picking files for category ${category.toString()}: $e');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error selecting files from ${category.toString()}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {}
  }

  /// Pick files using the default file picker.
  void _pickFiles() async {
    // Show progress first
    final current = ValueNotifier<int>(0);
    final total = ValueNotifier<int>(0);
    _showProcessingDialog(current, total);

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        // 🔥 TRACK: Store result for cleanup
        _filePickerResults.add(result);
        total.value = result.files.length;
        await _processResultWithProgress(result, current: current);
        if (mounted) Navigator.of(context).pop();
      } else {
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {}
  }

  Future<void> _processResultWithProgress(FilePickerResult result,
      {ValueNotifier<int>? current, String? successSnackBar}) async {
    final progress = current ?? ValueNotifier<int>(0);
    final total = result.files.length;
    // If dialog not shown by caller, show it now
    if (current == null && mounted) {
      _showProcessingDialog(progress, ValueNotifier<int>(total));
    }

    try {
      for (int i = 0; i < total; i++) {
        final file = result.files[i];
        if (file.path != null) {
          final fileInfo = await _createFileInfo(file.path!);
          final isAlreadySelected =
              _selectedFiles.any((existing) => existing.path == fileInfo.path);
          if (!isAlreadySelected) {
            if (mounted) {
              setState(() {
                _selectedFiles.add(fileInfo);
              });
            }
          }
        }
        progress.value = i + 1;
        await Future.delayed(Duration.zero);
      }
      if (mounted && current == null) {
        Navigator.of(context).pop(); // close progress dialog we opened
        if (successSnackBar != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successSnackBar),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (current == null) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showProcessingDialog(
      ValueNotifier<int> current, ValueNotifier<int> total) {
    final l10n = AppLocalizations.of(context);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          content: ValueListenableBuilder<int>(
            valueListenable: current,
            builder: (context, value, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: total,
                      builder: (context, totalVal, __) {
                        final showNumbers = (totalVal > 0);
                        final text = showNumbers
                            ? l10n.processingNumberOfTotal(value, totalVal)
                            : l10n.waitingForFileSelection;
                        return Text(
                          text,
                          softWrap: true,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<FileInfo> _createFileInfo(String filePath) async {
    final file = File(filePath);
    final stat = await file.stat();
    final name = file.path.split(Platform.pathSeparator).last;
    final extension =
        name.contains('.') ? name.split('.').last.toLowerCase() : '';

    return FileInfo(
      path: filePath,
      name: name,
      size: stat.size,
      extension: extension,
    );
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _clearAllFiles() {
    setState(() {
      _selectedFiles.clear();
    });
    // 🔥 CLEANUP: Safe to cleanup cache when clearing files - they won't be used
    _cleanupFilePickerCache();
  }

  void _sendFiles() async {
    if (_selectedFiles.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // 🔥 FIX: Mark files as sent before calling back
      _filesSent = true;

      final filePaths = _selectedFiles.map((file) => file.path).toList();
      widget.onSendFiles(filePaths);

      if (mounted) {
        // 🔥 IMPORTANT: DO NOT cleanup cache here - files are still needed for transfer
        // Cache will be cleaned up by P2P service after transfer completes
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
        return Icons.audio_file;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return Icons.archive;
      case 'txt':
        return Icons.text_snippet;
      case 'json':
      case 'xml':
      case 'html':
      case 'css':
      case 'js':
      case 'dart':
      case 'java':
      case 'cpp':
      case 'py':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: _isLoading ? null : _pickFiles,
      onLongPressStart: _isLoading
          ? null
          : (details) => _showContextMenu(details.globalPosition),
      onSecondaryTapDown: _isLoading
          ? null
          : (details) => _showContextMenu(details.globalPosition),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 64,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noFilesSelected,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tapRightClickForOptions,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              _buildEnhancedAddFilesButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with total size
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected Files (${_selectedFiles.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              _formatTotalSize(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const Divider(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: _selectedFiles.length,
            itemBuilder: (context, index) {
              final fileInfo = _selectedFiles[index];
              return ListTile(
                leading: Icon(
                  _getFileIcon(fileInfo.extension),
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  fileInfo.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${_formatFileSize(fileInfo.size)} • ${fileInfo.extension.toUpperCase()}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeFile(index),
                  color: Colors.red,
                ),
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatTotalSize() {
    if (_selectedFiles.isEmpty) return '0 B';
    final totalSize =
        _selectedFiles.fold<int>(0, (sum, file) => sum + file.size);
    return _formatBytes(totalSize);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

class FileInfo {
  final String path;
  final String name;
  final int size;
  final String extension;

  FileInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.extension,
  });
}
