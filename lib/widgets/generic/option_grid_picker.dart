import 'package:flutter/material.dart';
import 'package:p2lan/widgets/generic/option_item.dart';

enum LabelAlign { left, center, right }

enum IconAlign { aboveTitle, rightOfTitle, belowTitle, leftOfTitle }

class OptionGridDecorator {
  final EdgeInsets? padding;
  final IconAlign? iconAlign;
  final double? customTextSize;
  final LabelAlign labelAlign;
  final double iconSpacing;
  final double borderRadius;

  const OptionGridDecorator({
    this.padding,
    this.iconAlign,
    this.customTextSize,
    this.labelAlign = LabelAlign.center,
    this.iconSpacing = 0.0,
    this.borderRadius = 12.0,
  });
}

class AutoScaleOptionGridPicker<T> extends StatelessWidget {
  final String title;
  final List<OptionItem<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelectionChanged;
  final double minCellWidth;
  final double maxCellWidth;
  final double fixedCellHeight;
  final OptionGridDecorator? decorator;

  const AutoScaleOptionGridPicker({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelectionChanged,
    required this.minCellWidth,
    required this.fixedCellHeight,
    this.maxCellWidth = -1,
    this.decorator,
  });

  @override
  Widget build(BuildContext context) {
    // Validation for maxCellWidth
    if (maxCellWidth != -1 && maxCellWidth < minCellWidth) {
      throw ArgumentError(
          'maxCellWidth must be greater than or equal to minCellWidth when specified');
    }

    // Validation for iconAlign
    final effectiveDecorator = decorator ?? const OptionGridDecorator();
    if (effectiveDecorator.iconAlign != null) {
      for (final option in options) {
        if (option.visible && option.icon == null) {
          throw ArgumentError(
              'If iconAlign is provided, all visible options must have an icon');
        }
      }
    }

    final theme = Theme.of(context);

    // Filter visible options
    final visibleOptions = options.where((option) => option.visible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: effectiveDecorator.padding ??
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = (constraints.maxWidth / minCellWidth).floor();

            if (maxCellWidth != -1) {
              double currentCellWidth = constraints.maxWidth / crossAxisCount;
              while (currentCellWidth > maxCellWidth &&
                  crossAxisCount < visibleOptions.length) {
                crossAxisCount++;
                currentCellWidth = constraints.maxWidth / crossAxisCount;
              }
            }

            if (crossAxisCount < 1) {
              crossAxisCount = 1;
            }

            final double actualCellWidth =
                (constraints.maxWidth - (crossAxisCount - 1) * 8) /
                    crossAxisCount;

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: visibleOptions.map((option) {
                final isSelected = option.value == selectedValue;
                return SizedBox(
                  width: actualCellWidth,
                  height: fixedCellHeight,
                  child: _buildCellContent(context, option, isSelected),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCellContent(
      BuildContext context, OptionItem<T> option, bool isSelected) {
    final theme = Theme.of(context);
    final effectiveDecorator = decorator ?? const OptionGridDecorator();

    // Handle disabled state
    final effectiveEnabled = option.enabled;
    final opacity = effectiveEnabled ? 1.0 : 0.5;

    TextAlign getTextAlign() {
      switch (effectiveDecorator.labelAlign) {
        case LabelAlign.left:
          return TextAlign.left;
        case LabelAlign.center:
          return TextAlign.center;
        case LabelAlign.right:
          return TextAlign.right;
      }
    }

    final textWidget = Text(
      option.label,
      style: (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
        fontSize: effectiveDecorator.customTextSize,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
      ),
      textAlign: getTextAlign(),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    Widget cellContent;

    if (effectiveDecorator.iconAlign == null) {
      cellContent = Center(child: textWidget);
    } else {
      final iconWidget = option.icon;

      if (iconWidget == null) {
        cellContent = Center(child: textWidget);
      } else {
        switch (effectiveDecorator.iconAlign!) {
          case IconAlign.aboveTitle:
            cellContent = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconWidget,
                SizedBox(height: effectiveDecorator.iconSpacing),
                textWidget,
              ],
            );
            break;
          case IconAlign.belowTitle:
            cellContent = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textWidget,
                SizedBox(height: effectiveDecorator.iconSpacing),
                iconWidget,
              ],
            );
            break;
          case IconAlign.leftOfTitle:
            cellContent = effectiveDecorator.labelAlign == LabelAlign.center
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconWidget,
                      SizedBox(width: effectiveDecorator.iconSpacing),
                      Flexible(child: textWidget),
                    ],
                  )
                : Row(
                    children: [
                      iconWidget,
                      SizedBox(width: effectiveDecorator.iconSpacing),
                      Expanded(child: textWidget),
                    ],
                  );
            break;
          case IconAlign.rightOfTitle:
            cellContent = effectiveDecorator.labelAlign == LabelAlign.center
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: textWidget),
                      SizedBox(width: effectiveDecorator.iconSpacing),
                      iconWidget,
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: textWidget),
                      SizedBox(width: effectiveDecorator.iconSpacing),
                      iconWidget,
                    ],
                  );
            break;
        }
      }
    }

    return Opacity(
      opacity: opacity,
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveDecorator.borderRadius),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        color: option.backgroundColor ??
            (isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surface),
        child: InkWell(
          onTap:
              effectiveEnabled ? () => onSelectionChanged(option.value) : null,
          borderRadius: BorderRadius.circular(effectiveDecorator.borderRadius),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: cellContent,
          ),
        ),
      ),
    );
  }
}

