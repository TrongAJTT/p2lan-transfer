import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/p2p_services/p2p_service_manager.dart';
import 'package:p2lan/services/function_info_service.dart';
import 'package:p2lan/widgets/p2p/advanced_touchpad_widget.dart';

/// Remote Control Screen for controlling Windows devices from Android
class RemoteControlScreen extends StatefulWidget {
  final P2PUser targetUser;

  const RemoteControlScreen({
    super.key,
    required this.targetUser,
  });

  @override
  State<RemoteControlScreen> createState() => _RemoteControlScreenState();
}

class _RemoteControlScreenState extends State<RemoteControlScreen> {
  final P2PServiceManager _p2pService = P2PServiceManager.instance;
  late AppLocalizations _loc;

  bool _isConnected = false;
  bool _isHoldingLeftMouse = false;
  bool _isHoldingMiddleMouse = false;
  _ControlMode _controlMode = _ControlMode.mouse;
  static const double _keyRowHeight = 40;

  // Text sending
  final TextEditingController _textController = TextEditingController();
  static const String _draftKey = 'remote_control_text_draft';

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _checkConnectionStatus();
    _loadDraftText();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loc = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _setupListeners() {
    _p2pService.addListener(_onServiceStateChanged);
  }

  void _onServiceStateChanged() {
    if (mounted) {
      setState(() {
        _isConnected = _p2pService.isControlling &&
            _p2pService.controlledUser?.id == widget.targetUser.id;
      });

      // If disconnected, close this screen
      if (!_isConnected && _p2pService.isControlling == false) {
        Navigator.of(context).pop();
      }
    }
  }

  void _checkConnectionStatus() {
    setState(() {
      _isConnected = _p2pService.isControlling &&
          _p2pService.controlledUser?.id == widget.targetUser.id;
    });
  }

