import 'package:flutter/material.dart';

/// Information for each panel in the three panels layout
class PanelInfo {
  final String title;
  final IconData? icon;
  final List<Widget>? actions;
  final Widget content;
  final int flex;

  const PanelInfo({
    required this.title,
    this.icon,
    this.actions,
    required this.content,
    this.flex = 1,
  });
}

/// A responsive layout that shows two panels side-by-side on larger screens
/// and as tabs on smaller screens.
class TwoPanelsLayout extends StatefulWidget {
  final List<PanelInfo> panelInfos;
  final PreferredSizeWidget? appBar;
  final bool useCompactTabLayout;
  final double desktopWidthThreshold;
  final Widget? floatingActionButton;

  final int initialIndex;
  final Function(int)? onIndexChanged;

  const TwoPanelsLayout({
    super.key,
    required this.panelInfos,
    this.appBar,
    this.floatingActionButton,
    this.useCompactTabLayout = false,
    this.desktopWidthThreshold = 800,
    this.initialIndex = 0,
    this.onIndexChanged,
  }) : assert(panelInfos.length == 2,
            'TwoPanelsLayout requires exactly 2 panelInfos');

  @override
  _TwoPanelsLayoutState createState() => _TwoPanelsLayoutState();
}

class _TwoPanelsLayoutState extends State<TwoPanelsLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.panelInfos.length - 1);
    _tabController = TabController(
      length: widget.panelInfos.length,
      vsync: this,
      initialIndex: _currentIndex,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(TwoPanelsLayout oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.panelInfos.length != oldWidget.panelInfos.length) {
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
      _tabController = TabController(
        length: widget.panelInfos.length,
        vsync: this,
        initialIndex: _currentIndex,
      );
      _tabController.addListener(_onTabChanged);
    }

    if (widget.initialIndex != oldWidget.initialIndex &&
        widget.initialIndex != _tabController.index) {
      _currentIndex =
          widget.initialIndex.clamp(0, widget.panelInfos.length - 1);
      _tabController.animateTo(_currentIndex);
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final newIndex = _tabController.index;
    if (newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
      widget.onIndexChanged?.call(newIndex);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= widget.desktopWidthThreshold;

    if (isDesktop) {
      return _buildDesktopLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    final desktopContent = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: widget.panelInfos.asMap().entries.map((entry) {
          final index = entry.key;
          final panel = entry.value;

          return Expanded(
            flex: panel.flex,
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == widget.panelInfos.length - 1 ? 0 : 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Panel title bar
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (panel.icon != null) ...[
                          Icon(
                            panel.icon,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            panel.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (panel.actions != null) ...[
                          const SizedBox(width: 8),
                          ...panel.actions!,
                        ],
                      ],
                    ),
                  ),
                  // Panel content
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                        ),
                        child: panel.content,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );

    return Scaffold(
      appBar: widget.appBar,
      body: desktopContent,
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildMobileLayout() {
    final tabContent = Column(
      children: [
        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: widget.panelInfos.length >= 5,
            tabs: widget.panelInfos
                .map((panel) => Tab(
                      icon: widget.useCompactTabLayout
                          ? null
                          : (panel.icon != null
                              ? Icon(panel.icon, size: 20)
                              : null),
                      text: panel.title,
                    ))
                .toList(),
          ),
        ),
        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.panelInfos.map((panel) => panel.content).toList(),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: widget.appBar,
      body: tabContent,
      floatingActionButton: widget.floatingActionButton,
    );
  }

  /// External API for tab navigation
  void navigateToPanel(int panelIndex) {
    if (panelIndex >= 0 && panelIndex < widget.panelInfos.length) {
      setState(() {
        _currentIndex = panelIndex;
      });
      _tabController.animateTo(panelIndex);
      widget.onIndexChanged?.call(panelIndex);
    }
  }

  /// Get current panel index
  int get currentPanelIndex => _currentIndex;
}
