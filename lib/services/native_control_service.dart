import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:win32/win32.dart';

/// Service to handle native system control (mouse, keyboard, etc.)
class NativeControlService {
  /// Move mouse cursor by relative amount
  static void moveMouse(double deltaX, double deltaY) {
    if (!Platform.isWindows) return;

    try {
      // Scale the delta movement for better sensitivity
      // Get virtual desktop size (all monitors combined)
      final virtualDesktop = getVirtualDesktopSize();
      final scaledDeltaX = (deltaX * virtualDesktop.width * 0.3)
          .round(); // 30% sensitivity horizontal
      final scaledDeltaY = (deltaY * virtualDesktop.height * 0.8)
          .round(); // 40% sensitivity vertical

      // Get current cursor position
      final point = calloc<POINT>();
      GetCursorPos(point);

      // Calculate new position without clamping to allow multi-monitor movement
      final newX = point.ref.x + scaledDeltaX;
      final newY = point.ref.y + scaledDeltaY;

      // Only clamp to virtual desktop bounds (all monitors)
      final clampedX = newX.clamp(
          virtualDesktop.left, virtualDesktop.left + virtualDesktop.width - 1);
      final clampedY = newY.clamp(
          virtualDesktop.top, virtualDesktop.top + virtualDesktop.height - 1);

      // Set new cursor position
      SetCursorPos(clampedX, clampedY);

      calloc.free(point);
    } catch (e) {
      logError('Error moving mouse: $e');
    }
  }

  /// Perform mouse scroll
  static void scrollMouse(double deltaX, double deltaY) {
    if (!Platform.isWindows) return;

    try {
      // Windows scroll wheel delta (120 = one wheel click)
      final wheelDelta = (deltaY * 120).round();

      // Use SendInput for more reliable input
      final input = calloc<INPUT>();
      input.ref.type = INPUT_MOUSE;
      input.ref.mi.dwFlags = MOUSEEVENTF_WHEEL;
      input.ref.mi.mouseData = wheelDelta;

      SendInput(1, input, sizeOf<INPUT>());
      calloc.free(input);
    } catch (e) {
      logError('Error scrolling mouse: $e');
    }
  }

  /// Perform mouse click
  static void clickMouse(
      {bool isLeft = true, bool isDown = true, bool isMiddle = false}) {
    if (!Platform.isWindows) return;

    try {
      final input = calloc<INPUT>();
      input.ref.type = INPUT_MOUSE;

      if (isMiddle) {
        input.ref.mi.dwFlags =
            isDown ? MOUSEEVENTF_MIDDLEDOWN : MOUSEEVENTF_MIDDLEUP;
      } else if (isLeft) {
        input.ref.mi.dwFlags =
            isDown ? MOUSEEVENTF_LEFTDOWN : MOUSEEVENTF_LEFTUP;
      } else {
        input.ref.mi.dwFlags =
            isDown ? MOUSEEVENTF_RIGHTDOWN : MOUSEEVENTF_RIGHTUP;
      }

      SendInput(1, input, sizeOf<INPUT>());
      calloc.free(input);
    } catch (e) {
      logError('Error clicking mouse: $e');
    }
  }

  /// Perform mouse long click (press and hold for a duration)
  static Future<void> longClickMouse(
      {bool isLeft = true, bool isMiddle = false, int durationMs = 500}) async {
    if (!Platform.isWindows) return;

    try {
      // Press down
      clickMouse(isLeft: isLeft, isDown: true, isMiddle: isMiddle);

      // Hold for duration
      await Future.delayed(Duration(milliseconds: durationMs));

      // Release
      clickMouse(isLeft: isLeft, isDown: false, isMiddle: isMiddle);
    } catch (e) {
      logError('Error performing long click: $e');
    }
  }

  /// Send keyboard input
  static void sendKey(int keyCode, {bool isDown = true}) {
    if (!Platform.isWindows) return;

    try {
      final input = calloc<INPUT>();
      input.ref.type = INPUT_KEYBOARD;
      input.ref.ki.wVk = keyCode;
      input.ref.ki.dwFlags = isDown ? 0 : KEYEVENTF_KEYUP;

      SendInput(1, input, sizeOf<INPUT>());
      calloc.free(input);
    } catch (e) {
      logError('Error sending key: $e');
    }
  }

  /// Send text input (for typing)
  static void sendText(String text) {
    if (!Platform.isWindows) return;

    try {
      for (int i = 0; i < text.length; i++) {
        final char = text.codeUnitAt(i);

        final input = calloc<INPUT>();
        input.ref.type = INPUT_KEYBOARD;
        input.ref.ki.wScan = char;
        input.ref.ki.dwFlags = KEYEVENTF_UNICODE;

        // Key down
        SendInput(1, input, sizeOf<INPUT>());

        // Key up
        input.ref.ki.dwFlags = KEYEVENTF_UNICODE | KEYEVENTF_KEYUP;
        SendInput(1, input, sizeOf<INPUT>());

        calloc.free(input);
      }
    } catch (e) {
      logError('Error sending text: $e');
    }
  }

  /// Get screen size (primary monitor only)
  static ({int width, int height}) getScreenSize() {
    if (!Platform.isWindows) return (width: 1920, height: 1080);

    try {
      final width = GetSystemMetrics(SM_CXSCREEN);
      final height = GetSystemMetrics(SM_CYSCREEN);
      return (width: width, height: height);
    } catch (e) {
      logError('Error getting screen size: $e');
      return (width: 1920, height: 1080);
    }
  }

  /// Get virtual desktop size (all monitors combined)
  static ({int left, int top, int width, int height}) getVirtualDesktopSize() {
    if (!Platform.isWindows)
      return (left: 0, top: 0, width: 1920, height: 1080);

    try {
      final left = GetSystemMetrics(SM_XVIRTUALSCREEN);
      final top = GetSystemMetrics(SM_YVIRTUALSCREEN);
      final width = GetSystemMetrics(SM_CXVIRTUALSCREEN);
      final height = GetSystemMetrics(SM_CYVIRTUALSCREEN);

      // Log virtual desktop info for debugging
      // logInfo(
      //     'Virtual Desktop: left=$left, top=$top, width=$width, height=$height');

      return (left: left, top: top, width: width, height: height);
    } catch (e) {
      logError('Error getting virtual desktop size: $e');
      return (left: 0, top: 0, width: 1920, height: 1080);
    }
  }

//   /// Get monitor information for debugging
//   static String getMonitorInfo() {
//     if (!Platform.isWindows) return 'Not Windows';

//     try {
//       final primary = getScreenSize();
//       final virtual = getVirtualDesktopSize();

//       return '''Monitor Information:
// Primary Screen: ${primary.width}x${primary.height}
// Virtual Desktop: ${virtual.width}x${virtual.height} at (${virtual.left}, ${virtual.top})
// Multi-monitor: ${virtual.width > primary.width || virtual.height > primary.height ? 'Yes' : 'No'}''';
//     } catch (e) {
//       return 'Error getting monitor info: $e';
//     }
//   }
}
