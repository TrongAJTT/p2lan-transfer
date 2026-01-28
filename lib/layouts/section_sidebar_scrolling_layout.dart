import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/utils/size_utils.dart';
import 'package:p2lan/utils/widget_layout_render_helper.dart';
import 'package:p2lan/widgets/generic/section_list_view.dart';
import 'package:p2lan/widgets/generic/section_item.dart';

// New mobile section selection screen
class MobileSectionSelectionScreen extends StatelessWidget {
  final String? title;
  final List<SectionItem> sections;
  final Function(String) onSectionSelected;

  const MobileSectionSelectionScreen({
    super.key,
    this.title,
    required this.sections,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? loc.settings),
      ),
      body: SafeArea(
        child: SectionListView(
          sections: sections,
          onSectionSelected: onSectionSelected,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: loc.showAll,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    SectionSidebarScrollingLayout(sections: sections)),
          );
        },
        child: const Icon(Icons.list),
      ),
    );
  }
}

class SectionSidebarScrollingLayout extends StatefulWidget {
  final String? title;
  final List<SectionItem> sections;
  final bool isEmbedded;
  final String? selectedSectionId;
  final Function(String)? onSectionChanged;
  final bool showViewToggle;

  const SectionSidebarScrollingLayout({
    super.key,
    this.title,
    required this.sections,
    this.isEmbedded = false,
    this.selectedSectionId,
    this.onSectionChanged,
    this.showViewToggle = false,
  });

  @override
  State<SectionSidebarScrollingLayout> createState() =>
      _SectionSidebarScrollingLayoutState();
}

