import 'package:flutter/material.dart';
import 'package:p2lantransfer/l10n/app_localizations.dart';
import 'package:p2lantransfer/models/p2p_models.dart';
import 'package:p2lantransfer/widgets/generic/generic_context_menu.dart';
import 'package:p2lantransfer/widgets/p2p/data_transfer_progress_widget.dart';
import 'package:p2lantransfer/utils/generic_dialog_utils.dart';
import 'package:p2lantransfer/variables.dart';

class TransferBatchWidget extends StatefulWidget {
  final String? batchId;
  final List<DataTransferTask> tasks;
  final void Function(String taskId) onCancel;
  final void Function(String taskId) onClear;
  final void Function(String taskId, bool deleteFile) onClearWithFile;
  final bool initialExpanded;
  final void Function(String? batchId, bool expanded)? onExpandChanged;
  final void Function(String? batchId)? onClearBatch;
  final void Function(String? batchId)? onClearBatchWithFiles;

  const TransferBatchWidget({
    super.key,
    required this.batchId,
    required this.tasks,
    required this.onCancel,
    required this.onClear,
    required this.onClearWithFile,
    this.initialExpanded = true,
    this.onExpandChanged,
    this.onClearBatch,
    this.onClearBatchWithFiles,
  });

  @override
  State<TransferBatchWidget> createState() => _TransferBatchWidgetState();
}

