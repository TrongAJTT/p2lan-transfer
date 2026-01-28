// parsers/markdown_info_parser.dart
import 'dart:ui';

import 'package:p2lan/models/info_models.dart';
import 'package:p2lan/utils/icon_mapper.dart';

class MarkdownInfoParser {
  InfoPage parse(String content) {
    final lines = content.split('\n');

    // Phân tích header và overview
    final title =
        lines.first.startsWith('# ') ? lines.first.substring(2).trim() : '';
    final overview = lines.length > 1 ? lines[1].trim() : '';

    // Phân tích các section
    final sections = <InfoSection>[];
    List<String> currentSectionLines = [];
    for (int i = 2; i < lines.length; i++) {
      final line = lines[i];
      if (line.startsWith('## ')) {
        if (currentSectionLines.isNotEmpty &&
            currentSectionLines.any((l) => l.trim().isNotEmpty)) {
          sections.add(_parseSection(currentSectionLines));
        }
        currentSectionLines = [line];
      } else {
        currentSectionLines.add(line);
      }
    }
    if (currentSectionLines.isNotEmpty &&
        currentSectionLines.any((l) => l.trim().isNotEmpty)) {
      sections.add(_parseSection(currentSectionLines));
    }

    return InfoPage(title: title, overview: overview, sections: sections);
  }

  List<InfoSection> parseSections(String content) {
    final lines = content.split('\n');
    final sections = <InfoSection>[];
    List<String> currentSectionLines = [];

    for (final line in lines) {
      if (line.startsWith('## ')) {
        if (currentSectionLines.isNotEmpty) {
          sections.add(_parseSection(currentSectionLines));
          currentSectionLines.clear();
        }
      }
      currentSectionLines.add(line);
    }

    if (currentSectionLines.isNotEmpty) {
      sections.add(_parseSection(currentSectionLines));
    }

    return sections;
  }

