import 'package:flutter/material.dart';
import 'package:p2lan/utils/function_type_utils.dart';
import 'package:p2lan/widgets/generic/generic_settings_helper.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/screens/about_layout.dart';
import 'package:p2lan/screens/p2lan_transfer/p2lan_transfer_settings_layout.dart';
import 'package:p2lan/services/p2p_services/p2p_settings_adapter.dart';
import 'package:p2lan/utils/snackbar_utils.dart';

/// Generic settings utilities for different function types.
///
/// This utility class provides factory methods to navigate to settings based on
/// function types using the generic settings system. It acts as a bridge between
/// specific function types and the generic settings navigation methods.
///
/// **Three Navigation Approaches:**
///
/// 1. **navigateSettings()** - Adaptive platform-specific navigation
/// 2. **navigateQuickSettings()** - Optimized for rapid access and frequent use
/// 3. **navigateBottomSheetSettings()** - Mobile-first modal interface
///
/// Each method automatically creates the appropriate configuration for the given
/// function type and delegates to the corresponding GenericSettingsHelper method.
class GenericSettingsUtils {
  /// Factory method to navigate to settings based on function type using
  /// platform-adaptive behavior.
  ///
  /// **Behavior:**
  /// - Desktop: Opens dialog window
  /// - Mobile/Tablet: Full-screen navigation
  ///
  /// **Use Cases:**
  /// - Main settings access from menus or dedicated settings buttons
  /// - When you want automatic platform-appropriate presentation
  /// - For comprehensive settings that may need more space
  ///
  /// **Parameters:**
  /// - [context]: Build context for navigation
  /// - [functionType]: Type of settings to show (see FunctionType enum)
  /// - [currentSettings]: Current settings object (type depends on functionType)
  /// - [onSettingsChanged]: Callback when settings are modified
  /// - [onCancel]: Optional callback when cancel is pressed
  /// - [showActions]: Whether to show action buttons (Save/Cancel)
  /// - [isCompact]: Whether to use compact layout
  /// - [preferredSize]: Preferred dialog size (desktop only)
  /// - [barrierDismissible]: Whether clicking outside dismisses dialog
  static void navigateSettings(
    BuildContext context,
    FunctionType functionType, {
    dynamic currentSettings,
    required Function(dynamic) onSettingsChanged,
    VoidCallback? onCancel,
    VoidCallback? onDialogClosed,
    bool showActions = true,
    bool isCompact = false,
    Size? preferredSize,
    bool barrierDismissible = false,
  }) {
    final config = _createSettingsConfig(
      context,
      functionType,
      currentSettings: currentSettings,
      onSettingsChanged: onSettingsChanged,
      onCancel: onCancel,
      onDialogClosed: onDialogClosed,
      showActions: showActions,
      isCompact: isCompact,
      preferredSize: preferredSize,
      barrierDismissible: barrierDismissible,
    );

    if (config != null) {
      GenericSettingsHelper.showSettings(context, config);
    }
  }

  /// Factory method for quick settings navigation optimized for rapid access.
  ///
  /// **Behavior:**
  /// - Desktop: Smaller, focused dialog (600x500 by default)
  /// - Mobile: Falls back to full-screen navigation
  ///
  /// **Use Cases:**
  /// - Frequently accessed settings that need quick modification
  /// - Settings accessed from toolbar buttons, context menus, or shortcuts
  /// - When you need settings access but want to minimize disruption
  /// - Power-user features or expert mode toggles
  ///
  /// **Design Philosophy:**
  /// This method prioritizes speed and efficiency. Settings are presented in
  /// a way that allows quick changes without losing context of the main task.
  ///
  /// **Parameters:**
  /// - [context]: Build context for navigation
  /// - [functionType]: Type of settings to show (see FunctionType enum)
  /// - [currentSettings]: Current settings object (type depends on functionType)
  /// - [onSettingsChanged]: Callback when settings are modified
  /// - [onCancel]: Optional callback when cancel is pressed
  /// - [quickSize]: Custom dialog size (desktop only, overrides default 600x500)
  /// - [barrierDismissible]: Whether clicking outside dismisses dialog (default: true)
  static void navigateQuickSettings(
    BuildContext context,
    FunctionType functionType, {
    dynamic currentSettings,
    required Function(dynamic) onSettingsChanged,
    VoidCallback? onCancel,
    Size? quickSize,
    bool barrierDismissible = true,
  }) {
    final config = _createSettingsConfig(
      context,
      functionType,
      currentSettings: currentSettings,
      onSettingsChanged: onSettingsChanged,
      onCancel: onCancel,
      showActions: true,
      isCompact: true,
      barrierDismissible: barrierDismissible,
    );

    if (config != null) {
      GenericSettingsHelper.showQuickSettings(
        context,
        config,
        quickSize: quickSize,
      );
    }
  }

