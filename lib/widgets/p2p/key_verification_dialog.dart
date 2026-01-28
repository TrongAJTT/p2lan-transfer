import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/utils/snackbar_utils.dart';

/// Dialog for verifying encryption key fingerprints between devices
/// Implements out-of-band authentication as recommended by security experts
class KeyVerificationDialog extends StatefulWidget {
  final P2PUser user;
  final String deviceFingerprint;
  final VoidCallback? onVerified;
  final VoidCallback? onCancelled;

  const KeyVerificationDialog({
    super.key,
    required this.user,
    required this.deviceFingerprint,
    this.onVerified,
    this.onCancelled,
  });

  @override
  State<KeyVerificationDialog> createState() => _KeyVerificationDialogState();
}

class _KeyVerificationDialogState extends State<KeyVerificationDialog> {
  bool _isVerified = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.security, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Verify Encryption')),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explanation
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info,
                        color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Compare these fingerprints with ${widget.user.displayName} to ensure secure communication.',
                        style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Your device fingerprint
            _buildFingerprintSection(
              title: 'Your Device',
              fingerprint: widget.deviceFingerprint,
              icon: Icons.smartphone,
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            // Peer device fingerprint
            _buildFingerprintSection(
              title: widget.user.displayName,
              fingerprint: widget.user.publicKeyFingerprint ?? 'Not available',
              icon: Icons.devices_other,
              color: Colors.green,
            ),

            const SizedBox(height: 16),

            // Verification checkbox
            Card(
              color: _isVerified ? Colors.green.shade50 : Colors.red.shade50,
              child: CheckboxListTile(
                title: Text(
                  'I have confirmed these fingerprints match',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _isVerified
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
                subtitle: Text(
                  'Only check this if you have verified the fingerprints through a secure channel (in person, phone call, etc.)',
                  style: TextStyle(
                    color: _isVerified
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
                value: _isVerified,
                onChanged: (value) {
                  setState(() {
                    _isVerified = value ?? false;
                  });
                },
                activeColor: Colors.green,
              ),
            ),

            const SizedBox(height: 8),

            // Security warning
            if (!_isVerified) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Unverified encryption may be vulnerable to man-in-the-middle attacks.',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onCancelled?.call();
          },
          child: Text(l10n.cancel),
        ),

        // Skip verification (proceed without verification)
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onVerified?.call();

            if (context.mounted) {
              SnackbarUtils.showTyped(
                context,
                'Encryption enabled (unverified)',
                SnackBarType.warning,
              );
            }
          },
          child: Text(
            'Skip',
            style: TextStyle(color: Colors.orange.shade700),
          ),
        ),

        // Proceed with verification
        ElevatedButton.icon(
          onPressed: _isVerified
              ? () {
                  Navigator.of(context).pop();
                  widget.onVerified?.call();

                  if (context.mounted) {
                    SnackbarUtils.showTyped(
                      context,
                      'Encryption verified and enabled',
                      SnackBarType.success,
                    );
                  }
                }
              : null,
          icon: Icon(_isVerified ? Icons.verified : Icons.security),
          label: const Text('Verify'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isVerified ? Colors.green : null,
            foregroundColor: _isVerified ? Colors.white : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFingerprintSection({
    required String title,
    required String fingerprint,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: fingerprint));
                    if (context.mounted) {
                      SnackbarUtils.showTyped(
                        context,
                        'Fingerprint copied',
                        SnackBarType.info,
                      );
                    }
                  },
                  tooltip: 'Copy fingerprint',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                fingerprint,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
