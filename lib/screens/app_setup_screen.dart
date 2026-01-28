import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/main.dart';
import 'package:p2lan/screens/p2lan_transfer/p2lan_transfer_screen.dart';
import 'package:p2lan/screens/terms_of_use_screen.dart';
import 'package:p2lan/services/app_installation_service.dart';
import 'package:p2lan/variables.dart';

class AppSetupScreen extends StatefulWidget {
  const AppSetupScreen({super.key});

  @override
  State<AppSetupScreen> createState() => _AppSetupScreenState();
}

class _AppSetupScreenState extends State<AppSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Config
  static const double _imagesSize = 100;

  // Settings
  Locale _selectedLocale = const Locale('en');
  ThemeMode _selectedTheme = ThemeMode.system;
  bool _agreedToTerms = false;
  bool _isSettingUp = false;

  final List<Locale> _supportedLocales = [
    const Locale('en'),
    const Locale('vi'),
  ];

  final List<ThemeMode> _supportedThemes = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark,
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with English as default for setup
    _selectedLocale = const Locale('en');
    _selectedTheme = settingsController.themeMode;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishSetup() async {
    setState(() {
      _isSettingUp = true;
    });

    try {
      // Apply settings
      await settingsController.setLocale(_selectedLocale);
      await settingsController.setThemeMode(_selectedTheme);

      // Initialize AppInstallation and mark setup as completed
      await AppInstallationService.instance.initialize();
      await AppInstallationService.instance.markFirstTimeSetupCompleted();

      // Complete services initialization
      await completeServicesInitialization();

      // Navigate to main screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => P2LanTransferScreen(
              isEmbedded: false,
              onToolSelected: (Widget tool, String toolType,
                  {IconData? icon, String? parentCategory}) {
                // Implement your logic here or leave empty if not needed
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Setup failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSettingUp = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const Image(
                      image: AssetImage(appAssetIcon),
                      height: _imagesSize,
                      width: _imagesSize),
                  const SizedBox(height: 16),
                  Text(
                    l10n.welcomeToApp,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: .3),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Page content
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildLanguagePage(l10n, theme),
                      _buildThemePage(l10n, theme),
                      _buildPrivacyPage(l10n, theme),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: _previousPage,
                          child: Text(l10n.previous),
                        ),
                      const Spacer(),
                      if (_currentPage < 2)
                        ElevatedButton(
                          onPressed: _nextPage,
                          child: Text(l10n.next),
                        ),
                      if (_currentPage == 2)
                        ElevatedButton(
                          onPressed: _isSettingUp
                              ? null
                              : (_agreedToTerms ? _finishSetup : null),
                          child: _isSettingUp
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.startUsingApp),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePage(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.languageSelection,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.selectYourLanguage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: .7),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _supportedLocales.length,
              itemBuilder: (context, index) {
                final locale = _supportedLocales[index];
                final isSelected = locale == _selectedLocale;
                final localeName = _getLocaleName(locale);

                return Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surface,
                  child: ListTile(
                    title: Text(
                      localeName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLocale = locale;
                      });
                      // Apply locale immediately for preview
                      settingsController.setLocale(locale);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePage(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.themeSelection,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.selectYourTheme,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: .7),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _supportedThemes.length,
              itemBuilder: (context, index) {
                final themeMode = _supportedThemes[index];
                final isSelected = themeMode == _selectedTheme;
                final themeName = _getThemeName(themeMode, l10n);
                final themeIcon = _getThemeIcon(themeMode);

                return Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surface,
                  child: ListTile(
                    leading: Icon(
                      themeIcon,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: .7),
                    ),
                    title: Text(
                      themeName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedTheme = themeMode;
                      });
                      // Apply theme immediately for preview
                      settingsController.setThemeMode(themeMode);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPage(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.privacyAndTerms,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Privacy statement
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.privacy_tip_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.privacyStatement,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.privacyStatementDesc,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Terms agreement
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(l10n.agreeToTerms),
                            ),
                            TextButton(
                              onPressed: () => TermsOfUseScreen.navigateOpen(
                                  context: context,
                                  localeCode: _selectedLocale.languageCode),
                              child: Text(l10n.termsOfUse),
                            ),
                          ],
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return locale.languageCode;
    }
  }

  String _getThemeName(ThemeMode themeMode, AppLocalizations l10n) {
    switch (themeMode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.system;
    }
  }

  IconData _getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings_brightness;
    }
  }
}
