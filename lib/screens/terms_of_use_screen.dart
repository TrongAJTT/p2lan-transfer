import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/utils/network_utils.dart';
import 'package:p2lan/variables.dart';
import 'package:p2lan/utils/variables_utils.dart';
import 'package:p2lan/widgets/generic/network_required_placeholder.dart';

class TermsOfUseScreen extends StatefulWidget {
  final String localeCode;
  const TermsOfUseScreen({super.key, this.localeCode = 'en'});

  @override
  State<TermsOfUseScreen> createState() => _TermsOfUseScreenState();

  static void navigateOpen(
      {required BuildContext context, required String localeCode}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TermsOfUseScreen(localeCode: localeCode),
      ),
    );
  }
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  String? _termsContent;
  bool _isLoading = true;
  String? _error;
  bool _hasNetwork = true;

  // Keyboard shortcut focus node
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkNetworkThenLoad();
  }

  Future<void> _checkNetworkThenLoad() async {
    final has = await NetworkUtils.isNetworkAvailable();
    if (!mounted) return;
    setState(() => _hasNetwork = has);
    if (has) {
      _loadTermsContent();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadTermsContent();
    }

    // Request focus for keyboard shortcuts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_keyboardFocusNode.hasFocus) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  void _handleKeyboardShortcuts(KeyDownEvent event) {
    // Debug: Print key events to help debug
    logDebug(
        'Settings Key event: ${event.logicalKey}, Focus: ${_keyboardFocusNode.hasFocus}');

    // Esc: Exit settings
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      logDebug('Executing: Exit terms of use screen');
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }
  }

  Widget _wrapWithKeyboardListener(Widget child) {
    final isDesktop = !isMobileLayoutContext(context);
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: isDesktop,
      onKeyEvent: (KeyEvent event) {
        if (!isDesktop) return;
        if (event is KeyDownEvent) _handleKeyboardShortcuts(event);
      },
      child: child,
    );
  }

  String get actualTermsUrl =>
      termsUrl.replaceFirst('<locale>', widget.localeCode);

  Future<void> _loadTermsContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await http.get(Uri.parse(actualTermsUrl));

      if (response.statusCode == 200) {
        setState(() {
          _termsContent = response.body;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load terms: HTTP ${response.statusCode}';
          _isLoading = false;
        });
        logError(_error!);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load terms: $e';
        _isLoading = false;
      });
      logError(_error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return _wrapWithKeyboardListener(Scaffold(
      appBar: AppBar(
        title: Text(l10n.termsOfUse),
        elevation: 0,
      ),
      body: _buildBody(l10n, theme),
    ));
  }

  Widget _buildBody(AppLocalizations l10n, ThemeData theme) {
    if (!_hasNetwork) {
      return NetworkRequiredPlaceholder(
        title: l10n.noNetworkConnection,
        description: l10n.internetRequiredToViewThisPage,
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTermsContent,
              child: Text(l10n.reload),
            ),
          ],
        ),
      );
    }

    if (_termsContent == null) {
      return Center(
        child: Text(
          l10n.noData,
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Markdown(
        data: _termsContent!,
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
          p: theme.textTheme.bodyMedium,
          h1: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          h2: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          h3: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
