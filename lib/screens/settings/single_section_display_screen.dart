import 'package:flutter/material.dart';
import 'package:p2lan/widgets/generic/section_item.dart';

/// Single section display screen for mobile
/// Shows only one settings section at a time
class SingleSectionDisplayScreen extends StatelessWidget {
  final String sectionId;
  final List<SectionItem> sections;
  final VoidCallback? onToolVisibilityChanged;

  const SingleSectionDisplayScreen({
    super.key,
    required this.sectionId,
    required this.sections,
    this.onToolVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final section = sections.firstWhere(
      (s) => s.id == sectionId,
      orElse: () => sections.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(section.title),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: section.content,
        ),
      ),
    );
  }
}
