import 'dart:io';

import 'package:flutter/material.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/models/p2p_chat.dart';
import 'package:p2lan/services/function_info_service.dart';
import 'package:p2lan/utils/widget_layout_render_helper.dart';

import 'package:p2lan/widgets/generic/option_slider.dart';
import 'package:p2lan/widgets/generic/option_switch.dart';

class P2PChatSettingsLayout extends StatefulWidget {
  final P2PChat chat;
  final void Function(P2PChat updatedChat)? onSave;
  const P2PChatSettingsLayout({Key? key, required this.chat, this.onSave})
      : super(key: key);

  @override
  State<P2PChatSettingsLayout> createState() => _P2PChatSettingsLayoutState();
}

class _P2PChatSettingsLayoutState extends State<P2PChatSettingsLayout> {
  late String displayName;
  late MessageRetention retention;
  late bool autoCopyIncomingMessages;
  late bool deleteAfterCopy;
  late bool clipboardSharing;
  late bool deleteAfterShare;
  bool changed = false;

  final _displayNameController = TextEditingController();
  late final AppLocalizations _loc;

  @override
  void initState() {
    super.initState();
    displayName = widget.chat.displayName;
    retention = widget.chat.retention;
    autoCopyIncomingMessages = widget.chat.autoCopyIncomingMessages;
    deleteAfterCopy = widget.chat.deleteAfterCopy;
    clipboardSharing = widget.chat.clipboardSharing;
    deleteAfterShare = widget.chat.deleteAfterShare;
    _displayNameController.text = displayName;
  }

  @override
  void didChangeDependencies() {
    _loc = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  void _onSave() {
    final newSettings = P2PChat()
      ..displayName = displayName
      ..retention = retention
      ..autoCopyIncomingMessages = autoCopyIncomingMessages
      ..deleteAfterCopy = autoCopyIncomingMessages ? deleteAfterCopy : false
      ..clipboardSharing = clipboardSharing
      ..deleteAfterShare = clipboardSharing ? deleteAfterShare : false;
    widget.onSave?.call(newSettings);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _loc.displayName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _displayNameController,
                maxLength: 20,
                onChanged: (val) {
                  displayName = val;
                  setState(() => changed = true);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  hintText: _loc.enterDisplayName,
                  counterText: '${_displayNameController.text.length}/20',
                ),
              ),
              const SizedBox(height: 12),
              // const Text('Hạn xóa file:'),
              OptionSlider<MessageRetention>(
                label: _loc.messageRetention,
                subtitle: _loc.messageRetentionDesc,
                currentValue: retention,
                options: P2PChat.getMessageRetentionOptions(context),
                onChanged: (val) {
                  retention = val;
                  setState(() => changed = true);
                },
                layout: OptionSliderLayout.none,
              ),
              const SizedBox(height: 12),
              OptionSwitch(
                title: _loc.p2pChatAutoCopyIncomingMessages,
                subtitle: _loc.p2pChatAutoCopyIncomingMessagesDesc,
                value: autoCopyIncomingMessages,
                onChanged: (val) {
                  autoCopyIncomingMessages = val;
                  setState(() => changed = true);
                },
              ),
              OptionSwitch(
                title: _loc.p2pChatDeleteAfterCopy,
                subtitle: _loc.p2pChatDeleteAfterCopyDesc,
                value: deleteAfterCopy,
                onChanged: (val) {
                  deleteAfterCopy = val;
                  setState(() => changed = true);
                },
                isEnabled: autoCopyIncomingMessages,
              ),
              OptionSwitch(
                title: _loc.p2pChatClipboardSharing,
                subtitle: _loc.p2pChatClipboardSharingDesc,
                value: clipboardSharing,
                onChanged: (val) {
                  clipboardSharing = val;
                  setState(() => changed = true);
                },
              ),
              OptionSwitch(
                title: _loc.p2pChatDeleteAfterShare,
                subtitle: _loc.p2pChatDeleteAfterShareDesc,
                value: deleteAfterShare,
                onChanged: (val) {
                  deleteAfterShare = val;
                  setState(() => changed = true);
                },
                isEnabled: clipboardSharing,
              ),
              if (Platform.isAndroid &&
                  (clipboardSharing || autoCopyIncomingMessages)) ...[
                const SizedBox(height: 12),
                FunctionInfo.buildSectionsFromText(
                    _loc.p2pChatCustomizationAndroidCaution),
              ]
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      WidgetLayoutRenderHelper.oneLeftTwoRight(
          const SizedBox(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              loc.cancel,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          ElevatedButton(
            onPressed: changed ? _onSave : null,
            child: Text(loc.save),
          ),
          twoInARowMinWidth: 100,
          threeInARowMinWidth: 300),
    ]);
  }
}
