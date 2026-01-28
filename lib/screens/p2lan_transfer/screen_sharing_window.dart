import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:p2lan/screens/p2lan_transfer/screen_sharing_viewer_screen.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/services/p2p_services/p2p_service_manager.dart';

/// Entry point for screen sharing window
/// This is called by desktop_multi_window when creating a new window
class ScreenSharingWindow extends StatelessWidget {
  final WindowController controller;
  final Map<String, dynamic> args;

  const ScreenSharingWindow({
    super.key,
    required this.controller,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    try {
      logInfo('ScreenSharingWindow: Building window with args: $args');

      // Parse session from args
      final sessionData = args['session'] as Map<String, dynamic>?;
      if (sessionData == null) {
        logError('ScreenSharingWindow: No session data provided');
        return const Scaffold(
          body: Center(
            child: Text('Error: No session data'),
          ),
        );
      }

      final session = ScreenSharingSession.fromJson(sessionData);
      logInfo(
          'ScreenSharingWindow: Session parsed: ${session.senderUser.displayName} -> ${session.receiverUser.displayName}');

      // Get service manager instance (singleton)
      final serviceManager = P2PServiceManager.instance;
      logInfo('ScreenSharingWindow: Service manager obtained');

      return MaterialApp(
        title: 'Screen Sharing - ${session.senderUser.displayName}',
        theme: ThemeData.dark(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('vi'),
        ],
        home: ScreenSharingViewerScreen(
          session: session,
          windowController: controller,
          serviceManager: serviceManager,
        ),
      );
    } catch (e, stackTrace) {
      logError('ScreenSharingWindow: Error building window: $e\n$stackTrace');
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error: $e'),
          ),
        ),
      );
    }
  }
}
