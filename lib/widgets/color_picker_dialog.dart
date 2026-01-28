import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:p2lan/l10n/app_localizations.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final String title;
  final String subtitle;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.title,
    required this.subtitle,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;
  int _currentPickerType = 0;

  // 50 predefined colors
  static const List<Color> _predefinedColors = [
    // Primary colors
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,

    // Darker shades
    Color(0xFF8B0000), // Dark red
    Color(0xFF4B0082), // Indigo
    Color(0xFF006400), // Dark green
    Color(0xFF8B4513), // Saddle brown
    Color(0xFF2F4F4F), // Dark slate gray
    Color(0xFF800080), // Purple
    Color(0xFF008080), // Teal
    Color(0xFF000080), // Navy
    Color(0xFF800000), // Maroon
    Color(0xFF008000), // Green

    // Lighter shades
    Color(0xFFFFB6C1), // Light pink
    Color(0xFFE6E6FA), // Lavender
    Color(0xFFB0E0E6), // Powder blue
    Color(0xFF98FB98), // Pale green
    Color(0xFFFFFFE0), // Light yellow
    Color(0xFFFFE4E1), // Misty rose
    Color(0xFFF0F8FF), // Alice blue
    Color(0xFFE0FFFF), // Light cyan
    Color(0xFFF5FFFA), // Mint cream
    Color(0xFFFFF8DC), // Cornsilk

    // Vibrant colors
    Color(0xFFFF1493), // Deep pink
    Color(0xFF00FF00), // Lime
    Color(0xFF00FFFF), // Aqua
    Color(0xFFFF00FF), // Magenta
    Color(0xFFFFFF00), // Yellow
    Color(0xFFFF4500), // Orange red
    Color(0xFF32CD32), // Lime green
    Color(0xFF1E90FF), // Dodger blue
    Color(0xFFFF69B4), // Hot pink
    Color(0xFF00CED1), // Dark turquoise
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width < 500
              ? MediaQuery.of(context).size.width * 0.9
              : 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.color_lens,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.subtitle.isNotEmpty)
                          Text(
                            widget.subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Selected color preview
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    l10n.selectedColor,
                    style: TextStyle(
                      color: _selectedColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Picker type selector
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 0,
                    label: Text(l10n.predefinedColors),
                    icon: const Icon(Icons.palette),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text(l10n.customColor),
                    icon: const Icon(Icons.color_lens),
                  ),
                ],
                selected: {_currentPickerType},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _currentPickerType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Color picker content
              Expanded(
                child: _currentPickerType == 0
                    ? _buildPredefinedColorsGrid()
                    : _buildCustomColorPicker(),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selectedColor),
                    child: Text(l10n.select),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredefinedColorsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _predefinedColors.length,
      itemBuilder: (context, index) {
        final color = _predefinedColors[index];
        final isSelected = color.toARGB32() == _selectedColor.toARGB32();

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    size: 16,
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildCustomColorPicker() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Color wheel picker
          ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            pickerAreaHeightPercent: 0.7,
            enableAlpha: false,
            displayThumbColor: true,
            portraitOnly: true,
            hexInputBar: true,
            colorPickerWidth: 300,
            pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ],
      ),
    );
  }
}
