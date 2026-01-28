import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/services/app_logger.dart';

class LogViewerScreen extends StatefulWidget {
  final bool isEmbedded;

  const LogViewerScreen({super.key, this.isEmbedded = false});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  List<String> _logFiles = [];
  String? _selectedFile;
  String _logContent = '';
  bool _loading = false;
  bool _loadingFiles = true;
  final ScrollController _scrollController = ScrollController();

  // Lazy loading state
  bool _isLazyLoading = false;
  List<String> _logChunks = [];
  int _currentChunkIndex = 0;
  Map<String, dynamic>? _fileInfo;
  bool _showingSkeleton = false;

  @override
  void initState() {
    super.initState();
    _loadLogFiles();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadLogFiles() async {
    try {
      setState(() {
        _loadingFiles = true;
      });

      final files = await AppLogger.instance.getLogFileNames();
      setState(() {
        _logFiles = files;
        _loadingFiles = false;

        // Auto-select the most recent log file
        if (files.isNotEmpty) {
          _selectedFile = files.first;
          _loadLogContent();
        }
      });
    } catch (e) {
      setState(() {
        _loadingFiles = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load log files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadLogContent() async {
    if (_selectedFile == null) return;

    try {
      setState(() {
        _loading = true;
        _showingSkeleton = true;
        _fileInfo = null;
      });

      // Get file info first
      final fileInfo = await AppLogger.instance.getLogFileInfo(_selectedFile!);

      setState(() {
        _fileInfo = fileInfo;
      });

      // Check if file requires chunking (>6000 lines) - use lazy loading
      if (fileInfo['requiresChunking'] == true) {
        await _loadLogContentLazy();
      } else {
        await _loadLogContentNormal();
      }

      setState(() {
        _loading = false;
        _showingSkeleton = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _showingSkeleton = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load log content: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadLogContentNormal() async {
    final content = await AppLogger.instance.readLogContent(_selectedFile!);
    setState(() {
      _logContent = content;
      _isLazyLoading = false;
      _logChunks.clear();
      _currentChunkIndex = 0;
    });
  }

  Future<void> _loadLogContentLazy() async {
    final chunks =
        await AppLogger.instance.readLogContentInChunks(_selectedFile!);
    setState(() {
      _logChunks = chunks;
      _currentChunkIndex = 0;
      _isLazyLoading = true;
      _logContent = chunks.isNotEmpty ? chunks[0] : '';
    });
  }

  void _loadNextChunk() {
    if (_isLazyLoading && _currentChunkIndex < _logChunks.length - 1) {
      setState(() {
        _loading = true;
      });

      // Simulate loading delay for better UX
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _currentChunkIndex++;
            _logContent =
                _logChunks[_currentChunkIndex]; // Load only current chunk
            _loading = false;
          });
          _scrollToTop();
        }
      });
    }
  }

  void _loadPreviousChunk() {
    if (_isLazyLoading && _currentChunkIndex > 0) {
      setState(() {
        _loading = true;
      });

      // Simulate loading delay for better UX
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _currentChunkIndex--;
            _logContent =
                _logChunks[_currentChunkIndex]; // Load only current chunk
            _loading = false;
          });
          _scrollToTop();
        }
      });
    }
  }

  void _loadAllChunks() {
    if (_isLazyLoading) {
      setState(() {
        _loading = true;
      });

      // Loading all chunks takes longer
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _logContent = _logChunks.join('\n');
            _currentChunkIndex = _logChunks.length - 1;
            _isLazyLoading = false; // Switch to normal mode after loading all
            _loading = false;
          });
        }
      });
    }
  }

  void _loadFirstChunk() {
    if (_isLazyLoading && _currentChunkIndex > 0) {
      setState(() {
        _loading = true;
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _currentChunkIndex = 0;
            _logContent = _logChunks[0];
            _loading = false;
          });
          _scrollToTop();
        }
      });
    }
  }

  void _loadLastChunk() {
    if (_isLazyLoading && _currentChunkIndex < _logChunks.length - 1) {
      setState(() {
        _loading = true;
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _currentChunkIndex = _logChunks.length - 1;
            _logContent = _logChunks[_currentChunkIndex];
            _loading = false;
          });
          _scrollToTop();
        }
      });
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _logContent));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log content copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _clearLogs() async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllCache), // Reuse existing localization
        content: const Text(
            'Are you sure you want to clear all log files? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear Logs'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AppLogger.instance.clearLogs();
        await _loadLogFiles();
        setState(() {
          _selectedFile = null;
          _logContent = '';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All log files cleared'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear logs: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatFileName(String fileName) {
    // Extract date from filename like "APPNAME_2024-12-10.log"
    final parts = fileName.replaceAll('.log', '').split('_');
    if (parts.length >= 4) {
      final datePart = parts.sublist(3).join('-');
      return 'Log $datePart';
    }
    return fileName;
  }

  Widget _buildChunkNavigationControls(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 600;

    return Row(
      children: [
        Text(
          'Part ${_currentChunkIndex + 1} of ${_logChunks.length}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        if (isDesktop) ...[
          // Desktop: Show all navigation buttons
          IconButton(
            onPressed: _currentChunkIndex > 0 ? _loadFirstChunk : null,
            icon: const Icon(Icons.first_page),
            iconSize: 20,
            tooltip: l10n.firstPart,
          ),
          IconButton(
            onPressed: _currentChunkIndex > 0 ? _loadPreviousChunk : null,
            icon: const Icon(Icons.chevron_left),
            iconSize: 20,
            tooltip: l10n.previousChunk,
          ),
          IconButton(
            onPressed: _currentChunkIndex < _logChunks.length - 1
                ? _loadNextChunk
                : null,
            icon: const Icon(Icons.chevron_right),
            iconSize: 20,
            tooltip: l10n.nextChunk,
          ),
          IconButton(
            onPressed: _currentChunkIndex < _logChunks.length - 1
                ? _loadLastChunk
                : null,
            icon: const Icon(Icons.last_page),
            iconSize: 20,
            tooltip: l10n.lastPart,
          ),
        ] else ...[
          // Mobile: Only show prev/next, others in context menu
          IconButton(
            onPressed: _currentChunkIndex > 0 ? _loadPreviousChunk : null,
            icon: const Icon(Icons.chevron_left),
            iconSize: 20,
            tooltip: l10n.previousChunk,
          ),
          IconButton(
            onPressed: _currentChunkIndex < _logChunks.length - 1
                ? _loadNextChunk
                : null,
            icon: const Icon(Icons.chevron_right),
            iconSize: 20,
            tooltip: l10n.nextChunk,
          ),
        ],
      ],
    );
  }

  Widget _buildSkeletonLoading() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loading indicator
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  _fileInfo != null && _fileInfo!['requiresChunking'] == true
                      ? l10n.loadingLargeFile
                      : l10n.loadingLogContent,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Skeleton lines
            for (int i = 0; i < 10; i++) ...[
              Container(
                width: double.infinity,
                height: 14,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],

            // Animated shimmer effect
            if (_fileInfo != null && _fileInfo!['requiresChunking'] == true)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.largeFileDetected,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (widget.isEmbedded) {
      return _buildContent(l10n);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Logs'),
        // Remove action buttons to make space for log file dropdown
      ),
      body: _buildContent(l10n),
      floatingActionButton: _logFiles.isNotEmpty
          ? isMobile
              ? _buildMobileActionButtons()
              : _buildActionMenu()
          : null,
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    return Column(
      children: [
        // File selector
        if (!_loadingFiles && _logFiles.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 20),
                    const SizedBox(width: 12),
                    const Text('Log File:'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedFile,
                        isExpanded: true,
                        items: _logFiles.map((file) {
                          return DropdownMenuItem<String>(
                            value: file,
                            child: Text(_formatFileName(file)),
                          );
                        }).toList(),
                        onChanged: (newFile) {
                          setState(() {
                            _selectedFile = newFile;
                          });
                          _loadLogContent();
                        },
                      ),
                    ),
                  ],
                ),

                // File info
                if (_fileInfo != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Size: ${_fileInfo!['sizeFormatted']} • Lines: ${_fileInfo!['lineCount']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      if (_fileInfo!['requiresChunking'] == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_fileInfo!['chunkCount']} Parts',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.blue.shade700,
                                      fontSize: 10,
                                    ),
                          ),
                        ),
                      ],
                      if (_fileInfo!['isLarge'] == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.largeFile,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.orange.shade700,
                                      fontSize: 10,
                                    ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                // Lazy loading controls
                if (_isLazyLoading) ...[
                  const SizedBox(height: 8),
                  _buildChunkNavigationControls(l10n),
                ],
              ],
            ),
          ),

        // Log content
        Expanded(
          child: _loadingFiles
              ? const Center(child: CircularProgressIndicator())
              : _logFiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No log files available',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Log files will appear here as the app generates them',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : _loading || _showingSkeleton
                      ? _buildSkeletonLoading()
                      : Container(
                          padding: const EdgeInsets.all(16),
                          child: _logContent.isEmpty
                              ? Center(
                                  child: Text(
                                    'Selected log file is empty',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: SelectableText(
                                      _logContent,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
        ),
      ],
    );
  }

  Widget _buildActionMenu() {
    final l10n = AppLocalizations.of(context);
    return FloatingActionButton(
      onPressed: () => _showActionBottomSheet(),
      tooltip: l10n.logActions,
      child: const Icon(Icons.more_vert),
    );
  }

  Widget _buildMobileActionButtons() {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scroll to top button
        FloatingActionButton.small(
          heroTag: "scrollTop",
          onPressed: _scrollToTop,
          tooltip: l10n.scrollToTop,
          child: const Icon(Icons.keyboard_arrow_up),
        ),
        const SizedBox(height: 8),
        // Scroll to bottom button
        FloatingActionButton.small(
          heroTag: "scrollBottom",
          onPressed: _scrollToBottom,
          tooltip: l10n.scrollToBottom,
          child: const Icon(Icons.keyboard_arrow_down),
        ),
        const SizedBox(height: 8),
        // Actions menu button
        FloatingActionButton(
          heroTag: "actions",
          onPressed: () => _showActionBottomSheet(),
          tooltip: l10n.logActions,
          child: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  void _showActionBottomSheet() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chunk navigation options (mobile only, when chunking is active)
            if (_isLazyLoading && _logChunks.length > 1) ...[
              ListTile(
                leading: const Icon(Icons.first_page),
                title: Text(l10n.firstPart),
                onTap: () {
                  Navigator.pop(context);
                  _loadFirstChunk();
                },
                enabled: _currentChunkIndex > 0,
              ),
              ListTile(
                leading: const Icon(Icons.last_page),
                title: Text(l10n.lastPart),
                onTap: () {
                  Navigator.pop(context);
                  _loadLastChunk();
                },
                enabled: _currentChunkIndex < _logChunks.length - 1,
              ),
              ListTile(
                leading: const Icon(Icons.expand_more),
                title: Text(l10n.loadAll),
                onTap: () {
                  Navigator.pop(context);
                  _loadAllChunks();
                },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy to Clipboard'),
              onTap: () {
                Navigator.pop(context);
                if (_logContent.isNotEmpty) _copyToClipboard();
              },
              enabled: _logContent.isNotEmpty,
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh'),
              onTap: () {
                Navigator.pop(context);
                _loadLogFiles();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Clear All Logs'),
              onTap: () {
                Navigator.pop(context);
                _clearLogs();
              },
            ),
          ],
        ),
      ),
    );
  }
}
