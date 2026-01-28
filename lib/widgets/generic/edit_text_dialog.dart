import 'package:flutter/material.dart';

/// A reusable dialog for editing a single line of text with validation.
///
/// Features:
/// - Initial value and optional default value (shows Reset if provided)
/// - Min/max length validation
/// - Customizable title, label, hint, helper/message text, and button labels
/// - Callbacks for cancel, save, reset, and onChanged
/// - Returns the saved string (or default if reset pressed), or null if cancelled
class EditTextDialog extends StatefulWidget {
  final String title;
  final String? message;
  final String label;
  final String? hint;
  final String initialValue;
  final String? defaultValue;
  final int minLength;
  final int maxLength;
  final String saveButtonText;
  final String cancelButtonText;
  final String resetButtonText;
  final TextInputType keyboardType;
  final double? minWidth;
  final double? maxWidth;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCancel;
  final ValueChanged<String>? onSave;
  final VoidCallback? onReset;

  const EditTextDialog({
    super.key,
    required this.title,
    this.message,
    required this.label,
    this.hint,
    required this.initialValue,
    this.defaultValue,
    this.minLength = 0,
    this.maxLength = 20,
    this.saveButtonText = 'Save',
    this.cancelButtonText = 'Cancel',
    this.resetButtonText = 'Reset',
    this.keyboardType = TextInputType.text,
    this.minWidth,
    this.maxWidth,
    this.onChanged,
    this.onCancel,
    this.onSave,
    this.onReset,
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? message,
    required String label,
    String? hint,
    required String initialValue,
    String? defaultValue,
    int minLength = 0,
    int maxLength = 20,
    String saveButtonText = 'Save',
    String cancelButtonText = 'Cancel',
    String resetButtonText = 'Reset',
    TextInputType keyboardType = TextInputType.text,
    double? minWidth,
    double? maxWidth,
    ValueChanged<String>? onChanged,
    VoidCallback? onCancel,
    ValueChanged<String>? onSave,
    VoidCallback? onReset,
  }) async {
    return await showDialog<String>(
      context: context,
      builder: (ctx) => EditTextDialog(
        title: title,
        message: message,
        label: label,
        hint: hint,
        initialValue: initialValue,
        defaultValue: defaultValue,
        minLength: minLength,
        maxLength: maxLength,
        saveButtonText: saveButtonText,
        cancelButtonText: cancelButtonText,
        resetButtonText: resetButtonText,
        keyboardType: keyboardType,
        minWidth: minWidth,
        maxWidth: maxWidth,
        onChanged: onChanged,
        onCancel: onCancel,
        onSave: onSave,
        onReset: onReset,
      ),
    );
  }

  @override
  State<EditTextDialog> createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<EditTextDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _validate(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get textValue => _controller.text.trim();

  void _validate(String value) {
    String? err;
    final trimmed = value.trim();
    if (widget.minLength > 0 && trimmed.length < widget.minLength) {
      err = 'Min ${widget.minLength} characters';
    } else if (trimmed.length > widget.maxLength) {
      err = 'Max ${widget.maxLength} characters';
    }
    setState(() => _error = err);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDefault = (widget.defaultValue != null);
    final canSave = _error == null;

    final contentChild = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.message != null) ...[
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
        ],
        TextField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            errorText: _error,
            border: const OutlineInputBorder(),
            counterText: '${_controller.text.length}/${widget.maxLength}',
          ),
          onChanged: (v) {
            widget.onChanged?.call(v);
            _validate(v);
          },
        ),
      ],
    );

    final constrainedContent = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: widget.minWidth ?? 0,
        maxWidth: widget.maxWidth ?? 1000,
      ),
      child: contentChild,
    );

    return AlertDialog(
      title: Text(widget.title),
      content: constrainedContent,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        // Left-aligned: Cancel
        if (hasDefault)
          TextButton(
            onPressed: () {
              widget.onReset?.call();
              _controller.text = widget.defaultValue!;
            },
            child: Text(widget.resetButtonText),
          ),

        // Right-aligned: Reset (if any) + Save
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                widget.onCancel?.call();
                Navigator.of(context).pop(null);
              },
              child: Text(widget.cancelButtonText),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: canSave
                  ? () {
                      widget.onSave?.call(textValue);
                      Navigator.of(context).pop(textValue);
                    }
                  : null,
              child: Text(widget.saveButtonText),
            ),
          ],
        ),
      ],
    );
  }
}
