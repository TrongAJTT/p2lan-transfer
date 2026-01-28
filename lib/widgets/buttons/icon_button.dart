import 'package:flutter/material.dart';

class IconButtonX extends StatelessWidget {
  const IconButtonX({
    super.key,
    required this.icon,
    required this.text,
    this.padding = const EdgeInsets.all(8),
    this.spacing = 8,
    this.backColor,
    this.foreColor,
    this.onTap,
    this.onLongPressStart,
    this.onSecondaryTap,
  });

  final Widget icon;
  final EdgeInsets padding;
  final String text;
  final double spacing;
  final Color? backColor;
  final Color? foreColor;
  final VoidCallback? onTap;
  final GestureLongPressStartCallback? onLongPressStart;
  final GestureTapDownCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      onSecondaryTapDown: onSecondaryTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: backColor ?? Theme.of(context).colorScheme.primary,
        ),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(width: spacing),
              Text(
                text,
                style: TextStyle(
                  color: foreColor ?? Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
