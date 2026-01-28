import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:p2lan/services/network_security_service.dart';

void main() {
  group('NetworkSecurityService Mobile IP Tests', () {
    setUpAll(() {
      // Mock the method channel for testing
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dev.trongajtt.p2lan/network_security'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getMobileIpAddress':
              // Mock response for mobile IP address
              return {
                'success': true,
                'ipAddress': '10.123.45.67',
                'interfaceName': 'rmnet0',
                'type': 'mobile',
                'isUp': true,
                'displayName': 'Mobile Data Interface'
              };
            case 'getWifiSecurityInfo':
              return {
                'isSecure': true,
                'securityType': 'NOT_CONNECTED',
              };
            default:
              return null;
          }
        },
      );
    });

    tearDownAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dev.trongajtt.p2lan/network_security'),
        null,
      );
    });

    test('should get mobile IP address when on mobile data', () async {
      // Mock connectivity to return mobile
      // Note: In real testing, you'd need to mock connectivity_plus too

      final localIp = await NetworkSecurityService.getLocalIpAddress();
      expect(localIp, isNotNull);
      print('Local IP Address: $localIp');
    });

    test('should check network security for mobile connection', () async {
      final networkInfo = await NetworkSecurityService.checkNetworkSecurity();

      expect(networkInfo.isSecure, isTrue);
      expect(networkInfo.securityLevel.toString(), contains('secure'));

      print('Network Info:');
      print('- isWiFi: ${networkInfo.isWiFi}');
      print('- isMobile: ${networkInfo.isMobile}');
      print('- isSecure: ${networkInfo.isSecure}');
      print('- ipAddress: ${networkInfo.ipAddress}');
      print('- securityType: ${networkInfo.securityType}');
    });
  });
}
