import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/p2p_services/p2p_service_manager.dart';
import 'package:p2lan/widgets/p2p/device_info_card.dart';

/// Screen Sharing Request Dialog
/// Shows when receiving a screen sharing request from another device
class ScreenSharingRequestDialog extends StatefulWidget {
  final ScreenSharingRequest request;

  const ScreenSharingRequestDialog({
    super.key,
    required this.request,
  });

  @override
  State<ScreenSharingRequestDialog> createState() =>
      _ScreenSharingRequestDialogState();
}

class _ScreenSharingRequestDialogState
    extends State<ScreenSharingRequestDialog> {
  final P2PServiceManager _serviceManager = P2PServiceManager.instance;
  bool _isProcessing = false;
  P2PUser? _senderUser;

  @override
  void initState() {
    super.initState();
    _loadSenderUser();
  }

  void _loadSenderUser() {
    // Get sender user from discovered users
    final users = _serviceManager.discoveredUsers;
    _senderUser =
        users.where((u) => u.id == widget.request.fromUserId).firstOrNull;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: const Text('Screen Sharing Request'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sender info
            if (_senderUser != null)
              DeviceInfoCard(
                user: _senderUser!,
                showStatusChips: false,
                isCompact: true,
              ),

            const SizedBox(height: 16),

            // Request message
            Text(
              '${widget.request.fromUserName} wants to share their screen with you.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),

            if (widget.request.reason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Reason: ${widget.request.reason}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Quality info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.high_quality, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Quality: ${widget.request.quality.name.toUpperCase()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.request.quality.width} x ${widget.request.quality.height} @ ${widget.request.quality.fps} FPS',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Warning text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will allow ${widget.request.fromUserName} to share their screen content with you.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_isProcessing) ...[
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Processing...'),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: _isProcessing
          ? []
          : [
              TextButton(
                onPressed: () => _respondToRequest(false),
                child: Text(l10n.reject),
              ),
              ElevatedButton(
                onPressed: () => _respondToRequest(true),
                child: const Text('Accept'),
              ),
            ],
    );
  }

  void _respondToRequest(bool accept) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await _serviceManager.respondToScreenSharingRequest(
        widget.request.requestId,
        accept,
        rejectReason: accept ? null : 'User declined',
      );

      if (mounted) {
        Navigator.of(context).pop(accept && success);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
