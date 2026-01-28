import 'dart:io';

import 'package:flutter/material.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/utils/size_utils.dart';
import 'package:p2lan/utils/url_utils.dart';
import 'package:p2lan/utils/widget_layout_render_helper.dart';
import 'package:p2lan/widgets/generic/generic_dialog.dart';
import 'package:p2lan/variables.dart';

class DataTransferProgressWidget extends StatelessWidget {
  final DataTransferTask task;
  final VoidCallback? onCancel;
  final VoidCallback? onClear;
  final void Function(bool deleteFile)? onClearWithFile;
  final bool isInBatch;
  final List<DataTransferTask>? batchTasks; // Add batch context
  final bool showBatchSummary; // Add option to show batch summary

  const DataTransferProgressWidget({
    super.key,
    required this.task,
    this.onCancel,
    this.onClear,
    this.onClearWithFile,
    this.isInBatch = false,
    this.batchTasks,
    this.showBatchSummary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isInBatch) {
      return _buildCompactView(context);
    } else {
      return _buildFullView(context);
    }
  }

  // Batch summary calculations
  Map<String, dynamic> _getBatchSummary() {
    if (batchTasks == null || batchTasks!.isEmpty) {
      return {
        'totalFiles': 1,
        'totalSize': task.fileSize,
        'transferredSize': task.transferredBytes,
        'overallProgress': task.progress,
        'completedFiles': task.status == DataTransferStatus.completed ? 1 : 0,
      };
    }

    final totalFiles = batchTasks!.length;
    final totalSize = batchTasks!.fold<int>(0, (sum, t) => sum + t.fileSize);
    final transferredSize =
        batchTasks!.fold<int>(0, (sum, t) => sum + t.transferredBytes);
    final overallProgress = totalSize > 0 ? transferredSize / totalSize : 0.0;
    final completedFiles = batchTasks!
        .where((t) => t.status == DataTransferStatus.completed)
        .length;

    return {
      'totalFiles': totalFiles,
      'totalSize': totalSize,
      'transferredSize': transferredSize,
      'overallProgress': overallProgress,
      'completedFiles': completedFiles,
    };
  }