class _SectionSidebarScrollingLayoutState
    extends State<SectionSidebarScrollingLayout> {
  late ScrollController _scrollController;
  String? _currentSectionId;
  final Map<String, GlobalKey> _sectionKeys = {};
  bool _isScrolling = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showSingleSection = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _currentSectionId = widget.selectedSectionId ?? widget.sections.first.id;

    // Create keys for each section
    for (final section in widget.sections) {
      _sectionKeys[section.id] = GlobalKey();
    }

    // Listen to scroll changes
    _scrollController.addListener(_onScroll);

    // Auto-scroll to the selected section after the frame is built
    if (widget.selectedSectionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToSection(widget.selectedSectionId!);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SectionSidebarScrollingLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If a new selectedSectionId is provided, scroll to it
    if (widget.selectedSectionId != null &&
        widget.selectedSectionId != oldWidget.selectedSectionId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToSection(widget.selectedSectionId!);
        }
      });
    }
  }

  void _onScroll() {
    if (_isScrolling) return;

    // Find which section is currently visible
    for (final section in widget.sections) {
      final key = _sectionKeys[section.id];
      if (key?.currentContext != null) {
        final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          final sectionTop = position.dy;
          final sectionHeight = renderBox.size.height;

          // Consider a section "current" if its top is within the viewport
          if (sectionTop <= 200 && sectionTop + sectionHeight > 100) {
            if (section.id != _currentSectionId) {
              setState(() {
                _currentSectionId = section.id;
              });
              widget.onSectionChanged?.call(section.id);
            }
            break;
          }
        }
      }
    }
  }

  void _scrollToSection(String sectionId) {
    final key = _sectionKeys[sectionId];
    if (key?.currentContext != null) {
      _isScrolling = true;
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 600), () {
          _isScrolling = false;
        });
      });

      setState(() {
        _currentSectionId = sectionId;
      });
      widget.onSectionChanged?.call(sectionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1000;

    if (isDesktop) {
      return _buildDesktopLayout();
    } else {
      // Mobile always shows all sections by default
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    if (widget.isEmbedded) {
      return _buildDesktopContent();
    } else {
      return Scaffold(
        body: SafeArea(child: _buildDesktopContent()),
      );
    }
  }

  Widget _buildDesktopContent() {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        // Sidebar (30% width) - Removed header/appbar
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                // Section list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: widget.sections.length,
                    itemBuilder: (context, index) {
                      final section = widget.sections[index];
                      final isSelected = section.id == _currentSectionId;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.7)
                              : null,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : (section.iconColor ?? Colors.grey)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              section.icon,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : section.iconColor ?? Colors.grey,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            section.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                      : null,
                                ),
                          ),
                          subtitle: section.subtitle != null
                              ? Text(
                                  section.subtitle!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer
                                                .withValues(alpha: 0.7)
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                      ),
                                )
                              : null,
                          onTap: () {
                            if (_showSingleSection) {
                              // In single section mode, just change the current section
                              setState(() {
                                _currentSectionId = section.id;
                              });
                              widget.onSectionChanged?.call(section.id);
                            } else {
                              // In list mode, scroll to the section
                              _scrollToSection(section.id);
                            }
                          },
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    },
                  ),
                ),

                // View toggle segment button at bottom of sidebar
                if (widget.showViewToggle)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: WidgetLayoutRenderHelper.twoInARowThreshold(
                        Text(
                          l10n.viewMode,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment(
                              value: false,
                              label: Text(l10n.all),
                              icon: const Icon(Icons.all_inbox, size: 16),
                            ),
                            ButtonSegment(
                              value: true,
                              label: Text(l10n.single),
                              icon: const Icon(Icons.article, size: 16),
                            ),
                          ],
                          selected: {_showSingleSection},
                          onSelectionChanged: (Set<bool> selection) {
                            setState(() {
                              _showSingleSection = selection.first;
                            });
                          },
                          style: SegmentedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        TwoInARowDecorator(
                            widthWidget2: DynamicDimension.expanded()),
                        const TwoInARowConditionType.overallWidth(300),
                        spacing: TwoDimSpacing.specific(
                            vertical: 8, horizontal: 16)),
                  ),
              ],
            ),
          ),
        ),

        // Content area (70% width) - Updated styling for full width sections
        Expanded(
          flex: 7,
          child: Container(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: _showSingleSection
                  ? _buildSingleSection()
                  : _buildAllSections(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title:
                  Text(widget.title ?? AppLocalizations.of(context).settings),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
              ],
            ),
      endDrawer: _buildMobileDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: _buildAllSections(),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //           builder: (context) =>
      //               SectionSidebarScrollingLayout(sections: widget.sections)),
      //     );
      //   },
      //   child: const Icon(Icons.list),
      // ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          if (widget.title != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.sections.length,
              itemBuilder: (context, index) {
                final section = widget.sections[index];
                final isSelected = section.id == _currentSectionId;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.7)
                        : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : (section.iconColor ?? Colors.grey)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        section.icon,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : section.iconColor ?? Colors.grey,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      section.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : null,
                          ),
                    ),
                    subtitle: section.subtitle != null
                        ? Text(
                            section.subtitle!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                              .withValues(alpha: 0.7)
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                    ),
                          )
                        : null,
                    onTap: () {
                      Navigator.of(context).pop(); // Close drawer
                      // On mobile, always scroll to the section (no single mode)
                      _scrollToSection(section.id);
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

  Widget _buildAllSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.sections.map((section) {
        return Container(
          key: _sectionKeys[section.id],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header with full width background - Made smaller
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.4),
                ),
                child: Row(
                  children: [
                    // Icon with background border like sidebar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: section.iconColor ??
                            Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        section.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                          if (section.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              section.subtitle!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Section content with full width background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Theme.of(context).colorScheme.surface,
                child: section.content,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleSection() {
    final currentSection = widget.sections.firstWhere(
      (s) => s.id == _currentSectionId,
      orElse: () => widget.sections.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.4),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: currentSection.iconColor ??
                      Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  currentSection.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentSection.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                    if (currentSection.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        currentSection.subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Section content
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Theme.of(context).colorScheme.surface,
          child: currentSection.content,
        ),
      ],
    );
  }
}
