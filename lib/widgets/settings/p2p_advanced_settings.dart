import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/settings_models.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:p2lan/services/p2p_services/p2p_service_manager.dart';
import 'package:p2lan/services/app_logger.dart';

class P2PAdvancedSettings extends StatefulWidget {
  const P2PAdvancedSettings({super.key});

  @override
  State<P2PAdvancedSettings> createState() => _P2PAdvancedSettingsState();
}

class _P2PAdvancedSettingsState extends State<P2PAdvancedSettings> {
  late AppLocalizations loc;
  P2PAdvancedSettingsData? _settings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ExtensibleSettingsService.getAdvancedSettings();
      if (mounted) {
        setState(() {
          _settings = settings;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _settings = const P2PAdvancedSettingsData();
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      await ExtensibleSettingsService.updateAdvancedSettings(_settings!);

      // Refresh transfer service settings để áp dụng ngay lập tức
      try {
        final transferService = P2PServiceManager.instance.transferService;
        await transferService.reloadTransferSettings();
        logInfo(
            'Refreshed P2P transfer service settings after advanced settings change');
      } catch (e) {
        logError('Failed to refresh transfer service settings: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);

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
          // Security & Encryption
          _buildSectionHeader(loc.securityAndEncryption, Icons.security),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                RadioListTile<EncryptionType>(
                  title: Text(loc.none),
                  subtitle: Text(loc.p2lanOptionEncryptionNoneDesc),
                  value: EncryptionType.none,
                  groupValue: _settings!.encryptionType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _settings = _settings!.copyWith(encryptionType: value);
                      });
                      _saveSettings();
                    }
                  },
                ),
                RadioListTile<EncryptionType>(
                  title: const Text('AES-GCM'),
                  subtitle: Text(loc.p2lanOptionEncryptionAesGcmDesc),
                  value: EncryptionType.aesGcm,
                  groupValue: _settings!.encryptionType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _settings = _settings!.copyWith(encryptionType: value);
                      });
                      _saveSettings();
                    }
                  },
                ),
                RadioListTile<EncryptionType>(
                  title: const Text('ChaCha20-Poly1305'),
                  subtitle: Text(loc.p2lanOptionEncryptionChaCha20Desc),
                  value: EncryptionType.chaCha20,
                  groupValue: _settings!.encryptionType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _settings = _settings!.copyWith(encryptionType: value);
                      });
                      _saveSettings();
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Performance Information
          _buildSectionHeader(loc.performanceInfo, Icons.info),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                      loc.performanceInfoEncrypt, _getEncryptionDisplayText()),
                  _buildInfoRow(
                      loc.performanceInfoSecuLevel, _getSecurityLevel()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Performance Warning Card
          if (_settings!.encryptionType != EncryptionType.none)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer),
                        const SizedBox(width: 8),
                        Text(
                          loc.performanceWarning,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.performanceWarningInfo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          setState(() {
                            _settings = _settings!.copyWith(
                              encryptionType: EncryptionType.none,
                            );
                          });
                          await _saveSettings();
                        },
                        icon: Icon(Icons.security_update_good,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer),
                        label: Text(
                          loc.resetToSafeDefaults,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildInfoRow(String label, String value) {
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

  String _getEncryptionDisplayText() {
    switch (_settings!.encryptionType) {
      case EncryptionType.none:
        return loc.fastest;
      case EncryptionType.aesGcm:
        return loc.strongest;
      case EncryptionType.chaCha20:
        return loc.mobileOptimized;
    }
  }

  String _getSecurityLevel() {
    if (_settings!.encryptionType == EncryptionType.none) {
      return '${loc.none} (${loc.notRecommended})';
    } else {
      return '${loc.high} (${loc.encrypted})';
    }
  }
}
