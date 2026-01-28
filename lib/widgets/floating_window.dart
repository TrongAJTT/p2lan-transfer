import 'package:flutter/material.dart';

/// A draggable, resizable floating window widget
/// Can be used to display content in a window-like interface within the app
class FloatingWindow extends StatefulWidget {
  final String title;
  final Widget child;
  final VoidCallback? onClose;
  final double initialWidth;
  final double initialHeight;
  final Offset? initialPosition;
  final Color? headerColor;
  final bool showMinimize;
  final bool showMaximize;

  const FloatingWindow({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
    this.initialWidth = 800,
    this.initialHeight = 600,
    this.initialPosition,
    this.headerColor,
    this.showMinimize = true,
    this.showMaximize = true,
  });

  @override
  State<FloatingWindow> createState() => _FloatingWindowState();
}

class _FloatingWindowState extends State<FloatingWindow> {
  late Offset _position;
  late Size _size;
  bool _isMaximized = false;
  bool _isMinimized = false;
  Size? _preMaximizeSize;
  Offset? _preMaximizePosition;

  // Resize handle size
  static const double _resizeHandleSize = 8.0;
  static const double _headerHeight = 40.0;

  @override
  void initState() {
    super.initState();
    _size = Size(widget.initialWidth, widget.initialHeight);
    _position = widget.initialPosition ?? const Offset(100, 100);
  }

  void _startDrag(DragStartDetails details) {
    if (_isMaximized) return;
    // Store drag start position for future use if needed
  }

  void _updateDrag(DragUpdateDetails details) {
    if (_isMaximized) return;
    setState(() {
      _position = Offset(
        _position.dx + details.delta.dx,
        _position.dy + details.delta.dy,
      );
    });
  }

  void _endDrag(DragEndDetails details) {
    // Drag ended
  }

