import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';

class DeviceInfoCard extends StatefulWidget {
  final P2PUser? user;
  final String title;
  final bool showStatusChips;
  final bool isCompact;
  final bool showDeviceIdToggle;

  const DeviceInfoCard({
    super.key,
    required this.user,
    this.title = 'Device Information',
    this.showStatusChips = true,
    this.isCompact = false,
    this.showDeviceIdToggle = false,
  });

  @override
  State<DeviceInfoCard> createState() => _DeviceInfoCardState();
}

class _DeviceInfoCardState extends State<DeviceInfoCard> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.user == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'No device information available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with optional toggle button
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Device info rows
            _buildInfoRow(
              context,
              l10n.deviceName,
              widget.user!.displayName,
              icon: Icons.devices,
            ),
            if (!widget.isCompact) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                l10n.appInstallationId,
                widget.user!.id,
                icon: Icons.fingerprint,
              ),
            ],
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              l10n.ipAddress,
              widget.user!.ipAddress,
              icon: Icons.location_on,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              l10n.port,
              widget.user!.port.toString(),
              icon: Icons.router,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              l10n.status,
              widget.user!.isOnline ? l10n.online : l10n.offline,
              icon:
                  widget.user!.isOnline ? Icons.circle : Icons.circle_outlined,
              statusColor: widget.user!.isOnline ? Colors.green : Colors.red,
            ),
            if (!widget.isCompact) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                l10n.lastSeen,
                _formatLastSeen(widget.user!.lastSeen),
                icon: Icons.access_time,
              ),
            ],

            // Status chips
            if (widget.showStatusChips && _hasAnyStatus()) ...[
              const SizedBox(height: 12),
              _buildStatusChips(context),
            ],
          ],
        ),
      ),
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
          size: widget.isCompact ? 16 : 18,
          color: statusColor ?? Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isCompact) ...[
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
              ],
              Text(
                widget.isCompact ? '$label: $value' : value,
                style: widget.isCompact
                    ? Theme.of(context).textTheme.bodySmall
                    : Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChips(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 6.0,
      runSpacing: 4.0,
      children: [
        if (widget.user!.isPaired)
          Chip(
            label: Text(l10n.paired),
            avatar: const Icon(Icons.link, size: 14),
            backgroundColor: Colors.blue,
            labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
            visualDensity: VisualDensity.compact,
          ),
        if (widget.user!.isTrusted)
          Chip(
            label: Text(l10n.trust),
            avatar: const Icon(Icons.verified_user, size: 14),
            backgroundColor: Colors.green,
            labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
            visualDensity: VisualDensity.compact,
          ),
        if (widget.user!.isStored)
          Chip(
            label: Text(l10n.saved),
            avatar: const Icon(Icons.save, size: 14),
            backgroundColor: Colors.purple,
            labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  bool _hasAnyStatus() {
    return widget.user!.isPaired ||
        widget.user!.isTrusted ||
        widget.user!.isStored;
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      final months = difference.inDays ~/ 30;
      return '$months months ago';
    }
  }
}
