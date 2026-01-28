import 'package:flutter/material.dart';
import 'package:p2lan/widgets/generic/radial_menu.dart';

enum FileCategory {
  downloads('Downloads', Icons.download, Colors.blue),
  videos('Videos', Icons.video_library, Colors.red),
  images('Images', Icons.photo_library, Colors.green),
  documents('Documents', Icons.description, Colors.orange),
  audio('Audio', Icons.audio_file, Colors.purple);

  const FileCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// A specialized radial menu for selecting file categories.
///
/// This widget acts as a wrapper around the generic [RadialMenu],
/// providing it with the specific [FileCategory] items.
class FileTypeRadialMenu extends StatelessWidget {
  final VoidCallback? onCancel;
  final Function(FileCategory? category)? onCategorySelected;
  final double radius;
  final Offset initialPosition;

  const FileTypeRadialMenu({
    super.key,
    this.onCancel,
    this.onCategorySelected,
    this.radius = 130.0,
    required this.initialPosition,
  });

  @override
  Widget build(BuildContext context) {
    // Convert the enum into a list of generic RadialMenuItem objects.
    final items = FileCategory.values.map((category) {
      return RadialMenuItem<FileCategory>(
        value: category,
        label: category.label,
        icon: category.icon,
        color: category.color,
      );
    }).toList();

    return RadialMenu<FileCategory>(
      items: items,
      radius: radius,
      initialPosition: initialPosition,
      onCancel: onCancel,
      onItemSelected: (category) {
        onCategorySelected?.call(category);
      },
    );
  }
}
