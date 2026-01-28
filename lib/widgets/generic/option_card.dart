import 'package:flutter/material.dart';
import 'package:p2lan/utils/icon_utils.dart';
import 'package:p2lan/widgets/generic/option_item.dart';

class CardDecorator {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final GenericIcon? primaryTrailingIcon;
  final GenericIcon? secondaryTrailingIcon;

  const CardDecorator({
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.primaryTrailingIcon,
    this.secondaryTrailingIcon,
  });
}

class OptionCard extends StatelessWidget {
  final OptionItem option;
  final VoidCallback? onTap;
  final CardDecorator? decorator;

  const OptionCard({
    super.key,
    required this.option,
    this.onTap,
    this.decorator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = option.enabled && onTap != null;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: decorator?.padding ??
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: decorator?.borderColor ??
                  theme.colorScheme.outline.withValues(alpha: 0.2),
              width: decorator?.borderWidth ?? 0.5,
            ),
            borderRadius: decorator?.borderRadius ?? BorderRadius.circular(8),
            color: decorator?.backgroundColor ??
                theme.colorScheme.surfaceContainerLow,
          ),
          child: Row(
            children: [
              if (option.icon != null) ...[
                option.icon!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isEnabled ? null : theme.disabledColor,
                      ),
                    ),
                    if (option.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        option.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isEnabled
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.disabledColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Display primary trailing icon if not null
              if (decorator?.primaryTrailingIcon != null) ...[
                decorator!.primaryTrailingIcon!,
              ],
              // Display defailt trailing icon
              if (decorator?.primaryTrailingIcon == null) ...[
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandableOptionCard extends StatefulWidget {
  final OptionItem option;
  final Widget child;
  final CardDecorator? decorator;
  final bool initialExpanded;
  final Function(bool)? onExpansionChanged;

  const ExpandableOptionCard({
    super.key,
    required this.option,
    required this.child,
    this.decorator,
    this.initialExpanded = false,
    this.onExpansionChanged,
  });

  @override
  State<ExpandableOptionCard> createState() => _ExpandableOptionCardState();
}

class _ExpandableOptionCardState extends State<ExpandableOptionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decorator = widget.decorator ?? const CardDecorator();
    final isEnabled = widget.option.enabled;

    final GenericIcon? trailingIcon;
    if (_isExpanded) {
      // Icon for expanded state
      trailingIcon = decorator.secondaryTrailingIcon ??
          GenericIcon.icon(Icons.expand_less);
    } else {
      // Icon for collapsed state
      trailingIcon =
          decorator.primaryTrailingIcon ?? GenericIcon.icon(Icons.expand_more);
    }

    final header = OptionCard(
      option: widget.option,
      onTap: _toggleExpansion,
      decorator: decorator.copyWith(
        primaryTrailingIcon: trailingIcon,
        backgroundColor: _isExpanded
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
            : decorator.backgroundColor,
      ),
    );

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Column(
        children: [
          header,
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: decorator.borderColor ??
                      theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: decorator.borderWidth ?? 0.5,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                color: decorator.backgroundColor ?? theme.colorScheme.surface,
              ),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

extension on CardDecorator {
  CardDecorator copyWith({
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    GenericIcon? primaryTrailingIcon,
    GenericIcon? secondaryTrailingIcon,
  }) {
    return CardDecorator(
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      primaryTrailingIcon: primaryTrailingIcon ?? this.primaryTrailingIcon,
      secondaryTrailingIcon:
          secondaryTrailingIcon ?? this.secondaryTrailingIcon,
    );
  }
}
