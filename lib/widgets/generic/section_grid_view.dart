import 'package:flutter/material.dart';
import 'package:p2lan/widgets/generic/section_item.dart';

class SectionGridDecorator {
  final EdgeInsets? padding;
  final double borderRadius;

  const SectionGridDecorator({
    this.padding,
    this.borderRadius = 12.0,
  });
}

Widget _buildSectionCard(
  BuildContext context,
  SectionItem section,
  SectionGridDecorator decorator,
  void Function(String) onSectionSelected,
) {
  final theme = Theme.of(context);

  return Card(
    elevation: 2,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(decorator.borderRadius),
    ),
    child: InkWell(
      onTap: () => onSectionSelected(section.id),
      borderRadius: BorderRadius.circular(decorator.borderRadius),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: (section.iconColor ?? theme.colorScheme.primary)
                  .withValues(alpha: .2),
              radius: 24,
              child: Icon(
                section.icon,
                color: section.iconColor ?? theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    section.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (section.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      section.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}

class AutoScaleSectionGridView extends StatelessWidget {
  final List<SectionItem> sections;
  final Function(String) onSectionSelected;
  final double minCellWidth;
  final double maxCellWidth;
  final double fixedCellHeight;
  final SectionGridDecorator? decorator;

  const AutoScaleSectionGridView({
    super.key,
    required this.sections,
    required this.onSectionSelected,
    required this.minCellWidth,
    required this.fixedCellHeight,
    this.maxCellWidth = -1,
    this.decorator,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDecorator = decorator ?? const SectionGridDecorator();

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: effectiveDecorator.padding ?? const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = (constraints.maxWidth / minCellWidth)
                .floor()
                .clamp(1, sections.length);
            double actualCellWidth =
                (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                    crossAxisCount;

            if (maxCellWidth > 0) {
              while (actualCellWidth > maxCellWidth &&
                  crossAxisCount < sections.length) {
                crossAxisCount++;
                actualCellWidth =
                    (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                        crossAxisCount;
              }
            }

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: sections.map((section) {
                return SizedBox(
                  width: actualCellWidth,
                  height: fixedCellHeight,
                  child: _buildSectionCard(
                    context,
                    section,
                    effectiveDecorator,
                    onSectionSelected,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class SectionGridView extends StatelessWidget {
  final List<SectionItem> sections;
  final Function(String) onSectionSelected;
  final int crossAxisCount;
  final double aspectRatio;
  final SectionGridDecorator? decorator;

  const SectionGridView({
    super.key,
    required this.sections,
    required this.onSectionSelected,
    this.crossAxisCount = 3,
    this.aspectRatio = 1.2,
    this.decorator,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDecorator = decorator ?? const SectionGridDecorator();

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: effectiveDecorator.padding ?? const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth =
                (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                    crossAxisCount;
            final itemHeight = itemWidth / aspectRatio;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: sections.map((section) {
                return SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: _buildSectionCard(
                    context,
                    section,
                    effectiveDecorator,
                    onSectionSelected,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
