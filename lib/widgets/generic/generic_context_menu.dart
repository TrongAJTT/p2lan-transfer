import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p2lan/variables.dart';

class OptionItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  OptionItem({required this.label, this.icon, this.onTap});
}

class GenericContextMenu {
  static void show({
    required BuildContext context,
    required List<OptionItem> actions,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
    Function? onInit,
    Function? onDispose,
    Widget? topWidget,
    Widget? bottomWidget,
    Offset? position,
    double desktopDialogWidth = 340,
    bool enableKeyboardNavigation = true, // New parameter
  }) {
    if (onInit != null) {
      onInit();
    }

    final screenSize = MediaQuery.of(context).size;

    if (screenSize.width > desktopScreenWidthThreshold) {
      // Process desktop positioning
      // Desktop context menu with keyboard navigation
      _showDesktopContextMenu(
        context: context,
        actions: actions,
        position: position,
        screenSize: screenSize,
        desktopDialogWidth: desktopDialogWidth,
        enableKeyboardNavigation: enableKeyboardNavigation,
        onDispose: onDispose,
        topWidget: topWidget,
        bottomWidget: bottomWidget,
        padding: padding,
      );
    } else {
      // Mobile bottom sheet
      _showMobileBottomSheet(
        context: context,
        actions: actions,
        padding: padding,
        topWidget: topWidget,
        bottomWidget: bottomWidget,
        onDispose: onDispose,
      );
    }
  }

  static void _showDesktopContextMenu({
    required BuildContext context,
    required List<OptionItem> actions,
    required Size screenSize,
    required double desktopDialogWidth,
    required bool enableKeyboardNavigation,
    Offset? position,
    Function? onDispose,
    Widget? topWidget,
    Widget? bottomWidget,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
  }) {
    Offset mousePosition = position ??
        Offset((screenSize.width - desktopDialogWidth) / 2,
            screenSize.height * 0.4);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        return _DesktopContextMenuWidget(
          actions: actions,
          mousePosition: mousePosition,
          enableKeyboardNavigation: enableKeyboardNavigation,
          topWidget: topWidget,
          bottomWidget: bottomWidget,
          desktopDialogWidth: desktopDialogWidth,
          padding: padding,
        );
      },
    ).then((_) {
      if (onDispose != null) {
        onDispose();
      }
    });
  }

  static void _showMobileBottomSheet({
    required BuildContext context,
    required List<OptionItem> actions,
    required EdgeInsetsGeometry padding,
    Widget? topWidget,
    Widget? bottomWidget,
    Function? onDispose,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (topWidget != null) topWidget,
              ...actions.map((action) => ListTile(
                    leading: action.icon != null ? Icon(action.icon) : null,
                    title: Text(action.label),
                    onTap: () {
                      Navigator.of(context).pop();
                      action.onTap?.call();
                    },
                  )),
              if (bottomWidget != null) bottomWidget,
            ],
          ),
        );
      },
    ).then((_) {
      if (onDispose != null) {
        onDispose();
      }
    });
  }
}

class _DesktopContextMenuWidget extends StatefulWidget {
  final List<OptionItem> actions;
  final Offset mousePosition;
  final bool enableKeyboardNavigation;
  final Widget? topWidget;
  final Widget? bottomWidget;
  final double desktopDialogWidth;
  final EdgeInsetsGeometry padding;

