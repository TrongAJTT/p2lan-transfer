import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/widgets/hold_to_confirm_dialog.dart';

class BatchDeleteDialog extends StatelessWidget {
  final int templateCount;
  final VoidCallback onConfirm;

  const BatchDeleteDialog({
    Key? key,
    required this.templateCount,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return HoldToConfirmDialog(
      title: l10n.confirmBatchDelete,
      content: l10n.typeConfirmToDelete(templateCount),
      cancelText: l10n.batchDelete,
      holdText: l10n.holdToDelete,
      processingText: l10n.deleting,
      instructionText: l10n.holdToDeleteInstruction,
      onConfirmed: () {
        Navigator.of(context).pop();
        onConfirm();
      },
      holdDuration: const Duration(seconds: 5),
      actionIcon: Icons.delete_forever,
      l10n: l10n,
    );
  }
}
