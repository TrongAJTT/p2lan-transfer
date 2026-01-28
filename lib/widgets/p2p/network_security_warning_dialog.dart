import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';

class NetworkSecurityWarningDialog extends StatelessWidget {
  final NetworkInfo networkInfo;
  final VoidCallback onProceed;
  final VoidCallback onCancel;

  const NetworkSecurityWarningDialog({
    super.key,
    required this.networkInfo,
    required this.onProceed,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      icon: const Icon(
        Icons.warning,
        color: Colors.orange,
        size: 48,
      ),
      title: Text(l10n.networkSecurityWarning),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.unsecureNetworkDetected,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildWarningItem(
            icon: Icons.wifi,
            title: l10n.currentNetwork,
            description: networkInfo.wifiName ?? 'Unknown WiFi',
          ),
          const SizedBox(height: 12),
          _buildWarningItem(
            icon: Icons.security,
            title: l10n.securityLevel,
            description: _getSecurityDescription(context),
            isWarning: true,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.securityRisks,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.unsecureNetworkRisks,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: onProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.proceedAnyway),
        ),
      ],
    );
  }

  Widget _buildWarningItem({
    required IconData icon,
    required String title,
    required String description,
    bool isWarning = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: isWarning ? Colors.orange : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                description,
                style: TextStyle(
                  color: isWarning ? Colors.orange : Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getSecurityDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (networkInfo.securityLevel) {
      case NetworkSecurityLevel.secure:
        return l10n.secureNetwork;
      case NetworkSecurityLevel.unsecure:
        return l10n.unsecureNetwork;
      case NetworkSecurityLevel.unknown:
        return l10n.unknownSecurity;
    }
  }
}