  void _toggleMaximize() {
    setState(() {
      if (_isMaximized) {
        // Restore
        _size =
            _preMaximizeSize ?? Size(widget.initialWidth, widget.initialHeight);
        _position = _preMaximizePosition ?? const Offset(100, 100);
        _isMaximized = false;
      } else {
        // Maximize
        _preMaximizeSize = _size;
        _preMaximizePosition = _position;
        _position = Offset.zero;
        // Get screen size from context
        final screenSize = MediaQuery.of(context).size;
        _size = screenSize;
        _isMaximized = true;
      }
    });
  }

  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
    });
  }

  void _startResize(DragStartDetails details, _ResizeDirection direction) {
    // Store initial size and position for resize
  }

  void _updateResize(DragUpdateDetails details, _ResizeDirection direction) {
    if (_isMaximized) return;

    setState(() {
      switch (direction) {
        case _ResizeDirection.topLeft:
          _position = Offset(
              _position.dx + details.delta.dx, _position.dy + details.delta.dy);
          _size = Size(
              _size.width - details.delta.dx, _size.height - details.delta.dy);
          break;
        case _ResizeDirection.top:
          _position = Offset(_position.dx, _position.dy + details.delta.dy);
          _size = Size(_size.width, _size.height - details.delta.dy);
          break;
        case _ResizeDirection.topRight:
          _position = Offset(_position.dx, _position.dy + details.delta.dy);
          _size = Size(
              _size.width + details.delta.dx, _size.height - details.delta.dy);
          break;
        case _ResizeDirection.right:
          _size = Size(_size.width + details.delta.dx, _size.height);
          break;
        case _ResizeDirection.bottomRight:
          _size = Size(
              _size.width + details.delta.dx, _size.height + details.delta.dy);
          break;
        case _ResizeDirection.bottom:
          _size = Size(_size.width, _size.height + details.delta.dy);
          break;
        case _ResizeDirection.bottomLeft:
          _position = Offset(_position.dx + details.delta.dx, _position.dy);
          _size = Size(
              _size.width - details.delta.dx, _size.height + details.delta.dy);
          break;
        case _ResizeDirection.left:
          _position = Offset(_position.dx + details.delta.dx, _position.dy);
          _size = Size(_size.width - details.delta.dx, _size.height);
          break;
      }

      // Enforce minimum size
      if (_size.width < 300) {
        _size = Size(300, _size.height);
      }
      if (_size.height < 200) {
        _size = Size(_size.width, 200);
      }
    });
  }

  Widget _buildResizeHandle(_ResizeDirection direction) {
    MouseCursor cursor;
    switch (direction) {
      case _ResizeDirection.topLeft:
      case _ResizeDirection.bottomRight:
        cursor = SystemMouseCursors.resizeUpLeftDownRight;
        break;
      case _ResizeDirection.topRight:
      case _ResizeDirection.bottomLeft:
        cursor = SystemMouseCursors.resizeUpRightDownLeft;
        break;
      case _ResizeDirection.top:
      case _ResizeDirection.bottom:
        cursor = SystemMouseCursors.resizeUpDown;
        break;
      case _ResizeDirection.left:
      case _ResizeDirection.right:
        cursor = SystemMouseCursors.resizeLeftRight;
        break;
    }

    return Positioned(
      top: direction == _ResizeDirection.top ||
              direction == _ResizeDirection.topLeft ||
              direction == _ResizeDirection.topRight
          ? 0
          : direction == _ResizeDirection.bottom ||
                  direction == _ResizeDirection.bottomLeft ||
                  direction == _ResizeDirection.bottomRight
              ? null
              : _resizeHandleSize,
      bottom: direction == _ResizeDirection.bottom ||
              direction == _ResizeDirection.bottomLeft ||
              direction == _ResizeDirection.bottomRight
          ? 0
          : direction == _ResizeDirection.top ||
                  direction == _ResizeDirection.topLeft ||
                  direction == _ResizeDirection.topRight
              ? null
              : _resizeHandleSize,
      left: direction == _ResizeDirection.left ||
              direction == _ResizeDirection.topLeft ||
              direction == _ResizeDirection.bottomLeft
          ? 0
          : direction == _ResizeDirection.right ||
                  direction == _ResizeDirection.topRight ||
                  direction == _ResizeDirection.bottomRight
              ? null
              : _resizeHandleSize,
      right: direction == _ResizeDirection.right ||
              direction == _ResizeDirection.topRight ||
              direction == _ResizeDirection.bottomRight
          ? 0
          : direction == _ResizeDirection.left ||
                  direction == _ResizeDirection.topLeft ||
                  direction == _ResizeDirection.bottomLeft
              ? null
              : _resizeHandleSize,
      child: GestureDetector(
        onPanStart: (details) => _startResize(details, direction),
        onPanUpdate: (details) => _updateResize(details, direction),
        child: MouseRegion(
          cursor: cursor,
          child: Container(
            width: direction == _ResizeDirection.left ||
                    direction == _ResizeDirection.right
                ? _resizeHandleSize
                : null,
            height: direction == _ResizeDirection.top ||
                    direction == _ResizeDirection.bottom
                ? _resizeHandleSize
                : null,
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isMinimized) {
      // Show minimized bar at bottom
      return Positioned(
        left: _position.dx,
        bottom: 0,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 200,
            height: 40,
            decoration: BoxDecoration(
              color: widget.headerColor ?? Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_full,
                      color: Colors.white, size: 16),
                  onPressed: _toggleMinimize,
                  tooltip: 'Restore',
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Material(
        elevation: 16,
        borderRadius: BorderRadius.circular(_isMaximized ? 0 : 8),
        child: Container(
          width: _size.width,
          height: _size.height,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(_isMaximized ? 0 : 8),
            border: _isMaximized
                ? null
                : Border.all(
                    color: Colors.grey.shade700,
                    width: 1,
                  ),
          ),
          child: Stack(
            children: [
              // Content
              Column(
                children: [
                  // Header
                  GestureDetector(
                    onPanStart: _startDrag,
                    onPanUpdate: _updateDrag,
                    onPanEnd: _endDrag,
                    onDoubleTap: widget.showMaximize ? _toggleMaximize : null,
                    child: Container(
                      height: _headerHeight,
                      decoration: BoxDecoration(
                        color: widget.headerColor ??
                            Theme.of(context).primaryColor,
                        borderRadius: _isMaximized
                            ? null
                            : const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.move,
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (widget.showMinimize)
                            IconButton(
                              icon: const Icon(Icons.minimize,
                                  color: Colors.white, size: 20),
                              onPressed: _toggleMinimize,
                              tooltip: 'Minimize',
                              padding: EdgeInsets.zero,
                            ),
                          if (widget.showMaximize)
                            IconButton(
                              icon: Icon(
                                _isMaximized
                                    ? Icons.close_fullscreen
                                    : Icons.open_in_full,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _toggleMaximize,
                              tooltip: _isMaximized ? 'Restore' : 'Maximize',
                              padding: EdgeInsets.zero,
                            ),
                          if (widget.onClose != null)
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 20),
                              onPressed: widget.onClose,
                              tooltip: 'Close',
                              padding: EdgeInsets.zero,
                            ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  // Body
                  Expanded(
                    child: widget.child,
                  ),
                ],
              ),
              // Resize handles (only if not maximized)
              if (!_isMaximized) ...[
                _buildResizeHandle(_ResizeDirection.topLeft),
                _buildResizeHandle(_ResizeDirection.top),
                _buildResizeHandle(_ResizeDirection.topRight),
                _buildResizeHandle(_ResizeDirection.right),
                _buildResizeHandle(_ResizeDirection.bottomRight),
                _buildResizeHandle(_ResizeDirection.bottom),
                _buildResizeHandle(_ResizeDirection.bottomLeft),
                _buildResizeHandle(_ResizeDirection.left),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _ResizeDirection {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
}
