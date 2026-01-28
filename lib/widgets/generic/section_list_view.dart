import 'package:flutter/material.dart';
import 'package:p2lan/widgets/generic/section_item.dart';

class SectionListView extends StatelessWidget {
  final List<SectionItem> sections;
  final Function(String) onSectionSelected;
  final EdgeInsets? padding;

  const SectionListView({
    super.key,
    required this.sections,
    required this.onSectionSelected,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: sections.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 72, endIndent: 16),
      itemBuilder: (context, index) {
        final section = sections[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: () => onSectionSelected(section.id),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  (section.iconColor ?? Theme.of(context).colorScheme.primary)
                      .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              section.icon,
              color: section.iconColor ?? Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          title: Text(
            section.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: section.subtitle != null
              ? Text(
                  section.subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                )
              : null,
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }
}
