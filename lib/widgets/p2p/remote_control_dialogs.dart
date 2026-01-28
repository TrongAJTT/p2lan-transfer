import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/widgets/hold_to_confirm_dialog.dart';

/// Dialog for responding to remote control requests
class RemoteControlRequestDialog extends StatefulWidget {
  final RemoteControlRequest request;
  final Function(String requestId, bool accept, String? rejectReason)
      onResponse;

  const RemoteControlRequestDialog({
    super.key,
    required this.request,
    required this.onResponse,
  });

  @override
  State<RemoteControlRequestDialog> createState() =>
      _RemoteControlRequestDialogState();
}

class _RemoteControlRequestDialogState
    extends State<RemoteControlRequestDialog> {
  late AppLocalizations _loc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loc = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.computer, color: Colors.orange),
          const SizedBox(width: 8),
          Text(_loc.remoteControlRequest),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _loc.remoteControlRequestMessage(widget.request.fromUserName),
            style: const TextStyle(fontSize: 16),
          ),
          if (widget.request.reason != null &&
              widget.request.reason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${_loc.reason}: ${widget.request.reason}',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
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
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _loc.securityWarning,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _loc.securityWarningMessage,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text('• ${_loc.controlMouseCursor}',
                    style: const TextStyle(fontSize: 12)),
                Text('• ${_loc.clickAnywhere}',
                    style: const TextStyle(fontSize: 12)),
                Text('• ${_loc.scrollScreen}',
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  _loc.trustWarning,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _reject('User declined'),
          child: Text(_loc.reject),
        ),
        ElevatedButton(
          onPressed: _showAcceptConfirmation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(_loc.accept),
        ),
      ],
    );
  }

  void _showAcceptConfirmation() {
    showDialog(
      context: context,
      builder: (context) => HoldToConfirmDialog(
        title: _loc.confirmRemoteControlAccess,
        content: _loc.confirmRemoteControlMessage(widget.request.fromUserName),
        holdText: _loc.holdToAllowControl,
        processingText: _loc.allowing,
        instructionText: _loc.controlInstruction(widget.request.fromUserName),
        onConfirmed: () {
          widget.onResponse(widget.request.requestId, true, null);
          Navigator.of(context).pop(); // Close hold dialog
          Navigator.of(context).pop(); // Close the main dialog
        },
        holdDuration: const Duration(seconds: 2),
        actionIcon: Icons.computer,
        l10n: _loc,
      ),
    );
  }

  void _reject(String reason) {
    widget.onResponse(widget.request.requestId, false, reason);
    Navigator.of(context).pop();
  }
}

/// Dialog for sending remote control requests
class SendRemoteControlRequestDialog extends StatefulWidget {
  final P2PUser targetUser;
  final Function(P2PUser user, String? reason) onSendRequest;

  const SendRemoteControlRequestDialog({
    super.key,
    required this.targetUser,
    required this.onSendRequest,
  });

  @override
  State<SendRemoteControlRequestDialog> createState() =>
      _SendRemoteControlRequestDialogState();
}

class _SendRemoteControlRequestDialogState
    extends State<SendRemoteControlRequestDialog> {
  final TextEditingController _reasonController = TextEditingController();
  late AppLocalizations _loc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loc = AppLocalizations.of(context)!;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.computer, color: Colors.blue),
          const SizedBox(width: 8),
          Text(_loc.requestRemoteControl),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _loc.sendRemoteControlRequest(widget.targetUser.displayName),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: _loc.reasonOptional,
              hintText: _loc.reasonHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _loc.remoteControlAccess,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _loc.remoteControlAccessMessage,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text('• ${_loc.controlRemoteMouse}',
                    style: const TextStyle(fontSize: 12)),
                Text('• ${_loc.clickRemoteScreen}',
                    style: const TextStyle(fontSize: 12)),
                Text('• ${_loc.scrollRemoteScreen}',
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  _loc.requestExpiresIn60,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
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
          child: Text(_loc.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final reason = _reasonController.text.trim();
            widget.onSendRequest(
              widget.targetUser,
              reason.isEmpty ? null : reason,
            );
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text(_loc.sendRequest),
        ),
      ],
    );
  }
}
