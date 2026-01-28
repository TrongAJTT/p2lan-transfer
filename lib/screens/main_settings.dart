import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/shared_preferences_service.dart';
import 'package:p2lan/utils/variables_utils.dart';
import 'package:p2lan/main.dart';

// Settings modules
import 'package:p2lan/widgets/settings/user_interface_settings.dart';
import 'package:p2lan/widgets/settings/data_management_settings.dart';
import 'package:p2lan/widgets/settings/about_settings.dart';
import 'package:p2lan/widgets/settings/p2p_general_settings.dart';
import 'package:p2lan/widgets/settings/p2p_receiver_location_settings.dart';
import 'package:p2lan/widgets/settings/p2p_network_speed_settings.dart';
import 'package:p2lan/widgets/settings/p2p_advanced_settings.dart';

// Layout components
import 'package:p2lan/layouts/section_sidebar_scrolling_layout.dart';
import 'package:p2lan/widgets/generic/section_item.dart';
import 'package:p2lan/screens/settings/single_section_display_screen.dart';

class MainSettingsScreen extends StatefulWidget {
  final VoidCallback? onToolVisibilityChanged;
  final String? initialSectionId;

  const MainSettingsScreen({
    super.key,
    this.onToolVisibilityChanged,
    this.initialSectionId,
  });

  @override
  State<MainSettingsScreen> createState() => _MainSettingsScreenState();
}

class _MainSettingsScreenState extends State<MainSettingsScreen> {
  bool _loading = true;

