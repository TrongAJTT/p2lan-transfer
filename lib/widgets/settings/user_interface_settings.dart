import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/settings_models.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:p2lan/main.dart';
import 'package:p2lan/utils/shortcut_tooltip_utils.dart';

/// User Interface Settings Module
/// Handles theme, language, and layout settings
class UserInterfaceSettings extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final Function(bool)? onCompactLayoutChanged;
  final Function(bool)? onShowShortcutsChanged;

  const UserInterfaceSettings({
    super.key,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.onCompactLayoutChanged,
    this.onShowShortcutsChanged,
  });

  @override
  State<UserInterfaceSettings> createState() => _UserInterfaceSettingsState();
}

class _UserInterfaceSettingsState extends State<UserInterfaceSettings> {
  late AppLocalizations loc;
  UserInterfaceSettingsData? _settings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings =
          await ExtensibleSettingsService.getUserInterfaceSettings();
      if (mounted) {
        setState(() {
          _settings = settings;
          _loading = false;
        });

        // Apply shortcut tooltip setting immediately when settings are loaded
        ShortcutTooltipUtils.I
            .setShowShortcutsInTooltips(settings.showShortcutsInTooltips);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _settings = UserInterfaceSettingsData();
          _loading = false;
        });

        // Apply default shortcut tooltip setting
        ShortcutTooltipUtils.I
            .setShowShortcutsInTooltips(_settings!.showShortcutsInTooltips);
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      await ExtensibleSettingsService.updateUserInterfaceSettings(_settings!);
    }
  }

  void _onThemeChanged(ThemeMode? mode) async {
    if (mode != null && _settings != null) {
      setState(() {
        _settings = _settings!.copyWith(themeMode: mode.name);
      });

      // Update global settings controller
      settingsController.setThemeMode(mode);

      // Save to Isar
      await _saveSettings();

      // Notify parent
      widget.onThemeChanged?.call(mode);
    }
  }

  void _onLanguageChanged(String? lang) async {
    if (lang != null && _settings != null) {
      setState(() {
        _settings = _settings!.copyWith(languageCode: lang);
      });

      // Update global settings controller
      settingsController.setLocale(Locale(lang));

      // Save to Isar
      await _saveSettings();

      // Notify parent
      widget.onLanguageChanged?.call(lang);
    }
  }

  void _onCompactLayoutChanged(bool value) async {
    if (_settings != null) {
      setState(() {
        _settings = _settings!.copyWith(useCompactLayoutOnMobile: value);
      });

      // Save to Isar
      await _saveSettings();

      // Trigger UI refresh for layout changes
      settingsController.refreshUI();

      // Notify parent
      widget.onCompactLayoutChanged?.call(value);
    }
  }

  void _onShowShortcutsChanged(bool value) async {
    if (_settings != null) {
      setState(() {
        _settings = _settings!.copyWith(showShortcutsInTooltips: value);
      });

      // Save to Isar
      await _saveSettings();

      // Trigger UI refresh for tooltip changes
      settingsController.refreshUI();

      // Update global singleton utility
      ShortcutTooltipUtils.I.setShowShortcutsInTooltips(value);

      // Notify parent
      widget.onShowShortcutsChanged?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_settings == null) {
      return Center(child: Text(loc.failedToLoadSettings('null')));
    }

    // Get width for responsive layout
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme & Language with responsive layout
          (width > 1000)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildThemeSection()),
                    const SizedBox(width: 32),
                    Expanded(child: _buildLanguageSection()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThemeSection(),
                    const SizedBox(height: 24),
                    _buildLanguageSection(),
                  ],
                ),

          const SizedBox(height: 24),

          // Mobile Layout
          _buildSectionHeader(loc.mobileLayout, Icons.phone_android),
          const SizedBox(height: 16),

          Card(
            child: SwitchListTile.adaptive(
              title: Text(loc.useCompactLayout),
              subtitle: Text(loc.useCompactLayoutDesc),
              value: _settings!.useCompactLayoutOnMobile,
              onChanged: _onCompactLayoutChanged,
              secondary: const Icon(Icons.phone_android),
            ),
          ),

          const SizedBox(height: 24),

          // User Experience
          _buildSectionHeader(loc.userExperience, Icons.tune),
          const SizedBox(height: 16),

          Card(
            child: SwitchListTile.adaptive(
              title: Text(loc.showShortcutsInTooltips),
              subtitle: Text(loc.showShortcutsInTooltipsDesc),
              value: _settings!.showShortcutsInTooltips,
              onChanged: _onShowShortcutsChanged,
              secondary: const Icon(Icons.keyboard),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(loc.theme, Icons.palette),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                title: Row(
                  children: [
                    Icon(Icons.brightness_auto_outlined,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(loc.system),
                  ],
                ),
                value: ThemeMode.system,
                groupValue: _getThemeModeFromString(_settings!.themeMode),
                onChanged: (value) => _onThemeChanged(value),
              ),
              RadioListTile<ThemeMode>(
                title: Row(
                  children: [
                    Icon(Icons.light_mode_outlined,
                        color: Colors.amber.shade600),
                    const SizedBox(width: 8),
                    Text(loc.light),
                  ],
                ),
                value: ThemeMode.light,
                groupValue: _getThemeModeFromString(_settings!.themeMode),
                onChanged: (value) => _onThemeChanged(value),
              ),
              RadioListTile<ThemeMode>(
                title: Row(
                  children: [
                    Icon(Icons.dark_mode_outlined,
                        color: Colors.indigo.shade600),
                    const SizedBox(width: 8),
                    Text(loc.dark),
                  ],
                ),
                value: ThemeMode.dark,
                groupValue: _getThemeModeFromString(_settings!.themeMode),
                onChanged: (value) => _onThemeChanged(value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(loc.language, Icons.language),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text("🇬🇧 English"),
                value: 'en',
                groupValue: _settings!.languageCode,
                onChanged: (value) => _onLanguageChanged(value),
              ),
              RadioListTile<String>(
                title: const Text("🇻🇳 Tiếng Việt"),
                value: 'vi',
                groupValue: _settings!.languageCode,
                onChanged: (value) => _onLanguageChanged(value),
              ),
            ],
          ),
        ),
      ],
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

  ThemeMode _getThemeModeFromString(String themeMode) {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
