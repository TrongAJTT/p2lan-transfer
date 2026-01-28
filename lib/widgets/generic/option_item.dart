import 'package:flutter/material.dart';
import 'package:p2lan/utils/icon_utils.dart';

/// Generic option item for all option-based widgets
class OptionItem<T> {
  /// The value associated with this option
  final T value;

  /// The display label for this option
  final String label;

  /// Optional subtitle/description for this option
  final String? subtitle;

  /// Optional icon for this option
  final GenericIcon? icon;

  /// Optional background color for this option
  final Color? backgroundColor;

  /// Whether this option is enabled (default: true)
  /// When false, the option will be dimmed and non-interactive
  final bool enabled;

  /// Whether this option is visible (default: true)
  /// When false, the option will be completely hidden
  final bool visible;

  const OptionItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.backgroundColor,
    this.enabled = true,
    this.visible = true,
  });

  /// Helper constructor for creating options with Material icons
  factory OptionItem.withIcon({
    required T value,
    required String label,
    String? subtitle,
    required IconData iconData,
    Color? iconColor,
    double iconSize = 20,
    Color? backgroundColor,
    bool enabled = true,
    bool visible = true,
  }) {
    return OptionItem(
      value: value,
      label: label,
      subtitle: subtitle,
      icon: GenericIcon.icon(iconData, size: iconSize, color: iconColor),
      backgroundColor: backgroundColor,
      enabled: enabled,
      visible: visible,
    );
  }

  /// Helper constructor for creating options with emoji icons
  factory OptionItem.withEmoji({
    required T value,
    required String label,
    String? subtitle,
    required String emoji,
    Color? emojiColor,
    double emojiSize = 20,
    Color? backgroundColor,
    bool enabled = true,
    bool visible = true,
  }) {
    return OptionItem(
      value: value,
      label: label,
      subtitle: subtitle,
      icon: GenericIcon.emoji(emoji, size: emojiSize, color: emojiColor),
      backgroundColor: backgroundColor,
      enabled: enabled,
      visible: visible,
    );
  }

  /// Helper constructor for creating options without icons
  factory OptionItem.textOnly({
    required T value,
    required String label,
    String? subtitle,
    Color? backgroundColor,
    bool enabled = true,
    bool visible = true,
  }) {
    return OptionItem(
      value: value,
      label: label,
      subtitle: subtitle,
      backgroundColor: backgroundColor,
      enabled: enabled,
      visible: visible,
    );
  }

  /// Create a copy of this option with some properties changed
  OptionItem<T> copyWith({
    T? value,
    String? label,
    String? subtitle,
    GenericIcon? icon,
    Color? backgroundColor,
    bool? enabled,
    bool? visible,
  }) {
    return OptionItem<T>(
      value: value ?? this.value,
      label: label ?? this.label,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      enabled: enabled ?? this.enabled,
      visible: visible ?? this.visible,
    );
  }
}
