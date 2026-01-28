import 'package:flutter/material.dart';
import 'package:p2lan/widgets/generic/generic_dialog.dart';
import 'package:p2lan/utils/icon_utils.dart';

class EnterTextDialog extends StatefulWidget {
  final IconData? icon;
  final String title;
  final String? description;
  final String? initialText;
  final String cancelText;
  final String applyText;
  final ValueChanged<String> onApply;

  const EnterTextDialog({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.initialText,
    this.cancelText = 'Cancel',
    this.applyText = 'Apply',
    required this.onApply,
  });

  @override
  State<EnterTextDialog> createState() => _EnterTextDialogState();
}

class _EnterTextDialogState extends State<EnterTextDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GenericDialog(
      header: GenericDialogHeader(
        icon: widget.icon != null ? GenericIcon.icon(widget.icon!) : null,
        title: widget.title,
      ),
      body: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.description != null) ...[
              Text(widget.description!,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _apply(),
            ),
          ],
        ),
      ),
      footer: GenericDialogFooter.twoInARow(
        left: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelText),
        ),
        right: ElevatedButton(
          onPressed: _apply,
          child: Text(widget.applyText),
        ),
        width: 300,
      ),
    );
  }

  void _apply() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Navigator.of(context).pop();
      widget.onApply(text);
    }
  }
}
