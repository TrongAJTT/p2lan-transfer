import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:p2lan/models/p2p_models.dart';

/// Utility class for detecting and managing platform information
class PlatformDetectionUtils {
  /// Get current device platform
  static UserPlatform getCurrentPlatform() {
    if (kIsWeb) {
      return UserPlatform.web;
    }

    if (Platform.isAndroid) {
      return UserPlatform.android;
    }

    if (Platform.isIOS) {
      return UserPlatform.ios;
    }

    if (Platform.isWindows) {
      return UserPlatform.windows;
    }

    if (Platform.isMacOS) {
      return UserPlatform.macos;
    }

    if (Platform.isLinux) {
      return UserPlatform.linux;
    }

    return UserPlatform.unknown;
  }

  /// Get platform display name
  static String getPlatformDisplayName(UserPlatform platform) {
    switch (platform) {
      case UserPlatform.android:
        return 'Android';
      case UserPlatform.ios:
        return 'iOS';
      case UserPlatform.windows:
        return 'Windows';
      case UserPlatform.macos:
        return 'macOS';
      case UserPlatform.linux:
        return 'Linux';
      case UserPlatform.web:
        return 'Web';
      case UserPlatform.unknown:
        return 'Unknown';
    }
  }

  /// Get platform icon data
  static String getPlatformIcon(UserPlatform platform) {
    switch (platform) {
      case UserPlatform.android:
        return '🤖';
      case UserPlatform.ios:
        return '🍎';
      case UserPlatform.windows:
        return '🪟';
      case UserPlatform.macos:
        return '🍎';
      case UserPlatform.linux:
        return '🐧';
      case UserPlatform.web:
        return '🌐';
      case UserPlatform.unknown:
        return '❓';
    }
  }

  /// Detect platform from user agent string (for web)
  static UserPlatform detectFromUserAgent(String userAgent) {
    final lowerUserAgent = userAgent.toLowerCase();

    if (lowerUserAgent.contains('android')) {
      return UserPlatform.android;
    }

    if (lowerUserAgent.contains('iphone') ||
        lowerUserAgent.contains('ipad') ||
        lowerUserAgent.contains('ipod')) {
      return UserPlatform.ios;
    }

    if (lowerUserAgent.contains('windows')) {
      return UserPlatform.windows;
    }

    if (lowerUserAgent.contains('macintosh') ||
        lowerUserAgent.contains('mac os')) {
      return UserPlatform.macos;
    }

    if (lowerUserAgent.contains('linux')) {
      return UserPlatform.linux;
    }

    return UserPlatform.unknown;
  }
}
