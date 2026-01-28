import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart' as network_info_plus;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/app_installation_service.dart';

class NetworkSecurityService {
  static final network_info_plus.NetworkInfo _networkInfo =
      network_info_plus.NetworkInfo();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const MethodChannel _channel =
      MethodChannel('dev.trongajtt.p2lan/network_security');

  /// Check current network security level
  static Future<NetworkInfo> checkNetworkSecurity({bool verbose = true}) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        // Mobile data is considered secure (carrier handles security)
        final mobileInfo = await _getMobileInfo(verbose: verbose);
        return mobileInfo;
      }

      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        final wifiInfo = await _getWiFiInfo(verbose: verbose);
        return wifiInfo;
      }

      if (connectivityResult.contains(ConnectivityResult.ethernet)) {
        // Ethernet is generally secure (physical connection required)
        return await _getEthernetInfo();
      }

      // No connection or unknown type
      return NetworkInfo(
        isWiFi: false,
        isMobile: false,
        isSecure: false,
        securityLevel: NetworkSecurityLevel.unknown,
      );
    } catch (e) {
      AppLogger.instance.error('Error checking network security: $e');
      return NetworkInfo(
        isWiFi: false,
        isMobile: false,
        isSecure: false,
        securityLevel: NetworkSecurityLevel.unknown,
      );
    }
  }

  static Future<NetworkInfo> _getEthernetInfo() async {
    try {
      // Try to get detailed network info from native platform first
      if (Platform.isAndroid || Platform.isWindows) {
        try {
          final result = await _channel.invokeMethod('getNetworkInfo');
          if (result is Map) {
            final isConnected = result['isConnected'] as bool? ?? false;
            final isEthernet = result['isEthernet'] as bool? ?? false;

            if (isConnected && isEthernet) {
              final ipAddress = result['ipAddress'] as String?;
              final gatewayAddress = result['gatewayAddress'] as String?;

              return NetworkInfo(
                ipAddress: ipAddress,
                gatewayAddress: gatewayAddress,
                isWiFi: false,
                isMobile: false,
                isSecure: true, // Ethernet is secure (physical connection)
                securityLevel: NetworkSecurityLevel.secure,
                securityType: 'ETHERNET',
              );
            }
          }
        } catch (e) {
          AppLogger.instance.warning('Failed to get native network info: $e');
        }
      }

      // Fallback - basic ethernet info
      final ipAddress =
          await _networkInfo.getWifiIP(); // This works for ethernet too
      final gatewayAddress = await _networkInfo.getWifiGatewayIP();

      return NetworkInfo(
        ipAddress: ipAddress,
        gatewayAddress: gatewayAddress,
        isWiFi: false,
        isMobile: false,
        isSecure: true, // Ethernet connections are generally secure
        securityLevel: NetworkSecurityLevel.secure,
        securityType: 'ETHERNET',
      );
    } catch (e) {
      AppLogger.instance.error('Error getting Ethernet info: $e');
      return NetworkInfo(
        isWiFi: false,
        isMobile: false,
        isSecure: true, // Default to secure for ethernet
        securityLevel: NetworkSecurityLevel.secure,
        securityType: 'ETHERNET',
      );
    }
  }

  static Future<NetworkInfo> _getWiFiInfo({bool verbose = true}) async {
    try {
      // Try to get WiFi security info from native platform first (Android)
      bool isSecure = true;
      String securityType = 'UNKNOWN';
      String? nativeSSID;

      if (Platform.isAndroid) {
        try {
          final result = await _channel.invokeMethod('getWifiSecurityInfo');
          if (verbose) logInfo('Native WiFi result: $result');
          if (result is Map) {
            isSecure = result['isSecure'] as bool? ?? true;
            securityType = result['securityType'] as String? ?? 'UNKNOWN';
            nativeSSID = result['ssid'] as String?;
            if (verbose) {
              logInfo(
                  'Native WiFi security check: secure=$isSecure, type=$securityType, ssid=$nativeSSID');
            }
          }
        } catch (e) {
          if (verbose) {
            logWarning('Failed to get native WiFi security info: $e');
          }
          // Fallback to assuming secure
          isSecure = true;
        }
      }

      // Get standard WiFi info
      final wifiName = await _networkInfo.getWifiName();
      final wifiSSID = await _networkInfo.getWifiBSSID();
      final ipAddress = await _networkInfo.getWifiIP();
      final gatewayAddress = await _networkInfo.getWifiGatewayIP();

      if (verbose) {
        logInfo(
            'Standard WiFi info: name=$wifiName, ssid=$wifiSSID, ip=$ipAddress, gateway=$gatewayAddress');
      }

      // Use native SSID if available, otherwise fallback to standard WiFi name
      final finalWifiName =
          nativeSSID?.isNotEmpty == true ? nativeSSID : wifiName;
      if (verbose) logInfo('Final WiFi name: $finalWifiName');

      return NetworkInfo(
        wifiName: finalWifiName,
        wifiSSID: wifiSSID,
        ipAddress: ipAddress,
        gatewayAddress: gatewayAddress,
        isWiFi: true,
        isMobile: false,
        isSecure: isSecure,
        securityLevel: isSecure
            ? NetworkSecurityLevel.secure
            : NetworkSecurityLevel.unsecure,
        securityType: securityType,
      );
    } catch (e) {
      AppLogger.instance.error('Error getting WiFi info: $e');
      return NetworkInfo(
        isWiFi: true,
        isMobile: false,
        isSecure: false,
        securityLevel: NetworkSecurityLevel.unknown,
      );
    }
  }

  static Future<NetworkInfo> _getMobileInfo({bool verbose = true}) async {
    try {
      String? ipAddress;
      String? gatewayAddress;
      String? interfaceName;
      String? networkType = 'mobile';

      // Try to get mobile IP from native platform
      if (Platform.isAndroid) {
        try {
          final result = await _channel.invokeMethod('getMobileIpAddress');
          if (result is Map && result['success'] == true) {
            ipAddress = result['ipAddress'] as String?;
            interfaceName = result['interfaceName'] as String?;
            networkType = result['type'] as String? ?? 'mobile';
            if (verbose) {
              logInfo(
                  'Native mobile IP check: ip=$ipAddress, interface=$interfaceName, type=$networkType');
            }
          } else {
            if (verbose)
              logWarning('Failed to get native mobile IP: ${result?['error']}');
          }
        } catch (e) {
          if (verbose) logWarning('Failed to get native mobile IP info: $e');
        }
      }

      // Fallback to trying WiFi methods (sometimes works for hotspot scenarios)
      if (ipAddress == null) {
        try {
          ipAddress = await _networkInfo.getWifiIP();
          gatewayAddress = await _networkInfo.getWifiGatewayIP();
          if (verbose) {
            logInfo(
                'Fallback WiFi methods - IP: $ipAddress, Gateway: $gatewayAddress');
          }
        } catch (e) {
          if (verbose) logWarning('Fallback WiFi methods failed: $e');
        }
      }

      return NetworkInfo(
        ipAddress: ipAddress,
        gatewayAddress: gatewayAddress,
        isWiFi: false,
        isMobile: true,
        isSecure: true, // Mobile data is secure (carrier handles security)
        securityLevel: NetworkSecurityLevel.secure,
        securityType: networkType?.toUpperCase(),
        // Add interface info for debugging
        wifiName:
            interfaceName != null ? 'Mobile Interface: $interfaceName' : null,
      );
    } catch (e) {
      AppLogger.instance.error('Error getting mobile info: $e');
      return NetworkInfo(
        isWiFi: false,
        isMobile: true,
        isSecure: true, // Default to secure for mobile
        securityLevel: NetworkSecurityLevel.secure,
        securityType: 'MOBILE',
      );
    }
  }

  /// Get stable app installation ID (replaces device ID with app-specific stable identifier)
  static Future<String> getAppInstallationId() async {
    try {
      return await AppInstallationService.instance.getAppInstallationId();
    } catch (e) {
      AppLogger.instance.error('Failed to get app installation ID: $e');
      return 'TEMP${DateTime.now().millisecondsSinceEpoch % 1000000}';
    }
  }

  /// Get readable app installation ID
  static Future<String> getReadableAppInstallationId() async {
    return AppInstallationService.instance.getAppInstallationWordId();
  }

  /// Get device display name
  static Future<String> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.model;
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      AppLogger.instance.error('Error getting device name: $e');
      return 'Unknown Device';
    }
  }

  /// Get local IP address
  static Future<String?> getLocalIpAddress() async {
    try {
      // First try the standard WiFi method
      String? ipAddress = await _networkInfo.getWifiIP();

      // If that fails and we're on mobile, try the native mobile method
      if (ipAddress == null && Platform.isAndroid) {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.mobile)) {
          try {
            final result = await _channel.invokeMethod('getMobileIpAddress');
            if (result is Map && result['success'] == true) {
              ipAddress = result['ipAddress'] as String?;
              logInfo('Got IP from native mobile method: $ipAddress');
            }
          } catch (e) {
            logWarning('Failed to get IP from native mobile method: $e');
          }
        }
      }

      return ipAddress;
    } catch (e) {
      AppLogger.instance.error('Error getting local IP address: $e');
      return null;
    }
  }

  /// Check if network is available for P2P (respects user data usage preferences)
  static Future<bool> isNetworkAvailableForP2P() async {
    final networkInfo = await checkNetworkSecurity(verbose: false);
    final isConnectionTypeSupported = networkInfo.isWiFi ||
        networkInfo.isMobile ||
        (networkInfo.securityType == 'ETHERNET');

    if (!isConnectionTypeSupported) {
      return false;
    }

    return true;
  }

  // Helper methods for logging
  static void logInfo(String message) {
    AppLogger.instance.info('NetworkSecurityService: $message');
  }

  static void logWarning(String message) {
    AppLogger.instance.warning('NetworkSecurityService: $message');
  }
}
