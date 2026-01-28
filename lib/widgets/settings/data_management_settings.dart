import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/widgets/generic/option_slider.dart';
import 'package:p2lan/services/cache_service.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:p2lan/services/p2p_services/p2p_service_manager.dart';
import 'package:p2lan/screens/log_viewer_screen.dart';

/// Data Management Settings Module
/// Handles cache management and log settings
class DataManagementSettings extends StatefulWidget {
  final bool isEmbedded;
  final int initialLogRetentionDays;
  final Function(int)? onLogRetentionChanged;

  const DataManagementSettings({
    super.key,
    this.isEmbedded = false,
    required this.initialLogRetentionDays,
    this.onLogRetentionChanged,
  });

  @override
  State<DataManagementSettings> createState() => _DataManagementSettingsState();
}

class _DataManagementSettingsState extends State<DataManagementSettings> {
  String _cacheInfo = '';
  late int _logRetentionDays;
  String _logInfo = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _logRetentionDays = widget.initialLogRetentionDays;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) {
      _loadCacheInfo();
      _loadLogInfo();
    }
  }

  Future<void> _loadCacheInfo() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    if (mounted) {
      setState(() {
        _cacheInfo = l10n.calculating;
      });
    }

    try {
      final totalCacheSize = await CacheService.getTotalCacheSize();
      final totalLogSize = await CacheService.getTotalLogSize();

      if (mounted) {
        setState(() {
          final cacheFormated = CacheService.formatCacheSize(totalCacheSize);
          final logFormated = CacheService.formatCacheSize(totalLogSize);
          _cacheInfo = l10n.cacheWithLogSize(cacheFormated, logFormated);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cacheInfo = l10n.unknown;
          _loading = false;
        });
      }
    }
  }

  Future<void> _clearCache() async {
    final l10n = AppLocalizations.of(context);

    // Show confirmation dialog for clearing cache AND P2P data
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.theseWillBeCleared}:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ${l10n.pairingRequests}',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text('• ${l10n.transferReRequests}',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text('• ${l10n.transferTasks}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.clearAll),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(l10n.calculating)),
            ],
          ),
        ),
      );

      try {
        // Clear cache first
        await CacheService.clearAllCache();

        // Clear P2P data (pairing requests, transfer requests, transfer tasks)
        final p2pManager = P2PServiceManager.instance;
        await p2pManager.clearPairingRequests();

        // Clear transfer requests and tasks
        await p2pManager.clearAllTransferData();

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cache and P2P data cleared successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }

      // Refresh cache info after clearing
      await _loadCacheInfo();
    }
  }

  Future<void> _loadLogInfo() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    if (mounted) {
      setState(() {
        _logInfo = l10n.calculating;
      });
    }

    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 500));

    // This would load actual log information
    // For now, just set some placeholder data
    if (mounted) {
      setState(() {
        _logInfo = l10n.logsAvailable;
      });
    }
  }

  Future<void> _updateLogRetention(int days) async {
    setState(() {
      _logRetentionDays = days;
    });

    // Update global settings
    final currentSettings =
        await ExtensibleSettingsService.getDataAndStorageSettings();
    final updatedSettings = currentSettings.copyWith(
      logRetentionDays: days,
    );
    await ExtensibleSettingsService.updateDataAndStorageSettings(
        updatedSettings);

    // Notify parent
    widget.onLogRetentionChanged?.call(days);
  }

  Future<void> _forceCleanupLogs() async {
    final l10n = AppLocalizations.of(context);

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(l10n.deletingOldLogs)),
            ],
          ),
        ),
      );

      // Force cleanup
      final deletedCount = await AppLogger.instance.forceCleanupNow();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Pre-compute message
      final message = deletedCount > 0
          ? l10n.deletedOldLogFiles(deletedCount)
          : l10n.noOldLogFilesToDelete;

      // Show result
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeletingLogs(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showLogViewer() async {
    final screenWidth = MediaQuery.of(context).size.width;

    if (widget.isEmbedded && screenWidth >= 900) {
      // If embedded in desktop view, show as dialog
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: const LogViewerScreen(isEmbedded: true),
          ),
        ),
      );
    } else {
      // Mobile or standalone - navigate to full screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LogViewerScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isTwoColumnLayout = MediaQuery.of(context).size.width > 1000;

    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return isTwoColumnLayout
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildCacheManagement(loc)),
              const SizedBox(width: 32),
              Expanded(child: _buildLogSection(loc)),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCacheManagement(loc),
              const SizedBox(height: 24),
              _buildLogSection(loc),
            ],
          );
  }

  Widget _buildCacheManagement(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.dataAndStorage,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          _cacheInfo,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Expanded(
            //   child: OutlinedButton.icon(
            //     onPressed: _showCacheDetails,
            //     icon: const Icon(Icons.info_outline),
            //     label: Text(loc.viewCacheDetails),
            //     style: OutlinedButton.styleFrom(
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _clearCache,
                icon: const Icon(Icons.delete_forever),
                label: Text(loc.clearCache),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildLogSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Log Application title with icon
        Text(
          loc.logApplication,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        _buildLogContent(loc),
      ],
    );
  }

  Widget _buildLogContent(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Log info
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              loc.statusInfo(_logInfo),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildLogRetentionSettings(loc),
        _buildLogManagementButtons(loc),
      ],
    );
  }

  Widget _buildLogRetentionSettings(AppLocalizations loc) {
    // Map retention days to slider index
    final List<SliderOption<int>> logOptions = [
      SliderOption(value: 5, label: loc.logRetentionDays(5)),
      SliderOption(value: 10, label: loc.logRetentionDays(10)),
      SliderOption(value: 15, label: loc.logRetentionDays(15)),
      SliderOption(value: 20, label: loc.logRetentionDays(20)),
      SliderOption(value: 25, label: loc.logRetentionDays(25)),
      SliderOption(value: 30, label: loc.logRetentionDays(30)),
      SliderOption(value: -1, label: loc.logRetentionForever),
    ];

    return OptionSlider<int>(
      label: loc.logRetention,
      subtitle: loc.logRetentionDescDetail,
      icon: Icons.history,
      currentValue: _logRetentionDays,
      options: logOptions,
      onChanged: _updateLogRetention,
      layout: OptionSliderLayout.none,
    );
  }

  Widget _buildLogManagementButtons(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.visibility_outlined),
            label: Text(loc.viewLogs),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: _showLogViewer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.delete_sweep_outlined),
            label: Text(loc.clearLogs),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: _forceCleanupLogs,
          ),
        ),
      ],
    );
  }
}
