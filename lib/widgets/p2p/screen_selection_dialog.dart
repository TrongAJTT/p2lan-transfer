import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';

/// Screen Selection Dialog for Windows multi-screen support
class ScreenSelectionDialog extends StatefulWidget {
  final List<ScreenInfo> screens;

  const ScreenSelectionDialog({
    super.key,
    required this.screens,
  });

  @override
  State<ScreenSelectionDialog> createState() => _ScreenSelectionDialogState();
}

class _ScreenSelectionDialogState extends State<ScreenSelectionDialog> {
  int? _selectedScreenIndex;

  @override
  void initState() {
    super.initState();
    // Default to primary screen
    final primaryScreen = widget.screens.where((s) => s.isPrimary).firstOrNull;
    _selectedScreenIndex = primaryScreen?.index ?? widget.screens.first.index;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: const Text('Select Screen to Share'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Multiple screens detected. Please select which screen to share:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...widget.screens.map((screen) => _buildScreenOption(screen)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _selectedScreenIndex != null
              ? () => Navigator.of(context).pop(_selectedScreenIndex)
              : null,
          child: const Text('Share Selected'),
        ),
      ],
    );
  }

  Widget _buildScreenOption(ScreenInfo screen) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: RadioListTile<int>(
        value: screen.index,
        groupValue: _selectedScreenIndex,
        onChanged: (value) {
          setState(() {
            _selectedScreenIndex = value;
          });
        },
        title: Text(screen.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resolution: ${screen.width} x ${screen.height}'),
            if (screen.isPrimary)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Primary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        secondary: Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              // Screen representation
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: screen.isPrimary ? Colors.blue[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Screen number
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${screen.index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
