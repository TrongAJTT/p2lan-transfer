import 'package:flutter/material.dart';
import 'package:p2lan/screens/about_layout.dart';

/// About Settings Module
/// Simple wrapper for the AboutLayout
class AboutSettings extends StatelessWidget {
  const AboutSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const AboutLayout(showHeader: true);
  }
}
