import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/utils/snackbar_utils.dart';

/// Result of a settings save operation
class SettingsSaveResult<T> {
  final bool success;
  final T? data;
  final String? errorMessage;

  const SettingsSaveResult.success(this.data)
      : success = true,
        errorMessage = null;

  const SettingsSaveResult.error(this.errorMessage)
      : success = false,
        data = null;
}

/// Callback for settings save completion with automatic navigation and feedback
typedef SettingsSaveCallback<T> = Function(SettingsSaveResult<T> result);

/// Abstract base class for settings layouts in the generic settings system.
///
/// This class provides:
/// - Standardized save/cancel logic
/// - Automatic success/error feedback
/// - Proper navigation handling
/// - Change tracking pattern
///
/// **Usage Pattern:**
/// 1. Extend this class
/// 2. Implement `performSave()` for actual save logic
/// 3. Implement `buildSettingsContent()` for UI
/// 4. Call `notifyHasChanges()` when settings change
/// 5. The base class handles everything else automatically
abstract class BaseSettingsLayout<T> extends StatefulWidget {
  /// Callback when settings are successfully saved
  final SettingsSaveCallback<T>? onSettingsSaved;

  /// Callback when cancel is pressed
  final VoidCallback? onCancel;

  /// Whether to show action buttons (Save/Cancel)
  final bool showActions;

  const BaseSettingsLayout({
    super.key,
    this.onSettingsSaved,
    this.onCancel,
    this.showActions = true,
  });
}

/// Base state for settings layouts
abstract class BaseSettingsLayoutState<W extends BaseSettingsLayout<T>, T>
    extends State<W> {
  bool _loading = true;
  bool _hasChanges = false;
  bool _saving = false;

  /// Whether the layout is currently loading
  bool get isLoading => _loading;

  /// Whether there are unsaved changes
  bool get hasChanges => _hasChanges;

  /// Whether a save operation is in progress
  bool get isSaving => _saving;

  @override
  void initState() {
    super.initState();
    _loadInitialSettings();
  }

  /// Load initial settings. Override this method to load your settings.
  Future<void> loadSettings();

  /// Perform the actual save operation. Return the saved data or throw an exception.
  Future<T> performSave();

  /// Build the settings content UI
  Widget buildSettingsContent(BuildContext context, AppLocalizations loc);

  /// Call this when settings change to update the hasChanges flag
  void notifyHasChanges(bool hasChanges) {
    if (_hasChanges != hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  /// Call this when loading is complete
  void notifyLoadingComplete() {
    if (_loading) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadInitialSettings() async {
    try {
      await loadSettings();
    } catch (e) {
      // Override can handle errors if needed
    } finally {
      notifyLoadingComplete();
    }
  }

  Future<void> _saveSettings() async {
    if (_saving) return; // Prevent double-save

    setState(() {
      _saving = true;
    });

    try {
      final result = await performSave();

      // Reset changes flag on successful save
      setState(() {
        _hasChanges = false;
        _saving = false;
      });

      // Show success feedback
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          AppLocalizations.of(context)!.saved,
          SnackBarType.success,
        );
      }

      // Notify parent with success result (this will trigger navigation)
      if (widget.onSettingsSaved != null) {
        widget.onSettingsSaved!(SettingsSaveResult.success(result));
      }
    } catch (e) {
      setState(() {
        _saving = false;
      });

      // Show error feedback
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          'Error saving settings: $e',
          SnackBarType.error,
        );
      }

      // Notify parent with error result (no navigation)
      if (widget.onSettingsSaved != null) {
        widget.onSettingsSaved!(SettingsSaveResult.error(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Content
        Expanded(
          child: buildSettingsContent(context, loc),
        ),

        // Actions
        if (widget.showActions) ...[
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.onCancel != null) ...[
                  TextButton(
                    onPressed: _saving ? null : widget.onCancel,
                    child: Text(loc.cancel),
                  ),
                  const SizedBox(width: 12),
                ],
                FilledButton(
                  onPressed: (_hasChanges && !_saving) ? _saveSettings : null,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(loc.save),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
