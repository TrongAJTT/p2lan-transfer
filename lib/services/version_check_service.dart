import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:p2lan/l10n/app_localizations.dart';

import 'package:p2lan/utils/localization_utils.dart';
import 'package:p2lan/utils/url_utils.dart';
import 'package:p2lan/variables.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ReleaseAsset {
  final String name;
  final int size;
  final String browserDownloadUrl;
  final DateTime updatedAt;

  ReleaseAsset({
    required this.name,
    required this.size,
    required this.browserDownloadUrl,
    required this.updatedAt,
  });

  factory ReleaseAsset.fromJson(Map<String, dynamic> json) {
    return ReleaseAsset(
      name: json['name'] ?? '',
      size: json['size'] ?? 0,
      browserDownloadUrl: json['browser_download_url'] ?? '',
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get sizeInMB {
    return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class ReleaseInfo {
  final String name;
  final String tag;
  final String body;
  final DateTime publishedAt;
  final List<ReleaseAsset> assets;

  ReleaseInfo({
    required this.name,
    required this.body,
    required this.tag,
    required this.publishedAt,
    required this.assets,
  });

  factory ReleaseInfo.fromJson(Map<String, dynamic> json) {
    final assetsList = (json['assets'] as List<dynamic>?)
            ?.map((asset) => ReleaseAsset.fromJson(asset))
            .toList() ??
        [];

    return ReleaseInfo(
      name: json['name'],
      tag: json['tag_name'],
      body: json['body'],
      publishedAt: DateTime.parse(json['published_at']).toLocal(),
      assets: assetsList,
    );
  }
}

class VersionCheckService {
  static Future<ReleaseInfo?> fetchLatestRelease() async {
    try {
      final response = await http.get(
        Uri.parse(latestReleaseEndpoint),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': userAgent,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ReleaseInfo.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch release info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching release info: $e');
    }
  }

  static Future<bool> isCurrentVersionLatest() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final releaseInfo = await fetchLatestRelease();

      if (releaseInfo == null) return true;

      return compareVersions(currentVersion, releaseInfo.tag) >= 0;
    } catch (e) {
      return true; // If we can't check, assume it's latest to avoid false positives
    }
  }

  static int compareVersions(String version1, String version2) {
    // Remove 'v' prefix if present
    final v1 = version1.startsWith('v') ? version1.substring(1) : version1;
    final v2 = version2.startsWith('v') ? version2.substring(1) : version2;

    final v1Parts = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad with zeros to make them the same length
    while (v1Parts.length < v2Parts.length) {
      v1Parts.add(0);
    }
    while (v2Parts.length < v1Parts.length) {
      v2Parts.add(0);
    }

    for (int i = 0; i < v1Parts.length; i++) {
      if (v1Parts[i] > v2Parts[i]) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
    }

    return 0;
  }

  static void showVersionDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(loc.checkingForUpdates),
          ],
        ),
      ),
    );

    try {
      final releaseInfo = await fetchLatestRelease();
      final packageInfo = await PackageInfo.fromPlatform();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (releaseInfo != null) {
          final isLatest =
              compareVersions(packageInfo.version, releaseInfo.tag) >= 0;
          _showReleaseInfoDialog(context, releaseInfo, packageInfo, isLatest);
        } else {
          _showErrorDialog(context, loc.noNewUpdates);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog(context, loc.updateCheckError(e.toString()));
      }
    }
  }

  // Show dialog for new version available, only used for new version available
  static void showNewVersionAvailableDialog(
      BuildContext context, ReleaseInfo latestReleaseInfo) async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (context.mounted) {
      _showReleaseInfoDialog(context, latestReleaseInfo, packageInfo, false);
    }
  }

  static void _showReleaseInfoDialog(BuildContext context,
      ReleaseInfo releaseInfo, PackageInfo packageInfo, bool isLatest) {
    final loc = AppLocalizations.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? MediaQuery.of(context).size.width * 0.95 : 700,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.update,
                      color: Theme.of(context).colorScheme.primary,
                      size: isMobile ? 28 : 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLatest
                                ? loc.usingLatestVersion
                                : loc.newVersionAvailable,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 18 : null,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                releaseInfo.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: isLatest
                                          ? Colors.green
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: isMobile ? 14 : null,
                                    ),
                              ),
                              if (isLatest) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    loc.latest,
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: isMobile ? 10 : 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (!isLatest) ...[
                            const SizedBox(height: 4),
                            Text(
                              loc.currentVersion(packageInfo.version),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                    fontSize: isMobile ? 11 : null,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        size: isMobile ? 20 : 24,
                      ),
                      constraints: BoxConstraints(
                        minWidth: isMobile ? 36 : 48,
                        minHeight: isMobile ? 36 : 48,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Release date
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            loc.publishDate(LocalizationUtils.formatDateTime(
                                context: context,
                                dateTime: releaseInfo.publishedAt,
                                formatType: DateTimeFormatType.exceptSec)),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Release notes
                      Text(
                        loc.releaseNotes,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),

                      // Markdown content in a container with max height
                      Container(
                        constraints: const BoxConstraints(maxHeight: 400),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Markdown(
                          data: releaseInfo.body.isEmpty
                              ? loc.noReleaseNotes
                              : releaseInfo.body,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          styleSheet: MarkdownStyleSheet(
                            p: Theme.of(context).textTheme.bodyMedium,
                            h1: Theme.of(context).textTheme.titleLarge,
                            h2: Theme.of(context).textTheme.titleMedium,
                            h3: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Always use Column layout for mobile to prevent overflow
                      if (isMobile) ...[
                        SizedBox(
                          width: double.infinity,
                          child: isLatest
                              ? ElevatedButton.icon(
                                  onPressed: null, // Disabled button
                                  icon: const Icon(Icons.check_circle),
                                  label: Text(
                                    loc.alreadyLatestVersion,
                                    textAlign: TextAlign.center,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor:
                                        Colors.green.withValues(alpha: 0.7),
                                    backgroundColor:
                                        Colors.green.withValues(alpha: 0.1),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: releaseInfo.assets.isNotEmpty
                                      ? () => _showDownloadDialog(
                                          context, releaseInfo.assets)
                                      : null,
                                  icon: const Icon(Icons.download),
                                  label: Text(loc.download),
                                ),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: isLatest
                                  ? ElevatedButton.icon(
                                      onPressed: null, // Disabled button
                                      icon: const Icon(Icons.check_circle),
                                      label: Text(loc.alreadyLatestVersion),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor:
                                            Colors.green.withValues(alpha: 0.7),
                                        backgroundColor:
                                            Colors.green.withValues(alpha: 0.1),
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: releaseInfo.assets.isNotEmpty
                                          ? () => _showDownloadDialog(
                                              context, releaseInfo.assets)
                                          : null,
                                      icon: const Icon(Icons.download),
                                      label: Text(loc.download),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showDownloadDialog(
      BuildContext context, List<ReleaseAsset> assets) {
    final filteredAssets = _filterAssetsByPlatform(assets);
    final showAllAssets = filteredAssets.isEmpty;
    final assetsToShow = showAllAssets ? assets : filteredAssets;
    final loc = AppLocalizations.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? MediaQuery.of(context).size.width * 0.95 : 600,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            minHeight: 200,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.download,
                      color: Theme.of(context).colorScheme.primary,
                      size: isMobile ? 24 : 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            loc.selectVersionToDownload,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 16 : null,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!showAllAssets) ...[
                            const SizedBox(height: 4),
                            Text(
                              loc.filteredForPlatform(_getPlatformName()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                    fontSize: isMobile ? 11 : null,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        size: isMobile ? 20 : 24,
                      ),
                      constraints: BoxConstraints(
                        minWidth: isMobile ? 36 : 48,
                        minHeight: isMobile ? 36 : 48,
                      ),
                    ),
                  ],
                ),
              ),

              // Asset list
              Flexible(
                child: ListView.separated(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  itemCount: assetsToShow.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final asset = assetsToShow[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          radius: isMobile ? 18 : 20,
                          child: Icon(
                            _getFileIcon(asset.name),
                            color: Theme.of(context).colorScheme.primary,
                            size: isMobile ? 18 : 20,
                          ),
                        ),
                        title: Text(
                          asset.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isMobile ? 14 : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              loc.sizeInMB(asset.sizeInMB),
                              style: TextStyle(
                                fontSize: isMobile ? 12 : null,
                              ),
                            ),
                            Text(
                              loc.uploadDate(
                                LocalizationUtils.formatDateTime(
                                  context: context,
                                  dateTime: asset.updatedAt,
                                  formatType: DateTimeFormatType.exceptSec,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: isMobile ? 12 : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.download,
                          size: isMobile ? 20 : 24,
                        ),
                        onTap: () => _showDownloadConfirmation(context, asset),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 4 : 8,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showDownloadConfirmation(
      BuildContext context, ReleaseAsset asset) {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.confirmDownload),
        content: Text(
          loc.confirmDownloadMessage(
            asset.name,
            asset.sizeInMB,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close confirmation dialog
              Navigator.of(context).pop(); // Close download dialog
              UriUtils.launchInBrowser(asset.browserDownloadUrl, context);
            },
            child: Text(loc.download),
          ),
        ],
      ),
    );
  }

  static void _showErrorDialog(BuildContext context, String message) {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.eerror),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.close),
          ),
        ],
      ),
    );
  }

  static String _getPlatformName() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Other';
  }

  static List<ReleaseAsset> _filterAssetsByPlatform(List<ReleaseAsset> assets) {
    if (Platform.isAndroid) {
      return assets
          .where((asset) =>
              asset.name.toLowerCase().contains('android') ||
              asset.name.toLowerCase().contains('.apk'))
          .toList();
    } else if (Platform.isWindows) {
      return assets
          .where((asset) =>
              asset.name.toLowerCase().contains('windows') ||
              asset.name.toLowerCase().contains('.exe') ||
              asset.name.toLowerCase().contains('.msi'))
          .toList();
    } else if (Platform.isMacOS) {
      return assets
          .where((asset) =>
              asset.name.toLowerCase().contains('macos') ||
              asset.name.toLowerCase().contains('mac') ||
              asset.name.toLowerCase().contains('.dmg'))
          .toList();
    } else if (Platform.isLinux) {
      return assets
          .where((asset) =>
              asset.name.toLowerCase().contains('linux') ||
              asset.name.toLowerCase().contains('.deb') ||
              asset.name.toLowerCase().contains('.rpm') ||
              asset.name.toLowerCase().contains('.appimage'))
          .toList();
    }

    // Return all assets if platform is not recognized
    return assets;
  }

  static IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'apk':
        return Icons.android;
      case 'exe':
      case 'msi':
        return Icons.computer;
      case 'dmg':
      case 'pkg':
        return Icons.laptop_mac;
      case 'deb':
      case 'rpm':
      case 'appimage':
        return Icons.desktop_windows;
      case 'zip':
      case 'tar':
      case 'gz':
      case '7z':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }
}
