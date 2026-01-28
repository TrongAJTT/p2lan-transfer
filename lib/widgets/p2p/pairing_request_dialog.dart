import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/isar_service.dart';
import 'package:p2lan/services/p2p_services/p2p_service_manager.dart';
import 'package:p2lan/utils/isar_utils.dart';

class PairingRequestDialog extends StatefulWidget {
  final List<PairingRequest> requests;
  final Function(
          String requestId, bool accept, bool trustUser, bool saveConnection)
      onRespond;

  const PairingRequestDialog({
    super.key,
    required this.requests,
    required this.onRespond,
  });

  @override
  State<PairingRequestDialog> createState() => _PairingRequestDialogState();
}

class _PairingRequestDialogState extends State<PairingRequestDialog> {
  int _currentIndex = 0;
  bool _trustUser = false;
  bool _saveConnection = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (widget.requests.isEmpty) {
      return AlertDialog(
        title: Text(l10n.pairingRequests),
        content: Text(l10n.noPairingRequests),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      );
    }

    final request = widget.requests[_currentIndex];

    final blockBtn = SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _showBlockConfirm(context),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
        ),
        child: Text(l10n.blockTitle),
      ),
    );

    final rejectBtn = Expanded(
      child: ElevatedButton(
        onPressed: () => _respondToRequest(false),
        child: Text(l10n.reject),
      ),
    );

    final acceptBtn = Expanded(
      child: ElevatedButton(
        onPressed: () => _respondToRequest(true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        child: Text(l10n.accept),
      ),
    );

    final previousBtn = IconButton(
      onPressed: _currentIndex > 0 ? _previousRequest : null,
      icon: const Icon(Icons.arrow_back),
      tooltip: l10n.previousRequest,
    );

    final nextBtn = IconButton(
      onPressed:
          _currentIndex < widget.requests.length - 1 ? _nextRequest : null,
      icon: const Icon(Icons.arrow_forward),
      tooltip: l10n.nextRequest,
    );

    final actionsLayout = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.requests.length > 1) ...[
          Column(
            children: [
              previousBtn,
              const SizedBox(height: 4),
              nextBtn,
            ],
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              blockBtn,
              const SizedBox(height: 8),
              Row(
                children: [
                  rejectBtn,
                  const SizedBox(width: 8),
                  acceptBtn,
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.notifications,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.pairingRequests)),
          if (widget.requests.length > 1)
            Text(
              '${_currentIndex + 1}/${widget.requests.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 400, maxWidth: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pairingRequestFrom,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Request info card
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
                            _getUserPlatformIcon(request),
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.fromUserName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${request.fromIpAddress}:${request.fromPort}',
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
                      value: request.fromDeviceId.length > 20
                          ? '${request.fromDeviceId.substring(0, 20)}...'
                          : request.fromDeviceId,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.access_time,
                      label: l10n.sentTime,
                      value: _formatTime(request.requestTime),
                    ),
                    // Note: Removed "wants to save connection" display since
                    // connection saving is now handled per-device independently
                  ],
                ),
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 12),

              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.onlyAcceptFromTrustedDevices,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange[700],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [actionsLayout],
    );
  }

  void _showBlockConfirm(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.blockTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 400, maxWidth: 600),
          child: Text(l10n.blockDesc),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final request = widget.requests[_currentIndex];
              // Persist blocked user; mark as temporarily stored when created from pairing dialog
              final isar = IsarService.isar;
              final existing =
                  await isar.p2PUsers.get(fastHash(request.fromUserId));
              final user = existing ??
                  P2PUser(
                    id: request.fromUserId,
                    displayName: request.fromUserName,
                    profileId: request.fromDeviceId,
                    ipAddress: request.fromIpAddress,
                    port: request.fromPort,
                    lastSeen: DateTime.now(),
                    isStored: false,
                    isTempStored: true,
                  );
              user.isBlocked = true;
              // Ensure temp flag is set for existing records created here
              if (existing != null) {
                user.isTempStored = user.isTempStored || !user.isStored;
              }
              await isar.writeTxn(() async => isar.p2PUsers.put(user));

              // Push immediate UI update via discovery service so lists refresh
              P2PServiceManager.instance.blockUserFromPairing(
                userId: request.fromUserId,
                displayName: request.fromUserName,
                profileId: request.fromDeviceId,
                ipAddress: request.fromIpAddress,
                port: request.fromPort,
              );

              // Auto-reject and close both dialogs so UI updates immediately
              if (context.mounted) {
                Navigator.of(ctx).pop(); // Close confirmation
                Navigator.of(context).pop(); // Close pairing dialog
              }
              // Notify caller to process rejection
              widget.onRespond(request.id, false, false, false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.blockTitle),
          ),
        ],
      ),
    );
  }

  IconData _getUserPlatformIcon(PairingRequest request) {
    // Try to get platform from existing user, otherwise use unknown
    try {
      final user = P2PServiceManager.instance.getUserById(request.fromUserId);
      if (user != null) {
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
    } catch (e) {
      // Fallback to unknown platform
    }
    return Icons.device_unknown;
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

  void _previousRequest() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _resetOptions();
      });
    }
  }

  void _nextRequest() {
    if (_currentIndex < widget.requests.length - 1) {
      setState(() {
        _currentIndex++;
        _resetOptions();
      });
    }
  }

  void _resetOptions() {
    _trustUser = false;
    _saveConnection = false;
  }

  void _respondToRequest(bool accept) {
    final request = widget.requests[_currentIndex];
    Navigator.of(context).pop();
    widget.onRespond(request.id, accept, _trustUser, _saveConnection);
  }
}
