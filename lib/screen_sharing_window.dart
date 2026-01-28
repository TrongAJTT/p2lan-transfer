import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/screens/p2lan_transfer/screen_sharing_viewer_screen.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Entry point for screen sharing viewer window
void main(List<String> args) {
  runApp(ScreenSharingWindow(args));
}

class ScreenSharingWindow extends StatelessWidget {
  final List<String> args;

  const ScreenSharingWindow(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Sharing Viewer',
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _buildScreenSharingViewer(),
    );
  }

  Widget _buildScreenSharingViewer() {
    try {
      // Parse arguments passed from main window
      if (args.isNotEmpty) {
        final data = jsonDecode(args.first) as Map<String, dynamic>;
        if (data['route'] == '/screen_sharing_viewer' &&
            data['session'] != null) {
          final session = ScreenSharingSession.fromJson(data['session']);
          return ScreenSharingViewerScreen(session: session);
        }
      }

      // Fallback if no valid session data
      return const Scaffold(
        body: Center(
          child: Text('Invalid screen sharing session data'),
        ),
      );
    } catch (e) {
      return Scaffold(
        body: Center(
          child: Text('Error loading screen sharing viewer: $e'),
        ),
      );
    }
  }
}
