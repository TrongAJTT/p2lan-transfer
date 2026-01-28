import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/utils/icon_utils.dart';
import 'package:p2lan/utils/size_utils.dart';
import 'package:p2lan/utils/widget_layout_render_helper.dart';

/// A decorator class to customize the appearance of a [GenericDialog].
@immutable
class GenericDialogDecorator {
  final DynamicDimension width;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? bodyPadding;
  final EdgeInsetsGeometry? footerPadding;
  final Color? headerBackColor;
  final Color? headerTextColor;
  final Color? bodyBackColor;
  final Color? footerBackColor;
  final bool displayTopDivider;
  final bool displayBottomDivider;

  const GenericDialogDecorator({
    required this.width,
    this.borderRadius,
    this.headerPadding,
    this.bodyPadding,
    this.footerPadding,
    this.headerBackColor,
    this.headerTextColor,
    this.bodyBackColor,
    this.footerBackColor,
    this.displayTopDivider = false,
    this.displayBottomDivider = false,
  });
}

/// A generic, customizable dialog header.
class GenericDialogHeader extends StatelessWidget {
  final GenericIcon? icon;
  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final bool displayExitButton;
  final GenericIcon? customExitIcon;
  final Color? headerTextColor;

  const GenericDialogHeader({
    super.key,
    this.icon,
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.subtitleStyle,
    this.displayExitButton = false,
    this.customExitIcon,
    this.headerTextColor,
  }) : assert(customExitIcon == null || displayExitButton,
            'customExitIcon can only be used when displayExitButton is true.');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: titleStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: headerTextColor,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: subtitleStyle ??
                      theme.textTheme.bodyMedium?.copyWith(
                        color: headerTextColor ??
                            theme.colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (displayExitButton)
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: customExitIcon ?? GenericIcon.icon(Icons.close),
            splashRadius: 20,
          ),
      ],
    );
  }
}

/// A generic dialog footer with preset button layouts.
class GenericDialogFooter extends StatelessWidget {
  final Widget child;

  const GenericDialogFooter({super.key, required this.child});

  /// Layout: Empty
  factory GenericDialogFooter.empty() {
    return const GenericDialogFooter(child: SizedBox.shrink());
  }

  /// Layout: [Reset to Default]...[Cancel][Save]
  factory GenericDialogFooter.defaultCancelSave({
    required VoidCallback onReset,
    required VoidCallback onCancel,
    required VoidCallback onSave,
    String? resetText,
    String? cancelText,
    String? saveText,
  }) {
    return GenericDialogFooter(
      child: Builder(builder: (context) {
        final l10n = MaterialLocalizations.of(context);
        final theme = Theme.of(context);

        const buttonRadius = 8.0;

        return WidgetLayoutRenderHelper.oneLeftTwoRight(
          // Reset to Default (minimal, icon left, subtle style)
          TextButton.icon(
            onPressed: onReset,
            icon:
                Icon(Icons.refresh, size: 20, color: theme.colorScheme.primary),
            label: Text(
              resetText ?? "Reset to Default",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: const Size(0, 36),
            ),
          ),
          // Cancel (minimal, text only)
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: const Size(0, 36),
            ),
            child: Text(
              cancelText ?? l10n.cancelButtonLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Save (primary, filled, rounded)
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              foregroundColor: theme.colorScheme.onSurface,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
              minimumSize: const Size(120, 40),
              textStyle: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              saveText ?? l10n.okButtonLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          threeInARowMinWidth: 400.0,
          twoInARowMinWidth: 200.0,
          singleRowWidgetOnTop: true,
          spacing: TwoDimSpacing.both(8.0),
        );
      }),
    );
  }

