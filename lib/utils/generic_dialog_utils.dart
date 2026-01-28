import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/utils/icon_utils.dart';
import 'package:p2lan/utils/size_utils.dart';
import 'package:p2lan/utils/widget_layout_render_helper.dart';
import 'package:p2lan/widgets/generic/generic_dialog.dart';
import 'package:p2lan/widgets/hold_button.dart';

/// A utility class for showing common generic dialogs.
class GenericDialogUtils {
  /// Shows a standardized dialog for confirming a 'clear' or 'delete' action.
  static Future<bool?> showSimpleGenericClearDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title,
    String? description,
    GenericIcon? icon,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return GenericDialog(
          decorator: GenericDialogDecorator(
            width: DynamicDimension.flexibilityMax(90, 400),
            displayTopDivider: true,
          ),
          header: GenericDialogHeader(
            title: title ?? l10n.clearAll,
            icon: icon ?? GenericIcon.icon(Icons.delete_sweep_outlined),
            displayExitButton: true,
          ),
          body: description != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    description,
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : const SizedBox.shrink(),
          footer: GenericDialogFooter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Use a simple Row for two equal buttons, which is more direct
                // than the layout render helper for this specific case.
                return Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        ),
                        onPressed: () {
                          onConfirm();
                          Navigator.of(context).pop(true);
                        },
                        child: Text(l10n.delete),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Shows a dialog that requires the user to hold down a button to confirm.
  static Future<bool?> showSimpleHoldClearDialog({
    required BuildContext context,
    required String title,
    required String content,
    required Duration duration,
    required VoidCallback onConfirm,
  }) {
    // NOTE: This is a placeholder implementation.
    // You should replace this with your actual HoldToDeleteDialog widget.
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => GenericDialog(
        decorator: GenericDialogDecorator(
          width: DynamicDimension.flexibilityMax(90, 400),
          displayTopDivider: true,
        ),
        header: GenericDialogHeader(
          title: title,
          icon: GenericIcon.icon(Icons.delete_sweep_outlined),
          displayExitButton: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(content),
        ),
        footer: GenericDialogFooter(
          child: WidgetLayoutRenderHelper.twoInARowThreshold(
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            HoldButton(
              onHoldComplete: () {
                onConfirm();
                Navigator.of(context).pop(true);
              },
              text: '${l10n.holdToDelete} (${duration.inSeconds}s)',
              contentAlign: ContentAlign.center,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              holdDuration: duration,
            ),
            TwoInARowDecorator(
              widthWidget1: DynamicDimension.percentage(25),
              widthWidget2: DynamicDimension.percentage(75),
            ),
            const TwoInARowConditionType.overallWidth(300),
            spacing: TwoDimSpacing.specific(vertical: 8.0, horizontal: 8.0),
          ),
        ),
      ),
    );
  }

  static Future<bool?> showClearAllBookmarksDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    final l10n = AppLocalizations.of(context);
    return showSimpleHoldClearDialog(
      context: context,
      title: l10n.clearAllBookmarks,
      content: l10n.clearAllBookmarksConfirm,
      duration: const Duration(seconds: 1),
      onConfirm: onConfirm,
    );
  }
}
