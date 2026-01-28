import 'dart:io';
import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/settings_models.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:p2lan/services/file_storage_service.dart';
import 'package:p2lan/services/p2p_services/p2p_service_manager.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/utils/snackbar_utils.dart';
import 'package:p2lan/widgets/generic/option_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class P2PReceiverLocationSettings extends StatefulWidget {
  const P2PReceiverLocationSettings({super.key});

  @override
  State<P2PReceiverLocationSettings> createState() =>
      _P2PReceiverLocationSettingsState();
}

class _P2PReceiverLocationSettingsState
    extends State<P2PReceiverLocationSettings> {
  P2PReceiverSettingsData? _settings;
  late AppLocalizations loc;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ExtensibleSettingsService.getReceiverSettings();
      if (mounted) {
        setState(() {
          _settings = settings;
          _loading = false;
        });
        // Initialize default path if empty
        if (_settings!.downloadPath.isEmpty) {
          _initializeDefaultPath();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _settings = const P2PReceiverSettingsData();
          _loading = false;
        });
        _initializeDefaultPath();
      }
    }
  }

  Future<void> _initializeDefaultPath() async {
    if (_settings != null && _settings!.downloadPath.isEmpty) {
      final defaultPath = await _getDefaultDownloadPath();
      if (mounted) {
        setState(() {
          _settings = _settings!.copyWith(downloadPath: defaultPath);
        });
        _saveSettings();
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      await ExtensibleSettingsService.updateReceiverSettings(_settings!);

      // Refresh transfer service settings để áp dụng ngay lập tức
      try {
        final transferService = P2PServiceManager.instance.transferService;
        await transferService.reloadTransferSettings();
        logInfo(
            'Refreshed P2P transfer service settings after receiver settings change');
      } catch (e) {
        logError('Failed to refresh transfer service settings: $e');
      }
    }
  }

  Future<String> _getDefaultDownloadPath() async {
    return await FileStorageService.instance.getAppDownloadsDirectory();
  }

  Widget _buildInfoCard(String title, String content, IconData icon,
      {Color? color}) {
    return Card(
      color: color ?? Theme.of(context).colorScheme.surfaceContainer,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          // Download Location
          _buildSectionHeader(loc.downloadLocation, Icons.folder),
          const SizedBox(height: 16),

          InkWell(
            onTap: _selectDownloadPath,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.downloadFolder,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _settings!.downloadPath.isEmpty
                              ? loc.selectDownloadFolder
                              : _settings!.downloadPath,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: _settings!.downloadPath.isEmpty
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                        : null,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),

          if (Platform.isAndroid) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              loc.androidStorageAccess,
              loc.androidStorageAccessDescription,
              Icons.security,
            ),
            const SizedBox(height: 8),

            // Only show "Use App Folder" button if current path is not the app folder
            FutureBuilder<String>(
              future: _getDefaultDownloadPath(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final appFolderPath = snapshot.data!;
                  final isCurrentlyAppFolder =
                      _settings!.downloadPath == appFolderPath;

                  if (isCurrentlyAppFolder) {
                    return const SizedBox.shrink(); // Hide button
                  }

                  return Container(
                    // padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          final defaultPath = await _getDefaultDownloadPath();
                          setState(() {
                            _settings =
                                _settings!.copyWith(downloadPath: defaultPath);
                          });
                          _saveSettings();
                        },
                        icon: const Icon(Icons.home, size: 18),
                        label: Text(loc.useAppFolder),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],

          const SizedBox(height: 24),

          // File Organization
          _buildSectionHeader(loc.fileOrganization, Icons.auto_awesome),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(loc.fileOrgNone),
                  subtitle: Text(loc.fileOrgNoneDescription),
                  value: 'none',
                  groupValue: _getFileOrganizationValue(),
                  onChanged: (value) {
                    _setFileOrganizationValue(value);
                    _saveSettings();
                  },
                ),
                RadioListTile<String>(
                  title: Text(loc.fileOrgDate),
                  subtitle: Text(loc.fileOrgDateDescription),
                  value: 'date',
                  groupValue: _getFileOrganizationValue(),
                  onChanged: (value) {
                    _setFileOrganizationValue(value);
                    _saveSettings();
                  },
                ),
                RadioListTile<String>(
                  title: Text(loc.fileOrgSender),
                  subtitle: Text(loc.fileOrgSenderDescription),
                  value: 'sender',
                  groupValue: _getFileOrganizationValue(),
                  onChanged: (value) {
                    _setFileOrganizationValue(value);
                    _saveSettings();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Size Limits
          _buildSectionHeader(loc.sizeLimits, Icons.tune),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                OptionSlider<int>(
                  icon: Icons.file_present,
                  label: loc.maxFileSizePerFile,
                  subtitle: loc.maxFileSizePerFileDescription,
                  options: _getFileSizeOptions(),
                  currentValue: _settings!.maxReceiveFileSize,
                  onChanged: (value) {
                    setState(() {
                      _settings =
                          _settings!.copyWith(maxReceiveFileSize: value);
                    });
                    _saveSettings();
                  },
                  layout: OptionSliderLayout.none,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                OptionSlider<int>(
                  icon: Icons.inventory,
                  label: loc.maxTotalSize,
                  subtitle: loc.maxTotalSizeDescription,
                  options: _getTotalSizeOptions(),
                  currentValue: _settings!.maxTotalReceiveSize,
                  onChanged: (value) {
                    setState(() {
                      _settings =
                          _settings!.copyWith(maxTotalReceiveSize: value);
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

  void _selectDownloadPath() async {
    String? path;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 30) {
          path = await FilePicker.platform.getDirectoryPath(
            dialogTitle: loc.selectDownloadFolder,
          );
        } else {
          if (await Permission.storage.request().isGranted) {
            path = await FilePicker.platform.getDirectoryPath(
              dialogTitle: loc.selectDownloadFolder,
            );
          } else {
            if (mounted) {
              SnackbarUtils.showTyped(
                context,
                loc.storagePermissionRequired,
                SnackBarType.warning,
              );
            }
            return;
          }
        }
      } else {
        path = await FilePicker.platform.getDirectoryPath(
          dialogTitle: loc.selectDownloadFolder,
        );
      }

      if (path != null && mounted) {
        setState(() {
          _settings = _settings!.copyWith(downloadPath: path);
        });
        _saveSettings();
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          'Error selecting folder: $e',
          SnackBarType.error,
        );
      }
    }
  }

  String? _getFileOrganizationValue() {
    if (_settings!.createSenderFolders) {
      return 'sender';
    } else if (_settings!.createDateFolders) {
      return 'date';
    } else {
      return 'none';
    }
  }

  void _setFileOrganizationValue(String? value) {
    setState(() {
      switch (value) {
        case 'sender':
          _settings = _settings!.copyWith(
            createSenderFolders: true,
            createDateFolders: false,
          );
          break;
        case 'date':
          _settings = _settings!.copyWith(
            createSenderFolders: false,
            createDateFolders: true,
          );
          break;
        case 'none':
        default:
          _settings = _settings!.copyWith(
            createSenderFolders: false,
            createDateFolders: false,
          );
          break;
      }
    });
  }

  List<SliderOption<int>> _getFileSizeOptions() {
    return const [
      SliderOption(value: 10 * 1024 * 1024, label: '10 MB'),
      SliderOption(value: 50 * 1024 * 1024, label: '50 MB'),
      SliderOption(value: 100 * 1024 * 1024, label: '100 MB'),
      SliderOption(value: 200 * 1024 * 1024, label: '200 MB'),
      SliderOption(value: 500 * 1024 * 1024, label: '500 MB'),
      SliderOption(value: 1 * 1024 * 1024 * 1024, label: '1 GB'),
      SliderOption(value: 2 * 1024 * 1024 * 1024, label: '2 GB'),
      SliderOption(value: 5 * 1024 * 1024 * 1024, label: '5 GB'),
      SliderOption(value: 10 * 1024 * 1024 * 1024, label: '10 GB'),
      SliderOption(value: -1, label: 'Unlimited'),
    ];
  }

  List<SliderOption<int>> _getTotalSizeOptions() {
    return const [
      SliderOption(value: 100 * 1024 * 1024, label: '100 MB'),
      SliderOption(value: 500 * 1024 * 1024, label: '500 MB'),
      SliderOption(value: 1 * 1024 * 1024 * 1024, label: '1 GB'),
      SliderOption(value: 2 * 1024 * 1024 * 1024, label: '2 GB'),
      SliderOption(value: 5 * 1024 * 1024 * 1024, label: '5 GB'),
      SliderOption(value: 10 * 1024 * 1024 * 1024, label: '10 GB'),
      SliderOption(value: 20 * 1024 * 1024 * 1024, label: '20 GB'),
      SliderOption(value: 50 * 1024 * 1024 * 1024, label: '50 GB'),
      SliderOption(value: 100 * 1024 * 1024 * 1024, label: '100 GB'),
      SliderOption(value: -1, label: 'Unlimited'),
    ];
  }
}
