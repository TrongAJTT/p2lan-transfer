import 'package:flutter_test/flutter_test.dart';
import 'package:p2lan/services/network_security_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  group('Network Detection Debug', () {
    test('Check connectivity results', () async {
      // Test basic connectivity
      final connectivity = Connectivity();
      final results = await connectivity.checkConnectivity();

      print('Connectivity Results: $results');

      for (final result in results) {
        print('- ${result.toString()}');
      }

      // Test our network security service
      try {
        final networkInfo = await NetworkSecurityService.checkNetworkSecurity();

        print('\nNetworkInfo Results:');
        print('- isWiFi: ${networkInfo.isWiFi}');
        print('- isMobile: ${networkInfo.isMobile}');
        print('- isSecure: ${networkInfo.isSecure}');
        print('- securityType: ${networkInfo.securityType}');
        print('- securityLevel: ${networkInfo.securityLevel}');
        print('- wifiName: ${networkInfo.wifiName}');
        print('- ipAddress: ${networkInfo.ipAddress}');
      } catch (e) {
        print('Error getting network info: $e');
      }
    });
  });
}
