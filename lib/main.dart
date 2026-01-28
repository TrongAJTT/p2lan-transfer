// Search @DebugLog for debugging mode toggle in development
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/screens/p2lan_transfer/p2lan_transfer_screen.dart';
import 'package:p2lan/screens/p2lan_transfer/screen_sharing_window.dart';
import 'package:p2lan/screens/app_setup_screen.dart';
import 'package:p2lan/widgets/floating_window_manager.dart';
import 'package:p2lan/services/isar_service.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/app_installation_service.dart';
import 'package:p2lan/services/p2p_services/p2p_notification_service.dart';
import 'package:p2lan/services/p2p_services/p2p_service_manager.dart';
import 'package:p2lan/utils/date_utils.dart';
import 'package:p2lan/utils/network_utils.dart';
import 'package:p2lan/utils/snackbar_utils.dart';
import 'package:p2lan/utils/shortcut_tooltip_utils.dart';
import 'package:p2lan/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io';
import 'package:p2lan/services/version_check_service.dart';
import 'package:p2lan/services/shared_preferences_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Global navigation key for deep linking
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// App boot completion notifier for showing a loading screen during init
final ValueNotifier<bool> bootCompletedNotifier = ValueNotifier<bool>(false);

// --- Workmanager Setup ---
@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // This background task is a simple keep-alive.
    // Its purpose is just to wake the app up periodically to prevent the OS
    // from completely killing the process, allowing P2P timers to continue.
    //
    // Note: We check for silentMode to ensure no notifications are shown

    try {
      final now = DateTime.now();
      final taskInfo = 'Task: $task, Input: $inputData';
      final silentMode = inputData?['silentMode'] ?? true;
      final showNotification = inputData?['showNotification'] ?? false;

      // Only log the execution - no notifications unless explicitly requested
      if (!silentMode || showNotification) {
        logInfo('📱 Background KeepAlive: $taskInfo at $now');
      }

      // Perform minimal work - just prove the app is alive
      // No network calls, no heavy processing, just a simple heartbeat

      if (!silentMode) {
        logInfo('✅ Background KeepAlive completed successfully');
      }
      return Future.value(true);
    } catch (e) {
      // Always log errors regardless of silent mode
      logInfo('❌ Background KeepAlive failed: $e');
      return Future.value(false);
    }
  });
}
// --- End Workmanager Setup ---

// Global flag to track first time setup
bool _isFirstTimeSetup = false;

// Function to complete services initialization after setup
Future<void> completeServicesInitialization() async {
  try {
    logInfo('Completing services initialization after setup...');

    // Initialize P2P Service Manager (includes chat service and all P2P services)
    await P2PServiceManager.init();
    logInfo('P2PServiceManager initialized');

    // Initialize other background services if not already done
    _initializeServicesInBackground();

    logInfo('Services initialization completed after setup');
  } catch (e) {
    logError('Error completing services initialization after setup', e);
  }
}

class BreadcrumbData {
  final String title;
  final String toolType;
  final Widget? tool;
  final IconData? icon;

  const BreadcrumbData({
    required this.title,
    required this.toolType,
    this.tool,
    this.icon,
  });
}

Future<void> main(List<String> args) async {
  // Ensure Flutter binding is initialized first (needed for all windows)
  WidgetsFlutterBinding.ensureInitialized();

  // Check if this is a sub-window (desktop_multi_window)
  // IMPORTANT: Must check args BEFORE any other initialization
  if (args.isNotEmpty && args.first == 'multi_window') {
    // This is a sub-window, run minimal initialization
    try {
      final windowId = int.parse(args[1]);
      final argument = args[2].isEmpty
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(jsonDecode(args[2]) as Map);

      // Log for debugging
      debugPrint('=== SUB-WINDOW START ===');
      debugPrint('Window ID: $windowId');
      debugPrint('Window Type: ${argument['windowType']}');

      // Handle different window types
      final windowType = argument['windowType'] as String?;
      if (windowType == 'screen_sharing') {
        // For sub-windows, run minimal app
        runApp(ScreenSharingWindow(
          controller: WindowController.fromWindowId(windowId),
          args: argument,
        ));
        return; // CRITICAL: Return here to avoid main window initialization
      }

      // Unknown window type
      debugPrint('ERROR: Unknown window type: $windowType');
      return;
    } catch (e, stackTrace) {
      debugPrint('ERROR parsing sub-window args: $e\n$stackTrace');
      return;
    }
  }

  // ========================================================================
  // MAIN WINDOW INITIALIZATION BELOW THIS LINE
  // Sub-windows should have returned above
  // ========================================================================

  debugPrint('=== MAIN WINDOW START ===');

  // Initialize workmanager for background tasks on mobile platforms
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode:
            false, // Always disable debug mode to prevent notifications
      );
      logInfo('WorkManager initialized successfully (notifications disabled)');
    } catch (e) {
      logError('Failed to initialize WorkManager: $e');
    }
  }

  // Setup window manager for desktop platforms
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    await windowManager.ensureInitialized();
    // Don't prevent close - just trigger emergency save
    await windowManager.setPreventClose(false);
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Reduce accessibility tree errors on Windows debug builds
  if (kDebugMode && defaultTargetPlatform == TargetPlatform.windows) {
    // Disable semantic debugging to reduce accessibility bridge errors
    WidgetsBinding.instance.ensureSemantics();
  }

  // Initialize core databases first
  try {
    logInfo('Initializing databases...');

    // Initialize Isar database
    await IsarService.init();
    logInfo('Isar initialized');

    // Wait a bit to ensure Isar is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));

    // Initialize App Installation Service immediately after Isar
    _isFirstTimeSetup = await AppInstallationService.instance.initialize();
    logInfo(
        'AppInstallationService initialized, first time setup: $_isFirstTimeSetup');

    // Check if this is first time setup - if yes, don't initialize yet
    if (_isFirstTimeSetup) {
      logInfo('First time setup detected - delaying full initialization');
      // Don't initialize other services yet, they will be initialized after setup
    } else {
      // Initialize other services for existing installations
      _initializeServicesInBackground();
    }

    // These services no longer have an init() method or are initialized elsewhere
    // await TemplateService.init();
    // await UnifiedRandomStateService.init();
  } catch (e) {
    // Log the error but don't crash the app
    logError('Error during database initialization', e);
    _isFirstTimeSetup = true; // Assume first time setup on error
  }

  // Initialize other services in background after UI starts
  _initializeServicesInBackground();

  runApp(const MainApp());
}

