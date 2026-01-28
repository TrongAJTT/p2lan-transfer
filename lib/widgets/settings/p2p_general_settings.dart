import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:p2lan/utils/snackbar_utils.dart';
import 'package:p2lan/utils/variables_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/settings_models.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:p2lan/services/p2p_services/p2p_service_manager.dart';
import 'package:p2lan/services/p2p_services/p2p_notification_service.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/widgets/generic/option_slider.dart';
import 'package:p2lan/widgets/generic/generic_dialog.dart';
import 'package:p2lan/widgets/generic/edit_text_dialog.dart';
import 'package:p2lan/utils/size_utils.dart';

class P2PGeneralSettings extends StatefulWidget {
  const P2PGeneralSettings({super.key});

  @override
  State<P2PGeneralSettings> createState() => _P2PGeneralSettingsState();
}

class _P2PGeneralSettingsState extends State<P2PGeneralSettings> {
  P2PGeneralSettingsData? _settings;
  bool _loading = true;
  final _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<String> _getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name;
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return macInfo.computerName;
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.name;
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      logError('Failed to get device name: $e');
      return 'Unknown Device';
    }
  }

  Future<void> _loadSettings() async {
    try {
      // Get device name first
      final deviceName = await _getDeviceName();

      final settings = await ExtensibleSettingsService.getGeneralSettings();
      if (mounted) {
        setState(() {
          _settings = settings;
          _displayNameController.text =
              settings.displayName?.trim().isNotEmpty == true
                  ? settings.displayName!
                  : deviceName;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _settings = const P2PGeneralSettingsData(); // Default settings
          _displayNameController.text = 'Unknown Device';
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      await ExtensibleSettingsService.updateGeneralSettings(_settings!);

      // Refresh transfer service settings
      try {
        // Get transfer service and refresh its settings
        final transferService = P2PServiceManager.instance.transferService;
        await transferService.reloadTransferSettings();
        logInfo('Refreshed P2P transfer service settings after change');
      } catch (e) {
        logError('Failed to refresh transfer service settings: $e');
      }
    }
  }

  Future<void> _handleNotificationToggle(bool value) async {
    if (value) {
      // User is enabling notifications, check permissions first
      final hasPermission = await _checkNotificationPermission();
      if (!hasPermission) {
        final granted = await _requestNotificationPermission();
        if (!granted) {
          // Permission denied, don't enable notifications
          return;
        }
      }

      // Show restart suggestion when enabling notifications
      _showRestartSuggestion();
    } else {
      // User is disabling notifications, check if there are active notifications
      final hasActiveNotifications = await _checkActiveNotifications();
      if (hasActiveNotifications) {
        final shouldClear = await _showClearNotificationsDialog();
        if (shouldClear == true) {
          await _clearAllNotifications();
        }
      }
    }

    setState(() {
      _settings = _settings!.copyWith(enableNotifications: value);
    });
    await _saveSettings();

    // Refresh notification service settings
    try {
      final notificationService = P2PNotificationService.instanceOrNull;
      if (notificationService != null) {
        await notificationService.refreshSettings();
        logInfo('Refreshed notification service settings after toggle');
      }
    } catch (e) {
      logError('Failed to refresh notification service settings: $e');
    }
  }

  Future<bool> _checkActiveNotifications() async {
    try {
      // Check if notification service has any active notifications
      final notificationService = P2PNotificationService.instanceOrNull;
      if (notificationService != null && notificationService.isReady) {
        // This is a basic check - you might need to implement a more sophisticated check
        return true; // Assume there might be notifications if service is active
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkNotificationPermission() async {
    try {
      // Check actual system notification permission, not just service state
      if (Platform.isAndroid) {
        final permission = await Permission.notification.status;
        return permission.isGranted;
      } else if (Platform.isIOS) {
        final permission = await Permission.notification.status;
        return permission.isGranted;
      }
      return false;
    } catch (e) {
      logError('Failed to check notification permission: $e');
      return false;
    }
  }

  Future<bool> _requestNotificationPermission() async {
    try {
      // Request actual system notification permission
      if (Platform.isAndroid) {
        late bool granted;

        if (!(await Permission.notification.isGranted) && mounted) {
          final userAction = await showDialog<bool>(
              context: context,
              builder: (context) {
                final loc = AppLocalizations.of(context);
                return GenericDialog(
                  header: GenericDialogHeader(
                      title: loc.notificationRequestPermission),
                  body: Text(loc.notificationRequestPermissionDesc),
                  footer: GenericDialogFooter.twoSimpleButtons(
                    context: context,
                    leftText: loc.cancel,
                    rightText: loc.grantPermission,
                    onLeft: () => Navigator.of(context).pop(false),
                    onRight: () => Navigator.of(context).pop(true),
                    minToggleDisplayWidth: 400,
                  ),
                );
              });

          if (userAction == true) {
            // User agreed to grant permission
            final permission = await Permission.notification.request();
            granted = permission.isGranted;
          } else {
            granted = false; // User denied permission
          }
        } else {
          granted = true; // Already granted
        }

        if (granted) {
          // Initialize notification service after permission granted
          try {
            final notificationService = P2PNotificationService.instanceOrNull;
            if (notificationService != null) {
              await notificationService.initialize();
              logInfo(
                  'Notification service initialized after permission granted');
            }
          } catch (e) {
            logError('Failed to initialize notification service: $e');
          }
        }

        return granted;
      }
      return false;
    } catch (e) {
      logError('Failed to request notification permission: $e');
      return false;
    }
  }

  void _showRestartSuggestion() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Restart the app to initialize notification service'),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  Future<bool?> _showClearNotificationsDialog() async {
    final loc = AppLocalizations.of(context);
    return await showDialog<bool>(
      context: context,
      builder: (context) => GenericDialog(
        header: GenericDialogHeader(
          title: loc.clearNotification,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.clearNotificationInfo1),
            const SizedBox(height: 16),
            Text(loc.clearNotificationInfo2),
          ],
        ),
        footer: GenericDialogFooter.twoSimpleButtons(
          context: context,
          leftText: loc.keep,
          rightText: loc.clearAll,
          onLeft: () => Navigator.of(context).pop(false),
          onRight: () => Navigator.of(context).pop(true),
          minToggleDisplayWidth: 300,
        ),
        decorator: GenericDialogDecorator(
          width: DynamicDimension.flexibilityMax(90, 500),
        ),
      ),
    );
  }

  Future<void> _clearAllNotifications() async {
    try {
      final notificationService = P2PNotificationService.instanceOrNull;
      if (notificationService != null) {
        await notificationService.clearAllNotifications();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDeskop = !isMobileLayoutContext(context);
    final colorScheme = Theme.of(context).colorScheme;
    const double sizeHeight = 48;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_settings == null) {
      return Center(child: Text(loc.failedToLoadSettings('null')));
    }

    Future<void> changeDisplayName() async {
      final deviceName = await _getDeviceName();
      final current = _displayNameController.text.trim();
      final result = await EditTextDialog.show(
        context,
        title: loc.deviceName,
        message: loc.deviceNameEditDesc,
        label: loc.displayName,
        hint: loc.displayName,
        initialValue: current,
        defaultValue: deviceName,
        minLength: 1,
        maxLength: 20,
        minWidth: 400,
        maxWidth: 600,
        saveButtonText: loc.save,
        cancelButtonText: loc.cancel,
        resetButtonText: loc.reset,
      );

      if (!mounted) return;
      if (result == null) return; // cancelled

      setState(() {
        _displayNameController.text = result;
        _settings = _settings?.copyWith(displayName: result);
      });
      await _saveSettings();
    }

    Future<void> resetDisplayName() async {
      final deviceName = await _getDeviceName();

      setState(() {
        _displayNameController.text = deviceName;
        _settings = _settings?.copyWith(displayName: deviceName);
      });
      await _saveSettings();

      // Show confirmation
      if (context.mounted) {
        SnackbarUtils.showTyped(
          context,
          loc.displayNameHasReset,
          SnackBarType.info,
        );
      }
    }

    return SingleChildScrollView(
      // padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device Name Section
          _buildSectionHeader(loc.yourProfile, Icons.person),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.devices),
                title: Text(loc.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.deviceNameDesc),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: changeDisplayName,
                            child: Container(
                              height: sizeHeight,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _displayNameController.text,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (isDeskop) ...[
                          SizedBox(
                            height: sizeHeight,
                            child: FilledButton.icon(
                              onPressed: resetDisplayName,
                              icon: const Icon(Icons.refresh),
                              label: Text(loc.reset),
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            height: sizeHeight,
                            width: sizeHeight,
                            child: IconButton(
                              icon: const Icon(Icons.refresh),
                              color: colorScheme.secondary,
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                minimumSize: const Size(0, sizeHeight),
                              ),
                              onPressed: resetDisplayName,
                              tooltip: loc.reset,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
                dense: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // User Preferences Section
          _buildSectionHeader(loc.userPreferences, Icons.settings),
          const SizedBox(height: 16),

          const SizedBox(height: 16),

          // Only show notifications on supported platforms
          if (!Platform.isWindows) ...[
            Card(
              child: SwitchListTile.adaptive(
                title: Text(loc.enableNotifications),
                subtitle: Text(loc.enableNotificationsDescription),
                value: _settings!.enableNotifications,
                onChanged: _handleNotificationToggle,
                secondary: const Icon(Icons.notifications),
              ),
            ),
          ] else ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_off),
                title: Text(loc.enableNotifications),
                subtitle: Text(loc.notSupportedOnWindows),
                enabled: false,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Transfer Progress Auto-Cleanup Section (separate from notifications)
          _buildSectionHeader(
              loc.transferProgressAutoCleanup, Icons.auto_delete),
          const SizedBox(height: 16),

          // Startup cleanup - its own card above the rest
          Card(
            child: SwitchListTile.adaptive(
              title: Text(loc.clearTransfersAtStartup),
              subtitle: Text(loc.clearTransfersAtStartupDesc),
              value: _settings!.clearTransfersAtStartup,
              onChanged: (value) async {
                setState(() {
                  _settings =
                      _settings!.copyWith(clearTransfersAtStartup: value);
                });
                await _saveSettings();
              },
              secondary: const Icon(Icons.auto_delete),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.autoRemoveTransferMessages,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    title: Text(loc.completedTransfers),
                    subtitle: Text(loc.removeProgressOnSuccess),
                    value: _settings!.autoCleanupCompletedTasks,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings!
                            .copyWith(autoCleanupCompletedTasks: value);
                      });
                      _saveSettings();
                      logInfo(
                          'Auto-cleanup completed tasks setting changed to: $value');
                    },
                    secondary: const Icon(Icons.check_circle),
                    contentPadding: EdgeInsets.zero,
                    dense: false,
                  ),
                  SwitchListTile.adaptive(
                    title: Text(loc.cancelledTransfers),
                    subtitle: Text(loc.removeProgressOnCancel),
                    value: _settings!.autoCleanupCancelledTasks,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings!
                            .copyWith(autoCleanupCancelledTasks: value);
                      });
                      _saveSettings();
                      logInfo(
                          'Auto-cleanup cancelled tasks setting changed to: $value');
                    },
                    secondary: const Icon(Icons.cancel),
                    contentPadding: EdgeInsets.zero,
                    dense: false,
                  ),
                  SwitchListTile.adaptive(
                    title: Text(loc.failedTransfers),
                    subtitle: Text(loc.removeProgressOnFail),
                    value: _settings!.autoCleanupFailedTasks,
                    onChanged: (value) {
                      setState(() {
                        _settings =
                            _settings!.copyWith(autoCleanupFailedTasks: value);
                      });
                      _saveSettings();
                      logInfo(
                          'Auto-cleanup failed tasks setting changed to: $value');
                    },
                    secondary: const Icon(Icons.error),
                    contentPadding: EdgeInsets.zero,
                    dense: false,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 20),
                      const SizedBox(width: 8),
                      Text('${loc.cleanupDelay}: '),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _settings!.autoCleanupDelaySeconds,
                        items: [
                          DropdownMenuItem(
                              value: 0, child: Text(loc.immediate)),
                          DropdownMenuItem(
                              value: 3, child: Text('3 ${loc.secondsPlural}')),
                          DropdownMenuItem(
                              value: 5, child: Text('5 ${loc.secondsPlural}')),
                          DropdownMenuItem(
                              value: 10,
                              child: Text('10 ${loc.secondsPlural}')),
                          DropdownMenuItem(
                              value: 30,
                              child: Text('30 ${loc.secondsPlural}')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _settings = _settings!
                                  .copyWith(autoCleanupDelaySeconds: value);
                            });
                            _saveSettings();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // UI Performance Section
          _buildSectionHeader(loc.uiPerformance, Icons.tune),
          const SizedBox(height: 16),

          // TODO: Implement actual performance settings
          Card(
            child: OptionSlider<int>(
              icon: Icons.schedule,
              label: "${loc.uiRefreshRate} [BETA]",
              subtitle: loc.uiRefreshRateDescription,
              options: _getUIRefreshOptions(loc),
              currentValue: _settings!.uiRefreshRateSeconds,
              onChanged: (value) {
                setState(() {
                  _settings = _settings!.copyWith(uiRefreshRateSeconds: value);
                });
                _saveSettings();
              },
              layout: OptionSliderLayout.none,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),

          const SizedBox(height: 24),

          // App Update Section (auto check updates daily)
          _buildSectionHeader(loc.about, Icons.system_update_alt),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile.adaptive(
              title: Text(loc.autoCheckUpdatesDaily),
              subtitle: Text(loc.autoCheckUpdatesDailyDesc),
              value: _settings!.autoCheckUpdatesDaily,
              onChanged: (value) async {
                setState(() {
                  _settings = _settings!.copyWith(autoCheckUpdatesDaily: value);
                });
                await _saveSettings();
              },
              secondary: const Icon(Icons.update),
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

  List<SliderOption<int>> _getUIRefreshOptions(AppLocalizations loc) {
    return [
      SliderOption(value: 0, label: loc.immediate),
      SliderOption(value: 1, label: '1 ${loc.secondsLabel}'),
      SliderOption(value: 2, label: '2 ${loc.secondsPlural}'),
      SliderOption(value: 3, label: '3 ${loc.secondsPlural}'),
      SliderOption(value: 4, label: '4 ${loc.secondsPlural}'),
      SliderOption(value: 5, label: '5 ${loc.secondsPlural}'),
    ];
  }
}