  /// Factory method for bottom sheet settings navigation with mobile-first design.
  ///
  /// **Behavior:**
  /// - All platforms: Modal bottom sheet that slides up from bottom
  /// - Includes drag handle and swipe-to-dismiss gestures
  /// - Takes 80% of screen height by default
  ///
  /// **Use Cases:**
  /// - Mobile-optimized settings that complement the main content
  /// - Contextual settings related to the current screen or task
  /// - Temporary settings that don't require full navigation commitment
  /// - Settings that benefit from gesture-based interaction
  ///
  /// **Design Philosophy:**
  /// This method provides a modern, mobile-native experience that keeps users
  /// in context. It's ideal for settings that are:
  /// - Supplementary to the main workflow
  /// - Frequently toggled or adjusted
  /// - Context-dependent or screen-specific
  ///
  /// **Interaction Design:**
  /// - Drag handle at top for visual affordance
  /// - Swipe down or tap outside to dismiss (if enabled)
  /// - Close button for explicit dismissal
  /// - Smooth slide-up animation for polished feel
  ///
  /// **Parameters:**
  /// - [context]: Build context for navigation
  /// - [functionType]: Type of settings to show (see FunctionType enum)
  /// - [currentSettings]: Current settings object (type depends on functionType)
  /// - [onSettingsChanged]: Callback when settings are modified
  /// - [onCancel]: Optional callback when cancel is pressed
  /// - [height]: Custom height (default: 80% of screen height)
  /// - [isDismissible]: Whether tapping outside dismisses the sheet (default: true)
  /// - [enableDrag]: Whether drag gestures can dismiss the sheet (default: true)
  static void navigateBottomSheetSettings(
    BuildContext context,
    FunctionType functionType, {
    dynamic currentSettings,
    required Function(dynamic) onSettingsChanged,
    VoidCallback? onCancel,
    double? height,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final config = _createSettingsConfig(
      context,
      functionType,
      currentSettings: currentSettings,
      onSettingsChanged: onSettingsChanged,
      onCancel: onCancel,
      showActions: true,
      isCompact: true,
    );

    if (config != null) {
      GenericSettingsHelper.showBottomSheetSettings(
        context,
        config,
        height: height,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
      );
    }
  }

  /// Creates settings configuration based on function type.
  ///
  /// This internal method acts as a factory to create the appropriate
  /// GenericSettingsConfig for the given function type. It handles the
  /// type-specific logic for creating settings layouts and configurations.
  ///
  /// **Current Support:**
  /// - P2Lan Transfer: Fully implemented with P2LanTransferSettingsLayout
  /// - Other types: Placeholders for future implementation
  ///
  /// **Parameters:**
  /// - [context]: Build context for widget creation
  /// - [functionType]: The type of settings to create configuration for
  /// - [currentSettings]: Current settings object (type varies by function type)
  /// - [onSettingsChanged]: Callback when settings are modified
  /// - [onCancel]: Optional callback when cancel action is performed
  /// - [showActions]: Whether to display action buttons (Save/Cancel)
  /// - [isCompact]: Whether to use compact layout variant
  /// - [preferredSize]: Preferred size for dialog presentation
  /// - [barrierDismissible]: Whether dialog can be dismissed by clicking outside
  ///
  /// **Returns:**
  /// GenericSettingsConfig for the function type, or null if not implemented
  static GenericSettingsConfig? _createSettingsConfig(
    BuildContext context,
    FunctionType functionType, {
    dynamic currentSettings,
    required Function(dynamic) onSettingsChanged,
    VoidCallback? onCancel,
    VoidCallback? onDialogClosed,
    bool showActions = true,
    bool isCompact = false,
    Size? preferredSize,
    bool barrierDismissible = false,
  }) {
    switch (functionType) {
      case FunctionType.p2lanTransfer:
        return _createP2LanTransferConfig(
          context,
          currentSettings: currentSettings as P2PDataTransferSettings?,
          onSettingsChanged:
              onSettingsChanged as Function(P2PDataTransferSettings),
          onCancel: onCancel,
          onDialogClosed: onDialogClosed,
          showActions: showActions,
          isCompact: isCompact,
          preferredSize: preferredSize,
          barrierDismissible: barrierDismissible,
        );
      case FunctionType.appSettings:
      case FunctionType.storageManagement:
      case FunctionType.userInterface:
      case FunctionType.networkSettings:
      case FunctionType.securitySettings:
      case FunctionType.notificationSettings:
      case FunctionType.fileManagement:
        // Not implemented yet
        return null;
    }
  }

  /// Create P2Lan transfer settings configuration
  static GenericSettingsConfig<P2PDataTransferSettings>
      _createP2LanTransferConfig(
    BuildContext context, {
    P2PDataTransferSettings? currentSettings,
    required Function(P2PDataTransferSettings) onSettingsChanged,
    VoidCallback? onCancel,
    VoidCallback? onDialogClosed,
    bool showActions = true,
    bool isCompact = false,
    Size? preferredSize,
    bool barrierDismissible = false,
  }) {
    return GenericSettingsConfig<P2PDataTransferSettings>(
      title: FunctionType.p2lanTransfer.displayName,
      settingsLayout: P2LanTransferSettingsLayout(
        currentSettings: currentSettings,
        onSettingsChanged: (settings) {
          onSettingsChanged(settings);
          Navigator.of(context).pop();
          // Call the callback after successful save
          if (onDialogClosed != null) {
            onDialogClosed();
          }
        },
        onCancel: () {
          if (onCancel != null) {
            onCancel();
          } else {
            Navigator.of(context).pop();
          }
        },
        showActions: showActions,
        isCompact: isCompact,
      ),
      currentSettings: currentSettings,
      onSettingsChanged: onSettingsChanged,
      onCancel: onCancel,
      showActions: showActions,
      isCompact: isCompact,
      preferredSize: preferredSize,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Convenience method to open P2P Transfer settings.
  static void quickOpenP2PTransferSettings(
    BuildContext context, {
    bool showSuccessMessage = true,
    VoidCallback? onDialogClosed,
  }) async {
    try {
      // Fetch settings asynchronously first
      final settings = await P2PSettingsAdapter.getSettings();

      // Ensure the context is still mounted before showing the dialog
      if (!context.mounted) return;

      // Use navigateSettings for full responsive dialog like other settings
      navigateSettings(
        context,
        FunctionType.p2lanTransfer,
        currentSettings: settings,
        onSettingsChanged: (dynamic newSettings) async {
          try {
            await P2PSettingsAdapter.updateSettings(
                newSettings as P2PDataTransferSettings);

            if (showSuccessMessage && context.mounted) {
              SnackbarUtils.showTyped(
                context,
                'P2P Transfer settings saved successfully',
                SnackBarType.success,
              );
            }

            // Call the callback after successful save and UI feedback
            if (onDialogClosed != null) {
              // Add small delay to ensure UI updates are complete
              await Future.delayed(const Duration(milliseconds: 50));
              onDialogClosed();
            }
          } catch (e) {
            if (context.mounted) {
              SnackbarUtils.showTyped(
                context,
                'Failed to save P2P settings: $e',
                SnackBarType.error,
              );
            }
          }
        },
        onDialogClosed: onDialogClosed,
        showActions: true,
        isCompact: false,
        barrierDismissible: false,
      );
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showTyped(
          context,
          'Error loading P2P settings: $e',
          SnackBarType.error,
        );
      }
    }
  }

  /// Navigate to About screen using platform-adaptive behavior.
  ///
  /// **Behavior:**
  /// - Desktop: Opens dialog window with padding
  /// - Mobile/Tablet: Full-screen navigation
  ///
  /// **Use Cases:**
  /// - About information access from app bars or main menus
  /// - Displaying app version, credits, and external links
  /// - When you want automatic platform-appropriate presentation
  ///
  /// **Parameters:**
  /// - [context]: Build context for navigation
  static void navigateAbout(BuildContext context) {
    final config = GenericSettingsConfig<dynamic>(
      title: 'About',
      settingsLayout: const AboutLayout(),
      currentSettings: null,
      onSettingsChanged: (_) {}, // No settings to change for About
      showActions: false, // No save/cancel buttons needed
      isCompact: false,
      barrierDismissible: true,
      padding: const EdgeInsets.all(16), // Add padding for desktop dialog
    );

    GenericSettingsHelper.showSettings(context, config);
  }
}
