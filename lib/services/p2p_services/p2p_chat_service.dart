import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:p2lan/models/app_installation.dart';
import 'package:p2lan/models/p2p_chat.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/models/p2p_cache_models.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/settings_models_service.dart';
import 'package:p2lan/services/p2p_services/p2p_notification_service.dart';
import 'package:p2lan/utils/url_utils.dart';

class P2PChatService extends ChangeNotifier {
  /// Lấy 1 trang tin nhắn của đoạn chat, mặc định lấy từ dưới lên (mới nhất)
  List<P2PCMessage> getMessagesPage(P2PChat chat,
      {int page = 0, int pageSize = 30}) {
    final allMessages = chat.messages.toList();
    if (allMessages.isEmpty) return [];
    final total = allMessages.length;
    final end = total - page * pageSize;
    final start = end - pageSize;
    final realStart = start < 0 ? 0 : start;
    final realEnd = end < 0 ? 0 : end;
    if (realEnd <= realStart) return [];
    return allMessages.sublist(realStart, realEnd);
  }

  Future<int> addMessageAndNotify(
      P2PCMessage msg, P2PChat chat, P2PCMessageStatus status) async {
    late int id;
    if (msg.containsFile() && Platform.isAndroid) {
      // move file to P2P service directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final basePath = '${appDocDir.parent.path}/files';
      final fileName = UriUtils.getFileName(msg.filePath!);
      final newFilePath = '$basePath/$fileName';
      await Directory(basePath).create(recursive: true);
      await File(msg.filePath!).copy(newFilePath);
      msg.filePath = newFilePath;
    }
    await isar.writeTxn(() async {
      msg.status = status;
      id = await isar.p2PCMessages.put(msg);
      chat.messages.add(msg);
      chat.updatedAt = DateTime.now();
      await chat.messages.save();
    });

    // Move these operations outside the transaction
    await chat.messages.load();
    _chatMap[chat.id.toString()] = chat;

    // Show notification for incoming messages when chat is not visible
    if (status == P2PCMessageStatus.onDevice &&
        msg.senderId != _currentUserId &&
        _currentVisibleChatId != chat.id.toString()) {
      logInfo(
          'Showing notification for new message from ${msg.senderId} in chat ${chat.id}');
      _showNewMessageNotification(msg, chat);
    } else {
      logDebug(
          'Notification skipped: status=$status, senderId=${msg.senderId}, currentUser=$_currentUserId, visibleChat=$_currentVisibleChatId, chatId=${chat.id}');
    }

    notifyListeners();
    return id;
  }

  Future<void> updateMessageStatus(
      P2PCMessage msg, P2PChat chat, P2PCMessageStatus status) async {
    await isar.writeTxn(() async {
      msg.status = status;
      await isar.p2PCMessages.put(msg);
    });
    notifyListeners();
  }

  P2PChat? getChatById(String chatId) => _chatMap[chatId];
  final Isar isar;
  final Map<String, P2PChat> _chatMap = {};
  late final String _currentUserId;
  String? _currentVisibleChatId; // Track which chat is currently being viewed

  P2PChatService(this.isar) {
    final installation = isar.appInstallations.where().findFirstSync();
    _currentUserId = installation!.installationId!;
    loadAllChats();

    // Schedule cleanup of expired messages in background
    _scheduleMessageCleanup();
  }

  /// Set the currently visible chat (to prevent notifications for the active chat)
  void setCurrentVisibleChat(String? chatId) {
    _currentVisibleChatId = chatId;
    logDebug('Current visible chat set to: $chatId');
  }

  /// Test notification (for debugging)
  Future<void> testNotification() async {
    try {
      final notificationService = P2PNotificationService.instanceOrNull;
      if (notificationService != null) {
        await notificationService.showTestChatNotification();
        logInfo('Test notification triggered successfully');
      } else {
        logError('Notification service not available for test');
      }
    } catch (e) {
      logError('Error triggering test notification: $e');
    }
  }

