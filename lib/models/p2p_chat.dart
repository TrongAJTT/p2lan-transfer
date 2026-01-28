import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/utils/url_utils.dart';
import 'package:p2lan/widgets/generic/option_slider.dart';
import 'package:uuid/uuid.dart';

part 'p2p_chat.g.dart';

enum P2PCMessageType {
  text,
  file,
  mediaImage,
  mediaVideo,
}

enum P2PCMessageStatus { waiting, onDevice, request, lost, lostBoth, deleted }

@Collection()
class P2PChat {
  Id id = Isar.autoIncrement;

  late String userAId;
  late String userBId;
  late String displayName;

  @Backlink(to: 'chat')
  var messages = IsarLinks<P2PCMessage>();

  late DateTime createdAt;
  late DateTime updatedAt;
  @enumerated
  late MessageRetention retention;

  bool autoCopyIncomingMessages = false;
  bool deleteAfterCopy = false;

  bool clipboardSharing = false;
  bool deleteAfterShare = false;

  P2PChat();

  static empty() {
    return P2PChat()..id = 0;
  }

  bool isEmpty() {
    return id == 0;
  }

  void updateSettings(P2PChat other) {
    displayName = other.displayName;
    retention = other.retention;
    autoCopyIncomingMessages = other.autoCopyIncomingMessages;
    deleteAfterCopy = other.deleteAfterCopy;
    clipboardSharing = other.clipboardSharing;
    deleteAfterShare = other.deleteAfterShare;
  }

  /// Get the number of days for a retention setting
  int getRetentionDays() {
    switch (retention) {
      case MessageRetention.days7:
        return 7;
      case MessageRetention.days15:
        return 15;
      case MessageRetention.days30:
        return 30;
      case MessageRetention.days60:
        return 60;
      case MessageRetention.days90:
        return 90;
      case MessageRetention.days180:
        return 180;
      case MessageRetention.days360:
        return 360;
      case MessageRetention.never:
        return -1; // Never expire
    }
  }

  /// Check if messages should be cleaned up based on retention setting
  bool shouldCleanupMessages() {
    return retention != MessageRetention.never;
  }

  /// Get the cutoff date for message cleanup
  DateTime? getMessageCutoffDate() {
    if (retention == MessageRetention.never) return null;
    final days = getRetentionDays();
    return DateTime.now().subtract(Duration(days: days));
  }

  static List<SliderOption<MessageRetention>> getMessageRetentionOptions(
      BuildContext context) {
    final loc = AppLocalizations.of(context);
    return [
      SliderOption<MessageRetention>(
        value: MessageRetention.days7,
        label: loc.numberOfDays(7),
      ),
      SliderOption<MessageRetention>(
        value: MessageRetention.days15,
        label: loc.numberOfDays(15),
      ),
      SliderOption<MessageRetention>(
        value: MessageRetention.days30,
        label: loc.numberOfDays(30),
      ),
      SliderOption<MessageRetention>(
        value: MessageRetention.days60,
        label: loc.numberOfDays(60),
      ),
      SliderOption<MessageRetention>(
        value: MessageRetention.days90,
        label: loc.numberOfDays(90),
      ),
      SliderOption<MessageRetention>(
        value: MessageRetention.days180,
        label: loc.numberOfDays(180),
      ),
      SliderOption<MessageRetention>(
        value: MessageRetention.days360,
        label: loc.numberOfDays(360),
      ),
      SliderOption<MessageRetention>(
        value: MessageRetention.never,
        label: loc.unlimited,
      ),
    ];
  }
}

enum MessageRetention {
  days7,
  days15,
  days30,
  days60,
  days90,
  days180,
  days360,
  never,
}

@Collection()
class P2PCMessage {
  Id id = Isar.autoIncrement;
  late String syncId;
  late String senderId;
  @enumerated
  late P2PCMessageType type;
  @enumerated
  late P2PCMessageStatus status;
  late String content;
  late DateTime sentAt;
  String? filePath;

  final chat = IsarLink<P2PChat>();

  bool isEmpty() {
    return id == 0;
  }

  bool isCopiable() {
    return type == P2PCMessageType.text || type == P2PCMessageType.mediaImage;
  }

