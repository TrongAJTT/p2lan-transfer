import 'package:flutter/material.dart';

const VersionType currentVersionType = VersionType.beta;
const String githubRepoUrl = 'https://github.com/TrongAJTT/p2lan-transfer';
const String appCode = 'p2lan_transfer';
const String appName = 'P2Lan Transfer';
const String appSlogan = "Make LAN transfers easy, no server needed";
const String appAssetIcon = 'assets/app_icon.png';

const String githubIssuesUrl =
    'https://github.com/TrongAJTT/p2lan-transfer/issues';
const String githubReleaseUrl =
    'https://github.com/TrongAJTT/p2lan-transfer/releases';

const String githubSponsorUrl = 'https://github.com/sponsors/TrongAJTT';
const String buyMeACoffeeUrl = 'https://www.buymeacoffee.com/trongajtt';
const String termsUrl =
    'https://raw.githubusercontent.com/TrongAJTT/p2lan-transfer-terms/main/TERM_OF_USE_<locale>.md';
// Replace <locale> with the actual locale code

const String latestReleaseEndpoint =
    'https://api.github.com/repos/TrongAJTT/p2lan-transfer/releases/latest';
const String authorProductsEndpoint =
    'https://raw.githubusercontent.com/TrongAJTT/TrongAJTT/refs/heads/main/MY_PRODUCTS.json';
const String authorAvatarEndpoint =
    'https://avatars.githubusercontent.com/u/157729907?v=4';

const String userAgent = "P2Lan-Transfer-App";

const double tabletScreenWidthThreshold = 600.0;
const double desktopScreenWidthThreshold = 1024.0;

const int p2pChatMediaWaitTimeBeforeDelete = 6; // seconds
const int p2pChatClipboardPollingInterval = 3; // seconds

const Color sendColor = Colors.blue;
const Color receiveColor = Colors.yellow;

const int p2pBasePort = 8080;
const int p2pMaxPort = 8090;

// This enum represents the different types of app versions.
// It is used to determine the current version type of the application.
enum VersionType {
  release,
  beta,
  dev,
}
