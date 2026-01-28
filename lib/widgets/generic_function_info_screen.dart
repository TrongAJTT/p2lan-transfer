import 'package:flutter/material.dart';
import 'package:p2lan/models/info_models.dart';
import 'package:p2lan/utils/url_utils.dart';

class GenericInfoScreen extends StatelessWidget {
  final InfoPage page;
  const GenericInfoScreen({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              page.overview,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          // Sections
          ...page.sections.map((section) => buildSectionWidget(theme, section)),
        ],
      ),
    );
  }

  static Widget buildSectionWidget(ThemeData theme, InfoSection section) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(section.icon, color: section.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                        color: section.color, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Section Items
            ...section.items.map((item) => _buildItemWidget(theme, item)),
          ],
        ),
      ),
    );
  }

  static Widget _buildItemWidget(ThemeData theme, InfoItem item) {
    if (item is FeatureInfoItem) {
      return _buildFeatureInfoItem(theme, item);
    }
    if (item is DividerInfoItem) {
      return const Divider();
    }
    if (item is ColoredShapeInfoItem) {
      return _buildColoredShapeItem(theme, item);
    }
    if (item is SubSectionTitleInfoItem) {
      return _buildSubSectionTitleInfoItem(theme, item);
    }
    if (item is LinkButtonInfoItem) {
      return _buildLinkButtonItem(theme, item);
    }
    if (item is StepInfoItem) {
      return _buildStepInfoItem(theme, item);
    }
    if (item is PlainSubSectionInfoItem) {
      return _buildPlainSubSectionInfoItem(theme, item);
    }
    if (item is MathExpressionItem) {
      return _buildMathExpressionItem(theme, item);
    }
    if (item is UnorderListItem) {
      return _buildUnorderListItem(theme, item);
    }
    if (item is ParagraphInfoItem) {
      return _buildParagraphInfoItem(theme, item);
    }
    if (item is BlankLineInfoItem) {
      return _buildBlankLineItem(theme, item);
    }
    return const SizedBox.shrink();
  }

  static Widget _buildLinkButtonItem(ThemeData theme, LinkButtonInfoItem item) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: TextButton(
          onPressed: () => UriUtils.launchInBrowser(item.url, context),
          style: OutlinedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: theme.colorScheme.primary.withValues(alpha: .1),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: .3),
            ),
          ),
          child: Text(
            item.text,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }

  static Widget _buildColoredShapeItem(
      ThemeData theme, ColoredShapeInfoItem item) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: item.shape == 'circle' ? BoxShape.circle : BoxShape.rectangle,
          color: item.color,
        ),
      ),
      title: Text(item.title, style: theme.textTheme.bodyLarge),
      subtitle: Text(item.description, style: theme.textTheme.bodyMedium),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      minVerticalPadding: 0,
      dense: true,
    );
  }

  static Widget _buildFeatureInfoItem(ThemeData theme, FeatureInfoItem item) {
    return ListTile(
      leading:
          Icon(item.icon, color: theme.iconTheme.color?.withValues(alpha: .7)),
      title: Text(item.title, style: theme.textTheme.titleMedium),
      subtitle: Text(item.description, style: theme.textTheme.bodyMedium),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      minVerticalPadding: 0,
      dense: true,
    );
  }

  static Widget _buildSubSectionTitleInfoItem(
      ThemeData theme, SubSectionTitleInfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        item.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: item.color,
        ),
      ),
    );
  }

  static Widget _buildStepInfoItem(ThemeData theme, StepInfoItem item) {
    return ListTile(
      leading: CircleAvatar(
        radius: 14,
        child: Text('${item.step}'),
      ),
      title: Text(item.title, style: theme.textTheme.bodyLarge),
      subtitle: Text(item.description, style: theme.textTheme.bodyMedium),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      minVerticalPadding: 0,
      dense: true,
    );
  }

  static Widget _buildPlainSubSectionInfoItem(
      ThemeData theme, PlainSubSectionInfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          if (item.description != null)
            Text(item.description!, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  static Widget _buildMathExpressionItem(
      ThemeData theme, MathExpressionItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Center(
        child: Text(
          item.expression,
          style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Courier'),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  static Widget _buildUnorderListItem(ThemeData theme, UnorderListItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: theme.textTheme.bodyLarge),
          Expanded(
              child: Text(item.content, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  static Widget _buildParagraphInfoItem(
      ThemeData theme, ParagraphInfoItem item) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(item.text, style: theme.textTheme.bodyMedium));
  }

  static Widget _buildBlankLineItem(ThemeData theme, BlankLineInfoItem item) {
    return SizedBox(height: item.spaceCount * 8.0); // Adjust space as needed
  }
}

class GenericInfoSectionList extends StatelessWidget {
  final List<InfoSection> sections;

  const GenericInfoSectionList({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections
            .map((section) => GenericInfoScreen.buildSectionWidget(
                  Theme.of(context),
                  section,
                ))
            .toList(),
      ),
    );
  }
}
