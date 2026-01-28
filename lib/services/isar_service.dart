import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:p2lan/models/p2p_chat.dart';
import 'package:p2lan/models/settings_models.dart';
import 'package:p2lan/models/p2p_models.dart';
import 'package:p2lan/models/p2p_cache_models.dart';
import 'package:p2lan/models/app_installation.dart';
import 'package:p2lan/services/app_logger.dart';
import 'package:p2lan/services/p2p_services/p2p_chat_service.dart';

/// Isar database service for P2Lan Transfer
/// Internal beta v0.5.0 - Clean architecture without legacy migrations
class IsarService {
  static late Isar isar;

  static P2PChatService? _chatService;
  static P2PChatService get chatService {
    if (_chatService == null) {
      logError('IsarService.chatService accessed before initialization!');
      throw Exception('IsarService.chatService not initialized');
    }
    return _chatService!;
  }

  IsarService._();

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final schemas = [
      AppInstallationSchema,
      ExtensibleSettingsSchema,
      P2PUserSchema,
      P2PDataCacheSchema, // P2P generic data cache schema
      P2PChatSchema,
      P2PCMessageSchema,
      FileTransferRequestSchema,
      PairingRequestSchema, // DEPRECATED: Will be migrated to P2PDataCache
      DataTransferTaskSchema, // DEPRECATED: Will be migrated to P2PDataCache
    ];

    if (kDebugMode) {
      isar = await Isar.open(
        schemas,
        directory: dir.path,
        inspector: true,
      );
      logDebug('Isar initialized in debug mode with inspector enabled');
      logDebug('Isar directory: ${dir.path}');
    } else {
      isar = await Isar.open(
        schemas,
        directory: dir.path,
      );
    }
    _chatService = P2PChatService(isar);
  }

  static Future<void> close() async {
    await isar.close();
  }

  // ignore: unnecessary_null_comparison
  static bool get isReady => isar != null;
}