  const _DesktopContextMenuWidget({
    required this.actions,
    required this.mousePosition,
    required this.enableKeyboardNavigation,
    this.topWidget,
    this.bottomWidget,
    this.desktopDialogWidth = 400,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  State<_DesktopContextMenuWidget> createState() =>
      _DesktopContextMenuWidgetState();
}

class _DesktopContextMenuWidgetState extends State<_DesktopContextMenuWidget> {
  final GlobalKey _containerKey = GlobalKey();
  double? _adjustedLeft;
  double? _adjustedTop;
  int _highlightedIndex = 0;
  bool _isUsingKeyboard = false;
  late FocusNode _focusNode;

  static const double _adjustSize = 24.0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Auto focus for keyboard navigation
    if (widget.enableKeyboardNavigation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
          _adjustPositionIfNeeded();
        }
      });
    }
  }

  void _adjustPositionIfNeeded() {
    final screenSize = MediaQuery.of(context).size;
    final RenderBox? box =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final dialogSize = box.size;
      double left = widget.mousePosition.dx;
      double top = widget.mousePosition.dy;
      // Nếu tràn phải
      if (left + dialogSize.width > screenSize.width) {
        left = screenSize.width - dialogSize.width - _adjustSize;
      }
      // Nếu tràn dưới
      if (top + dialogSize.height > screenSize.height) {
        top = screenSize.height - dialogSize.height - _adjustSize;
      }
      // Không âm
      left = left < _adjustSize ? _adjustSize : left;
      top = top < _adjustSize ? _adjustSize : top;
      setState(() {
        _adjustedLeft = left;
        _adjustedTop = top;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (!widget.enableKeyboardNavigation) return;

    if (event is KeyDownEvent) {
      _isUsingKeyboard = true;

      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          _navigateNext();
          break;
        case LogicalKeyboardKey.arrowUp:
          _navigatePrevious();
          break;
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.arrowRight:
          // Optional: Handle left/right navigation if needed
          break;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.space:
          _selectCurrentItem();
          break;
        case LogicalKeyboardKey.escape:
          Navigator.of(context).pop();
          break;
      }
    }
  }

  void _navigateNext() {
    setState(() {
      _highlightedIndex = (_highlightedIndex + 1) % widget.actions.length;
    });
  }

  void _navigatePrevious() {
    setState(() {
      _highlightedIndex = (_highlightedIndex - 1 + widget.actions.length) %
          widget.actions.length;
    });
  }

  void _selectCurrentItem() {
    final action = widget.actions[_highlightedIndex];
    Navigator.of(context).pop();
    action.onTap?.call();
  }

  void _onMouseEnter(int index) {
    if (!_isUsingKeyboard) {
      setState(() {
        _highlightedIndex = index;
      });
    }
  }

  void _onMouseMove() {
    _isUsingKeyboard = false;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => _onMouseMove(),
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          _handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: Listener(
          onPointerDown: (event) {
            // Update mouse position if needed
          },
          child: Stack(
            children: [
              // Invisible barrier to close menu when clicking outside
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(color: Colors.transparent),
                ),
              ),

              // Context menu
              Positioned(
                left: _adjustedLeft ?? widget.mousePosition.dx,
                top: _adjustedTop ?? widget.mousePosition.dy,
                child: Material(
                  elevation: 8,
                  color: Colors.transparent,
                  child: Padding(
                    padding: widget.padding,
                    child: Container(
                      key: _containerKey,
                      width: widget.desktopDialogWidth,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.topWidget != null) widget.topWidget!,
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: widget.actions.length,
                              itemBuilder: (ctx, index) {
                                final action = widget.actions[index];
                                final isHighlighted =
                                    _highlightedIndex == index;

                                return MouseRegion(
                                  onEnter: (_) => _onMouseEnter(index),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      action.onTap?.call();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isHighlighted
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.18)
                                            : Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(
                                              index == 0 ? 8 : 0),
                                          bottom: Radius.circular(
                                              index == widget.actions.length - 1
                                                  ? 8
                                                  : 0),
                                        ),
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        leading: action.icon != null
                                            ? Icon(
                                                action.icon,
                                                color: isHighlighted
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                              )
                                            : null,
                                        title: Text(
                                          action.label,
                                          style: TextStyle(
                                            color: isHighlighted
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                            // fontWeight: isHighlighted
                                            //     ? FontWeight.w600
                                            //     : FontWeight.normal,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (widget.bottomWidget != null) widget.bottomWidget!,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
