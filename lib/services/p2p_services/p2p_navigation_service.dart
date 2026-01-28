import 'package:flutter/material.dart';
import 'package:p2lan/services/app_logger.dart';

/// P2P Navigation destination
enum P2PNavigationTarget {
  p2lanMain('p2lan_main', 0),
  p2lanTransfers('p2lan_transfers', 1);

  const P2PNavigationTarget(this.id, this.tabIndex);
  final String id;
  final int tabIndex;
}

/// Service to handle P2P-related navigation across the app
class P2PNavigationService {
  static P2PNavigationService? _instance;
  static P2PNavigationService get instance =>
      _instance ??= P2PNavigationService._();

  P2PNavigationService._();

  /// Current navigation context (set by main app)
  BuildContext? _context;

  /// Callbacks for P2LAN screen interactions
  Function(int)? _switchTabCallback;
  Function(String, Map<String, dynamic>)? _showDialogCallback;
  int Function()? _getCurrentTabCallback;

  /// Set the current navigation context
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Set P2LAN screen callbacks
  void setP2LanCallbacks({
    Function(int)? switchTabCallback,
    Function(String, Map<String, dynamic>)? showDialogCallback,
    int Function()? getCurrentTabCallback,
  }) {
    _switchTabCallback = switchTabCallback;
    _showDialogCallback = showDialogCallback;
    _getCurrentTabCallback = getCurrentTabCallback;
  }

  /// Clear P2LAN screen callbacks
  void clearP2LanCallbacks() {
    _switchTabCallback = null;
    _showDialogCallback = null;
    _getCurrentTabCallback = null;
  }

  /// Navigate to P2LAN Transfer screen
  Future<bool> navigateToP2Lan({
    P2PNavigationTarget target = P2PNavigationTarget.p2lanMain,
    Map<String, dynamic>? arguments,
  }) async {
    if (_context == null) {
      logError('P2P Navigation: No context available');
      return false;
    }

    try {
      // Check if we're already on P2LAN Transfer screen
      final currentRoute = ModalRoute.of(_context!)?.settings.name;
      if (currentRoute == '/p2lan_transfer') {
        // We're already on the screen, just switch tabs
        return _switchToTab(target.tabIndex);
      }

      // Navigate to P2LAN Transfer screen
      final result = await Navigator.pushNamed(
        _context!,
        '/p2lan_transfer',
        arguments: {
          'initialTab': target.tabIndex,
          ...?arguments,
        },
      );

      logInfo(
          'P2P Navigation: Navigated to P2LAN Transfer (tab: ${target.tabIndex})');
      return result != null;
    } catch (e) {
      logError('P2P Navigation: Failed to navigate to P2LAN: $e');
      return false;
    }
  }

  /// Switch to specific tab within P2LAN Transfer screen
  bool _switchToTab(int tabIndex) {
    try {
      if (_switchTabCallback != null) {
        _switchTabCallback!(tabIndex);
        logInfo('P2P Navigation: Switched to tab $tabIndex');
        return true;
      }

      logWarning(
          'P2P Navigation: P2LAN screen callback not available for tab switch');
      return false;
    } catch (e) {
      logError('P2P Navigation: Failed to switch tab: $e');
      return false;
    }
  }

  /// Navigate to P2LAN and show specific dialog
  Future<bool> navigateToP2LanWithDialog({
    required String dialogType,
    required Map<String, dynamic> dialogData,
    P2PNavigationTarget target = P2PNavigationTarget.p2lanMain,
  }) async {
    final navigated = await navigateToP2Lan(
      target: target,
      arguments: {
        'showDialog': dialogType,
        'dialogData': dialogData,
      },
    );

    if (navigated) {
      // Post-frame callback to show dialog after navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDialogAfterNavigation(dialogType, dialogData);
      });
    }

    return navigated;
  }

  /// Show dialog after navigation completes
  void _showDialogAfterNavigation(
      String dialogType, Map<String, dynamic> dialogData) {
    try {
      if (_showDialogCallback != null) {
        _showDialogCallback!(dialogType, dialogData);
        logInfo('P2P Navigation: Showed dialog $dialogType after navigation');
      }
    } catch (e) {
      logError('P2P Navigation: Failed to show dialog after navigation: $e');
    }
  }

  /// Navigate back from P2LAN if possible
  bool navigateBack() {
    if (_context == null) return false;

    try {
      Navigator.pop(_context!);
      return true;
    } catch (e) {
      logError('P2P Navigation: Failed to navigate back: $e');
      return false;
    }
  }

  /// Check if we're currently on P2LAN Transfer screen
  bool get isOnP2LanScreen {
    if (_context == null) return false;
    final currentRoute = ModalRoute.of(_context!)?.settings.name;
    return currentRoute == '/p2lan_transfer';
  }

  /// Get current tab index if on P2LAN screen
  int? get currentP2LanTab {
    try {
      return _getCurrentTabCallback?.call();
    } catch (e) {
      return null;
    }
  }
}