  /// Layout: [Clear]...[Cancel][Save]
  factory GenericDialogFooter.clearCancelSave({
    required VoidCallback onClear,
    required VoidCallback onCancel,
    required VoidCallback onSave,
    String? clearText,
    String? cancelText,
    String? saveText,
  }) {
    return GenericDialogFooter(
      child: Builder(builder: (context) {
        final l10n = MaterialLocalizations.of(context);
        return WidgetLayoutRenderHelper.oneLeftTwoRight(
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear_all),
            label: Text(clearText ?? "Clear"),
          ),
          TextButton(
            onPressed: onCancel,
            child: Text(cancelText ?? l10n.cancelButtonLabel),
          ),
          ElevatedButton(
            onPressed: onSave,
            child: Text(saveText ?? l10n.okButtonLabel),
          ),
          threeInARowMinWidth: 400.0,
          twoInARowMinWidth: 0,
          singleRowWidgetOnTop: false,
          spacing: TwoDimSpacing.both(8.0),
        );
      }),
    );
  }

  /// Layout: [Cancel] [Save] (with configurable flex)
  factory GenericDialogFooter.cancelSave({
    required VoidCallback onCancel,
    required VoidCallback? onSave,
    String? cancelText,
    String? saveText,
    int cancelFlex = 1,
    int saveFlex = 1,
  }) {
    return GenericDialogFooter(
      child: Builder(builder: (context) {
        final l10n = MaterialLocalizations.of(context);
        return Row(
          children: [
            Expanded(
              flex: cancelFlex,
              child: OutlinedButton(
                onPressed: onCancel,
                child: Text(cancelText ?? l10n.cancelButtonLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: saveFlex,
              child: ElevatedButton(
                onPressed: onSave,
                child: Text(saveText ?? l10n.okButtonLabel),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Layout: ... [ButtonLeft] [ButtonRight]
  factory GenericDialogFooter.twoCustomButtons({
    required BuildContext context,
    required TextButton leftButton,
    required TextButton rightButton,
    double minToggleDisplayWidth = 600.0,
    double spacing = 8.0,
  }) {
    // Get widget width
    final widgetSize = MediaQuery.of(context).size;
    return GenericDialogFooter(
        child: (widgetSize.width >= minToggleDisplayWidth)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  leftButton,
                  SizedBox(width: spacing),
                  rightButton,
                ],
              )
            : WidgetLayoutRenderHelper.twoEqualWidthInRow(
                leftButton,
                rightButton,
                minWidth: minToggleDisplayWidth / 2,
                spacing: TwoDimSpacing.both(spacing),
              ));
  }

  /// Factory: ... [ButtonLeft] [ButtonRight]
  factory GenericDialogFooter.twoSimpleButtons({
    required BuildContext context,
    required String leftText,
    required String rightText,
    required VoidCallback onLeft,
    required VoidCallback onRight,
    double minToggleDisplayWidth = 600.0,
    double spacing = 8.0,
  }) {
    return GenericDialogFooter.twoCustomButtons(
      context: context,
      leftButton: TextButton(
        onPressed: onLeft,
        child: Text(leftText),
      ),
      rightButton: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        onPressed: onRight,
        child: Text(rightText),
      ),
      minToggleDisplayWidth: minToggleDisplayWidth,
      spacing: spacing,
    );
  }

  /// Layout: ... [No] [Yes]
  factory GenericDialogFooter.yesNo({
    required BuildContext context,
    required VoidCallback onYes,
    required VoidCallback onNo,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return GenericDialogFooter.twoSimpleButtons(
      context: context,
      leftText: l10n.no,
      rightText: l10n.yes,
      onLeft: onNo,
      onRight: onYes,
    );
  }

  /// Layout for a single button (e.g., Save, OK, I Know, Close)
  factory GenericDialogFooter.singleButton({
    required String text,
    required VoidCallback onPressed,
    MainAxisAlignment alignment = MainAxisAlignment.end,
  }) {
    return GenericDialogFooter(
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          ElevatedButton(
            onPressed: onPressed,
            child: Text(text),
          ),
        ],
      ),
    );
  }

  /// Layout: [left][right] ngang, width tuỳ chọn, chia đều
  factory GenericDialogFooter.twoInARow({
    required Widget left,
    required Widget right,
    double width = 300,
  }) {
    return GenericDialogFooter(
      child: SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: left),
            const SizedBox(width: 16),
            Expanded(child: right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// A generic dialog that combines a header, body, and footer.
class GenericDialog extends StatelessWidget {
  final GenericDialogHeader header;
  final Widget body;
  final GenericDialogFooter footer;
  final GenericDialogDecorator? decorator;

  const GenericDialog({
    super.key,
    required this.header,
    required this.body,
    required this.footer,
    this.decorator,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Use provided decorator or default values
    final effectiveDecorator = decorator ??
        GenericDialogDecorator(
          width: DynamicDimension.flexibilityMax(90, 600),
        );

    final dialogWidth = effectiveDecorator.width.calculate(screenSize.width);

    final dialogShape = RoundedRectangleBorder(
      borderRadius:
          effectiveDecorator.borderRadius ?? BorderRadius.circular(12.0),
    );

    return AlertDialog(
      shape: dialogShape,
      title: null, // Title is handled inside content
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero, // All padding handled internally
      actions: null,
      actionsPadding: EdgeInsets.zero,
      // backgroundColor: Colors.transparent, // Avoid default background
      elevation: 0,

      content: SizedBox(
        width: dialogWidth,
        child: ClipRRect(
          borderRadius:
              effectiveDecorator.borderRadius ?? BorderRadius.circular(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: effectiveDecorator.headerPadding ??
                    const EdgeInsets.fromLTRB(24, 24, 12, 12),
                color: effectiveDecorator.headerBackColor ??
                    Theme.of(context).colorScheme.surface,
                child: header,
              ),

              if (effectiveDecorator.displayTopDivider)
                const Divider(height: 1),

              // Body
              Flexible(
                child: Container(
                  padding: effectiveDecorator.bodyPadding ??
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  color: effectiveDecorator.bodyBackColor ??
                      Theme.of(context).colorScheme.surface,
                  child: body,
                ),
              ),

              if (effectiveDecorator.displayBottomDivider)
                const Divider(height: 1),

              // Footer
              Container(
                padding: effectiveDecorator.footerPadding ??
                    const EdgeInsets.fromLTRB(24, 12, 24, 24),
                color: effectiveDecorator.footerBackColor ??
                    Theme.of(context).colorScheme.surface,
                child: footer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
