import 'dart:async';
import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/app_logger.dart';

class FileTransferRequestDialog extends StatefulWidget {
  final FileTransferRequest request;
  final Function(bool accept, String? rejectMessage) onResponse;
  final int? initialCountdown;

  const FileTransferRequestDialog({
    super.key,
    required this.request,
    required this.onResponse,
    this.initialCountdown,
  });

  @override
  State<FileTransferRequestDialog> createState() =>
      _FileTransferRequestDialogState();
}

class _FileTransferRequestDialogState extends State<FileTransferRequestDialog> {
  late int _countdown;
  Timer? _timer;
  bool _responded = false;
  late DateTime _dialogOpenTime;

  @override
  void initState() {
    super.initState();
    _dialogOpenTime = DateTime.now();
    // Calculate actual remaining time based on request time
    _countdown = _calculateRemainingTime();
    _startCountdown();
  }

  /// Calculate remaining time using receivedTime (local time) for accuracy
  int _calculateRemainingTime() {
    if (widget.initialCountdown != null) {
      logInfo(
          'FileTransferDialog: Using provided countdown: ${widget.initialCountdown}s');
      return widget.initialCountdown!;
    }

    final now = DateTime.now();

    // Prefer receivedTime (local time when request was received) over requestTime (sender's time)
    if (widget.request.receivedTime != null) {
      final receivedTime = widget.request.receivedTime!;
      final elapsedSinceReceived = now.difference(receivedTime);

      logInfo(
          'FileTransferDialog: Request received time (local): $receivedTime');
      logInfo('FileTransferDialog: Current time: $now');
      logInfo(
          'FileTransferDialog: Elapsed since received: ${elapsedSinceReceived.inSeconds}s');

      final remainingSeconds = 60 - elapsedSinceReceived.inSeconds;

      if (remainingSeconds <= 0) {
        logInfo('FileTransferDialog: Request expired, using minimum 5s');
        return 5;
      }

      logInfo(
          'FileTransferDialog: Using received time - remaining: ${remainingSeconds}s');
      return remainingSeconds.clamp(1, 60);
    } else {
      // Fallback: use dialog open time if receivedTime is not available
      logInfo(
          'FileTransferDialog: No receivedTime available, using dialog open time');
      final elapsedSinceDialog = now.difference(_dialogOpenTime);
      final remainingFromDialog = 60 - elapsedSinceDialog.inSeconds;
      logInfo(
          'FileTransferDialog: Elapsed since dialog: ${elapsedSinceDialog.inSeconds}s, remaining: ${remainingFromDialog}s');

      return remainingFromDialog.clamp(1, 60);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdown--;
        });

        if (_countdown <= 0) {
          _handleTimeout();
        }
      }
    });
  }

  void _handleTimeout() {
    if (!_responded) {
      _responded = true;
      _timer?.cancel();
      Navigator.of(context).pop();
      widget.onResponse(false, 'Request timed out (no response)');
    }
  }

  void _handleAccept() {
    if (!_responded) {
      _responded = true;
      _timer?.cancel();
      Navigator.of(context).pop();
      widget.onResponse(true, null);
    }
  }

  void _handleReject([String? customMessage]) {
    if (!_responded) {
      _responded = true;
      _timer?.cancel();
      Navigator.of(context).pop();
      widget.onResponse(false, customMessage ?? 'Rejected by user');
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isWide = MediaQuery.of(context).size.width > 500;
    final theme = Theme.of(context);
    final deviceName = widget.request.fromUserName;
    final fileCount = widget.request.files.length;
    final totalSize = widget.request.totalSize;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isWide ? 480 : double.infinity,
          minWidth: 320,
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with countdown
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.file_download,
                        color: theme.colorScheme.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.incomingFiles,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _countdown <= 10
                            ? Colors.red
                            : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_countdown}s',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              // Sender info
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.brightness == Brightness.dark
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.8),
                      child: Text(
                        deviceName.isNotEmpty
                            ? deviceName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(deviceName,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Text(l10n.wantsToSendYouFiles(fileCount),
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Files list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.filesToReceive,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.request.files.length,
                        itemBuilder: (context, index) {
                          final file = widget.request.files[index];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(_getFileIcon(file.fileName),
                                color: theme.colorScheme.primary, size: 22),
                            title: Text(file.fileName,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis),
                            trailing: Text(_formatFileSize(file.fileSize),
                                style: theme.textTheme.bodySmall),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Total size info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.totalSize,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(_formatFileSize(totalSize),
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.brightness == Brightness.dark
                              ? theme.colorScheme.error
                              : theme.colorScheme.error.withValues(alpha: 0.8),
                          side: BorderSide(
                              color: theme.brightness == Brightness.dark
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.error
                                      .withValues(alpha: 0.8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(l10n.reject,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.brightness == Brightness.dark
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary
                                  .withValues(alpha: 0.9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation:
                              theme.brightness == Brightness.dark ? 2 : 3,
                        ),
                        child: Text(l10n.accept,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }
}
