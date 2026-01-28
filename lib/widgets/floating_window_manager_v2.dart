import 'package:flutter/material.dart';
import 'package:p2lan/widgets/floating_window.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/screens/p2lan_transfer/screen_sharing_viewer_screen.dart';
import 'package:p2lan/services/app_logger.dart';

/// Manager for multiple floating screen sharing windows using Overlay
/// This version uses global Overlay which provides better isolation
class FloatingWindowManagerV2 extends StatefulWidget {
  final Widget child;

  const FloatingWindowManagerV2({
    super.key,
    required this.child,
  });

  static FloatingWindowManagerV2State? of(BuildContext context) {
    return context.findAncestorStateOfType<FloatingWindowManagerV2State>();
  }

  @override
  State<FloatingWindowManagerV2> createState() =>
      FloatingWindowManagerV2State();
}

class FloatingWindowManagerV2State extends State<FloatingWindowManagerV2> {
  final Map<String, _FloatingWindowEntry> _windows = {};
  int _nextZIndex = 1;

  @override
  void dispose() {
    // Remove all overlay entries when manager is disposed
    for (final window in _windows.values) {
      window.overlayEntry.remove();
    }
    _windows.clear();
    super.dispose();
  }

  /// Opens a new floating window for screen sharing
  void openScreenSharingWindow(ScreenSharingSession session) {
    logInfo(
        'FloatingWindowManagerV2: Opening window for ${session.senderUser.displayName}');

    // Check if window already exists for this session
    if (_windows.containsKey(session.sessionId)) {
      logWarning(
          'FloatingWindowManagerV2: Window already exists for session ${session.sessionId}');
      // Bring to front
      bringToFront(session.sessionId);
      return;
    }

    // Calculate initial position (cascade windows)
    final offset = _windows.length * 40.0;
    final initialPosition = Offset(100 + offset, 100 + offset);

    // Create overlay entry
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => FloatingWindow(
        key: ValueKey(session.sessionId),
        title: 'Screen Sharing - ${session.senderUser.displayName}',
        initialWidth: 800,
        initialHeight: 600,
        initialPosition: initialPosition,
        headerColor: Colors.blue.shade700,
        onClose: () => closeWindow(session.sessionId),
        child: GestureDetector(
          onTap: () => bringToFront(session.sessionId),
          child: ScreenSharingViewerScreen(
            session: session,
            isFloatingWindow: true,
          ),
        ),
      ),
    );

    // Insert overlay entry
    Overlay.of(context).insert(overlayEntry);

    _windows[session.sessionId] = _FloatingWindowEntry(
      session: session,
      overlayEntry: overlayEntry,
      zIndex: _nextZIndex++,
    );

    logInfo(
        'FloatingWindowManagerV2: Window opened, total windows: ${_windows.length}');
  }

  /// Closes a floating window
  void closeWindow(String sessionId) {
    logInfo('FloatingWindowManagerV2: Closing window for session $sessionId');

    final window = _windows[sessionId];
    if (window != null) {
      window.overlayEntry.remove();
      _windows.remove(sessionId);
      logInfo(
          'FloatingWindowManagerV2: Window closed, remaining windows: ${_windows.length}');
    }
  }

  /// Brings a window to front
  void bringToFront(String sessionId) {
    final window = _windows[sessionId];
    if (window != null) {
      // To bring to front, we need to remove and re-insert
      window.overlayEntry.remove();
      Overlay.of(context).insert(window.overlayEntry);
      window.zIndex = _nextZIndex++;
      logInfo('FloatingWindowManagerV2: Brought window $sessionId to front');
    }
  }

  /// Closes all windows
  void closeAllWindows() {
    logInfo('FloatingWindowManagerV2: Closing all ${_windows.length} windows');
    for (final window in _windows.values) {
      window.overlayEntry.remove();
    }
    _windows.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Just render the child, floating windows are in overlay
    return widget.child;
  }
}

class _FloatingWindowEntry {
  final ScreenSharingSession session;
  final OverlayEntry overlayEntry;
  int zIndex;

  _FloatingWindowEntry({
    required this.session,
    required this.overlayEntry,
    required this.zIndex,
  });
}
