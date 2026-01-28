import 'package:flutter/material.dart';
import 'package:p2lan/widgets/generic/option_item.dart';

/// A specialized OptionItem for slider values.
/// Use OptionItem constructor for creating slider options.
///
/// Example:
/// ```dart
/// OptionItem<int>(value: 5, label: '5 MB')
/// ```
class SliderOption<T> extends OptionItem<T> {
  /// Creates a SliderOption from OptionItem value constructor
  const SliderOption({
    required super.value,
    required super.label,
  });

  /// Creates SliderOption from OptionItem for convenience
  factory SliderOption.fromOptionItem(OptionItem<T> option) {
    return SliderOption<T>(
      value: option.value,
      label: option.label,
    );
  }
}

enum OptionSliderLayout { card, none }

/// A generic, reusable slider widget for selecting from a list of predefined options.
/// It mirrors the design of the FileSizeSlider for a consistent UI.
class OptionSlider<T> extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData? icon;
  final T currentValue;
  final List<SliderOption<T>> options;
  final ValueChanged<T> onChanged;
  final double fixedWidth;
  final OptionSliderLayout layout;
  final EdgeInsetsGeometry?
      padding; // Changed type to EdgeInsetsGeometry for flexibility

  const OptionSlider({
    super.key,
    required this.label,
    this.subtitle,
    this.icon,
    required this.currentValue,
    required this.options,
    required this.onChanged,
    this.fixedWidth = 100,
    this.layout = OptionSliderLayout.card,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    // Find the index of the currently selected option.
    final int selectedIndex =
        options.indexWhere((opt) => opt.value == currentValue);
    // If not found, default to the first option.
    final int displayIndex = selectedIndex != -1 ? selectedIndex : 0;
    final SliderOption<T> selectedOption = options[displayIndex];

    final content = Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.titleMedium),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
            // Desktop value display
            if (isLargeScreen) ...[
              const SizedBox(width: 12),
              Container(
                width: fixedWidth > 0 ? fixedWidth : null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  selectedOption.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              )
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: displayIndex.toDouble(),
                min: 0,
                max: (options.length - 1).toDouble(),
                divisions: options.length > 1 ? options.length - 1 : 1,
                label: selectedOption.label,
                onChanged: (double value) {
                  final newIndex = value.round();
                  if (newIndex >= 0 && newIndex < options.length) {
                    final newValue = options[newIndex].value;
                    onChanged(newValue);
                  }
                },
              ),
            ),
            if (!isLargeScreen) ...[
              const SizedBox(width: 4),
              Container(
                width: fixedWidth > 0 ? fixedWidth : null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  selectedOption.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              )
            ],
          ],
        ),
      ],
    );

    Widget paddedContent = padding != null
        ? Padding(
            padding: padding!,
            child: content,
          )
        : content;

    if (layout == OptionSliderLayout.card) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: paddedContent,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: paddedContent,
      );
    }
  }
}
