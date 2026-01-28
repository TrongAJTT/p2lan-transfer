import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/file_storage_service.dart';
import 'package:p2lan/services/network_security_service.dart';
import 'package:p2lan/services/p2p_services/p2p_notification_service.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/utils/snackbar_utils.dart';
import 'package:p2lan/widgets/generic/option_slider.dart';
import 'package:p2lan/widgets/generic/option_list_picker.dart';
import 'package:p2lan/widgets/generic/option_item.dart';
import 'package:p2lan/widgets/generic/permission_info_dialog.dart';
import 'package:p2lan/screens/p2lan_transfer/encryption_settings_section.dart';
import 'package:p2lan/l10n/app_localizations.dart';

class P2LanTransferSettingsLayout extends StatefulWidget {
  final P2PDataTransferSettings? currentSettings;
  final Function(P2PDataTransferSettings) onSettingsChanged;
  final VoidCallback? onCancel;
  final bool showActions;
  final bool isCompact;

  const P2LanTransferSettingsLayout({
    super.key,
    this.currentSettings,
    required this.onSettingsChanged,
    this.onCancel,
    this.showActions = true,
    this.isCompact = false,
  });

  @override
  State<P2LanTransferSettingsLayout> createState() =>
      _P2LanTransferSettingsLayoutState();
}

