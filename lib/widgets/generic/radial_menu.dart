import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:p2lan/widgets/generic/virtual_joystick_detector.dart';

/// Generic data model for a radial menu item.
class RadialMenuItem<T> {
  final T value;
  final String label;
  final IconData icon;
  final Color? color;

  const RadialMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.color,
  });
}

/// A generic, theme-aware radial menu widget that manages its own overlay and gestures.
class RadialMenu<T> extends StatefulWidget {
  final List<RadialMenuItem<T>> items;
  final VoidCallback? onCancel;
  final Function(T? value)? onItemSelected;
  final double radius;
  final Offset initialPosition;

  const RadialMenu({
    super.key,
    required this.items,
    this.onCancel,
    this.onItemSelected,
    this.radius = 130.0,
    required this.initialPosition,
  });

  @override
  RadialMenuState<T> createState() => RadialMenuState<T>();
}

class RadialMenuState<T> extends State<RadialMenu<T>>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _pulseAnimation;

  final GlobalKey _menuKey = GlobalKey();
  Offset? _panStartPoint;

  RadialMenuItem<T>? _hoveredItem;
  bool _isDragging = false;

  void _resetDragState() {
    if (mounted) {
      setState(() {
        _isDragging = false;
        _panStartPoint = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Offset? _globalToLocal(Offset global) {
    if (_menuKey.currentContext == null) return null;
    final renderBox = _menuKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.globalToLocal(global);
  }

  RadialMenuItem<T>? _getItemAtPosition(Offset position,
      {bool checkOuterBounds = true}) {
    if (widget.items.isEmpty) return null;
    final center = Offset(widget.radius, widget.radius);
    final distance = (position - center).distance;

    if (distance < 50) {
      return null;
    }

    if (checkOuterBounds && distance > widget.radius - 10) {
      return null;
    }

    final angle = math.atan2(position.dy - center.dy, position.dx - center.dx);
    final normalizedAngle = (angle + math.pi * 2) % (math.pi * 2);
    final sectorAngle = (math.pi * 2) / widget.items.length;
    final adjustedAngle = (normalizedAngle + math.pi / 2) % (math.pi * 2);
    final sectorIndex = (adjustedAngle / sectorAngle).floor();

    if (sectorIndex >= 0 && sectorIndex < widget.items.length) {
      return widget.items[sectorIndex];
    }
    return null;
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _panStartPoint = details.globalPosition;
      _hoveredItem = null;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDragging || _panStartPoint == null) return;
    final panDelta = details.globalPosition - _panStartPoint!;
    final menuCenter = Offset(widget.radius, widget.radius);
    final virtualPosition = menuCenter + panDelta;
    setState(() {
      _hoveredItem =
          _getItemAtPosition(virtualPosition, checkOuterBounds: false);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    if (_hoveredItem != null) {
      widget.onItemSelected?.call(_hoveredItem!.value);
    } else {
      widget.onCancel?.call();
    }
    _resetDragState();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isDragging) return;
    final localPosition = _globalToLocal(details.globalPosition);
    if (localPosition == null) {
      widget.onCancel?.call();
      return;
    }
    final center = Offset(widget.radius, widget.radius);
    final distance = (localPosition - center).distance;
    if (distance > widget.radius) {
      widget.onCancel?.call();
      return;
    }
    final selectedItem = _getItemAtPosition(localPosition);
    if (selectedItem != null) {
      setState(() => _hoveredItem = selectedItem);
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) widget.onItemSelected?.call(selectedItem.value);
      });
    } else {
      widget.onCancel?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const screenPadding = 16.0;

    double left = (widget.initialPosition.dx - widget.radius).clamp(
        screenPadding, screenSize.width - widget.radius * 2 - screenPadding);
    double top = (widget.initialPosition.dy - widget.radius).clamp(
        screenPadding, screenSize.height - widget.radius * 2 - screenPadding);

    final menuWidget = Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: Listenable.merge([_animationController, _pulseController]),
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              key: _menuKey,
              width: widget.radius * 2,
              height: widget.radius * 2,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: CustomPaint(
                painter: _RadialMenuPainter<T>(
                  items: widget.items,
                  hoveredItem: _hoveredItem,
                  radius: widget.radius,
                  pulseScale: _pulseAnimation.value,
                  isDragging: _isDragging,
                  theme: Theme.of(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return VirtualJoystickDetector(
      onDragStart: _handlePanStart,
      onDragUpdate: _handlePanUpdate,
      onDragEnd: _handlePanEnd,
      onTap: _handleTapUp,
      showVisualJoystick: true, // Enable the visual joystick
      joystickMode: JoystickMode.dynamic, // Appear at tap/drag location
      child: Stack(
        children: [
          Container(color: Colors.black.withValues(alpha: 0.3)),
          menuWidget,
        ],
      ),
    );
  }
}

class _RadialMenuPainter<T> extends CustomPainter {
  final List<RadialMenuItem<T>> items;
  final RadialMenuItem<T>? hoveredItem;
  final double radius;
  final double pulseScale;
  final bool isDragging;
  final ThemeData theme;

  _RadialMenuPainter({
    required this.items,
    this.hoveredItem,
    required this.radius,
    required this.pulseScale,
    required this.isDragging,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final center = size.center(Offset.zero);
    final sectorAngle = (2 * math.pi) / items.length;
    final colorScheme = theme.colorScheme;

    // Draw sectors
    for (int i = 0; i < items.length; i++) {
      _drawSector(canvas, center, i, sectorAngle, colorScheme);
    }

    // Draw center circle
    _drawCenterCircle(canvas, center, colorScheme);

    // Draw icons and labels
    for (int i = 0; i < items.length; i++) {
      _drawMenuItem(canvas, center, i, sectorAngle, colorScheme);
    }
  }

  void _drawSector(Canvas canvas, Offset center, int i, double sectorAngle,
      ColorScheme colorScheme) {
    final item = items[i];
    final startAngle = i * sectorAngle - math.pi / 2;
    final isHovered = item == hoveredItem;
    final paint = Paint();

    // Use solid color, slightly brighter on hover.
    paint.style = PaintingStyle.fill;
    final baseColor = item.color ?? colorScheme.primary;
    paint.color =
        isHovered ? Color.lerp(baseColor, Colors.white, 0.2)! : baseColor;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        sectorAngle, true, paint);
  }

  void _drawCenterCircle(
      Canvas canvas, Offset center, ColorScheme colorScheme) {
    final paint = Paint();
    final centerRadius = 40.0; // Slightly smaller center
    paint.style = PaintingStyle.fill;
    // A dark color for the center, simulating the "hole"
    paint.color = const Color(0xFF303030);
    canvas.drawCircle(center, centerRadius, paint);

    paint.style = PaintingStyle.stroke;
    paint.color = Colors.black.withOpacity(0.5);
    paint.strokeWidth = 2.0;
    canvas.drawCircle(center, centerRadius, paint);
  }

  void _drawMenuItem(Canvas canvas, Offset center, int i, double sectorAngle,
      ColorScheme colorScheme) {
    final item = items[i];
    final isHovered = item == hoveredItem;
    final startAngle = i * sectorAngle - math.pi / 2;
    final iconAngle = startAngle + sectorAngle / 2;
    final iconRadius = radius * 0.65;
    final iconPosition = Offset(
      center.dx + math.cos(iconAngle) * iconRadius,
      center.dy + math.sin(iconAngle) * iconRadius,
    );

    // Use white color for icon and text to match the old UI.
    final Color iconColor = Colors.white;

    final iconPainter = TextPainter(
      text: TextSpan(
          text: String.fromCharCode(item.icon.codePoint),
          style: TextStyle(
              fontFamily: item.icon.fontFamily,
              package: item.icon.fontPackage,
              fontSize: 28.0,
              color: iconColor)),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(canvas,
        iconPosition - Offset(iconPainter.width / 2, iconPainter.height / 2));

    final labelPainter = TextPainter(
      text: TextSpan(
          text: item.label,
          style: TextStyle(
              color: iconColor,
              fontSize: 14.0,
              fontWeight: isHovered ? FontWeight.bold : FontWeight.normal)),
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(
        canvas,
        iconPosition +
            Offset(-labelPainter.width / 2, iconPainter.height / 2 + 2));
  }

  @override
  bool shouldRepaint(covariant _RadialMenuPainter<T> oldDelegate) {
    return oldDelegate.hoveredItem != hoveredItem ||
        oldDelegate.pulseScale != pulseScale ||
        oldDelegate.isDragging != isDragging;
  }
}
