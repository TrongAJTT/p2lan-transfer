import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/widgets/generic/permission_info_dialog.dart';
import 'package:p2lan/widgets/generic/generic_dialog.dart';

/// Utility class to handle permission requests with proper UI flow
class PermissionUtils {
  PermissionUtils._();

  // Private helper methods

  /// Check if location permission is granted
  static Future<bool> _isLocationPermissionGranted() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  /// Check if nearby WiFi devices permission is granted (Android 12+)
  static Future<bool> _isNearbyDevicesPermissionGranted() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Only check for Android 12+ (API 31+)
      if (sdkInt >= 31) {
        final status = await Permission.nearbyWifiDevices.status;
        return status.isGranted;
      }

      // For older Android versions, this permission doesn't exist
      return true;
    } catch (e) {
      logWarning('Error checking nearby devices permission: $e');
      return true; // Assume granted if we can't check
    }
  }

  /// Request location permission with proper error handling
  static Future<bool> _requestLocationPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // Check current status first
      final currentStatus = await Permission.locationWhenInUse.status;
      logInfo('Current location permission status: $currentStatus');

      if (currentStatus.isGranted) {
        return true;
      }

      // For Android devices that don't show dialog properly, check if permission is permanently denied
      if (currentStatus.isPermanentlyDenied) {
        logWarning('Location permission is permanently denied');
        return false;
      }

      // Request permission
      logInfo('Requesting location permission...');
      final requestedStatus = await Permission.locationWhenInUse.request();
      logInfo('Location permission request result: $requestedStatus');

      // Additional check for specific device manufacturers that might have issues
      if (requestedStatus.isDenied) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final manufacturer = androidInfo.manufacturer.toLowerCase();
        final model = androidInfo.model;

        logWarning(
            'Permission request failed on $manufacturer $model - Status: $requestedStatus');

        // For problematic devices, provide specific error info
        if (manufacturer.contains('oppo') ||
            manufacturer.contains('realme') ||
            manufacturer.contains('oneplus') ||
            manufacturer.contains('vivo')) {
          logWarning('Known problematic manufacturer detected: $manufacturer');
        }
      }

      return requestedStatus.isGranted;
    } catch (e) {
      logError('Error requesting location permission: $e');
      return false;
    }
  }

  /// Request nearby WiFi devices permission (Android 13+)
  static Future<bool> _requestNearbyDevicesPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Only request for Android 13+ (API 33+)
      if (sdkInt >= 33) {
        final status = await Permission.nearbyWifiDevices.request();
        logInfo('Nearby WiFi devices permission status: $status');
        return status.isGranted;
      }

      // For older Android versions, this permission doesn't exist
      return true;
    } catch (e) {
      logError('Error requesting nearby devices permission: $e');
      return true; // Assume granted if we can't request
    }
  }

  /// Get Android SDK version for permission logic
  static Future<int> _getAndroidSdkVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      logError('Error getting Android SDK version: $e');
      return 0;
    }
  }

  // Public methods

  /// Request location permission with explanation dialog
  static Future<bool> requestLocationPermission(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    // Check if already granted
    final isGranted = await _isLocationPermissionGranted();
    if (isGranted) return true;

    // Show explanation dialog first
    bool userConfirmed = false;
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PermissionInfoDialog(
          title: l10n.p2pPermissionRequiredTitle,
          content: l10n.p2pPermissionExplanation,
          actionText: l10n.p2pPermissionContinue,
          onActionPressed: () {
            userConfirmed = true;
          },
          onCancel: () {
            userConfirmed = false;
          },
        ),
      );
    }

    if (!userConfirmed) return false;

    // Request the actual permission
    final granted = await _requestLocationPermission();

    if (!granted && context.mounted) {
      // Show specific error message for failed permission request
      final androidSdk = await _getAndroidSdkVersion();

      if (androidSdk > 0) {
        // This is Android - show Android-specific error
        throw Exception(
            'Location permission is required for WiFi scanning on Android. Please grant permission in device settings if the permission dialog did not appear.');
      } else {
        throw Exception('Location permission is required for WiFi scanning.');
      }
    }

    return granted;
  }

  /// Request nearby WiFi devices permission with explanation dialog (Android 12+)
  static Future<bool> requestNearbyDevicesPermission(
      BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    // Check if already granted
    final isGranted = await _isNearbyDevicesPermissionGranted();
    if (isGranted) return true;

    // Check if this permission is needed (Android 12+)
    final androidSdk = await _getAndroidSdkVersion();
    if (androidSdk < 33) return true; // Not needed for older Android

    // Show explanation dialog first
    bool userConfirmed = false;
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PermissionInfoDialog(
          title: l10n.p2pNearbyDevicesPermissionTitle,
          content: l10n.p2pNearbyDevicesPermissionExplanation,
          actionText: l10n.p2pPermissionContinue,
          onActionPressed: () {
            userConfirmed = true;
          },
          onCancel: () {
            userConfirmed = false;
          },
        ),
      );
    }

    if (!userConfirmed) return false;

    // Request the actual permission
    final granted = await _requestNearbyDevicesPermission();

    if (!granted && context.mounted) {
      // Show specific error message for failed permission request
      throw Exception(
          'Nearby WiFi devices permission is required for modern Android versions (Android 12+). Please grant permission in device settings if the permission dialog did not appear.');
    }

    return granted;
  }

  /// Check if all P2P permissions are granted
  static Future<bool> areP2PPermissionsGranted() async {
    final locationGranted = await _isLocationPermissionGranted();
    final nearbyDevicesGranted = await _isNearbyDevicesPermissionGranted();

    logInfo(
        'P2P Permissions - Location: $locationGranted, NearbyDevices: $nearbyDevicesGranted');

    return locationGranted && nearbyDevicesGranted;
  }

  /// Request all P2P permissions in sequence with proper UI flow
  static Future<bool> requestAllP2PPermissions(BuildContext context) async {
    // Step 1: Request location permission
    final locationGranted = await requestLocationPermission(context);
    if (!locationGranted) return false;

    // Step 2: Request nearby devices permission (Android 12+)
    final nearbyDevicesGranted = await requestNearbyDevicesPermission(context);
    if (!nearbyDevicesGranted) return false;

    return true;
  }

  // Future methods for other features:

  /// Request storage permissions for file operations
  static Future<bool> requestStoragePermission(BuildContext context) async {
    // TODO: Implement when needed for file picker features
    throw UnimplementedError('Storage permission request not implemented yet');
  }

  /// Request camera permissions for QR code scanning
  static Future<bool> requestCameraPermission(BuildContext context) async {
    // TODO: Implement when needed for QR features
    throw UnimplementedError('Camera permission request not implemented yet');
  }

  /// Request microphone permissions for voice features
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    // TODO: Implement when needed for voice features
    throw UnimplementedError(
        'Microphone permission request not implemented yet');
  }

  /// Check if notification permission is granted
  static Future<bool> _isNotificationPermissionGranted() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Request notification permission with explanation dialog
  static Future<bool> requestNotificationPermission(
      BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    // Check if already granted
    final isGranted = await _isNotificationPermissionGranted();
    if (isGranted) return true;

    // Show explanation dialog first
    bool? userConfirmed;
    if (context.mounted) {
      userConfirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return GenericDialog(
            header: GenericDialogHeader(
              title: l10n.notificationRequestPermission,
            ),
            body: Text(l10n.notificationRequestPermissionDesc),
            footer: GenericDialogFooter.twoSimpleButtons(
              context: context,
              leftText: l10n.cancel,
              rightText: l10n.grantPermission,
              onLeft: () => Navigator.of(context).pop(false),
              onRight: () => Navigator.of(context).pop(true),
              minToggleDisplayWidth: 400,
            ),
          );
        },
      );
    }
    logInfo('>>>>>>> userConfirmed: $userConfirmed');

    if (userConfirmed != true) return false;

    // Request the actual permission
    try {
      final result = await Permission.notification.request();
      return result.isGranted;
    } catch (e) {
      logError('>>>>>>>> Error requesting notification permission: $e');
      return false;
    }
  }
}
