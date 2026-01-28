import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:p2lan/services/network_security_service.dart';
import 'package:p2lan/services/app_logger.dart';

class NetworkDebugUtils {
  /// Debug network connectivity and log detailed information
  static Future<void> debugNetworkConnectivity() async {
    try {
      AppLogger.instance.info('🔍 === Network Debug Started ===');

      // Test basic connectivity
      final connectivity = Connectivity();
      final results = await connectivity.checkConnectivity();

      String connectionTypes = '';
      for (final result in results) {
        switch (result) {
          case ConnectivityResult.wifi:
            connectionTypes += 'WiFi ';
            break;
          case ConnectivityResult.mobile:
            connectionTypes += 'Mobile ';
            break;
          case ConnectivityResult.ethernet:
            connectionTypes += 'Ethernet ';
            break;
          case ConnectivityResult.none:
            connectionTypes += 'None ';
            break;
          default:
            connectionTypes += 'Other ';
        }
      }
      AppLogger.instance.info('📡 Connection: $connectionTypes');

      // Get network info once without verbose logging
      final networkInfo =
          await NetworkSecurityService.checkNetworkSecurity(verbose: false);

      // Summary format
      String networkSummary = '';
      if (networkInfo.isWiFi) {
        networkSummary =
            'WiFi - ${networkInfo.isSecure ? "🔒 Secure" : "🔓 Open"}';
        if (networkInfo.wifiName != null) {
          networkSummary += ' (${networkInfo.wifiName})';
        } else if (networkInfo.wifiSSID != null) {
          networkSummary += ' (SSID: ${networkInfo.wifiSSID})';
        }
      } else if (networkInfo.isMobile) {
        networkSummary = 'Mobile Data - 🔒 Secure';
      } else {
        networkSummary = 'Unknown Connection';
      }

      AppLogger.instance.info('🌐 Network: $networkSummary');
      AppLogger.instance.info('📍 IP: ${networkInfo.ipAddress ?? "Unknown"}');
      AppLogger.instance
          .info('🚪 Gateway: ${networkInfo.gatewayAddress ?? "Unknown"}');

      if (networkInfo.signalStrength != null) {
        AppLogger.instance.info('📶 Signal: ${networkInfo.signalStrength} dBm');
      }

      // P2P readiness
      final isP2PReady =
          await NetworkSecurityService.isNetworkAvailableForP2P();
      AppLogger.instance.info('🔗 P2P Ready: ${isP2PReady ? "✅ Yes" : "❌ No"}');

      AppLogger.instance.info('✅ === Network Debug Completed ===');
    } catch (e, stackTrace) {
      AppLogger.instance.error('Error in network debug: $e');
      AppLogger.instance.error('Stack trace: $stackTrace');
    }
  }

  /// Get a human-readable network status
  static Future<String> getNetworkStatusDescription() async {
    try {
      final connectivity = Connectivity();
      final results = await connectivity.checkConnectivity();

      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        return 'No network connection';
      }

      final types = results.map((r) => r.toString().split('.').last).join(', ');
      return 'Connected via: $types';
    } catch (e) {
      return 'Error checking network: $e';
    }
  }
}
