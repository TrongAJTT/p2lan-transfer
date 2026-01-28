import 'package:flutter/material.dart';
import 'package:p2lan/widgets/floating_window.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/screens/p2lan_transfer/screen_sharing_viewer_screen.dart';
import 'package:p2lan/services/app_logger.dart';

/// Manager for multiple floating screen sharing windows
/// Allows displaying multiple screen sharing sessions simultaneously
class FloatingWindowManager extends StatefulWidget {
  final Widget child;

  const FloatingWindowManager({
    super.key,
    required this.child,
  });

  static FloatingWindowManagerState? of(BuildContext context) {
    return context.findAncestorStateOfType<FloatingWindowManagerState>();
  }

  @override
  State<FloatingWindowManager> createState() => FloatingWindowManagerState();
}

class FloatingWindowManagerState extends State<FloatingWindowManager> {
  final List<_FloatingWindowData> _windows = [];
  int _nextZIndex = 1;

  /// Opens a new floating window for screen sharing
  void openScreenSharingWindow(ScreenSharingSession session) {
    logInfo(
        'FloatingWindowManager: Opening window for ${session.senderUser.displayName}');

    // Check if window already exists for this session
    final existingIndex =
        _windows.indexWhere((w) => w.sessionId == session.sessionId);
    if (existingIndex != -1) {
      logWarning(
          'FloatingWindowManager: Window already exists for session ${session.sessionId}');
      // Bring to front
      setState(() {
        _windows[existingIndex].zIndex = _nextZIndex++;
      });
      return;
    }

    // Calculate initial position (cascade windows)
    final offset = _windows.length * 40.0;
    final initialPosition = Offset(100 + offset, 100 + offset);

    setState(() {
      _windows.add(_FloatingWindowData(
        sessionId: session.sessionId,
        session: session,
        zIndex: _nextZIndex++,
        initialPosition: initialPosition,
      ));
    });

    logInfo(
        'FloatingWindowManager: Window opened, total windows: ${_windows.length}');
  }

  /// Closes a floating window
  void closeWindow(String sessionId) {
    logInfo('FloatingWindowManager: Closing window for session $sessionId');
    setState(() {
      _windows.removeWhere((w) => w.sessionId == sessionId);
    });
    logInfo(
        'FloatingWindowManager: Window closed, remaining windows: ${_windows.length}');
  }

  /// Brings a window to front
  void bringToFront(String sessionId) {
    final index = _windows.indexWhere((w) => w.sessionId == sessionId);
    if (index != -1) {
      setState(() {
        _windows[index].zIndex = _nextZIndex++;
      });
    }
  }

  /// Closes all windows
  void closeAllWindows() {
    logInfo('FloatingWindowManager: Closing all ${_windows.length} windows');
    setState(() {
      _windows.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        widget.child,
        // Floating windows
        ..._windows.map((windowData) {
          return Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: Stack(
                children: [
                  FloatingWindow(
                    key: ValueKey(windowData.sessionId),
                    title:
                        'Screen Sharing - ${windowData.session.senderUser.displayName}',
                    initialWidth: 800,
                    initialHeight: 600,
                    initialPosition: windowData.initialPosition,
                    headerColor: Colors.blue.shade700,
                    onClose: () => closeWindow(windowData.sessionId),
                    child: GestureDetector(
                      onTap: () => bringToFront(windowData.sessionId),
                      child: ScreenSharingViewerScreen(
                        session: windowData.session,
                        isFloatingWindow: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _FloatingWindowData {
  final String sessionId;
  final ScreenSharingSession session;
  int zIndex;
  final Offset initialPosition;

  _FloatingWindowData({
    required this.sessionId,
    required this.session,
    required this.zIndex,
    required this.initialPosition,
  });
}