  Future<bool> _onWillPop() async {
    // Show confirmation dialog
    final bool? shouldDisconnect = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_loc.disconnectRemoteControl),
        content: Text(
            _loc.disconnectRemoteControlConfirm(widget.targetUser.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_loc.disconnect),
          ),
        ],
      ),
    );

    if (shouldDisconnect == true) {
      await _disconnect();
      return true; // Allow back navigation
    }
    return false; // Prevent back navigation
  }

  Future<void> _disconnect() async {
    try {
      await _p2pService.disconnectRemoteControl();
    } catch (e) {
      logError('RemoteControlScreen: Error disconnecting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_loc.eerror} disconnecting: $e')),
        );
      }
    }
  }

  Future<void> _handleGestureEvent(RemoteControlEvent event) async {
    if (!_isConnected) return;

    try {
      await _p2pService.sendRemoteControlEvent(event);
    } catch (e) {
      logError('RemoteControlScreen: Error sending gesture event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: _isConnected ? Colors.green : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_loc.controlling} ${widget.targetUser.displayName}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.text_fields),
              tooltip: _loc.sendText,
              onPressed: _showTextSendDialog,
            ),
            // TODO: Full implementation of control mode switch
            // IconButton(
            //   icon: Icon(_controlMode == _ControlMode.mouse
            //       ? Icons.keyboard
            //       : Icons.mouse),
            //   tooltip:
            //       _controlMode == _ControlMode.mouse ? 'Bàn phím' : 'Chuột',
            //   onPressed: () => setState(() {
            //     _controlMode = _controlMode == _ControlMode.mouse
            //         ? _ControlMode.keyboard
            //         : _ControlMode.mouse;
            //   }),
            // ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showControlsInfo,
              tooltip: _loc.controlsInfo,
            ),
          ],
        ),
        body: _isConnected
            ? _buildControlInterface()
            : _buildConnectingInterface(),
      ),
    );
  }

  Widget _buildConnectingInterface() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            _loc.connectingTo(widget.targetUser.displayName),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildControlInterface() {
    return Column(
      children: [
        // Main control view
        Expanded(
          child: _controlMode == _ControlMode.mouse
              ? Column(
                  children: [
                    Expanded(
                      child: AdvancedTouchpadWidget(
                        onGestureEvent: _handleGestureEvent,
                        isEnabled: _isConnected,
                      ),
                    ),
                    _buildBottomControls(),
                  ],
                )
              : _buildKeyboardFullScreen(),
        ),
      ],
    );
  }

  Widget _buildKeyboardFullScreen() {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 24),
          child: _buildTKLKeyboard(),
        ),
      );
    });
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Left mouse button with press-and-hold behavior
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () =>
                    _handleGestureEvent(RemoteControlEvent.leftClick()),
                onLongPressStart: (_) {
                  setState(() => _isHoldingLeftMouse = true);
                  _handleGestureEvent(RemoteControlEvent.startLeftLongClick());
                },
                onLongPressEnd: (_) {
                  setState(() => _isHoldingLeftMouse = false);
                  _handleGestureEvent(RemoteControlEvent.stopLeftLongClick());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _isHoldingLeftMouse
                        ? Colors.blueGrey[600]
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mouse, size: 24, color: Colors.white),
                      const SizedBox(height: 4),
                      Text(
                        _loc.leftClick,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Middle mouse button with press-and-hold behavior
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () =>
                    _handleGestureEvent(RemoteControlEvent.middleClick()),
                onLongPressStart: (_) {
                  setState(() => _isHoldingMiddleMouse = true);
                  _handleGestureEvent(
                      RemoteControlEvent.startMiddleLongClick());
                },
                onLongPressEnd: (_) {
                  setState(() => _isHoldingMiddleMouse = false);
                  _handleGestureEvent(RemoteControlEvent.stopMiddleLongClick());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _isHoldingMiddleMouse
                        ? Colors.blueGrey[600]
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.radio_button_unchecked,
                          size: 24, color: Colors.white),
                      const SizedBox(height: 4),
                      Text(
                        _loc.middleClick,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildControlButton(
            icon: Icons.mouse,
            label: _loc.rightClick,
            onPressed: () =>
                _handleGestureEvent(RemoteControlEvent.rightClick()),
          ),
        ],
      ),
    );
  }

  // Legacy noop (kept for backward compatibility during rollout)
  // ignore: unused_element
  void _showKeyboardBottomSheet(BuildContext context) {}

  Widget _buildTKLKeyboard() {
    List<List<_KeyDef>> rows = _tklRows();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows
          .map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: row
                      .map((k) => Expanded(
                            flex: k.flex,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: _KeyButton(
                                keyDef: k,
                                onKeyDown: (code) => _handleGestureEvent(
                                    RemoteControlEvent.keyDown(code)),
                                onKeyUp: (code) => _handleGestureEvent(
                                    RemoteControlEvent.keyUp(code)),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ))
          .toList(),
    );
  }

  List<List<_KeyDef>> _tklRows() {
    return [
      [
        const _KeyDef('Esc', 27),
        const _KeyDef('F1', 112),
        const _KeyDef('F2', 113),
        const _KeyDef('F3', 114),
        const _KeyDef('F4', 115),
        const _KeyDef('F5', 116),
        const _KeyDef('F6', 117),
        const _KeyDef('F7', 118),
        const _KeyDef('F8', 119),
        const _KeyDef('F9', 120),
        const _KeyDef('F10', 121),
        const _KeyDef('F11', 122),
        const _KeyDef('F12', 123),
        const _KeyDef('PrtSc', 44),
        const _KeyDef('ScrLk', 145),
        const _KeyDef('Pause', 19),
      ],
      [
        const _KeyDef('`', 192),
        const _KeyDef('1', 49),
        const _KeyDef('2', 50),
        const _KeyDef('3', 51),
        const _KeyDef('4', 52),
        const _KeyDef('5', 53),
        const _KeyDef('6', 54),
        const _KeyDef('7', 55),
        const _KeyDef('8', 56),
        const _KeyDef('9', 57),
        const _KeyDef('0', 48),
        const _KeyDef('-', 189),
        const _KeyDef('=', 187),
        const _KeyDef('Back', 8, flex: 2),
        const _KeyDef('Ins', 45),
        const _KeyDef('Home', 36),
        const _KeyDef('PgUp', 33),
      ],
      [
        const _KeyDef('Tab', 9, flex: 2),
        const _KeyDef('Q', 81),
        const _KeyDef('W', 87),
        const _KeyDef('E', 69),
        const _KeyDef('R', 82),
        const _KeyDef('T', 84),
        const _KeyDef('Y', 89),
        const _KeyDef('U', 85),
        const _KeyDef('I', 73),
        const _KeyDef('O', 79),
        const _KeyDef('P', 80),
        const _KeyDef('[', 219),
        const _KeyDef(']', 221),
        const _KeyDef('\\', 220, flex: 2),
        const _KeyDef('Del', 46),
        const _KeyDef('End', 35),
        const _KeyDef('PgDn', 34),
      ],
      [
        const _KeyDef('Caps', 20, flex: 2),
        const _KeyDef('A', 65),
        const _KeyDef('S', 83),
        const _KeyDef('D', 68),
        const _KeyDef('F', 70),
        const _KeyDef('G', 71),
        const _KeyDef('H', 72),
        const _KeyDef('J', 74),
        const _KeyDef('K', 75),
        const _KeyDef('L', 76),
        const _KeyDef(';', 186),
        const _KeyDef("'", 222),
        const _KeyDef('Enter', 13, flex: 3),
        const _KeyDef('', 0),
        const _KeyDef('', 0),
        const _KeyDef('', 0),
      ],
      [
        const _KeyDef('Shift', 16, flex: 3),
        const _KeyDef('Z', 90),
        const _KeyDef('X', 88),
        const _KeyDef('C', 67),
        const _KeyDef('V', 86),
        const _KeyDef('B', 66),
        const _KeyDef('N', 78),
        const _KeyDef('M', 77),
        const _KeyDef(',', 188),
        const _KeyDef('.', 190),
        const _KeyDef('/', 191),
        const _KeyDef('Shift', 16, flex: 3),
        const _KeyDef('', 0),
        const _KeyDef('↑', 38),
        const _KeyDef('', 0),
      ],
      [
        const _KeyDef('Ctrl', 17, flex: 2, isModifier: true),
        const _KeyDef('Win', 91, isModifier: true),
        const _KeyDef('Alt', 18, isModifier: true),
        const _KeyDef('Space', 32, flex: 6),
        const _KeyDef('Alt', 18, isModifier: true),
        const _KeyDef('Win', 92, isModifier: true),
        const _KeyDef('Menu', 93),
        const _KeyDef('Ctrl', 17, flex: 2, isModifier: true),
        const _KeyDef('←', 37),
        const _KeyDef('↓', 40),
        const _KeyDef('→', 39),
      ],
    ];
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: MaterialButton(
          onPressed: onPressed,
          color: Colors.grey[800],
          textColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showControlsInfo() {
    FunctionInfo.show(context, FunctionInfoKeys.remoteControlHelp);
  }

  // Text sending methods
  Future<void> _loadDraftText() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftText = prefs.getString(_draftKey) ?? '';
      if (draftText.isNotEmpty) {
        _textController.text = draftText;
      }
    } catch (e) {
      logError('RemoteControlScreen: Error loading draft text: $e');
    }
  }

  Future<void> _saveDraftText(String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_draftKey, text);
    } catch (e) {
      logError('RemoteControlScreen: Error saving draft text: $e');
    }
  }

  Future<void> _clearDraftText() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (e) {
      logError('RemoteControlScreen: Error clearing draft text: $e');
    }
  }

  void _showTextSendDialog() {
    showDialog(
      context: context,
      builder: (context) => _TextSendDialog(
        controller: _textController,
        onSend: _sendText,
        onSaveDraft: _saveDraftText,
      ),
    );
  }

  Future<void> _sendText(String text) async {
    if (text.trim().isEmpty) return;

    try {
      // Send text as P2P message
      await _handleGestureEvent(RemoteControlEvent.sendText(text));

      // Clear draft after successful send
      await _clearDraftText();
      _textController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_loc.textSentSuccessfully),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      logError('RemoteControlScreen: Error sending text: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_loc.textSendError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _KeyDef {
  final String label;
  final int keyCode;
  final int flex;
  final bool isModifier;
  const _KeyDef(this.label, this.keyCode,
      {this.flex = 1, this.isModifier = false});
}

class _KeyButton extends StatefulWidget {
  final _KeyDef keyDef;
  final ValueChanged<int> onKeyDown;
  final ValueChanged<int> onKeyUp;
  const _KeyButton(
      {required this.keyDef, required this.onKeyDown, required this.onKeyUp});

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;

  void _down() {
    if (_pressed) return;
    setState(() => _pressed = true);
    widget.onKeyDown(widget.keyDef.keyCode);
  }

  void _up() {
    if (!_pressed) return;
    setState(() => _pressed = false);
    widget.onKeyUp(widget.keyDef.keyCode);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _down(),
      onTapUp: (_) => _up(),
      onTapCancel: _up,
      onLongPressStart: (_) => _down(),
      onLongPressEnd: (_) => _up(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _pressed ? Colors.blueGrey[600] : Colors.grey[800],
          borderRadius: BorderRadius.circular(6),
        ),
        height: _RemoteControlScreenState._keyRowHeight,
        child: Text(widget.keyDef.label,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
      ),
    );
  }
}