  InfoSection _parseSection(List<String> lines) {
    final headerLine = lines.first;
    // RegExp để lấy icon, color, title từ "## [icon, color] Title"
    final headerMatch =
        RegExp(r'##\s*\[([^,]+),\s*([^\]]+)\]\s*(.+)').firstMatch(headerLine);

    final title = headerMatch?.group(3)?.trim() ?? 'Section';
    final iconName = headerMatch?.group(1)?.trim() ?? 'help';
    final colorName = headerMatch?.group(2)?.trim() ?? 'grey';

    final items = <InfoItem>[];
    String? currentSubSectionTitle;

    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;

      // Phân tích Divider Item: "---"
      if (line.trim() == '---') {
        items.add(DividerInfoItem());
        continue;
      }

      // Phân tích PlainSubSectionInfoItem: "- [#] Title: Description" or just "[#] Title"
      if (line.startsWith('[#] ')) {
        final match = RegExp(r'\[#\]\s*(.+):\s*(.+)').firstMatch(line);
        if (match != null) {
          currentSubSectionTitle = match.group(1)?.trim();
          items.add(PlainSubSectionInfoItem(
            title: currentSubSectionTitle!,
            description: match.group(2)?.trim(),
          ));
        } else {
          currentSubSectionTitle = line.substring(3).trim();
          items.add(PlainSubSectionInfoItem(title: currentSubSectionTitle));
        }
        continue;
      }

      // Phân tích Sub-section Title: "[#:#HexCode] Title" or "[#:colorName] Title"
      if (line.startsWith('[#:') && line.contains(']')) {
        var match = RegExp(r'\[#:(#[0-9a-fA-F]+)\]\s*(.+)').firstMatch(line);
        if (match != null) {
          final color = IconMapper.getColor(match.group(1)!.trim());
          final title = match.group(2)!.trim();
          items.add(SubSectionTitleInfoItem(title: title, color: color));
          continue;
        }

        match = RegExp(r'\[#:(\w+)\]\s*(.+)').firstMatch(line);
        if (match != null) {
          final color = IconMapper.getColor(match.group(1)!.trim());
          final title = match.group(2)!.trim();
          items.add(SubSectionTitleInfoItem(title: title, color: color));
          continue;
        }
      }

      // Phân tích Feature Item: "- [icon:icon_name] Title: Desc", icon là hard text
      var featureMatch =
          RegExp(r'-\s*\[icon:([^\]]+)\]\s*([^:]+):\s*(.+)').firstMatch(line);
      if (featureMatch != null) {
        items.add(FeatureInfoItem(
          icon: IconMapper.getIcon(featureMatch.group(1)!.trim()),
          title: featureMatch.group(2)!.trim(),
          description: featureMatch.group(3)!.trim(),
        ));
        continue;
      }

      // Phân tích Colored Shape Item: "- [shape:circle/square,#HexColor] Title: Desc"
      featureMatch =
          RegExp(r'-\s*\[shape:(circle|square),#([\w]+)\]\s*([^:]+):\s*(.+)')
              .firstMatch(line);
      if (featureMatch != null) {
        items.add(ColoredShapeInfoItem(
          shape: featureMatch.group(1)!.trim(),
          color: Color(
              int.parse(featureMatch.group(2)!.trim().substring(1), radix: 16)),
          title: featureMatch.group(3)!.trim(),
          description: featureMatch.group(4)!.trim(),
        ));
        continue;
      }

      // Phân tích LinkButtonInfoItem: "([url]text)"
      if (line.startsWith('([') && line.contains(']') && line.contains(')')) {
        final linkMatch = RegExp(r'\(\[([^\]]+)\](.+)\)').firstMatch(line);
        if (linkMatch != null) {
          items.add(LinkButtonInfoItem(
            url: linkMatch.group(1)!.trim(),
            text: linkMatch.group(2)!.trim(),
          ));
          continue;
        }
      }

      // Phân tích Colored Shape Item: "- [shape:circle/square,ColorName] Title: Desc"
      featureMatch =
          RegExp(r'-\s*\[shape:(circle|square),([a-zA-Z]+)\]\s*([^:]+):\s*(.+)')
              .firstMatch(line);
      if (featureMatch != null) {
        items.add(ColoredShapeInfoItem(
          shape: featureMatch.group(1)!.trim(),
          color: IconMapper.getColor(featureMatch.group(2)!.trim()),
          title: featureMatch.group(3)!.trim(),
          description: featureMatch.group(4)!.trim(),
        ));
        continue;
      }

      // Phân tích dòng trống Blank Line Item: [blank]" hoặc "[blank:N]" với N là số dòng trống
      if (line.trim().startsWith('[blank')) {
        final match = RegExp(r'\[blank:(\d+)\]').firstMatch(line);
        if (match != null) {
          final spaceCount = int.tryParse(match.group(1) ?? '1') ?? 1;
          items.add(BlankLineInfoItem(spaceCount: spaceCount));
        } else {
          items.add(BlankLineInfoItem());
        }
        continue;
      }

      // Phân tích Step Item: "1. Title: description"
      featureMatch = RegExp(r'(\d+)\.\s*([^:]+):\s*(.+)').firstMatch(line);
      if (featureMatch != null) {
        items.add(StepInfoItem(
          step: int.parse(featureMatch.group(1)!),
          title: featureMatch.group(2)!.trim(),
          description: featureMatch.group(3)!.trim(),
        ));
        continue;
      }

      // Phân tích Unordered List Item: "- content"
      if (line.trim().startsWith('- ')) {
        items.add(UnorderListItem(content: line.trim().substring(2)));
        continue;
      }

      // Phân tích Math Expression Item: "$expression$"
      if (line.trim().startsWith('\$') && line.trim().endsWith('\$')) {
        items.add(MathExpressionItem(
            expression: line.trim().substring(1, line.length - 2)));
        continue;
      }

      // Text thông thường
      else {
        items.add(ParagraphInfoItem(text: line.trim()));
      }
    }

    return InfoSection(
      title: title,
      icon: IconMapper.getIcon(iconName),
      color: IconMapper.getColor(colorName),
      items: items,
    );
  }
}