class _P2LanTransferSettingsLayoutState
    extends State<P2LanTransferSettingsLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late P2PDataTransferSettings _currentSettings;
  bool _hasChanges = false;
  String _customDisplayName = '';
  String _currentDeviceName = '';
  late TextEditingController _displayNameController;

  static final List<SliderOption<int>> _chunkSizeOptions = [
    const SliderOption(value: 64, label: '64 KB'),
    const SliderOption(value: 128, label: '128 KB'),
    const SliderOption(value: 256, label: '256 KB'),
    const SliderOption(value: 512, label: '512 KB'),
    const SliderOption(value: 1024, label: '1 MB (Default)'),
    const SliderOption(value: 2048, label: '2 MB'),
    const SliderOption(value: 4096, label: '4 MB'),
    const SliderOption(value: 8192, label: '8 MB'),
    const SliderOption(value: 16384, label: '16 MB'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _displayNameController = TextEditingController();
    _currentSettings =
        widget.currentSettings?.copyWith() ?? _createDefaultSettings();
    _initializeDefaultPath();
    _getDeviceName();
  }

  Future<void> _getDeviceName() async {
    try {
      final deviceName = await NetworkSecurityService.getDeviceName();
      if (mounted) {
        setState(() {
          _currentDeviceName = deviceName;
          // Use saved custom display name if available, otherwise use device name
          _customDisplayName = _currentSettings.customDisplayName ?? deviceName;
          _displayNameController.text =
              _customDisplayName; // Set controller text
        });
      }
    } catch (e) {
      // Fallback to default name
      if (mounted) {
        setState(() {
          _currentDeviceName = 'My Device';
          _customDisplayName =
              _currentSettings.customDisplayName ?? 'My Device';
          _displayNameController.text =
              _customDisplayName; // Set controller text
        });
      }
    }
  }

  Future<void> _initializeDefaultPath() async {
    if (_currentSettings.downloadPath.isEmpty) {
      final defaultPath = await _getDefaultDownloadPath();
      if (mounted) {
        setState(() {
          _currentSettings.downloadPath = defaultPath;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<String> _getDefaultDownloadPath() async {
    return await FileStorageService.instance.getAppDownloadsDirectory();
  }

  P2PDataTransferSettings _createDefaultSettings() {
    return P2PDataTransferSettings(
      downloadPath: '',
      createDateFolders: true,
      maxReceiveFileSize: 100 * 1024 * 1024, // 100MB
      maxTotalReceiveSize: 5 * 1024 * 1024 * 1024, // 5GB
      maxConcurrentTasks: 3,
      sendProtocol: 'TCP',
      maxChunkSize: 1024, // 1MB
      uiRefreshRateSeconds: 0, // Default to immediate updates
      enableNotifications: false, // Default to disable notifications
      createSenderFolders: false, // Default to date folders
      encryptionType: EncryptionType.none, // Default to no encryption
    );
  }

  String? _getFileOrganizationValue() {
    if (_currentSettings.createSenderFolders) {
      return 'sender';
    } else if (_currentSettings.createDateFolders) {
      return 'date';
    } else {
      return 'none';
    }
  }

  String _getFileOrganizationDisplayText(AppLocalizations l10n) {
    if (_currentSettings.createSenderFolders) {
      return l10n.fileOrgSender;
    } else if (_currentSettings.createDateFolders) {
      return l10n.fileOrgDate;
    } else {
      return l10n.fileOrgNone;
    }
  }

  void _setFileOrganizationValue(String? value) {
    setState(() {
      switch (value) {
        case 'sender':
          _currentSettings.createSenderFolders = true;
          _currentSettings.createDateFolders = false;
          break;
        case 'date':
          _currentSettings.createSenderFolders = false;
          _currentSettings.createDateFolders = true;
          break;
        case 'none':
        default:
          _currentSettings.createSenderFolders = false;
          _currentSettings.createDateFolders = false;
          break;
      }
    });
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _saveSettings() {
    // Include display name in settings
    final updatedSettings = _currentSettings.copyWith(
      customDisplayName:
          _customDisplayName.isNotEmpty ? _customDisplayName : null,
    );

    widget.onSettingsChanged(updatedSettings);
    setState(() {
      _hasChanges = false;
    });
  }

  void _resetToDefaults() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetToDefaults),
        content: Text(l10n.resetToDefaultsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentSettings = _createDefaultSettings();
                _hasChanges = true;
              });
              _initializeDefaultPath();
            },
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Header with tabs
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                  text: l10n.settingsTabGeneric,
                  icon: const Icon(Icons.person, size: 18)),
              Tab(
                  text: l10n.settingsTabStorage,
                  icon: const Icon(Icons.storage, size: 18)),
              Tab(
                  text: l10n.settingsTabNetwork,
                  icon: const Icon(Icons.network_check, size: 18)),
              Tab(
                  text: l10n.security,
                  icon: const Icon(Icons.security, size: 18)),
            ],
            labelStyle: TextStyle(fontSize: widget.isCompact ? 12 : 14),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),

        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGenericTab(),
              _buildStorageTab(),
              _buildNetworkTab(),
              _buildSecurityTab(),
            ],
          ),
        ),

        // Actions
        if (widget.showActions) ...[
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Reset button - always show on left
                TextButton.icon(
                  onPressed: _resetToDefaults,
                  icon: const Icon(Icons.restore, size: 18),
                  label: Text(l10n.reset),
                ),
                const Spacer(),
                if (widget.onCancel != null) ...[
                  TextButton(
                    onPressed: widget.onCancel,
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                ],
                FilledButton.icon(
                  onPressed: _hasChanges ? _saveSettings : null,
                  icon: const Icon(Icons.save, size: 18),
                  label: Text(l10n.save),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenericTab() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isCompact ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(l10n.deviceName, Icons.person),
          const SizedBox(height: 16),
          _buildDisplayNameField(l10n),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.userPreferences, Icons.settings),
          const SizedBox(height: 16),

          // Only show notifications on supported platforms
          if (!Platform.isWindows) ...[
            Card(
              child: SwitchListTile.adaptive(
                title: Text(l10n.notifications),
                subtitle: Text(l10n.enableNotificationsDescription),
                value: _currentSettings.enableNotifications,
                onChanged: _handleNotificationToggle,
                secondary: const Icon(Icons.notifications),
              ),
            ),
          ] else ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_off),
                title: Text(l10n.notifications),
                subtitle: Text(l10n.notSupportedOnWindows),
                enabled: false,
              ),
            ),
          ],

          const SizedBox(height: 16),

          const SizedBox(height: 24),

          // User Interface Performance
          _buildSectionHeader(l10n.uiPerformance, Icons.tune),
          const SizedBox(height: 16),

          Card(
            child: OptionSlider<int>(
              icon: Icons.schedule,
              label: l10n.uiRefreshRate,
              subtitle: l10n.uiRefreshRateDescription,
              options: _uiRefreshRateOptions(l10n),
              currentValue: _currentSettings.uiRefreshRateSeconds,
              onChanged: (value) {
                setState(() {
                  _currentSettings.uiRefreshRateSeconds = value;
                });
                _markChanged();
              },
            ),
          ),

          const SizedBox(height: 24),

          // Current Configuration
          _buildSectionHeader(l10n.currentConfiguration, Icons.settings),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildConfigRow(
                      l10n.displayName,
                      _customDisplayName.isNotEmpty
                          ? _customDisplayName
                          : _currentDeviceName),
                  _buildConfigRow(
                      l10n.protocol, _getFileProtocolDisplayText(l10n)),
                  _buildConfigRow(l10n.maxFileSize,
                      _formatBytes(_currentSettings.maxReceiveFileSize)),
                  _buildConfigRow(l10n.maxTotalSize,
                      _formatBytes(_currentSettings.maxTotalReceiveSize)),
                  _buildConfigRow(l10n.concurrentTasks,
                      _getConcurrentTasksDisplayText(l10n)),
                  _buildConfigRow(
                      l10n.chunkSize, '${_currentSettings.maxChunkSize} KB'),
                  _buildConfigRow(l10n.fileOrganization,
                      _getFileOrganizationDisplayText(l10n)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Storage Information
          _buildSectionHeader(l10n.storageInfo, Icons.info),
          const SizedBox(height: 16),
          if (_currentSettings.downloadPath.isNotEmpty) ...[
            FutureBuilder<Map<String, String>>(
              future: _getStorageInfo(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final info = snapshot.data!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildConfigRowWithWrap(
                              l10n.downloadPath, _currentSettings.downloadPath),
                          if (info['totalSpace'] != null)
                            _buildConfigRow(
                                l10n.totalSpace, info['totalSpace']!),
                          if (info['freeSpace'] != null)
                            _buildConfigRow(l10n.freeSpace, info['freeSpace']!),
                          if (info['usedSpace'] != null)
                            _buildConfigRow(l10n.usedSpace, info['usedSpace']!),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
              },
            ),
          ] else ...[
            _buildInfoCard(
              l10n.noDownloadPathSet,
              l10n.noDownloadPathSetDescription,
              Icons.warning,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isCompact ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EncryptionSettingsSection(
            currentEncryptionType: _currentSettings.encryptionType,
            onEncryptionTypeChanged: (encryptionType) {
              setState(() {
                _currentSettings.encryptionType = encryptionType;
              });
              _markChanged();
            },
            isCompact: widget.isCompact,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageTab() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isCompact ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(l10n.downloadLocation, Icons.folder),
          const SizedBox(height: 16),

          // Download path selector
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
                          l10n.downloadFolder,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentSettings.downloadPath.isEmpty
                              ? l10n.selectDownloadFolder
                              : _currentSettings.downloadPath,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: _currentSettings.downloadPath.isEmpty
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
              l10n.androidStorageAccess,
              l10n.androidStorageAccessDescription,
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
                      _currentSettings.downloadPath == appFolderPath;

                  if (isCurrentlyAppFolder) {
                    return const SizedBox.shrink(); // Hide button
                  }

                  return Container(
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
                    child: TextButton.icon(
                      onPressed: () async {
                        final defaultPath = await _getDefaultDownloadPath();
                        setState(() {
                          _currentSettings.downloadPath = defaultPath;
                        });
                        _markChanged();
                      },
                      icon: const Icon(Icons.home, size: 18),
                      label: Text(l10n.useAppFolder),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],

          const SizedBox(height: 24),

          // Organization settings
          _buildSectionHeader(l10n.fileOrganization, Icons.auto_awesome),
          const SizedBox(height: 16),

          OptionListPicker<String>(
            options: _getFileOrganizationOptions(l10n),
            selectedValue: _getFileOrganizationValue(),
            onChanged: (value) {
              _setFileOrganizationValue(value);
              _markChanged();
            },
            allowMultiple: false,
            allowNull: true,
            showSelectionControl: true,
            isCompact: widget.isCompact,
          ),

          const SizedBox(height: 24),

          // Size limits
          _buildSectionHeader(l10n.sizeLimits, Icons.tune),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                OptionSlider<int>(
                  icon: Icons.file_present,
                  label: l10n.maxFileSizePerFile,
                  subtitle: l10n.maxFileSizePerFileDescription,
                  options: _getFileSizeOptions(l10n),
                  currentValue: _currentSettings.maxReceiveFileSize,
                  onChanged: (value) {
                    setState(() {
                      _currentSettings.maxReceiveFileSize = value;
                    });
                    _markChanged();
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                OptionSlider<int>(
                  icon: Icons.inventory,
                  label: l10n.maxTotalSize,
                  subtitle: l10n.maxTotalSizeDescription,
                  options: _getTotalSizeOptions(l10n),
                  currentValue: _currentSettings.maxTotalReceiveSize,
                  onChanged: (value) {
                    setState(() {
                      _currentSettings.maxTotalReceiveSize = value;
                    });
                    _markChanged();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkTab() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isCompact ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(l10n.transferProtocol, Icons.alt_route),
          const SizedBox(height: 16),

          // Protocol selection using OptionListPicker
          OptionListPicker<String>(
            options: _getProtocolOptions(l10n),
            selectedValue: _currentSettings.sendProtocol,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _currentSettings.sendProtocol = value;
                });
                _markChanged();
              }
            },
            allowMultiple: false,
            allowNull: false,
            showSelectionControl: true,
            isCompact: widget.isCompact,
          ),

          const SizedBox(height: 24),

          _buildSectionHeader(l10n.performanceTuning, Icons.speed),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                OptionSlider<int>(
                  icon: Icons.sync,
                  label: l10n.concurrentTransfers,
                  subtitle: l10n.concurrentTransfersSubtitle,
                  options: _getConcurrentTasksOptions(l10n),
                  currentValue: _currentSettings.maxConcurrentTasks,
                  onChanged: (value) {
                    setState(() {
                      _currentSettings.maxConcurrentTasks = value;
                    });
                    _markChanged();
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                OptionSlider<int>(
                  icon: Icons.layers,
                  label: l10n.transferChunkSize,
                  subtitle: l10n.transferChunkSizeSubtitle,
                  options: _chunkSizeOptions,
                  currentValue: _currentSettings.maxChunkSize,
                  onChanged: (value) {
                    setState(() {
                      _currentSettings.maxChunkSize = value;
                    });
                    _markChanged();
                  },
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

  Widget _buildConfigRowWithWrap(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
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
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes, [int decimals = 2]) {
    final l10n = AppLocalizations.of(context);
    if (bytes <= 0) return '0 B';
    if (bytes < 0) return l10n.unlimited;
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  Future<Map<String, String>> _getStorageInfo() async {
    try {
      final directory = Directory(_currentSettings.downloadPath);
      if (await directory.exists()) {
        // final stat = await directory.stat();
        // Note: Getting actual disk space requires platform-specific implementation
        return {
          'path': _currentSettings.downloadPath,
          'exists': 'Yes',
          'accessible': 'Yes',
        };
      } else {
        return {
          'path': _currentSettings.downloadPath,
          'exists': 'No',
          'accessible': 'No',
        };
      }
    } catch (e) {
      return {
        'path': _currentSettings.downloadPath,
        'error': e.toString(),
      };
    }
  }

  void _selectDownloadPath() async {
    String? path;
    final l10n = AppLocalizations.of(context);

    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 30) {
          path = await FilePicker.platform.getDirectoryPath(
            dialogTitle: l10n.selectDownloadFolder,
          );
        } else {
          if (await Permission.storage.request().isGranted) {
            path = await FilePicker.platform.getDirectoryPath(
              dialogTitle: l10n.selectDownloadFolder,
            );
          } else {
            if (mounted) {
              SnackbarUtils.showTyped(
                context,
                l10n.storagePermissionRequired,
                SnackBarType.warning,
              );
            }
            return;
          }
        }
      } else {
        path = await FilePicker.platform.getDirectoryPath(
          dialogTitle: l10n.selectDownloadFolder,
        );
      }

      if (path != null && mounted) {
        setState(() {
          _currentSettings.downloadPath = path!;
        });
        _markChanged();
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

  Future<void> _handleNotificationToggle(bool enable) async {
    final l10n = AppLocalizations.of(context);
    // Prevent changing the value optimistically in the UI before permission is known
    // The `setState` calls within this function will handle the final state.
    if (enable) {
      // User wants to enable notifications, so request permissions first
      final bool hasPermission =
          await P2PNotificationService.instance.requestPermissions();

      if (mounted) {
        if (hasPermission) {
          // Permission is granted, update the toggle state
          setState(() {
            _currentSettings =
                _currentSettings.copyWith(enableNotifications: true);
          });

          // Refresh notification service settings
          try {
            await P2PNotificationService.instance.refreshSettings();
            logInfo('Refreshed notification service settings after enabling');
          } catch (e) {
            logError('Failed to refresh notification service settings: $e');
          }
        } else {
          // Permission denied, show an explanatory dialog
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return PermissionInfoDialog(
                title: l10n.enableNotifications,
                content: l10n.enableNotificationsDescription,
                actionText: l10n.openSettings,
                onActionPressed: () {
                  P2PNotificationService.instance.openNotificationSettings();
                },
              );
            },
          );
          // Keep the toggle off
          setState(() {
            _currentSettings =
                _currentSettings.copyWith(enableNotifications: false);
          });
        }
      }
    } else {
      // User wants to disable notifications
      setState(() {
        _currentSettings =
            _currentSettings.copyWith(enableNotifications: false);
      });

      // Refresh notification service settings
      try {
        await P2PNotificationService.instance.refreshSettings();
        logInfo('Refreshed notification service settings after disabling');
      } catch (e) {
        logError('Failed to refresh notification service settings: $e');
      }
    }
    _markChanged();
  }

  List<SliderOption<int>> _uiRefreshRateOptions(AppLocalizations l10n) {
    return [
      SliderOption(value: 0, label: l10n.immediate),
      SliderOption(value: 1, label: '1 ${l10n.secondsLabel}'),
      SliderOption(value: 2, label: '2 ${l10n.secondsPlural}'),
      SliderOption(value: 3, label: '3 ${l10n.secondsPlural}'),
      SliderOption(value: 4, label: '4 ${l10n.secondsPlural}'),
      SliderOption(value: 5, label: '5 ${l10n.secondsPlural}'),
    ];
  }

  List<SliderOption<int>> _getFileSizeOptions(AppLocalizations l10n) {
    return [
      const SliderOption(value: 10 * 1024 * 1024, label: '10 MB'),
      const SliderOption(value: 50 * 1024 * 1024, label: '50 MB'),
      const SliderOption(value: 100 * 1024 * 1024, label: '100 MB'),
      const SliderOption(value: 200 * 1024 * 1024, label: '200 MB'),
      const SliderOption(value: 500 * 1024 * 1024, label: '500 MB'),
      const SliderOption(value: 1 * 1024 * 1024 * 1024, label: '1 GB'),
      const SliderOption(value: 2 * 1024 * 1024 * 1024, label: '2 GB'),
      const SliderOption(value: 5 * 1024 * 1024 * 1024, label: '5 GB'),
      const SliderOption(value: 10 * 1024 * 1024 * 1024, label: '10 GB'),
      const SliderOption(value: 50 * 1024 * 1024 * 1024, label: '50 GB'),
      SliderOption(value: -1, label: l10n.unlimited),
    ];
  }

  List<SliderOption<int>> _getTotalSizeOptions(AppLocalizations l10n) {
    return [
      const SliderOption(value: 100 * 1024 * 1024, label: '100 MB'),
      const SliderOption(value: 500 * 1024 * 1024, label: '500 MB'),
      const SliderOption(value: 1 * 1024 * 1024 * 1024, label: '1 GB'),
      const SliderOption(value: 2 * 1024 * 1024 * 1024, label: '2 GB'),
      const SliderOption(value: 5 * 1024 * 1024 * 1024, label: '5 GB'),
      const SliderOption(value: 10 * 1024 * 1024 * 1024, label: '10 GB'),
      const SliderOption(value: 20 * 1024 * 1024 * 1024, label: '20 GB'),
      const SliderOption(value: 50 * 1024 * 1024 * 1024, label: '50 GB'),
      const SliderOption(value: 100 * 1024 * 1024 * 1024, label: '100 GB'),
      SliderOption(value: -1, label: l10n.unlimited),
    ];
  }

  List<SliderOption<int>> _getConcurrentTasksOptions(AppLocalizations l10n) {
    return [
      const SliderOption(value: 1, label: '1'),
      const SliderOption(value: 2, label: '2'),
      SliderOption(value: 3, label: '3 ${l10n.defaultValue}'),
      const SliderOption(value: 4, label: '4'),
      const SliderOption(value: 5, label: '5'),
      const SliderOption(value: 6, label: '6'),
      const SliderOption(value: 8, label: '8'),
      const SliderOption(value: 10, label: '10'),
      SliderOption(value: 99, label: l10n.unlimited),
    ];
  }

  List<OptionItem<String>> _getProtocolOptions(AppLocalizations l10n) {
    return [
      OptionItem(
        value: 'TCP',
        label: l10n.protocolTcpReliable,
        subtitle: l10n.protocolTcpDescription,
      ),
      OptionItem(
        value: 'UDP',
        label: l10n.protocolUdpFast,
        subtitle: l10n.udpDescription,
      ),
    ];
  }

  List<OptionItem<String>> _getFileOrganizationOptions(AppLocalizations l10n) {
    return [
      OptionItem(
        value: 'none',
        label: l10n.fileOrgNone,
        subtitle: l10n.fileOrgNoneDescription,
      ),
      OptionItem(
        value: 'date',
        label: l10n.fileOrgDate,
        subtitle: l10n.fileOrgDateDescription,
      ),
      OptionItem(
        value: 'sender',
        label: l10n.fileOrgSender,
        subtitle: l10n.fileOrgSenderDescription,
      ),
    ];
  }

  String _getFileProtocolDisplayText(AppLocalizations l10n) {
    switch (_currentSettings.sendProtocol) {
      case 'TCP':
        return l10n.protocolTcpReliable;
      case 'UDP':
        return l10n.protocolUdpFast;
      default:
        return _currentSettings.sendProtocol;
    }
  }

  String _getConcurrentTasksDisplayText(AppLocalizations l10n) {
    if (_currentSettings.maxConcurrentTasks >= 99) {
      return l10n.unlimited;
    }
    return _currentSettings.maxConcurrentTasks.toString();
  }

  Widget _buildDisplayNameField(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.displayNameDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: l10n.deviceDisplayNameLabel,
                hintText: l10n.deviceDisplayNameHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit),
                helperText: l10n.defaultDisplayName(_currentDeviceName),
              ),
              onChanged: (value) {
                setState(() {
                  _customDisplayName = value;
                });
                _markChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}
