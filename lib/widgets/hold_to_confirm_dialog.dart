import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/utils/size_utils.dart';
import 'package:p2lan/utils/widget_layout_render_helper.dart';
import 'package:p2lan/widgets/generic/generic_dialog.dart';
import 'package:p2lan/widgets/hold_button.dart';

// Hold-to-confirm dialog widget - reusable for any confirmation action
class HoldToConfirmDialog extends StatefulWidget {
  final String title;
  final String content;
  final String? cancelText;
  final String holdText;
  final String processingText;
  final String? instructionText;
  final VoidCallback onConfirmed;
  final Duration holdDuration;
  final IconData actionIcon;
  final AppLocalizations l10n;

  const HoldToConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.holdText,
    required this.processingText,
    required this.onConfirmed,
    required this.holdDuration,
    required this.actionIcon,
    required this.l10n,
    this.cancelText,
    this.instructionText,
  });

  @override
  State<HoldToConfirmDialog> createState() => _HoldToConfirmDialogState();
}

class _HoldToConfirmDialogState extends State<HoldToConfirmDialog>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: widget.holdDuration,
      vsync: this,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isCompleted) {
        _isCompleted = true;
        widget.onConfirmed();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final holdSeconds = widget.holdDuration.inSeconds;
    final defaultInstruction =
        'Hold the button for $holdSeconds seconds to confirm';

    return GenericDialog(
      header: GenericDialogHeader(title: widget.title),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.content),
          const SizedBox(height: 16),
          Text(
            widget.instructionText ?? defaultInstruction,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      footer: GenericDialogFooter(
        child: WidgetLayoutRenderHelper.twoInARowThreshold(
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(widget.l10n.cancel),
            ),
            HoldButton(
              text: widget.holdText,
              onHoldComplete: widget.onConfirmed,
              holdDuration: widget.holdDuration,
            ),
            TwoInARowDecorator(
              widthWidget1: DynamicDimension.percentage(25),
              widthWidget2: DynamicDimension.percentage(75),
            ),
            const TwoInARowConditionType.overallWidth(300)),
      ),
      decorator: GenericDialogDecorator(
          width: DynamicDimension.flexibilityMax(90, 600),
          displayTopDivider: true),
    );
  }
}
