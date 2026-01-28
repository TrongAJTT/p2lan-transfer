import 'package:flutter/material.dart';
import 'package:p2lan/widgets/generic/option_item.dart';

@immutable
class OptionSwitchDecorator {
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double? switchScale;

  const OptionSwitchDecorator({
    this.padding,
    this.titleStyle,
    this.subtitleStyle,
    this.switchScale,
  });

  /// Creates a decorator for a compact version of the switch (0.7x scale).
  ///
  /// This scales down the padding, font sizes, and the switch itself.
  static OptionSwitchDecorator compact(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTitleStyle = theme.textTheme.titleMedium;
    final defaultSubtitleStyle = theme.textTheme.bodySmall;

    // Default values from Material Design spec if theme values are null.
    const defaultTitleFontSize = 16.0;
    const defaultSubtitleFontSize = 12.0;
    const defaultVerticalPadding = 8.0;
    const defaultHorizontalPadding = 4.0;

    const scale = 0.9;

    final titleFontSize = defaultTitleStyle?.fontSize ?? defaultTitleFontSize;
    final subtitleFontSize =
        defaultSubtitleStyle?.fontSize ?? defaultSubtitleFontSize;

    return OptionSwitchDecorator(
      switchScale: scale,
      titleStyle: defaultTitleStyle?.copyWith(
        fontSize: titleFontSize * scale,
      ),
      subtitleStyle: defaultSubtitleStyle?.copyWith(
        fontSize: subtitleFontSize * scale,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: defaultVerticalPadding * scale,
        horizontal: defaultHorizontalPadding * scale,
      ),
    );
  }

  OptionSwitchDecorator copyWith({
    EdgeInsetsGeometry? padding,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    double? switchScale,
  }) {
    return OptionSwitchDecorator(
      padding: padding ?? this.padding,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      switchScale: switchScale ?? this.switchScale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OptionSwitchDecorator &&
        other.padding == padding &&
        other.titleStyle == titleStyle &&
        other.subtitleStyle == subtitleStyle &&
        other.switchScale == switchScale;
  }

  @override
  int get hashCode =>
      padding.hashCode ^
      titleStyle.hashCode ^
      subtitleStyle.hashCode ^
      switchScale.hashCode;
}

class OptionSwitch extends StatelessWidget {
  const OptionSwitch({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
    this.decorator,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isEnabled;
  final OptionSwitchDecorator? decorator;

  /// Creates OptionSwitch using OptionItem constructor method
  /// Use OptionItem.textOnly() factory constructor for switch creation
  ///
  /// Example:
  /// ```dart
  /// final option = OptionItem.textOnly(value: true, label: "Enable Feature");
  /// OptionSwitch.fromOptionItem(
  ///   option: option,
  ///   onChanged: (value) => print('Changed to: $value'),
  /// )
  /// ```
  factory OptionSwitch.fromOptionItem({
    required OptionItem<bool> option,
    required ValueChanged<bool>? onChanged,
    OptionSwitchDecorator? decorator,
  }) {
    return OptionSwitch(
      title: option.label,
      subtitle: option.subtitle,
      value: option.value,
      onChanged: onChanged,
      isEnabled: option.enabled,
      decorator: decorator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isEffectivelyDisabled = !isEnabled || onChanged == null;

    final defaultTitleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w500,
      color: isEffectivelyDisabled ? theme.disabledColor : null,
    );
    final defaultSubtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: isEffectivelyDisabled
          ? theme.disabledColor
          : theme.colorScheme.onSurfaceVariant,
    );

    final titleStyle = decorator?.titleStyle ?? defaultTitleStyle;
    final subtitleStyle = decorator?.subtitleStyle ?? defaultSubtitleStyle;

    Widget switchWidget = Switch(
      value: value,
      onChanged: isEffectivelyDisabled ? null : onChanged,
    );

    if (decorator?.switchScale != null) {
      switchWidget = Transform.scale(
        scale: decorator!.switchScale!,
        child: switchWidget,
      );
    }

    return Opacity(
      opacity: isEffectivelyDisabled ? 0.5 : 1.0,
      child: InkWell(
        onTap: isEffectivelyDisabled ? null : () => onChanged?.call(!value),
        child: Padding(
          padding: decorator?.padding ??
              const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: subtitle != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(title, style: titleStyle),
                          const SizedBox(height: 4),
                          Text(subtitle!, style: subtitleStyle),
                        ],
                      )
                    : Text(title, style: titleStyle),
              ),
              const SizedBox(width: 24),
              switchWidget,
            ],
          ),
        ),
      ),
    );
  }
}
