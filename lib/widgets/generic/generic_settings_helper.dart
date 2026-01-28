import 'package:flutter/material.dart';
import 'package:p2lan/widgets/generic/generic_settings_dialog.dart';
import 'package:p2lan/widgets/generic/generic_settings_screen.dart';

/// Generic settings configuration
class GenericSettingsConfig<T> {
  /// Title for the settings screen/dialog
  final String title;

  /// Settings layout widget
  final Widget settingsLayout;

  /// Current settings object
  final T? currentSettings;

  /// Callback when settings are changed
  final Function(T) onSettingsChanged;

  /// Callback when cancel is pressed
  final VoidCallback? onCancel;

  /// Whether to show action buttons
  final bool showActions;

  /// Whether to use compact layout
  final bool isCompact;

  /// Preferred size for dialog (only used on desktop)
  final Size? preferredSize;

  /// Whether dialog is dismissible
  final bool barrierDismissible;

  /// Padding for the content container
  final EdgeInsets? padding;

  const GenericSettingsConfig({
    required this.title,
    required this.settingsLayout,
    this.currentSettings,
    required this.onSettingsChanged,
    this.onCancel,
    this.showActions = true,
    this.isCompact = false,
    this.preferredSize,
    this.barrierDismissible = false,
    this.padding,
  });
}

/// Generic settings helper for navigating to different settings screens
///
/// This class provides three main navigation methods for settings:
///
/// 1. **showSettings()** - The primary method that adapts to the platform:
///    - Desktop: Shows a dialog for better UX on large screens
///    - Mobile/Tablet: Shows full-screen navigation for better touch interaction
///    - Use this for main settings access where you want platform-appropriate behavior
///
/// 2. **showQuickSettings()** - Optimized for quick configuration changes:
///    - Desktop: Shows a smaller, focused dialog (600x500 by default)
///    - Mobile: Falls back to full-screen (same as showSettings)
///    - Use this for frequently accessed settings or when space is limited
///    - Ideal for toolbar buttons, context menus, or inline settings access
///
/// 3. **showBottomSheetSettings()** - Mobile-first modal interface:
///    - All platforms: Shows a modal bottom sheet that slides up from bottom
///    - Provides swipe-to-dismiss gesture and drag handle for intuitive interaction
///    - Takes 80% of screen height by default, but customizable
///    - Use this for mobile-specific flows, temporary settings, or contextual options
///    - Great for settings that complement the main content without full navigation
class GenericSettingsHelper {
  /// Shows settings using the appropriate UI based on screen size and platform.
  ///
  /// **Platform Behavior:**
  /// - **Desktop (width > 800px)**: Opens a dialog window for better desktop UX
  /// - **Mobile/Tablet**: Navigates to a full-screen settings page
  ///
  /// **When to use:**
  /// - Main settings access from app menus or settings buttons
  /// - When you want automatic platform-appropriate behavior
  /// - For comprehensive settings that may require more space
  ///
  /// **Parameters:**
  /// - [context]: Build context for navigation
  /// - [config]: Settings configuration including title, layout, and callbacks
  static void showSettings<T>(
    BuildContext context,
    GenericSettingsConfig<T> config,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800;

    if (isDesktop) {
      // Desktop: Use dialog
      _showSettingsDialog(context, config);
    } else {
      // Mobile/Tablet: Use full screen
      _showSettingsScreen(context, config);
    }
  }

  /// Show settings dialog (desktop)
  static void _showSettingsDialog<T>(
    BuildContext context,
    GenericSettingsConfig<T> config,
  ) {
    showDialog(
      context: context,
      barrierDismissible: config.barrierDismissible,
      builder: (context) => GenericSettingsDialog(
        title: config.title,
        preferredSize: config.preferredSize,
        settingsLayout: config.settingsLayout,
        padding: config.padding,
      ),
    );
  }

  /// Show settings screen (mobile/tablet)
  static void _showSettingsScreen<T>(
    BuildContext context,
    GenericSettingsConfig<T> config,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GenericSettingsScreen(
          title: config.title,
          settingsLayout: config.settingsLayout,
        ),
      ),
    );
  }

  /// Shows quick settings dialog with specific configuration for rapid access.
  ///
  /// **Platform Behavior:**
  /// - **Desktop**: Opens a smaller, focused dialog (600x500 by default)
  /// - **Mobile**: Falls back to full-screen navigation (same as showSettings)
  ///
  /// **When to use:**
  /// - Frequently accessed settings that need quick modification
  /// - Settings accessed from toolbar buttons or context menus
  /// - When screen real estate is limited but settings access is needed
  /// - For power-user features or expert mode toggles
  ///
  /// **Design Intent:**
  /// This method is optimized for speed and efficiency. The smaller dialog size
  /// on desktop keeps the main content visible while allowing quick adjustments.
  ///
  /// **Parameters:**
  /// - [context]: Build context for navigation
  /// - [config]: Settings configuration (title will be prefixed with "Quick")
  /// - [quickSize]: Optional custom size for the dialog (desktop only)
  static void showQuickSettings<T>(
    BuildContext context,
    GenericSettingsConfig<T> config, {
    Size? quickSize,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800;

    if (isDesktop) {
      showDialog(
        context: context,
        barrierDismissible: config.barrierDismissible,
        builder: (context) => GenericSettingsDialog(
          title: 'Quick ${config.title}',
          preferredSize: quickSize ?? const Size(600, 500),
          settingsLayout: config.settingsLayout,
          padding: config.padding,
        ),
      );
    } else {
      // On mobile, just show the regular settings screen
      _showSettingsScreen(context, config);
    }
  }

  /// Shows modal bottom sheet settings for mobile-optimized quick access.
  ///
  /// **Platform Behavior:**
  /// - **All platforms**: Shows a modal bottom sheet that slides up from the bottom
  /// - Includes drag handle and swipe-to-dismiss gestures for intuitive interaction
  /// - Takes 80% of screen height by default, but fully customizable
  ///
  /// **When to use:**
  /// - Mobile-first settings that complement the main content
  /// - Contextual settings that relate to the current screen
  /// - Temporary or quick-access settings that don't need full navigation
  /// - Settings that benefit from gesture-based interaction (swipe to dismiss)
  ///
  /// **Design Intent:**
  /// This method provides a modern, mobile-native experience. The bottom sheet
  /// approach keeps users in context while providing easy access to settings.
  /// It's particularly effective for settings that are:
  /// - Frequently toggled
  /// - Context-dependent
  /// - Supplementary to the main workflow
  ///
  /// **Parameters:**
  /// - [context]: Build context for navigation
  /// - [config]: Settings configuration
  /// - [height]: Custom height (default: 80% of screen height)
  /// - [isDismissible]: Whether tapping outside dismisses the sheet
  /// - [enableDrag]: Whether drag gestures can dismiss the sheet
  static void showBottomSheetSettings<T>(
    BuildContext context,
    GenericSettingsConfig<T> config, {
    double? height,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: height ?? MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      config.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Settings content
            Expanded(
              child: config.settingsLayout,
            ),
          ],
        ),
      ),
    );
  }
}