  /// Show notification for new message
  void _showNewMessageNotification(P2PCMessage message, P2PChat chat) async {
    try {
      logInfo(
          'Attempting to show notification for message: ${message.content}');

      // Check if notifications are enabled in settings
      final settings = await ExtensibleSettingsService.getGeneralSettings();
      if (!settings.enableNotifications) {
        logInfo('Notifications disabled in settings, skipping notification');
        return;
      }

      final notificationService = P2PNotificationService.instanceOrNull;
      if (notificationService == null) {
        logWarning('Notification service not available');
        return;
      }

      if (!notificationService.isReady) {
        logWarning(
            'Notification service not ready: initialized=${notificationService.isInitialized}, permissions=${notificationService.hasPermissions}');
        return;
      }

      final senderName = chat.displayName.isNotEmpty
          ? chat.displayName
          : 'User ${message.senderId}';

      String messageText = message.content;
      if (message.containsFile()) {
        final fileName = message.filePath != null
            ? UriUtils.getFileName(message.filePath!)
            : 'File attachment';
        messageText = '📎 $fileName';
      }

      logInfo('Showing notification: "$messageText" from $senderName');
      await notificationService.showNewMessage(
        chatId: chat.id.toString(),
        senderName: senderName,
        message: messageText,
        userId: message.senderId,
      );
    } catch (e) {
      logError('Error showing new message notification: $e');
    }
  }

  /// Schedule message cleanup to run in background
  void _scheduleMessageCleanup() {
    Future.microtask(() async {
      try {
        // Wait a bit to ensure all chats are loaded
        await Future.delayed(const Duration(seconds: 2));
        await cleanupExpiredMessages();
      } catch (e) {
        logError('Error during scheduled message cleanup: $e');
      }
    });
  }

  Future<List<P2PChat>> getAllChatsWithoutMessages() async {
    final chats = await isar.p2PChats.where().findAll();
    return chats.map((chat) {
      final displayName = chat.displayName.isNotEmpty
          ? chat.displayName
          : 'User ${chat.userBId}';
      return P2PChat()
        ..id = chat.id
        ..userAId = chat.userAId
        ..userBId = chat.userBId
        ..displayName = displayName
        ..createdAt = chat.createdAt
        ..updatedAt = chat.updatedAt
        ..retention = chat.retention;
    }).toList();
  }

  Future<List<P2PChat>> loadAllChats() async {
    final chats = await isar.p2PChats.where().sortByUpdatedAtDesc().findAll();

    // Reorder by pinned list stored in P2PDataCache (id: 'chat_pins')
    try {
      final pins = await isar.p2PDataCaches.getByIndex('id', ["chat_pins"]);
      if (pins != null) {
        final map = pins.getDataAsMap();
        final list =
            (map['userBIds'] as List?)?.cast<String>() ?? const <String>[];
        if (list.isNotEmpty) {
          final pinnedSet = list.toSet();
          chats.sort((a, b) {
            final aPinned = pinnedSet.contains(a.userBId);
            final bPinned = pinnedSet.contains(b.userBId);
            if (aPinned && !bPinned) return -1;
            if (!aPinned && bPinned) return 1;
            return b.updatedAt.compareTo(a.updatedAt);
          });
        }
      }
    } catch (_) {}
    _chatMap.clear();
    for (final chat in chats) {
      _chatMap[chat.id.toString()] = chat;
    }
    notifyListeners();
    return chats;
  }

