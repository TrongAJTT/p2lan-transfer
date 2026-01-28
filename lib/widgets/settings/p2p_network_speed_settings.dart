import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/settings_models.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:p2lan/services/p2p_services/p2p_service_manager.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/widgets/generic/option_slider.dart';

class P2PNetworkSpeedSettings extends StatefulWidget {
  const P2PNetworkSpeedSettings({super.key});

  @override
  State<P2PNetworkSpeedSettings> createState() =>
      _P2PNetworkSpeedSettingsState();
}

class _P2PNetworkSpeedSettingsState extends State<P2PNetworkSpeedSettings> {
  P2PNetworkSettingsData? _settings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ExtensibleSettingsService.getNetworkSettings();
      if (mounted) {
        setState(() {
          _settings = settings;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _settings = const P2PNetworkSettingsData();
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      await ExtensibleSettingsService.updateNetworkSettings(_settings!);

      // Refresh transfer service settings để áp dụng ngay lập tức
      try {
        final transferService = P2PServiceManager.instance.transferService;
        await transferService.reloadTransferSettings();
        logInfo(
            'Refreshed P2P transfer service settings after network settings change');
      } catch (e) {
        logError('Failed to refresh transfer service settings: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_settings == null) {
      return Center(child: Text(loc.failedToLoadSettings('null')));
    }

    return SingleChildScrollView(
      // padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transfer Protocol
          _buildSectionHeader(loc.transferProtocol, Icons.alt_route),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(loc.protocolTcpReliable),
                  subtitle: Text(loc.protocolTcpDescription),
                  value: 'TCP',
                  groupValue: _settings!.sendProtocol,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _settings = _settings!.copyWith(sendProtocol: value);
                      });
                      _saveSettings();
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text(loc.protocolUdpFast),
                  subtitle: Text(loc.udpDescription),
                  value: 'UDP',
                  groupValue: _settings!.sendProtocol,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _settings = _settings!.copyWith(sendProtocol: value);
                      });
                      _saveSettings();
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Performance Tuning
          _buildSectionHeader(loc.performanceTuning, Icons.speed),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                OptionSlider<int>(
                  icon: Icons.sync,
                  label: loc.concurrentTransfers,
                  subtitle: loc.concurrentTransfersDescription,
                  options: _getConcurrentTasksOptions(),
                  currentValue: _settings!.maxConcurrentTasks,
                  onChanged: (value) {
                    setState(() {
                      _settings =
                          _settings!.copyWith(maxConcurrentTasks: value);
                    });
                    _saveSettings();
                  },
                  layout: OptionSliderLayout.none,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                OptionSlider<int>(
                  icon: Icons.layers,
                  label: loc.transferChunkSize,
                  subtitle: loc.transferChunkSizeDescription,
                  options: _getChunkSizeOptions(),
                  currentValue: _settings!.maxChunkSize,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings!.copyWith(maxChunkSize: value);
                    });
                    _saveSettings();
                  },
                  layout: OptionSliderLayout.none,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Current Configuration
          _buildSectionHeader(loc.currentConfiguration, Icons.info),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildConfigRow(loc.protocol, _settings!.sendProtocol),
                  _buildConfigRow(
                      loc.concurrentTasks, _getConcurrentTasksDisplayText()),
                  _buildConfigRow(
                      loc.chunkSize, '${_settings!.maxChunkSize} KB'),
                  _buildConfigRow(loc.estimatedSpeed, _getEstimatedSpeed()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  List<SliderOption<int>> _getConcurrentTasksOptions() {
    return const [
      SliderOption(value: 1, label: '1'),
      SliderOption(value: 2, label: '2'),
      SliderOption(value: 3, label: '3 (Default)'),
      SliderOption(value: 4, label: '4'),
      SliderOption(value: 5, label: '5'),
      SliderOption(value: 6, label: '6'),
      SliderOption(value: 8, label: '8'),
      SliderOption(value: 10, label: '10'),
      SliderOption(value: 99, label: 'Unlimited'),
    ];
  }

  List<SliderOption<int>> _getChunkSizeOptions() {
    return const [
      SliderOption(value: 64, label: '64 KB'),
      SliderOption(value: 128, label: '128 KB'),
      SliderOption(value: 256, label: '256 KB'),
      SliderOption(value: 512, label: '512 KB'),
      SliderOption(value: 1024, label: '1 MB'),
      SliderOption(value: 2048, label: '2 MB (Default)'),
      SliderOption(value: 4096, label: '4 MB'),
      SliderOption(value: 8192, label: '8 MB'),
      SliderOption(value: 16384, label: '16 MB'),
    ];
  }

  String _getConcurrentTasksDisplayText() {
    if (_settings!.maxConcurrentTasks >= 99) {
      return 'Unlimited';
    }
    return _settings!.maxConcurrentTasks.toString();
  }

  String _getEstimatedSpeed() {
    // Simple estimation based on settings
    final baseSpeed = _settings!.sendProtocol == 'UDP' ? 50 : 35; // MB/s
    final chunkMultiplier =
        _settings!.maxChunkSize / 2048.0; // Relative to 2MB default
    final concurrencyMultiplier = _settings!.maxConcurrentTasks > 1
        ? (1 + (_settings!.maxConcurrentTasks - 1) * 0.3)
        : 1.0;

    final estimatedSpeed = baseSpeed * chunkMultiplier * concurrencyMultiplier;
    return '~${estimatedSpeed.round()} MB/s';
  }
}