  // Keyboard shortcut focus node
  final FocusNode _keyboardFocusNode = FocusNode();
  String? _selectedSectionId;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) {
      _loadSettings();
    }

    // Request focus for keyboard shortcuts on desktop only
    final isDesktop = !isMobileLayoutContext(context);
    if (isDesktop) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_keyboardFocusNode.hasFocus) {
          _keyboardFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _loading = false;
    });
  }

  void _onThemeChanged(ThemeMode? mode) async {
    if (mode != null) {
      settingsController.setThemeMode(mode);
    }
  }

  void _onLanguageChanged(String? lang) async {
    if (lang != null) {
      settingsController.setLocale(Locale(lang));
    }
  }

  void _onCompactLayoutChanged(bool useCompact) async {
    // Small delay to ensure settings are saved before triggering refresh
    await Future.delayed(const Duration(milliseconds: 100));

    // Force a global UI refresh to ensure all screens reload their layout settings
    // This will trigger P2LanTransferScreen to reload its compact layout setting
    settingsController.refreshUI();

    if (mounted) {
      setState(() {
        // Also trigger local rebuild
      });
    }
  }

  void _handleKeyboardShortcuts(KeyDownEvent event) {
    // Debug: Print key events to help debug
    logDebug(
        'Settings Key event: ${event.logicalKey}, Focus: ${_keyboardFocusNode.hasFocus}');

    // Esc: Exit settings
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      logDebug('Executing: Exit settings');
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }

    // Desktop-only: Ctrl+1..Ctrl+7 jump to sections
    final isDesktop = !isMobileLayoutContext(context);
    if (isDesktop && HardwareKeyboard.instance.isControlPressed) {
      int? index;
      if (event.logicalKey == LogicalKeyboardKey.digit1) {
        index = 0;
      } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
        index = 1;
      } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
        index = 2;
      } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
        index = 3;
      } else if (event.logicalKey == LogicalKeyboardKey.digit5) {
        index = 4;
      } else if (event.logicalKey == LogicalKeyboardKey.digit6) {
        index = 5;
      } else if (event.logicalKey == LogicalKeyboardKey.digit7) {
        index = 6;
      }
      if (index != null) {
        final sections = _buildSections(AppLocalizations.of(context));
        if (index >= 0 && index < sections.length) {
          final i = index;
          setState(() {
            _selectedSectionId = sections[i].id;
          });
        }
      }
    }
  }

  Widget _wrapWithKeyboardListener(Widget child) {
    final isDesktop = !isMobileLayoutContext(context);
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: isDesktop,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          _handleKeyboardShortcuts(event);
        }
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDesktop = !isMobileLayoutContext(context);

    if (_loading) {
      Widget loadingWidget = isDesktop
          ? const Center(child: CircularProgressIndicator())
          : Scaffold(
              appBar: AppBar(title: Text(loc.settings)),
              body: const Center(child: CircularProgressIndicator()),
            );
      return _wrapWithKeyboardListener(loadingWidget);
    }

    // On mobile, show section selection screen first if not embedded and not forcing full layout
    if (!isDesktop) {
      Widget mobileWidget = MobileSectionSelectionScreen(
        title: loc.settings,
        sections: _buildSections(loc),
        onSectionSelected: (sectionId) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SingleSectionDisplayScreen(
                sectionId: sectionId,
                sections: _buildSections(loc),
              ),
            ),
          );
        },
      );
      return _wrapWithKeyboardListener(mobileWidget);
    }

    // For single section display (mobile navigation)
    if (widget.initialSectionId != null) {
      Widget singleSectionWidget = SingleSectionDisplayScreen(
        sectionId: widget.initialSectionId!,
        sections: _buildSections(loc),
      );
      return _wrapWithKeyboardListener(singleSectionWidget);
    }

    // Full layout for desktop or embedded
    Widget desktopWidget = Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
      ),
      body: SectionSidebarScrollingLayout(
        isEmbedded: true,
        sections: _buildSections(loc),
        selectedSectionId: _selectedSectionId,
      ),
    );
    return _wrapWithKeyboardListener(desktopWidget);
  }

  List<SectionItem> _buildSections(AppLocalizations loc) {
    return [
      // User Interface section
      SectionItem(
        id: SharedPreferencesKeys.interface,
        title: loc.userInterface,
        subtitle: loc.userInterfaceDesc,
        icon: Icons.palette_outlined,
        iconColor: Colors.blue.shade600,
        content: UserInterfaceSettings(
          onThemeChanged: _onThemeChanged,
          onLanguageChanged: _onLanguageChanged,
          onCompactLayoutChanged: _onCompactLayoutChanged,
        ),
      ),

      // P2P General Settings
      SectionItem(
        id: SharedPreferencesKeys.p2pGeneral,
        title: loc.general,
        subtitle: loc.generalDesc,
        icon: Icons.person_outline,
        iconColor: Colors.orange.shade600,
        content: const P2PGeneralSettings(),
      ),

      // P2P Receiver Location & Size Limits
      SectionItem(
        id: SharedPreferencesKeys.p2pReceiverLocation,
        title: loc.receiverLocationSizeLimits,
        subtitle: loc.receiverLocationSizeLimitsDesc,
        icon: Icons.folder_outlined,
        iconColor: Colors.green.shade600,
        content: const P2PReceiverLocationSettings(),
      ),

      // P2P Network & Speed
      SectionItem(
        id: SharedPreferencesKeys.p2pNetworkSpeed,
        title: loc.networkSpeed,
        subtitle: loc.networkSpeedDesc,
        icon: Icons.network_check_outlined,
        iconColor: Colors.blue.shade700,
        content: const P2PNetworkSpeedSettings(),
      ),

      // P2P Advanced (Security + Compression)
      SectionItem(
        id: SharedPreferencesKeys.p2pAdvanced,
        title: loc.advanced,
        subtitle: loc.advancedDesc,
        icon: Icons.security_outlined,
        iconColor: Colors.red.shade600,
        content: const P2PAdvancedSettings(),
      ),

      // Data Management section
      SectionItem(
        id: SharedPreferencesKeys.data,
        title: loc.dataAndStorage,
        subtitle: loc.dataAndStorageDesc,
        icon: Icons.storage_outlined,
        iconColor: Colors.purple.shade600,
        content: const DataManagementSettings(
          initialLogRetentionDays:
              7, // Default value, will be loaded in the widget
        ),
      ),

      // About section
      SectionItem(
        id: SharedPreferencesKeys.about,
        title: loc.about,
        subtitle: loc.aboutDesc,
        icon: Icons.info_outline,
        iconColor: Colors.grey.shade600,
        content: const AboutSettings(),
      ),
    ];
  }
}