// Initialize ShortcutTooltipUtils from settings
Future<void> _initializeShortcutTooltipUtils() async {
  try {
    final uiSettings =
        await ExtensibleSettingsService.getUserInterfaceSettings();
    ShortcutTooltipUtils.I
        .setShowShortcutsInTooltips(uiSettings.showShortcutsInTooltips);
    logDebug(
        'ShortcutTooltipUtils initialized with value: ${uiSettings.showShortcutsInTooltips}');
  } catch (e) {
    logWarning('Failed to load shortcut tooltip settings, using default: $e');
    // Keep default value (true)
  }
}

// Initialize non-critical services in background
void _initializeServicesInBackground() {
  Future.microtask(() async {
    try {
      logDebug('Initializing background services...');

      // Initialize settings service
      await ExtensibleSettingsService.initialize();
      logDebug('ExtensibleSettingsService initialized');

      // Initialize AppLogger service (depends on settings)
      await AppLogger.instance.initialize();
      logDebug('AppLogger initialized');

      // Log SharedPreferences storage location for debugging
      if (kDebugMode) {
        await _logSharedPreferencesLocation();
      }

      // UnifiedRandomStateService is initialized on demand now
      // await UnifiedRandomStateService.initialize();

      // GraphingCalculatorService is no longer a separate service
      // await GraphingCalculatorService.initialize();

      // Initialize settings controller and load saved settings
      await settingsController.loadSettings();
      logDebug('Settings loaded');

      // Initialize ShortcutTooltipUtils from user interface settings
      await _initializeShortcutTooltipUtils();
      logDebug('ShortcutTooltipUtils initialized');

      // Initialize P2P Notification Service
      await P2PNotificationService.init();
      logDebug('P2PNotificationService initialized');

      // Initialize P2P Service Manager (includes all P2P services)
      await P2PServiceManager.init();
      logDebug('P2PServiceManager initialized');

      // Auto check for new version once per day (if enabled)
      await _maybeCheckForUpdatesDaily();

      // Clear all pairing requests on app startup
      try {
        final p2pManager = P2PServiceManager.instance;
        await p2pManager.clearPairingRequests();
        logInfo('Cleared all pairing requests on app startup');
      } catch (e) {
        logError('Failed to clear pairing requests on startup: $e');
      }

      logInfo('All background services initialized successfully');
      // Mark boot completed so UI can leave the loading screen
      bootCompletedNotifier.value = true;
    } catch (e) {
      // Log initialization errors but continue
      logError('Error during background service initialization', e);
      // Avoid keeping users on loading screen forever
      bootCompletedNotifier.value = true;
    }
  });
}

