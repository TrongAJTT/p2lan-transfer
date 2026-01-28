import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/utils/variables_utils.dart';
import 'package:p2lan/variables.dart';

class ManualConnectDialog extends StatefulWidget {
  final Function(P2PUser user, bool saveConnection, bool trustUser) onConnect;

  const ManualConnectDialog({
    Key? key,
    required this.onConnect,
  }) : super(key: key);

  @override
  State<ManualConnectDialog> createState() => _ManualConnectDialogState();
}

class _ManualConnectDialogState extends State<ManualConnectDialog> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  bool _isConnecting = false;
  bool _saveConnection = false;
  bool _trustUser = false;

  @override
  void initState() {
    super.initState();
    // Set default ip parts (can be empty or pre-filled with common local IP)
    _controllers[0].text = '192';
    _controllers[1].text = '168';
    _controllers[2].text = '1';
    _controllers[3].text = '2';
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged({required String value, required int index}) {
    // Auto-move to next field when current field is complete
    if (value.length == 3 && index < _controllers.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    // Auto-move to previous field when backspace is pressed on empty field
    else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  bool _isValidIpAddress() {
    for (int i = 0; i < 4; i++) {
      final text = _controllers[i].text;
      if (text.isEmpty) return false;

      final num = int.tryParse(text);
      if (num == null || num < 0 || num > 255) return false;
    }

    return true;
  }

  String _getIpAddress() {
    return _controllers.take(4).map((c) => c.text).join('.');
  }

  void _handleConnect() async {
    if (!_isValidIpAddress()) {
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    final ipAddress = _getIpAddress();

    // Try connecting to each port in the range from p2pBasePort to p2pMaxPort
    for (int port = p2pBasePort; port <= p2pMaxPort; port++) {
      widget.onConnect(P2PUser.onlyIp(ipAddress: ipAddress, port: port),
          _saveConnection, _trustUser);

      // Add a small delay between attempts
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Close dialog after scanning all ports
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildIpField(int index) {
    return SizedBox(
      width: 60,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
          _IpAddressInputFormatter(),
        ],
        textInputAction:
            index == 3 ? TextInputAction.done : TextInputAction.next,
        onChanged: (value) => _onFieldChanged(value: value, index: index),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  List<Widget> buildCharWidget({String char = '.'}) {
    return [
      const SizedBox(width: 8),
      Text(
        char,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      const SizedBox(width: 8),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pointWidget = buildCharWidget();

    final ipSection = isMobileLayoutContext(context)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIpField(0),
                  ...pointWidget,
                  _buildIpField(1),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIpField(2),
                  ...pointWidget,
                  _buildIpField(3),
                ],
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIpField(0),
              ...pointWidget,
              _buildIpField(1),
              ...pointWidget,
              _buildIpField(2),
              ...pointWidget,
              _buildIpField(3),
            ],
          );

    return AlertDialog(
      title: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Icon(Icons.link),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.connectToDevice,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.enterDeviceIpAddress,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Ports $p2pBasePort-$p2pMaxPort will be scanned automatically',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 16),
            ipSection,
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
            Text(
              l10n.connectToDeviceHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isConnecting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          onPressed:
              _isConnecting || !_isValidIpAddress() ? null : _handleConnect,
          icon: _isConnecting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          label: Text(_isConnecting ? l10n.connecting : l10n.sendRequest),
        ),
      ],
    );
  }
}

class _IpAddressInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow numbers 0-255
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final num = int.tryParse(newValue.text);
    if (num == null || num > 255) {
      return oldValue;
    }

    return newValue;
  }
}