class OptionGridPicker<T> extends StatelessWidget {
  /// Optional title displayed above the grid.
  final String? title;

  /// The list of options to display.
  final List<OptionItem<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelectionChanged;
  final int crossAxisCount;
  final double aspectRatio;
  final OptionGridDecorator? decorator;

  const OptionGridPicker({
    super.key,
    this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelectionChanged,
    this.crossAxisCount = 3,
    this.aspectRatio = 1.0,
    this.decorator,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDecorator = decorator ?? const OptionGridDecorator();

    // Validation for iconAlign
    if (effectiveDecorator.iconAlign != null) {
      for (final option in options) {
        if (option.visible && option.icon == null) {
          throw ArgumentError(
              'If iconAlign is provided, all visible options must have an icon');
        }
      }
    }

    final theme = Theme.of(context);

    // Filter visible options
    final visibleOptions = options.where((option) => option.visible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null && title!.isNotEmpty) ...[
          Text(
            title!,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: visibleOptions.length,
          itemBuilder: (context, index) {
            final option = visibleOptions[index];
            final isSelected = option.value == selectedValue;
            return _buildCellContent(context, option, isSelected);
          },
        ),
      ],
    );
  }

  Widget _buildCellContent(
      BuildContext context, OptionItem<T> option, bool isSelected) {
    final theme = Theme.of(context);
    final effectiveDecorator = decorator ?? const OptionGridDecorator();

    // Handle disabled state
    final effectiveEnabled = option.enabled;
    final opacity = effectiveEnabled ? 1.0 : 0.5;

    TextAlign getTextAlign() {
      switch (effectiveDecorator.labelAlign) {
        case LabelAlign.left:
          return TextAlign.left;
        case LabelAlign.center:
          return TextAlign.center;
        case LabelAlign.right:
          return TextAlign.right;
      }
    }

    final textWidget = Text(
      option.label,
      style: (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
        fontSize: effectiveDecorator.customTextSize,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
      ),
      textAlign: getTextAlign(),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    Widget cellContent;

    if (effectiveDecorator.iconAlign == null) {
      cellContent = Center(child: textWidget);
    } else {
      final iconWidget = option.icon;

      if (iconWidget == null) {
        cellContent = Center(child: textWidget);
      } else {
        switch (effectiveDecorator.iconAlign!) {
          case IconAlign.aboveTitle:
            cellContent = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconWidget,
                SizedBox(height: effectiveDecorator.iconSpacing),
                textWidget,
              ],
            );
            break;
          case IconAlign.belowTitle:
            cellContent = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textWidget,
                SizedBox(height: effectiveDecorator.iconSpacing),
                iconWidget,
              ],
            );
            break;
          case IconAlign.leftOfTitle:
            cellContent = effectiveDecorator.labelAlign == LabelAlign.center
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconWidget,
                      SizedBox(width: effectiveDecorator.iconSpacing),
                      Flexible(child: textWidget),
                    ],
                  )
                : Row(
                    children: [
                      iconWidget,
                      SizedBox(width: effectiveDecorator.iconSpacing),
                      Expanded(child: textWidget),
                    ],
                  );
            break;
          case IconAlign.rightOfTitle:
            cellContent = effectiveDecorator.labelAlign == LabelAlign.center
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: textWidget),
                      SizedBox(width: effectiveDecorator.iconSpacing),
                      iconWidget,
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: textWidget),
                      SizedBox(width: effectiveDecorator.iconSpacing),
                      iconWidget,
                    ],
                  );
            break;
        }
      }
    }

    return Opacity(
      opacity: opacity,
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveDecorator.borderRadius),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        color: option.backgroundColor ??
            (isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surface),
        child: InkWell(
          onTap:
              effectiveEnabled ? () => onSelectionChanged(option.value) : null,
          borderRadius: BorderRadius.circular(effectiveDecorator.borderRadius),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: cellContent,
          ),
        ),
      ),
    );
  }
}

class SortOptionSelector<T> extends StatelessWidget {
  final String title;
  final List<OptionItem<T>> options;
  final T selectedValue;
  final bool isAscending;
  final ValueChanged<T> onSelectionChanged;
  final VoidCallback onOrderToggle;
  final EdgeInsets? padding;

  const SortOptionSelector({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.isAscending,
    required this.onSelectionChanged,
    required this.onOrderToggle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              // Sort order toggle button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOrderToggle,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAscending ? 'A-Z' : 'Z-A',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = option.value == selectedValue;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelectionChanged(option.value),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        option.icon ?? const SizedBox.shrink(),
                        const SizedBox(width: 6),
                        Text(
                          option.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
