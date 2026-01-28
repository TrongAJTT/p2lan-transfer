import 'package:flutter/widgets.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/variables.dart';

extension VersionTypeExtension on VersionType {
  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case VersionType.release:
        return l10n.versionTypeReleaseDisplay;
      case VersionType.beta:
        return l10n.versionTypeBetaDisplay;
      case VersionType.dev:
        return l10n.versionTypeDevDisplay;
    }
  }

  String getShortName(AppLocalizations l10n) {
    switch (this) {
      case VersionType.release:
        return l10n.versionTypeRelease;
      case VersionType.beta:
        return l10n.versionTypeBeta;
      case VersionType.dev:
        return l10n.versionTypeDev;
    }
  }
}

String getScreenTitle(String? title) {
  return title ?? appName;
}

bool isMobileLayoutContext(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return isMobileLayout(screenWidth);
}

bool isTabletLayoutContext(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return isTabletLayout(screenWidth);
}

bool isDesktopLayoutContext(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return isDesktopLayout(screenWidth);
}

bool isMobileLayout(double screenWidth) {
  return screenWidth < tabletScreenWidthThreshold;
}

bool isTabletLayout(double screenWidth) {
  return screenWidth >= tabletScreenWidthThreshold &&
      screenWidth < desktopScreenWidthThreshold;
}

bool isDesktopLayout(double screenWidth) {
  return screenWidth >= desktopScreenWidthThreshold;
}