  // ----- Pinning API -----
  Future<void> pinChat(String userBId) async {
    final cacheId = 'chat_pins';
    var cache = await isar.p2PDataCaches.where().idEqualTo(cacheId).findFirst();
    List<String> userBIds = [];
    if (cache != null) {
      userBIds =
          (cache.getDataAsMap()['userBIds'] as List?)?.cast<String>() ?? [];
    } else {
      cache = P2PDataCache(
        id: cacheId,
        cacheType: 'chat_pins',
        data: '{"userBIds":[]}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    if (!userBIds.contains(userBId)) {
      userBIds.add(userBId);
      cache.setDataFromMap({'userBIds': userBIds});
      await isar.writeTxn(() async => isar.p2PDataCaches.put(cache!));
      await loadAllChats();
    }
  }

  Future<void> unpinChat(String userBId) async {
    final cacheId = 'chat_pins';
    final cache =
        await isar.p2PDataCaches.where().idEqualTo(cacheId).findFirst();
    if (cache == null) return;
    final userBIds =
        (cache.getDataAsMap()['userBIds'] as List?)?.cast<String>() ?? [];
    if (userBIds.remove(userBId)) {
      cache.setDataFromMap({'userBIds': userBIds});
      await isar.writeTxn(() async => isar.p2PDataCaches.put(cache));
      await loadAllChats();
    }
  }

  Future<bool> isPinned(String userBId) async {
    final cache =
        await isar.p2PDataCaches.where().idEqualTo('chat_pins').findFirst();
    if (cache == null) return false;
    final userBIds =
        (cache.getDataAsMap()['userBIds'] as List?)?.cast<String>() ?? [];
    return userBIds.contains(userBId);
  }

  Future<P2PChat> addChat(String userId,
      {MessageRetention retention = MessageRetention.days30}) async {
    final existing = await findChatByUsers(userId);
    String displayName = 'User $userId';
    try {
      final user = isar.p2PUsers.filter().idEqualTo(userId).findFirstSync();
      if (user != null && user.displayName.isNotEmpty) {
        displayName = user.displayName;
      }
    } catch (_) {}
    if (existing != null) {
      logInfo('Chat already exists between $_currentUserId and $userId');
      return existing;
    }
    final chat = P2PChat()
      ..userAId = _currentUserId
      ..userBId = userId
      ..displayName = displayName
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..retention = retention;
    await isar.writeTxn(() async {
      await isar.p2PChats.put(chat);
    });
    _chatMap[chat.id.toString()] = chat;
    notifyListeners();
    logInfo('Added new chat between $_currentUserId and $userId');
    return chat;
  }

  // This method is used to add messages to the received chat
  Future<int> addMessage(P2PCMessage msg, P2PChat chat) async {
    late int id;
    await isar.writeTxn(() async {
      msg.status = P2PCMessageStatus.onDevice; // Set status to on-device
      msg.sentAt = DateTime.now(); // Sync date time to avoid date region issues
      id = await isar.p2PCMessages.put(msg);
      chat.messages.add(msg);
      await chat.messages.save();
      chat.updatedAt = DateTime.now();
      await isar.p2PChats.put(chat);
    });
    logInfo('>>> Message added with ID: $id');
    notifyListeners();
    return id;
  }

  bool chatIdExists(String chatId) => _chatMap.containsKey(chatId);

  Future<P2PChat?> findChatByUsers(String userId) async {
    final chats = await isar.p2PChats
        .filter()
        .userAIdEqualTo(_currentUserId)
        .userBIdEqualTo(userId)
        .findAll();
    if (chats.isNotEmpty) return chats.first;
    final chatsReverse = await isar.p2PChats
        .filter()
        .userAIdEqualTo(_currentUserId)
        .userBIdEqualTo(userId)
        .findAll();
    if (chatsReverse.isNotEmpty) return chatsReverse.first;
    return null;
  }

  Future<P2PCMessage?> getLatestMessageWithUser(String userId) async {
    final chat = _chatMap.values
        .firstWhere((c) => c.userBId == userId, orElse: () => P2PChat.empty());
    if (chat.isEmpty()) return null;
    return chat.messages.lastOrNull;
  }

  Future<String?> handleCheckMessageFileExist(
      String userBId, String syncId) async {
    try {
      final chat = _chatMap.values.firstWhere((c) => c.userBId == userBId);
      logDebug('Checking file existence for user $userBId, syncId: $syncId');
      final msg = chat.messages.firstWhere((m) => m.syncId == syncId);
      logDebug('Message file path: ${msg.filePath}');
      if (msg.filePath != null && msg.filePath!.isNotEmpty) {
        // Check if the file exists before returning the path
        final file = File(msg.filePath!);
        if (await file.exists()) {
          return msg.filePath;
        } else {
          // File does not exist, update message status
          await updateMessageStatus(msg, chat, P2PCMessageStatus.lostBoth);
          return null;
        }
      }
      // If filePath is null or empty, return null
      return null;
    } catch (e) {
      logError('Error handling message file existence: $e');
      return null;
    }
  }

  Future<void> handleFileRequestLost(String userBId, String syncId) async {
    try {
      // Find the chat and message by userBId and syncId
      logDebug('Handling file request lost for user $userBId, syncId: $syncId');
      final chat = _chatMap.values.firstWhere((c) => c.userBId == userBId);
      final msg = chat.messages.firstWhere((m) => m.syncId == syncId);
      await updateMessageStatus(msg, chat, P2PCMessageStatus.lostBoth);
      await chat.messages.load();
      notifyListeners();
      logInfo('File request lost for user $userBId, syncId: $syncId');
    } catch (e) {
      logError('Error handling file request lost: $e');
    }
  }

  Future<void> handleChatResponseExist(String userBId, String syncId) async {
    try {
      final chat = _chatMap.values.firstWhere((c) => c.userBId == userBId);
      final msg = chat.messages.firstWhere((m) => m.syncId == syncId);
      await updateMessageStatus(msg, chat, P2PCMessageStatus.lostBoth);
      notifyListeners();
      logInfo('Chat response lost for user $userBId, syncId: $syncId');
    } catch (e) {
      logError('Error handling chat response lost: $e');
    }
  }

  Future<void> updateChatSettings(
      P2PChat currentChat, P2PChat updatedChat) async {
    try {
      await isar.writeTxn(() async {
        currentChat.updateSettings(updatedChat);
        await isar.p2PChats.put(currentChat);
      });
      _chatMap[currentChat.id.toString()] = currentChat;
      notifyListeners();
    } catch (e) {
      logError('Error updating chat settings: $e');
    }
  }

  Future<void> removeMessageAndNotify(
      {required P2PChat chat,
      required P2PCMessage message,
      required deleteFileIfExist}) async {
    await isar.writeTxn(() async {
      await isar.p2PCMessages.delete(message.id);
      chat.messages.remove(message);
      await chat.messages.save();
      if (deleteFileIfExist &&
          (message.type == P2PCMessageType.file ||
              message.type == P2PCMessageType.mediaImage ||
              message.type == P2PCMessageType.mediaVideo)) {
        final file = File(message.filePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    });
    _chatMap[chat.id.toString()] = chat;
    await chat.messages.load();
    notifyListeners();
  }

  Future<void> updateFileSyncResponseAndNotify(
      {required String userBId,
      required String syncId,
      required String filePath}) async {
    try {
      final chat = _chatMap.values.firstWhere((c) => c.userBId == userBId);
      final msg =
          await chat.messages.filter().syncIdEqualTo(syncId).findFirst();
      logDebug('updateFileSyncResponseAndNotify: Step 1');
      if (msg != null) {
        await isar.writeTxn(() async {
          msg.status = P2PCMessageStatus.onDevice;
          msg.filePath = filePath;
          await isar.p2PCMessages.put(msg);
        });
        logDebug('updateFileSyncResponseAndNotify: Step 2');

        // Reload messages and update cache
        await chat.messages.load();
        _chatMap[chat.id.toString()] = chat;

        // Notify listeners to refresh UI
        notifyListeners();

        logInfo(
            'P2PTransferService: Updated message status and refreshed UI for syncId: $syncId');
      }
    } catch (e) {
      logError(
          'P2PTransferService: Failed to update message status in Isar: $e');
    }
  }

  Future<void> updateFilePathAndNotify(
      {required String userBId, required String filePath}) async {
    try {
      final chat =
          await isar.p2PChats.filter().userBIdEqualTo(userBId).findFirst();
      final msg = chat!.messages.lastOrNull;
      if (msg != null) {
        logDebug('Updating file path for message: ${msg.syncId}');
        await isar.writeTxn(() async {
          msg.filePath = filePath;
          msg.status = P2PCMessageStatus.onDevice;
          await isar.p2PCMessages.put(msg);
        });

        // Move these operations outside the transaction
        await chat.messages.load();
        _chatMap[chat.id.toString()] = chat;

        // Notify listeners to refresh UI
        notifyListeners();

        logInfo(
            'P2PTransferService: Updated file path and refreshed UI for userBId: $userBId');
      }
    } catch (e) {
      logError('P2PTransferService: Failed to update filePath in Isar: $e');
    }
  }

  Future<P2PCMessage?> getMessageBaseOnSyncId(
      {required P2PChat chat, required String syncId}) async {
    if (chat.messages.isEmpty) return null;
    return await chat.messages.filter().syncIdEqualTo(syncId).findFirst();
  }

  Future<void> deleteChatAndNotify(P2PChat chat) async {
    try {
      // // Get all messages in the chat that has files
      // final messagesWithFiles = (chat.messages
      //         .where((msg) =>
      //             (msg.type == P2PCMessageType.file ||
      //                 msg.type == P2PCMessageType.mediaImage ||
      //                 msg.type == P2PCMessageType.mediaVideo) &&
      //             msg.status == P2PCMessageStatus.onDevice)
      //         .toList())
      //     .map((msg) => msg.filePath)
      //     .toList();
      // // Delete files in the background
      // backgroudnDeleteFiles(messagesWithFiles);
      // Delete the chat from the database
      await isar.writeTxn(() async {
        await isar.p2PChats.delete(chat.id);
      });

      // Remove from local cache and notify listeners after transaction
      _chatMap.remove(chat.id.toString());
      notifyListeners();
    } catch (e) {
      logError('Error deleting chat: $e');
    }
  }

  /// Clean up expired messages based on chat retention settings
  Future<void> cleanupExpiredMessages() async {
    try {
      logInfo('Starting automatic message cleanup...');
      int totalCleaned = 0;
      int totalFilesDeleted = 0;

      for (final chat in _chatMap.values) {
        if (!chat.shouldCleanupMessages()) continue;

        final cutoffDate = chat.getMessageCutoffDate();
        if (cutoffDate == null) continue;

        // Get expired messages
        final expiredMessages =
            await chat.messages.filter().sentAtLessThan(cutoffDate).findAll();

        if (expiredMessages.isEmpty) continue;

        logDebug(
            'Found ${expiredMessages.length} expired messages in chat ${chat.displayName}');

        // Clean up files from expired messages
        for (final message in expiredMessages) {
          if (message.containsFile() &&
              message.filePath != null &&
              message.filePath!.isNotEmpty) {
            try {
              final file = File(message.filePath!);
              if (await file.exists()) {
                await file.delete();
                totalFilesDeleted++;
                logDebug('Deleted expired file: ${message.filePath}');
              }
            } catch (e) {
              logWarning(
                  'Failed to delete expired file ${message.filePath}: $e');
            }
          }
        }

        // Delete expired messages from database
        await isar.writeTxn(() async {
          for (final message in expiredMessages) {
            await isar.p2PCMessages.delete(message.id);
            chat.messages.remove(message);
          }
          await chat.messages.save();

          // Update chat's updated time
          chat.updatedAt = DateTime.now();
          await isar.p2PChats.put(chat);
        });

        totalCleaned += expiredMessages.length;
        logInfo(
            'Cleaned ${expiredMessages.length} expired messages from chat ${chat.displayName}');
      }

      // Reload messages for updated chats and notify listeners
      if (totalCleaned > 0) {
        for (final chat in _chatMap.values) {
          await chat.messages.load();
        }
        notifyListeners();
        logInfo(
            'Message cleanup completed: $totalCleaned messages, $totalFilesDeleted files deleted');
      } else {
        logDebug('No expired messages found during cleanup');
      }
    } catch (e) {
      logError('Error during message cleanup: $e');
    }
  }

  /// Cleanup expired messages for a specific chat
  Future<int> cleanupExpiredMessagesForChat(P2PChat chat) async {
    try {
      if (!chat.shouldCleanupMessages()) return 0;

      final cutoffDate = chat.getMessageCutoffDate();
      if (cutoffDate == null) return 0;

      // Get expired messages
      final expiredMessages =
          await chat.messages.filter().sentAtLessThan(cutoffDate).findAll();

      if (expiredMessages.isEmpty) return 0;

      int filesDeleted = 0;

      // Clean up files from expired messages
      for (final message in expiredMessages) {
        if (message.containsFile() &&
            message.filePath != null &&
            message.filePath!.isNotEmpty) {
          try {
            final file = File(message.filePath!);
            if (await file.exists()) {
              await file.delete();
              filesDeleted++;
            }
          } catch (e) {
            logWarning('Failed to delete expired file ${message.filePath}: $e');
          }
        }
      }

      // Delete expired messages from database
      await isar.writeTxn(() async {
        for (final message in expiredMessages) {
          await isar.p2PCMessages.delete(message.id);
          chat.messages.remove(message);
        }
        await chat.messages.save();

        // Update chat's updated time
        chat.updatedAt = DateTime.now();
        await isar.p2PChats.put(chat);
      });

      // Reload messages and update cache
      await chat.messages.load();
      _chatMap[chat.id.toString()] = chat;
      notifyListeners();

      logInfo(
          'Cleaned ${expiredMessages.length} expired messages from chat ${chat.displayName} (${filesDeleted} files deleted)');
      return expiredMessages.length;
    } catch (e) {
      logError(
          'Error cleaning up expired messages for chat ${chat.displayName}: $e');
      return 0;
    }
  }
}
