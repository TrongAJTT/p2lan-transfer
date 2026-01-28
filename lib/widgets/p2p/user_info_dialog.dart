import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';

class UserInfoDialog extends StatelessWidget {
  final P2PUser user;

  const UserInfoDialog({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getUserStatusColor(user),
            child: Icon(
              _getUserStatusIcon(user),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.displayName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              context,
              l10n.appInstallationId,
              user.id,
              icon: Icons.fingerprint,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              l10n.ipAddress,
              user.ipAddress,
              icon: Icons.location_on,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              l10n.port,
              user.port.toString(),
              icon: Icons.router,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Platform',
              _getPlatformDisplayName(user.platform),
              icon: _getUserStatusIcon(user),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              l10n.status,
              user.isOnline ? l10n.online : l10n.offline,
              icon: user.isOnline ? Icons.circle : Icons.circle_outlined,
              statusColor: user.isOnline ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              l10n.lastSeen,
              _formatLastSeen(user.lastSeen),
              icon: Icons.access_time,
            ),
            if (user.pairedAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                l10n.pairedSince,
                _formatPairedAt(user.pairedAt!),
                icon: Icons.link,
              ),
            ],
            const SizedBox(height: 16),
            _buildStatusChips(l10n),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    required IconData icon,
    Color? statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: statusColor ?? Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChips(AppLocalizations l10n) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        if (user.isPaired)
          Chip(
            label: Text(l10n.paired),
            avatar: const Icon(Icons.link, size: 16),
            backgroundColor: Colors.blue,
            labelStyle: const TextStyle(color: Colors.white),
          ),
        if (user.isTrusted)
          Chip(
            label: Text(l10n.trust),
            avatar: const Icon(Icons.verified_user, size: 16),
            backgroundColor: Colors.green,
            labelStyle: const TextStyle(color: Colors.white),
          ),
        if (user.isStored)
          Chip(
            label: Text(l10n.saved),
            avatar: const Icon(Icons.save, size: 16),
            backgroundColor: Colors.purple,
            labelStyle: const TextStyle(color: Colors.white),
          ),
      ],
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      final months = difference.inDays ~/ 30;
      return '$months months ago';
    }
  }

  String _formatPairedAt(DateTime pairedAt) {
    final now = DateTime.now();
    final difference = now.difference(pairedAt);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      final months = difference.inDays ~/ 30;
      return '$months months ago';
    }
  }

  Color _getUserStatusColor(P2PUser user) {
    if (user.isPaired && user.isOnline) {
      return Colors.green; // Connected and paired
    } else if (user.isPaired) {
      return Colors.orange; // Paired but offline
    } else if (user.isOnline) {
      return Colors.blue; // Online but not paired
    } else {
      return Colors.grey; // Offline and not paired
    }
  }

  IconData _getUserStatusIcon(P2PUser user) {
    // Use platform icon instead of status icon
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

  String _getPlatformDisplayName(UserPlatform platform) {
    switch (platform) {
      case UserPlatform.android:
        return 'Android';
      case UserPlatform.ios:
        return 'iOS';
      case UserPlatform.windows:
        return 'Windows';
      case UserPlatform.macos:
        return 'macOS';
      case UserPlatform.linux:
        return 'Linux';
      case UserPlatform.web:
        return 'Web';
      case UserPlatform.unknown:
        return 'Unknown';
    }
  }
}