class _TransferBatchWidgetState extends State<TransferBatchWidget> {
  late bool _isExpanded;
  late AppLocalizations _loc;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize localization when dependencies are available
    _loc = AppLocalizations.of(context)!;
  }

  @override
  void didUpdateWidget(TransferBatchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update localization
    _loc = AppLocalizations.of(context)!;
    // Update expand state if initialExpanded changed
    if (widget.initialExpanded != oldWidget.initialExpanded) {
      _isExpanded = widget.initialExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) return const SizedBox.shrink();

    // If only one task, display it directly without grouping
    if (widget.tasks.length == 1) {
      return _buildSingleTaskWidget(widget.tasks.first);
    }

    // Multiple tasks - show as grouped batch
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBatchHeader(AppLocalizations.of(context)!),
          if (_isExpanded) ...[
            const Divider(height: 1),
            ...widget.tasks.map((task) => _buildTaskInBatch(task)),
          ],
        ],
      ),
    );
  }

  Widget _buildBatchHeader(AppLocalizations loc) {
    final sampleTask = widget.tasks.first;
    final totalSize =
        widget.tasks.fold<int>(0, (sum, task) => sum + task.fileSize);
    final completedTasks = widget.tasks
        .where((t) => t.status == DataTransferStatus.completed)
        .length;
    final failedTasks = widget.tasks
        .where((t) =>
            t.status == DataTransferStatus.failed ||
            t.status == DataTransferStatus.cancelled ||
            t.status == DataTransferStatus.rejected)
        .length;
    final transferringTasks = widget.tasks
        .where((t) => t.status == DataTransferStatus.transferring)
        .length;

    // Calculate overall progress for transferring tasks
    double overallProgress = 0.0;
    int transferredBytes = 0;
    if (widget.tasks.isNotEmpty) {
      for (final task in widget.tasks) {
        if (task.status == DataTransferStatus.completed) {
          transferredBytes += task.fileSize;
        } else {
          transferredBytes += task.transferredBytes;
        }
      }
      overallProgress = transferredBytes / totalSize;
    }

    Color headerColor = Colors.blue;
    IconData headerIcon = Icons.folder;
    String statusText = '';

    if (completedTasks == widget.tasks.length) {
      headerColor = Colors.green;
      headerIcon = Icons.check_circle;
      statusText = loc.allCompleted;
    } else if (failedTasks > 0 &&
        (failedTasks + completedTasks) == widget.tasks.length) {
      headerColor = Colors.red;
      headerIcon = Icons.error;
      statusText = loc.completedWithErrors;
    } else if (transferringTasks > 0) {
      headerColor = Colors.orange;
      headerIcon = Icons.sync;
      statusText = loc.transfering;
    } else {
      statusText = loc.waiting;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
        widget.onExpandChanged?.call(widget.batchId, _isExpanded);
      },
      onLongPressStart: (d) => _showBatchContextMenu(d.globalPosition),
      onSecondaryTapDown: (d) => _showBatchContextMenu(d.globalPosition),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: headerColor,
                  child: Icon(headerIcon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sampleTask.isOutgoing
                            ? _loc.numberFilesSendToUser(
                                widget.tasks.length, sampleTask.targetUserName)
                            : _loc.numberFilesReceivedFromUser(
                                widget.tasks.length, sampleTask.targetUserName),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            sampleTask.isOutgoing
                                ? Icons.file_upload
                                : Icons.file_download,
                            size: 16,
                            color: sampleTask.isOutgoing
                                ? sendColor
                                : receiveColor,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: headerColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatFileSize(totalSize),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (transferringTasks > 0)
                      Text(
                        '${(overallProgress * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: headerColor,
                            ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                ),
              ],
            ),

            // Progress bar for batch
            if (transferringTasks > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: overallProgress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(headerColor),
              ),
            ],

            // Summary info
            const SizedBox(height: 8),
            Row(
              children: [
                if (completedTasks > 0)
                  _buildStatusChip(
                      loc.completedTasksNumber(completedTasks), Colors.green),
                if (transferringTasks > 0) ...[
                  if (completedTasks > 0) const SizedBox(width: 8),
                  _buildStatusChip(
                      loc.transferringTasksNumber(transferringTasks),
                      Colors.orange),
                ],
                if (failedTasks > 0) ...[
                  if (completedTasks > 0 || transferringTasks > 0)
                    const SizedBox(width: 8),
                  _buildStatusChip(
                      loc.failedTasksNumber(failedTasks), Colors.red),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTaskInBatch(DataTransferTask task) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: DataTransferProgressWidget(
        task: task,
        onCancel: () => widget.onCancel(task.id),
        onClear: () => widget.onClear(task.id),
        onClearWithFile: (deleteFile) =>
            widget.onClearWithFile(task.id, deleteFile),
        isInBatch: true,
      ),
    );
  }

  Widget _buildSingleTaskWidget(DataTransferTask task) {
    // For single task widgets, check if it should show batch summary
    final shouldShowBatchSummary =
        widget.tasks.length > 1 && widget.tasks.first.id == task.id;

    return DataTransferProgressWidget(
      task: task,
      onCancel: () => widget.onCancel(task.id),
      onClear: () => widget.onClear(task.id),
      onClearWithFile: (deleteFile) =>
          widget.onClearWithFile(task.id, deleteFile),
      isInBatch: false,
      batchTasks: shouldShowBatchSummary ? widget.tasks : null,
      showBatchSummary: shouldShowBatchSummary,
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _showBatchContextMenu(Offset? position) {
    final options = [
      OptionItem(
          label: _loc.delete,
          icon: Icons.delete_outline,
          onTap: () {
            _clearBatch();
          }),
      OptionItem(
          label: _loc.deleteWithFile,
          icon: Icons.delete_forever,
          onTap: () {
            _clearBatchWithFiles();
          }),
    ];
    GenericContextMenu.show(
        context: context,
        actions: options,
        position: position,
        desktopDialogWidth: 240);
  }

  void _clearBatch() {
    GenericDialogUtils.showSimpleGenericClearDialog(
      context: context,
      title: _loc.clearTransferBatch,
      description: _loc.clearTransferBatchDesc,
      onConfirm: () {
        widget.onClearBatch?.call(widget.batchId);
      },
    );
  }

  void _clearBatchWithFiles() {
    GenericDialogUtils.showSimpleGenericClearDialog(
      context: context,
      title: _loc.clearTransferBatchWithFiles,
      description: _loc.clearTransferBatchWithFilesDesc,
      onConfirm: () {
        widget.onClearBatchWithFiles?.call(widget.batchId);
      },
    );
  }
}
