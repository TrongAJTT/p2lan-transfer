import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';

class UserPairingDialog extends StatefulWidget {
  final P2PUser user;
  final Function(bool saveConnection, bool trustUser) onPair;

  const UserPairingDialog({
    super.key,
    required this.user,
    required this.onPair,
  });

  @override
  State<UserPairingDialog> createState() => _UserPairingDialogState();
}

class _UserPairingDialogState extends State<UserPairingDialog> {
  bool _saveConnection = false;
  bool _trustUser = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.link,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text('${l10n.pair} ${l10n.devices}'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pairWithDevice,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),

          // User info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).primaryColor,
                      child: Icon(
                        _getUserPlatformIcon(widget.user),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${widget.user.ipAddress}:${widget.user.port}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.fingerprint,
                  label: l10n.deviceId,
                  value: widget.user.deviceId.length > 20
                      ? '${widget.user.deviceId.substring(0, 20)}...'
                      : widget.user.deviceId,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.access_time,
                  label: l10n.discoveryTime,
                  value: _formatTime(widget.user.lastSeen),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Save connection option
          CheckboxListTile(
            value: _saveConnection,
            onChanged: (value) {
              setState(() {
                _saveConnection = value ?? false;
              });
            },
            title: Text(l10n.saveConnection),
            subtitle: Text(
              l10n.autoReconnectDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),

          // Trust user option
          CheckboxListTile(
            value: _trustUser,
            onChanged: (value) {
              setState(() {
                _trustUser = value ?? false;
              });
            },
            title: Text(l10n.trustThisUser),
            subtitle: Text(
              l10n.allowFileTransfersWithoutConfirmation,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),

          const SizedBox(height: 12),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.pairingNotificationInfo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onPair(_saveConnection, _trustUser);
          },
          child: Text(l10n.sendRequest),
        ),
      ],
    );
  }

  IconData _getUserPlatformIcon(P2PUser user) {
    switch (user.platform) {
      case UserPlatform.android:
        return Icons.android;
      case UserPlatform.ios:
        return Icons.phone_iphone;
      case UserPlatform.windows:
        return Icons.computer;
      case UserPlatform.macos:
        return Icons.laptop_mac;
      case UserPlatform.linux:
        return Icons.laptop;
      case UserPlatform.web:
        return Icons.web;
      case UserPlatform.unknown:
        return Icons.device_unknown;
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else {
      return l10n.daysAgo(difference.inDays);
    }
  }
}