Future<void> _maybeCheckForUpdatesDaily() async {
  try {
    final settings = await ExtensibleSettingsService.getGeneralSettings();
    if (!settings.autoCheckUpdatesDaily) return;

    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(SharedPreferencesKeys.lastUpdateCheckEpochMs);
    final lastFetch = lastMs != null
        ? DateTime.fromMillisecondsSinceEpoch(lastMs)
        : DateTime.now();
    if (MyDateUtils.isToday(lastFetch)) {
      return;
    }

    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    if (!await NetworkUtils.isNetworkAvailable()) {
      if (ctx.mounted) {
        SnackbarUtils.showTyped(
          ctx,
          AppLocalizations.of(ctx)!.noInternetToFetchNewUpdate,
          SnackBarType.warning,
        );
      }
      return;
    }

    final latest = await VersionCheckService.fetchLatestRelease();
    if (latest != null) {
      final pkg = await PackageInfo.fromPlatform();
      final isNewer =
          VersionCheckService.compareVersions(pkg.version, latest.tag) < 0;
      if (isNewer) {
        if (ctx.mounted) {
          VersionCheckService.showNewVersionAvailableDialog(ctx, latest);
        } else {
          // Retry shortly if UI not ready yet
          Future.delayed(const Duration(seconds: 2), () {
            final retryCtx = navigatorKey.currentContext;
            if (retryCtx != null && retryCtx.mounted) {
              VersionCheckService.showNewVersionAvailableDialog(
                  retryCtx, latest);
            }
          });
        }
      }
    }

    await prefs.setInt(SharedPreferencesKeys.lastUpdateCheckEpochMs,
        DateTime.now().millisecondsSinceEpoch);
  } catch (e) {
    // ignore
  }
}

Future<void> _logSharedPreferencesLocation() async {
  try {
    if (kIsWeb) {
      logDebug('SharedPreferences storage: Web LocalStorage');
      return;
    }

    if (Platform.isAndroid) {
      final pkg = await PackageInfo.fromPlatform();
      final path =
          '/data/data/${pkg.packageName}/shared_prefs/${pkg.packageName}_preferences.xml';
      logDebug('SharedPreferences file (Android): $path');
      return;
    }

    if (Platform.isIOS) {
      final pkg = await PackageInfo.fromPlatform();
      logDebug(
          'SharedPreferences (iOS): NSUserDefaults for bundle ${pkg.packageName}');
      return;
    }

    if (Platform.isMacOS) {
      final pkg = await PackageInfo.fromPlatform();
      logDebug(
          'SharedPreferences (macOS): NSUserDefaults for bundle ${pkg.packageName}');
      return;
    }

    if (Platform.isWindows || Platform.isLinux) {
      final dir = await getApplicationSupportDirectory();
      final filePath = p.join(dir.path, 'shared_preferences.json');
      logDebug('SharedPreferences file: $filePath');
      return;
    }

    final dir = await getApplicationSupportDirectory();
    logDebug('SharedPreferences dir (unknown platform): ${dir.path}');
  } catch (e) {
    logError('Failed to determine SharedPreferences location', e);
  }
}

class SettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    // Load language
    final languageCode = prefs.getString('language') ?? 'en';
    _locale = Locale(languageCode);

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }

  // Force UI refresh - useful when settings change that affect layout
  void refreshUI() {
    notifyListeners();
  }
}

final SettingsController settingsController = SettingsController();

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // ...
    } else if (state == AppLifecycleState.paused) {
      // ...
    } else if (state == AppLifecycleState.detached &&
        (Platform.isAndroid || Platform.isIOS)) {
      // P2P service logic was here, now removed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        return MaterialApp(
          title: appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: settingsController.themeMode,
          locale: settingsController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: ValueListenableBuilder<bool>(
            valueListenable: bootCompletedNotifier,
            builder: (context, bootDone, __) {
              // Show a simple branded loading screen until boot completed
              if (!bootDone && !_isFirstTimeSetup) {
                return const _AppLoadingScreen();
              }

              return PopScope(
                canPop: false, // Prevent default pop behavior
                onPopInvokedWithResult: (bool didPop, dynamic result) async {
                  if (didPop) return; // If already popped, don't do anything

                  // Check if we're on the root screen (home screen)
                  final navigator = navigatorKey.currentState;
                  if (navigator == null || !navigator.canPop()) {
                    // On root screen - implement double back to exit
                    final now = DateTime.now();
                    if (_lastBackPressed == null ||
                        now.difference(_lastBackPressed!) >
                            const Duration(seconds: 3)) {
                      _lastBackPressed = now;
                      // Show snackbar using scaffold messenger
                      final currentContext = navigatorKey.currentContext;
                      if (currentContext != null) {
                        final loc = AppLocalizations.of(currentContext);
                        SnackbarUtils.showTyped(currentContext,
                            loc.pressBackAgainToExit, SnackBarType.info);
                      }
                      return; // Don't pop
                    }

                    // Back again within 3 seconds to exit
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (Platform.isWindows) {
                      await windowManager.destroy();
                    }
                    // Other platforms will implement their own exit logic in the future
                  } else {
                    // Not on root screen - allow normal back navigation
                    navigator.pop();
                  }
                },
                child: FloatingWindowManager(
                  child: _isFirstTimeSetup
                      ? const AppSetupScreen()
                      : P2LanTransferScreen(
                          isEmbedded: false,
                          onToolSelected: (Widget tool, String toolType,
                              {IconData? icon, String? parentCategory}) {
                            // Implement your logic here or leave empty if not needed
                          },
                        ),
                ),
              );
            },
          ),
          routes: const {
            // Routes removed - navigation handled by profile tabs
          },
          navigatorObservers: [
            NavigatorObserver(),
          ],
        );
      },
    );
  }
}

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                appAssetIcon,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              appName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