// Extension for localization
extension RemoteControlLocalizations on AppLocalizations {
  String get controlling => 'Controlling';
}

enum _ControlMode { mouse, keyboard }

class _TextSendDialog extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final Function(String) onSaveDraft;

  const _TextSendDialog({
    required this.controller,
    required this.onSend,
    required this.onSaveDraft,
  });

  @override
  State<_TextSendDialog> createState() => _TextSendDialogState();
}

class _TextSendDialogState extends State<_TextSendDialog> {
  late TextEditingController _localController;

  @override
  void initState() {
    super.initState();
    _localController = TextEditingController(text: widget.controller.text);
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth * 0.9).clamp(0.0, 600.0);

    return AlertDialog(
      title: Text(loc.sendText),
      content: SizedBox(
        width: dialogWidth,
        height: 200, // Fixed height to prevent overflow
        child: TextField(
          controller: _localController,
          maxLines: null, // Allow unlimited lines
          expands: true, // Fill available height
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
            hintText: loc.sendTextHint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(12),
          ),
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Save draft and close
            widget.onSaveDraft(_localController.text);
            Navigator.of(context).pop();
          },
          child: Text(loc.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final text = _localController.text.trim();
            if (text.isNotEmpty) {
              widget.onSend(text);
              Navigator.of(context).pop();
            }
          },
          child: Text(loc.send),
        ),
      ],
    );
  }
}
