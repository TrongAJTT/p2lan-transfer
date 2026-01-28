import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/library_list.dart';
import 'package:p2lan/screens/terms_of_use_screen.dart';
import 'package:p2lan/services/author_products_service.dart';
import 'package:p2lan/services/version_check_service.dart';
import 'package:p2lan/utils/network_utils.dart';
import 'package:p2lan/utils/snackbar_utils.dart';
import 'package:p2lan/utils/url_utils.dart';
import 'package:p2lan/utils/variables_utils.dart';
import 'package:p2lan/widgets/generic/generic_settings_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:p2lan/variables.dart';

/// About layout with GitHub, Sponsor, Credits, and Version information
class AboutLayout extends StatefulWidget {
  final bool showHeader;

  const AboutLayout({super.key, this.showHeader = true});

  @override
  State<AboutLayout> createState() => _AboutLayoutState();
}

class _AboutLayoutState extends State<AboutLayout> {
  PackageInfo? packageInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          packageInfo = info;
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle error silently, will show fallback version
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // App Header (conditional)
          if (widget.showHeader) ...[
            _buildAppHeader(theme),
            const SizedBox(height: 24),
          ],

          // GitHub Repository section
          ListTile(
            leading: Icon(
              Icons.qr_code,
              color: theme.colorScheme.onPrimary,
            ),
            title: Text(l10n.githubRepo),
            subtitle: Text(l10n.githubRepoDesc),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => UriUtils.launchInBrowser(githubRepoUrl, context),
          ),

          // Donate section
          ListTile(
            leading: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            title: Text(l10n.donate),
            subtitle: Text(l10n.donateDesc),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showDonateDialog,
          ),

          // // Donors Acknowledgment section
          // ListTile(
          //     leading: const Icon(
          //       Icons.star,
          //       color: Colors.yellow,
          //     ),
          //     title: Text(l10n.donorsAck),
          //     subtitle: Text(l10n.donorsAckDesc),
          //     trailing: const Icon(Icons.arrow_forward_ios),
          //     onTap: () {
          //       Navigator.of(context).push(
          //         MaterialPageRoute(
          //           builder: (context) => const DonorsAcknowledgmentScreen(),
          //         ),
          //       );
          //     }),

          // Credits & Acknowledgments section
          ListTile(
            leading: const Icon(
              Icons.groups,
              color: Colors.orange,
            ),
            title: Text(l10n.creditAck),
            subtitle: Text(l10n.creditAckDesc),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showCreditsDialog,
          ),

          // Terms of Use section
          ListTile(
            leading: const Icon(
              Icons.article,
              color: Colors.green,
            ),
            title: Text(l10n.termsOfUse),
            subtitle: Text(l10n.termsOfUseView),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => TermsOfUseScreen.navigateOpen(
                context: context,
                localeCode: Localizations.localeOf(context).languageCode),
          ),

          // Version Information section
          ListTile(
            leading: const Icon(
              Icons.info,
              color: Colors.blue,
            ),
            title: Text(l10n.versionInfo),
            subtitle: Text(_getVersionString()),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showVersionDialog,
          ),

