import 'package:flutter/material.dart';
import 'package:p2lan/widgets/generic/option_item.dart';

/// A generic option picker widget that supports both single and multiple selection
/// with configurable nullable behavior.
class OptionListPicker<T> extends StatelessWidget {
  /// List of available options
  final List<OptionItem<T>> options;

  /// Currently selected value(s)
  /// For single selection: T? or Set<T> with single item
  /// For multiple selection: Set<T>
  final dynamic selectedValue;

  /// Callback when selection changes
  /// For single selection: void Function(T? value)
  /// For multiple selection: void Function(Set<T> values)
  final void Function(dynamic value) onChanged;

  /// Whether to allow multiple selection
  final bool allowMultiple;

  /// Whether to allow null/no selection (only for single selection)
  final bool allowNull;

  /// Whether to show the selection control (radio/checkbox)
  final bool showSelectionControl;

  /// Whether to use compact layout (less padding)
  final bool isCompact;

  /// Custom card color when selected
  final Color? selectedCardColor;

  const OptionListPicker({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.allowMultiple = false,
    this.allowNull = false,
    this.showSelectionControl = true,
    this.isCompact = false,
    this.selectedCardColor,
  });

  @override
  Widget build(BuildContext context) {
    // Filter visible options
    final visibleOptions = options.where((option) => option.visible).toList();

    return Column(
      children: visibleOptions.map((option) {
        final isSelected = _isOptionSelected(option.value);
        final isEnabled = option.enabled;

        return Padding(
          padding: EdgeInsets.only(bottom: isCompact ? 8 : 12),
          child: Card(
            color: isSelected
                ? (selectedCardColor ??
                    Theme.of(context).colorScheme.primaryContainer)
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  width: 0.5),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isEnabled ? () => _handleTap(option.value) : null,
              child: Opacity(
                opacity: isEnabled ? 1.0 : 0.5,
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 12 : 16),
                  child: Row(
                    children: [
                      // Selection control (radio button or checkbox)
                      if (showSelectionControl) ...[
                        if (allowMultiple)
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => _handleTap(option.value),
                          )
                        else
                          Radio<T?>(
                            value: option.value,
                            groupValue: allowNull
                                ? selectedValue
                                : (isSelected ? option.value : null),
                            onChanged: (value) => _handleTap(value),
                          ),
                        SizedBox(width: isCompact ? 8 : 12),
                      ],

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                        : null,
                                  ),
                            ),
                            if (option.subtitle != null) ...[
                              SizedBox(height: isCompact ? 2 : 4),
                              Text(
                                option.subtitle!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                              .withValues(alpha: 0.8)
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _isOptionSelected(T value) {
    if (allowMultiple) {
      final selectedSet = selectedValue as Set<T>?;
      return selectedSet?.contains(value) ?? false;
    } else {
      return selectedValue == value;
    }
  }

  void _handleTap(T? value) {
    if (allowMultiple) {
      final currentSet = Set<T>.from(selectedValue as Set<T>? ?? <T>{});

      if (value != null) {
        if (currentSet.contains(value)) {
          currentSet.remove(value);
        } else {
          currentSet.add(value);
        }
      }

      onChanged(currentSet);
    } else {
      // Single selection
      if (allowNull && selectedValue == value) {
        // Deselect if already selected and nulls are allowed
        onChanged(null);
      } else {
        onChanged(value);
      }
    }
  }
}
