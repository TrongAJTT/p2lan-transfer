import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Generic layout widget for all random generators to ensure consistency
class RandomGeneratorLayout extends StatefulWidget {
  final Widget generatorContent;
  final Widget? historyWidget;
  final bool historyEnabled;
  final bool hasHistory;
  final bool isEmbedded;
  final String title;

  const RandomGeneratorLayout({
    super.key,
    required this.generatorContent,
    this.historyWidget,
    required this.historyEnabled,
    required this.hasHistory,
    required this.isEmbedded,
    required this.title,
  });

  @override
  State<RandomGeneratorLayout> createState() => _RandomGeneratorLayoutState();
}

class _RandomGeneratorLayoutState extends State<RandomGeneratorLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;

    Widget content;

    if (isLargeScreen) {
      if (widget.historyEnabled &&
          widget.hasHistory &&
          widget.historyWidget != null) {
        // Desktop with history: 3:2 ratio, history full height
        content = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Generator content: 60% width (3/5)
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: widget.generatorContent,
              ),
            ),
            const SizedBox(width: 24),
            // History widget: 40% width (2/5), full height
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
                child: widget.historyWidget!,
              ),
            ),
          ],
        );
      } else {
        // Desktop without history: Generator centered, 60% width
        content = Row(
          children: [
            // Left spacer: 20%
            const Expanded(flex: 1, child: SizedBox()),
            // Generator content: 60%
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: widget.generatorContent,
              ),
            ),
            // Right spacer: 20%
            const Expanded(flex: 1, child: SizedBox()),
          ],
        );
      }
    } else {
      // Mobile: Tab layout
      if (widget.historyEnabled &&
          widget.hasHistory &&
          widget.historyWidget != null) {
        final loc = AppLocalizations.of(context);
        content = Column(
          children: [
            TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  icon: const Icon(Icons.casino),
                  text: loc.random,
                ),
                Tab(
                  icon: const Icon(Icons.history),
                  text: loc.generationHistory,
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Random tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: widget.generatorContent,
                  ),
                  // History tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: widget.historyWidget!,
                  ),
                ],
              ),
            ),
          ],
        );
      } else {
        // Mobile without history: Single scroll view
        content = SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: widget.generatorContent,
        );
      }
    }

    // Return either the content directly (if embedded) or wrapped in a Scaffold
    if (widget.isEmbedded) {
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 0,
        ),
        body: content,
      );
    }
  }
}

/// Generic history widget builder for consistency
class RandomGeneratorHistoryWidget extends StatelessWidget {
  final String historyType;
  final List<dynamic> history;
  final String title;
  final VoidCallback onClearHistory;
  final void Function(String) onCopyItem;
  final Widget Function(dynamic item, BuildContext context)? customItemBuilder;

  const RandomGeneratorHistoryWidget({
    super.key,
    required this.historyType,
    required this.history,
    required this.title,
    required this.onClearHistory,
    required this.onCopyItem,
    this.customItemBuilder,
  });

  Widget _buildListItem(dynamic item, BuildContext context) {
    if (customItemBuilder != null) {
      return customItemBuilder!(item, context);
    }

    final loc = AppLocalizations.of(context);

    // Format timestamp based on locale
    String formattedTimestamp;
    try {
      final timestamp = item.timestamp as DateTime;
      final locale = Localizations.localeOf(context);

      if (locale.languageCode == 'vi') {
        // Vietnamese format: dd/MM/yyyy HH:mm
        formattedTimestamp =
            DateFormat('dd/MM/yyyy HH:mm', 'vi').format(timestamp);
      } else {
        // International format: yyyy-MM-dd HH:mm
        formattedTimestamp =
            DateFormat('yyyy-MM-dd HH:mm', 'en').format(timestamp);
      }
    } catch (e) {
      // Fallback if timestamp parsing fails
      formattedTimestamp = item.timestamp.toString().substring(0, 19);
    }

    // Default item builder
    return ListTile(
      dense: true,
      title: Text(
        item.value.toString(),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${loc.generatedAt}: $formattedTimestamp',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy, size: 18),
        onPressed: () => onCopyItem(item.value.toString()),
        tooltip: loc.copyToClipboard,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onClearHistory,
                  child: Text(loc.clearHistory),
                ),
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              TextButton(
                onPressed: onClearHistory,
                child: Text(loc.clearHistory),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      final loc = AppLocalizations.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              loc.noHistoryYet,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.noHistoryMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.of(context).size.width < 1200;

        if (isMobile) {
          // Mobile in tab: Use full height with Expanded ListView
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const Divider(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) =>
                          _buildListItem(history[index], context),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Desktop: Use Column with Expanded for full height
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const Divider(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) =>
                          _buildListItem(history[index], context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