          // Update new version section
          ListTile(
            leading: const Icon(
              Icons.update,
              color: Colors.purple,
            ),
            title: Text(l10n.checkForNewVersion),
            subtitle: Text(l10n.checkForNewVersionDesc),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              if (await NetworkUtils.isNetworkAvailable() && context.mounted) {
                VersionCheckService.showVersionDialog(context);
              } else {
                SnackbarUtils.showTyped(
                    context,
                    l10n.noInternetPleaseConnectAndTryAgain,
                    SnackBarType.warning);
              }
            },
          ),

          // View author's products section
          ListTile(
            leading: const Icon(
              Icons.shopping_bag,
              color: Colors.green,
            ),
            title: Text(l10n.authorProducts),
            subtitle: Text(l10n.authorProductsDesc),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              UriUtils.launchInBrowser(
                  "https://www.trongajtt.com/apps/", context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppHeader(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                theme.primaryColor,
                theme.primaryColor.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Image.asset(
            'assets/app_icon.png',
            fit: BoxFit.cover,
          ),
        ),
        Text(
          appName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          appSlogan,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  String _getVersionString() {
    final l10n = AppLocalizations.of(context);
    final versionType = currentVersionType.getDisplayName(l10n);

    if (isLoading || packageInfo == null) {
      return '${l10n.loading} ($versionType)';
    }

    return '${packageInfo!.version}+${packageInfo!.buildNumber} ($versionType)';
  }

  void _showDonateDialog() {
    final l10n = AppLocalizations.of(context);
    final config = GenericSettingsConfig<dynamic>(
      title: l10n.donate,
      settingsLayout: _buildDonateContent(),
      onSettingsChanged: (_) {},
    );

    GenericSettingsHelper.showSettings(context, config);
  }

  Widget _buildDonateContent() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Donation header
          const Icon(
            Icons.favorite,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.supportDesc,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 24),

          // Github Sponsors
          ListTile(
            // leading: const Icon(Icons.favorite_border),
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/logos/github.png'),
              backgroundColor: Colors.white,
              radius: 18,
            ),
            title: const Text(
              'GitHub Sponsors',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(l10n.githubSponsorsDesc),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => UriUtils.launchInBrowser(githubSponsorUrl, context),
          ),
          // Buy me a Coffee
          ListTile(
            // leading: const Icon(Icons.payment),
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/logos/buy_me_a_coffee.png'),
              backgroundColor: Colors.white,
              radius: 18,
            ),
            title: const Text(
              'Buy me a Coffee',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(l10n.buyMeACoffeeDesc),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => UriUtils.launchInBrowser(buyMeACoffeeUrl, context),
          ),
        ],
      ),
    );
  }

  void _showCreditsDialog() {
    final l10n = AppLocalizations.of(context);
    final config = GenericSettingsConfig<dynamic>(
      title: l10n.creditAck,
      settingsLayout: _buildCreditsContent(),
      currentSettings: null,
      onSettingsChanged: (_) {},
      showActions: false,
      isCompact: false,
      barrierDismissible: true,
      padding: const EdgeInsets.all(16),
    );

    GenericSettingsHelper.showSettings(context, config);
  }

  Widget _buildCreditsContent() {
    final libraries = libraryList;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thank you authors card
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.code,
                    color: Colors.blue,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.thanksLibAuthor,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.thanksLibAuthorDesc,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Libraries list
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: libraries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final lib = libraries[index];
              return ListTile(
                  title: Text(lib['name'] ?? ''),
                  subtitle:
                      Text('${lib['author'] ?? ''} • ${lib['license'] ?? ''}'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => UriUtils.launchInBrowser(
                      'https://pub.dev/packages/${lib['name'] ?? ''}',
                      context));
            },
          ),
        ),
      ],
    );
  }

  void _showVersionDialog() {
    final l10n = AppLocalizations.of(context);
    final config = GenericSettingsConfig<dynamic>(
      title: l10n.versionInfo,
      settingsLayout: _buildVersionContent(),
      currentSettings: null,
      onSettingsChanged: (_) {},
      showActions: false,
      isCompact: false,
      barrierDismissible: true,
      padding: const EdgeInsets.all(16),
    );

    GenericSettingsHelper.showSettings(context, config);
  }

  Widget _buildVersionContent() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.tag),
            title: Text(l10n.appVersion),
            subtitle: Text(
                isLoading ? 'Loading...' : (packageInfo?.version ?? 'Unknown')),
          ),
          ListTile(
            leading: const Icon(Icons.science),
            title: Text(l10n.versionType),
            subtitle: Text(currentVersionType.getDisplayName(l10n)),
          ),
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: Text(l10n.platform),
            subtitle: Text(Theme.of(context).platform.name),
          ),
        ],
      ),
    );
  }
}