  Widget _buildFullView(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildCompactView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: _buildContent(context, isCompact: true),
    );
  }

  Widget _buildContent(BuildContext context, {bool isCompact = false}) {
    final l10n = AppLocalizations.of(context);
    final batchSummary = showBatchSummary ? _getBatchSummary() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Batch summary (if enabled and available)
        if (showBatchSummary && batchSummary != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder_copy,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Batch Transfer',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${batchSummary['completedFiles']}/${batchSummary['totalFiles']} files',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${_formatFileSize(batchSummary['transferredSize'])} / ${_formatFileSize(batchSummary['totalSize'])}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: batchSummary['overallProgress'],
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(batchSummary['overallProgress'] * 100).toStringAsFixed(1)}% overall progress',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],

        // Header with file info
        Row(
          children: [
            if (!isCompact)
              CircleAvatar(
                backgroundColor: _getStatusColor(),
                child: Icon(
                  _getStatusIcon(),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            if (!isCompact) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.fileName,
                          style: TextStyle(
                            fontWeight:
                                isCompact ? FontWeight.normal : FontWeight.bold,
                            fontSize: isCompact ? 14 : 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (!isCompact)
                    Text(
                      task.isOutgoing
                          ? l10n.sendToUser(task.targetUserName)
                          : l10n.receiveFromUser(task.targetUserName),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            _buildActionButtons(context, isCompact),
          ],
        ),

        if (!isCompact) const SizedBox(height: 12),

        // Progress bar (only for transferring status)
        if (task.status == DataTransferStatus.transferring) ...[
          LinearProgressIndicator(
            value: task.progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
          ),
          const SizedBox(height: 8),
        ],

        // Status and details
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isInBatch) ...[
                        _buildDirectionIcon(context),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          _getStatusText(l10n),
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w500,
                            fontSize: isCompact ? 12 : 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (task.status == DataTransferStatus.transferring)
                    Text(
                      _getProgressText(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: isCompact ? 11 : null,
                          ),
                    ),
                  if (task.errorMessage != null)
                    Text(
                      'Lỗi: ${task.errorMessage}',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: isCompact ? 11 : 12,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatFileSize(task.fileSize),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: isCompact ? 11 : null,
                      ),
                ),
                if (task.status == DataTransferStatus.transferring)
                  Text(
                    _getTransferSpeed(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: isCompact ? 11 : null,
                        ),
                  ),
              ],
            ),
          ],
        ),

        // Time information
        if (!isCompact &&
            (task.startedAt != null || task.completedAt != null)) ...[
          const SizedBox(height: 8),
          Text(
            _getTimeInfo(l10n),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isCompact) {
    final l10n = AppLocalizations.of(context);

    if (task.status == DataTransferStatus.transferring && onCancel != null) {
      return IconButton(
        onPressed: onCancel,
        icon: const Icon(Icons.cancel),
        tooltip: l10n.cancelTransfer,
        iconSize: isCompact ? 20 : 24,
      );
    }

    if (task.status == DataTransferStatus.cancelled ||
        task.status == DataTransferStatus.failed) {
      return IconButton(
        onPressed: onClear,
        icon: Icon(Icons.clear, color: Colors.grey[700]),
        tooltip: l10n.clearTask,
        iconSize: isCompact ? 20 : 24,
      );
    }

    if (task.status == DataTransferStatus.completed) {
      // For completed incoming files, show delete with file option
      if (!task.isOutgoing && task.savePath != null) {
        return PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'open_in_app':
                UriUtils.openFile(context: context, filePath: task.savePath!);
                break;
              case 'share':
                UriUtils.shareFile(task.savePath!);
                break;
              case 'copy_to':
                UriUtils.simpleExternalOperation(
                  context: context,
                  sourcePath: task.savePath!,
                  isMove: false,
                );
                break;
              case 'open_in_explorer':
                UriUtils.openInFileExplorer(task.savePath!);
                break;
              case 'clear':
                onClear?.call();
                break;
              case 'delete_with_file':
                _showDeleteWithFileDialog(context);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'open_in_app',
              child: Row(
                children: [
                  const Icon(Icons.folder_open),
                  const SizedBox(width: 8),
                  Text(l10n.openInApp),
                ],
              ),
            ),
            if (Platform.isAndroid) ...[
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    const Icon(Icons.share),
                    const SizedBox(width: 8),
                    Text(l10n.share),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'copy_to',
                child: Row(
                  children: [
                    const Icon(Icons.copy),
                    const SizedBox(width: 8),
                    Text('${l10n.copyTo}...'),
                  ],
                ),
              ),
            ],
            if (Platform.isWindows) ...[
              PopupMenuItem(
                value: 'open_in_explorer',
                child: Row(
                  children: [
                    const Icon(Icons.folder_open),
                    const SizedBox(width: 8),
                    Text(l10n.openInExplorer),
                  ],
                ),
              ),
            ],
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  const Icon(Icons.delete_forever),
                  const SizedBox(width: 8),
                  Text(l10n.delete),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete_with_file',
              child: Row(
                children: [
                  const Icon(Icons.delete_sweep, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(l10n.deleteWithFile,
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          iconSize: isCompact ? 20 : 24,
        );
      } else {
        // For outgoing files or files without savePath, show regular clear option
        return PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'clear') {
              onClear?.call();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  const Icon(Icons.delete_forever),
                  const SizedBox(width: 8),
                  Text(l10n.delete),
                ],
              ),
            ),
          ],
          iconSize: isCompact ? 20 : 24,
        );
      }
    }

    return const SizedBox.shrink();
  }

  void _showDeleteWithFileDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => GenericDialog(
        header: GenericDialogHeader(title: l10n.deleteTaskWithFile),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deleteTaskWithFileConfirm),
            const SizedBox(height: 8),
            Text(
              task.fileName,
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
            if (task.savePath != null) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.path}: ${task.savePath}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.deleteTaskWithFileConfirm,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        footer: GenericDialogFooter(
          child: WidgetLayoutRenderHelper.oneLeftTwoRight(
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onClearWithFile?.call(false); // Clear task only
                },
                child: Text(l10n.deleteTaskOnly),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onClearWithFile?.call(true); // Delete task and file
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.deleteWithFile),
              ),
              threeInARowMinWidth: 400,
              twoInARowMinWidth: 0),
        ),
        decorator: GenericDialogDecorator(
            width: DynamicDimension.flexibilityMax(90, 700),
            displayTopDivider: true),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (task.status) {
      case DataTransferStatus.pending:
        return Icons.schedule;
      case DataTransferStatus.requesting:
        return Icons.help_outline;
      case DataTransferStatus.waitingForApproval:
        return Icons.hourglass_empty;
      case DataTransferStatus.rejected:
        return Icons.block;
      case DataTransferStatus.transferring:
        return Icons.sync;
      case DataTransferStatus.completed:
        return Icons.check_circle;
      case DataTransferStatus.failed:
        return Icons.error;
      case DataTransferStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor() {
    switch (task.status) {
      case DataTransferStatus.pending:
        return Colors.orange;
      case DataTransferStatus.requesting:
        return Colors.blue;
      case DataTransferStatus.waitingForApproval:
        return Colors.amber;
      case DataTransferStatus.rejected:
        return Colors.red;
      case DataTransferStatus.transferring:
        return Colors.green;
      case DataTransferStatus.completed:
        return Colors.green;
      case DataTransferStatus.failed:
        return Colors.red;
      case DataTransferStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText(AppLocalizations l10n) {
    switch (task.status) {
      case DataTransferStatus.pending:
        return l10n.waiting;
      case DataTransferStatus.requesting:
        return l10n.requesting;
      case DataTransferStatus.waitingForApproval:
        return l10n.waitingForApproval;
      case DataTransferStatus.rejected:
        return l10n.beingRefused;
      case DataTransferStatus.transferring:
        return task.isOutgoing ? l10n.sending : l10n.receiving;
      case DataTransferStatus.completed:
        return l10n.completed;
      case DataTransferStatus.failed:
        return l10n.failed;
      case DataTransferStatus.cancelled:
        return l10n.cancelled;
    }
  }

  String _getProgressText() {
    final progress = (task.progress * 100).toStringAsFixed(1);
    final transferred = _formatFileSize(task.transferredBytes);
    final total = _formatFileSize(task.fileSize);
    return '$progress% ($transferred / $total)';
  }

  String _getTransferSpeed() {
    if (task.startedAt == null ||
        task.status != DataTransferStatus.transferring) {
      return '';
    }

    final elapsed = DateTime.now().difference(task.startedAt!);
    if (elapsed.inSeconds == 0) {
      return '';
    }

    final bytesPerSecond = task.transferredBytes / elapsed.inSeconds;
    return '${_formatFileSize(bytesPerSecond.round())}/s';
  }

  String _getTimeInfo(AppLocalizations loc) {
    if (task.status == DataTransferStatus.cancelled ||
        task.status == DataTransferStatus.failed) {
      return loc.stopped;
    }
    if (task.completedAt != null) {
      final duration =
          task.completedAt!.difference(task.startedAt ?? task.createdAt);
      return loc.completedInTime(_formatDuration(duration));
    } else if (task.startedAt != null) {
      final elapsed = DateTime.now().difference(task.startedAt!);
      return loc.transferredInTime(_formatDuration(elapsed));
    } else {
      final waiting = DateTime.now().difference(task.createdAt);
      return loc.waitingInTime(_formatDuration(waiting));
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }

  // Direction visuals
  Color _directionColor() => task.isOutgoing ? sendColor : receiveColor;

  IconData _directionIcon() =>
      task.isOutgoing ? Icons.file_upload : Icons.file_download;

  Widget _buildDirectionIcon(BuildContext context) {
    final color = _directionColor();
    final l10n = AppLocalizations.of(context);
    final label = task.isOutgoing ? l10n.sending : l10n.receiving;
    return Tooltip(
      message: label,
      child: Icon(_directionIcon(), size: 16, color: color),
    );
  }
}