  bool containsFile() {
    return type == P2PCMessageType.file ||
        type == P2PCMessageType.mediaImage ||
        type == P2PCMessageType.mediaVideo;
  }

  bool isNotLost() {
    return status != P2PCMessageStatus.lost &&
        status != P2PCMessageStatus.lostBoth;
  }

  bool containsFileAndNotLost() {
    return containsFile() &&
        status != P2PCMessageStatus.lost &&
        status != P2PCMessageStatus.lostBoth;
  }

  // String getContent(AppLocalizations loc) {
  //   if (type == P2PCMessageType.text) {
  //     return content;
  //   } else if (type == P2PCMessageType.file) {
  //     return '${loc.file}: ${UriUtils.getFileName(filePath?. ?? loc.fileLost)}';
  //   } else if (type == P2PCMessageType.mediaImage) {
  //     return '${loc.image}: ${UriUtils.getFileName(filePath ?? loc.fileLost)}';
  //   } else if (type == P2PCMessageType.mediaVideo) {
  //     return '${loc.video}: ${UriUtils.getFileName(filePath ?? loc.fileLost)}';
  //   }
  //   return '';
  // }

  static P2PCMessage createEmpty() {
    return P2PCMessage()..id = 0;
  }

  static P2PCMessage createTextMessage({
    required String senderId,
    required String content,
    required P2PChat chat,
    String syncId = 'random',
  }) {
    return P2PCMessage()
      ..senderId = senderId
      ..syncId = syncId == 'random' ? const Uuid().v4() : syncId
      ..type = P2PCMessageType.text
      ..status = P2PCMessageStatus.waiting
      ..content = content
      ..sentAt = DateTime.now()
      ..chat.value = chat;
  }

  static P2PCMessage createFileMessage(
      {required String senderId,
      required P2PChat chat,
      filePath = '',
      fileName = '',
      String syncId = 'random'}) {
    return P2PCMessage()
      ..senderId = senderId
      ..syncId = syncId == 'random' ? const Uuid().v4() : syncId
      ..type = P2PCMessageType.file
      ..status = P2PCMessageStatus.waiting
      ..filePath = filePath
      ..content =
          filePath.isNotEmpty ? UriUtils.getFileName(filePath) : fileName
      ..sentAt = DateTime.now()
      ..chat.value = chat;
  }

  static P2PCMessage createMediaImageMessage(
      {required String senderId,
      required String filePath,
      required P2PChat chat,
      String syncId = 'random'}) {
    return P2PCMessage()
      ..senderId = senderId
      ..syncId = syncId == 'random' ? const Uuid().v4() : syncId
      ..type = P2PCMessageType.mediaImage
      ..status = P2PCMessageStatus.waiting
      ..filePath = filePath
      ..content = UriUtils.getFileName(filePath)
      ..sentAt = DateTime.now()
      ..chat.value = chat;
  }

  static P2PCMessage createMediaVideoMessage(
      {required String senderId,
      required String filePath,
      required P2PChat chat,
      String syncId = 'random'}) {
    return P2PCMessage()
      ..senderId = senderId
      ..syncId = syncId == 'random' ? const Uuid().v4() : syncId
      ..type = P2PCMessageType.mediaVideo
      ..status = P2PCMessageStatus.waiting
      ..filePath = filePath
      ..content = UriUtils.getFileName(filePath)
      ..sentAt = DateTime.now()
      ..chat.value = chat;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'syncId': syncId,
      'senderId': senderId,
      'type': type.name,
      'status': status.name,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'filePath': filePath ?? '',
    };
  }

  static P2PCMessage fromJson(Map<String, dynamic> json) {
    return P2PCMessage()
      ..id = json['id'] as int
      ..syncId = json['syncId'] as String
      ..senderId = json['senderId'] as String
      ..type = P2PCMessageType.values.firstWhere(
          (e) => e.name == json['type'] as String,
          orElse: () => P2PCMessageType.text)
      ..status = P2PCMessageStatus.values.firstWhere(
          (e) => e.name == json['status'] as String,
          orElse: () => P2PCMessageStatus.waiting)
      ..content = json['content'] as String
      ..sentAt = DateTime.parse(json['sentAt'] as String)
      ..filePath = json['filePath'] as String?;
  }
}
