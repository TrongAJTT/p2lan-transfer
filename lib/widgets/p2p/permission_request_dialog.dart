import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';

/// A dialog that explains why location permission is needed for P2P functionality.
class PermissionRequestDialog extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  const PermissionRequestDialog({
    super.key,
    required this.onContinue,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.p2pPermissionRequiredTitle),
      content: Text(l10n.p2pPermissionExplanation),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(l10n.p2pPermissionCancel),
        ),
        FilledButton(
          onPressed: onContinue,
          child: Text(l10n.p2pPermissionContinue),
        ),
      ],
    );
  }
}
