import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:p2lan/utils/isar_utils.dart';

part 'p2p_models.g.dart';

enum NetworkSecurityLevel {
  secure, // Mobile data or secured WiFi
  unsecure, // Open WiFi
  unknown, // Cannot determine
}

enum ConnectionStatus {
  disconnected,
  discovering,
  connected,
  pairing,
  paired,
}

enum ConnectionDisplayStatus {
  discovered, // Newly discovered device (blue)
  connectedOnline, // Stored connection, online (green)
  connectedOffline, // Stored connection, offline (gray)
}

enum DataTransferStatus {
  pending,
  requesting,
  waitingForApproval, // Waiting for receiver approval
  transferring,
  completed,
  failed,
  cancelled,
  rejected, // Rejected by receiver
}

enum FileTransferRejectReason {
  userRejected,
  timeout,
  fileSizeExceeded,
  totalSizeExceeded,
  storageInsufficient,
  unsupportedFileType,
  unknown,
}

enum EncryptionType {
  none,
  aesGcm,
  chaCha20,
}

enum KeyExchangeStatus {
  none, // No key exchange
  requested, // Key exchange requested
  exchanging, // Keys being exchanged
  completed, // Key exchange completed
  failed, // Key exchange failed
}

enum UserPlatform {
  android,
  ios,
  windows,
  macos,
  linux,
  web,
  unknown,
}

@Collection()
class P2PUser {
  Id get isarId => fastHash(id);

  @Index(unique: true, replace: true)
  String id;

  String displayName;

  @Index()
  String profileId; // Unified field replacing appInstallationId and deviceId

  String ipAddress;

  int port;

  DateTime lastSeen;

  bool isOnline;

  bool isPaired;

  bool isTrusted;

  DateTime? pairedAt;
  // Indicates if this is a stored/saved connection
  bool isStored;
  // Whether the user is blocked
  bool isBlocked;
  // Temporarily stored record (e.g., created when blocking from pairing dialog)
  bool isTempStored;

  // ECDH Key Exchange fields
  @Enumerated(EnumType.ordinal)
  KeyExchangeStatus keyExchangeStatus;

  // Public key fingerprint for verification (stored as hex string)
  String? publicKeyFingerprint;

  // Platform information
  @Enumerated(EnumType.ordinal)
  UserPlatform platform;

  // Session ID for encryption (temporary, not persisted)
  @ignore
  String? sessionId;

  P2PUser({
    required this.id,
    required this.displayName,
    required this.profileId,
    required this.ipAddress,
    required this.port,
    required this.lastSeen,
    this.isOnline = false,
    this.isPaired = false,
    this.isTrusted = false,
    this.pairedAt,
    this.isStored = false,
    this.isBlocked = false,
    this.isTempStored = false,
    this.keyExchangeStatus = KeyExchangeStatus.none,
    this.publicKeyFingerprint,
    this.platform = UserPlatform.unknown,
    this.sessionId,
  });

  factory P2PUser.onlyIp({
    required String ipAddress,
    required int port,
  }) =>
      P2PUser(
        id: const Uuid().v4(),
        displayName: '',
        profileId: '',
        ipAddress: ipAddress,
        port: port,
        lastSeen: DateTime.now(),
        platform: UserPlatform.unknown,
      );

  factory P2PUser.create({
    required String displayName,
    required String profileId,
    required String ipAddress,
    required int port,
    DateTime? lastSeen,
    bool isOnline = false,
    bool isPaired = false,
    bool isTrusted = false,
    DateTime? pairedAt,
    bool isStored = false,
    bool isTempStored = false,
    UserPlatform platform = UserPlatform.unknown,
  }) =>
      P2PUser(
        id: const Uuid().v4(),
        displayName: displayName,
        profileId: profileId,
        ipAddress: ipAddress,
        port: port,
        lastSeen: lastSeen ?? DateTime.now(),
        isOnline: isOnline,
        isPaired: isPaired,
        isTrusted: isTrusted,
        pairedAt: pairedAt,
        isStored: isStored,
        isTempStored: isTempStored,
        platform: platform,
      );

  // Backward compatibility getters
  String get deviceId => profileId;
  String get appInstallationId => profileId;

  /// Get connection status for UI display
  @ignore
  ConnectionDisplayStatus get connectionDisplayStatus {
    if (isStored) {
      return isOnline
          ? ConnectionDisplayStatus.connectedOnline
          : ConnectionDisplayStatus.connectedOffline;
    } else {
      return ConnectionDisplayStatus.discovered;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'profileId': profileId,
        // Keep old fields for backward compatibility
        'appInstallationId': profileId,
        'deviceId': profileId,
        'appSessionId': profileId,
        'ipAddress': ipAddress,
        'port': port,
        'lastSeen': lastSeen.toIso8601String(),
        'isOnline': isOnline,
        'isPaired': isPaired,
        'isTrusted': isTrusted,
        'pairedAt': pairedAt?.toIso8601String(),
        'isStored': isStored,
        'isBlocked': isBlocked,
        'isTempStored': isTempStored,
        'platform': platform.name,
      };

  factory P2PUser.fromJson(Map<String, dynamic> json) => P2PUser(
        id: json['id'],
        displayName: json['displayName'],
        // Try new field first, fallback to old fields for backward compatibility
        profileId: json['profileId'] ??
            json['appInstallationId'] ??
            json['appSessionId'] ??
            json['deviceId'],
        ipAddress: json['ipAddress'],
        port: json['port'],
        lastSeen: DateTime.parse(json['lastSeen']),
        isOnline: json['isOnline'] ?? false,
        isPaired: json['isPaired'] ?? false,
        isTrusted: json['isTrusted'] ?? false,
        pairedAt:
            json['pairedAt'] != null ? DateTime.parse(json['pairedAt']) : null,
        isStored: json['isStored'] ?? false,
        isBlocked: json['isBlocked'] ?? false,
        isTempStored: json['isTempStored'] ?? false,
        platform: json['platform'] != null
            ? UserPlatform.values.firstWhere(
                (p) => p.name == json['platform'],
                orElse: () => UserPlatform.unknown,
              )
            : UserPlatform.unknown,
      );

  String getIpAndPort() {
    return '$ipAddress:$port';
  }
}

@Collection()
class PairingRequest {
  Id get isarId => fastHash(id);

  @Index(unique: true, replace: true)
  String id;

  String fromUserId;

  String fromUserName;

  String fromProfileId;

  String fromIpAddress;

  int fromPort;

  DateTime requestTime;

  bool wantsSaveConnection;

  bool isProcessed;

  PairingRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromProfileId,
    required this.fromIpAddress,
    required this.fromPort,
    required this.requestTime,
    this.wantsSaveConnection = false,
    this.isProcessed = false,
  });

  factory PairingRequest.create({
    required String fromUserId,
    required String fromUserName,
    required String fromProfileId,
    required String fromIpAddress,
    required int fromPort,
    DateTime? requestTime,
    bool wantsSaveConnection = false,
    bool isProcessed = false,
  }) =>
      PairingRequest(
        id: const Uuid().v4(),
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromProfileId: fromProfileId,
        fromIpAddress: fromIpAddress,
        fromPort: fromPort,
        requestTime: requestTime ?? DateTime.now(),
        wantsSaveConnection: wantsSaveConnection,
        isProcessed: isProcessed,
      );

  // Backward compatibility getters
  @ignore
  String get fromDeviceId => fromProfileId;
  @ignore
  String get fromAppInstallationId => fromProfileId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromUserId': fromUserId,
        'fromUserName': fromUserName,
        'fromAppInstallationId': fromAppInstallationId,
        // Keep old fields for backward compatibility
        'fromDeviceId': fromAppInstallationId,
        'fromAppSessionId': fromAppInstallationId,
        'fromIpAddress': fromIpAddress,
        'fromPort': fromPort,
        'requestTime': requestTime.toIso8601String(),
        'wantsSaveConnection': wantsSaveConnection,
        'isProcessed': isProcessed,
      };

  factory PairingRequest.fromJson(Map<String, dynamic> json) => PairingRequest(
        id: json['id'],
        fromUserId: json['fromUserId'],
        fromUserName: json['fromUserName'],
        // Try new field first, fallback to old fields for backward compatibility
        fromProfileId: json['fromAppInstallationId'] ??
            json['fromAppSessionId'] ??
            json['fromDeviceId'],
        fromIpAddress: json['fromIpAddress'],
        fromPort: json['fromPort'],
        requestTime: DateTime.parse(json['requestTime']),
        wantsSaveConnection: json['wantsSaveConnection'] ?? false,
        isProcessed: json['isProcessed'] ?? false,
      );
}

/// Các key chuẩn cho metadata mở rộng của DataTransferTask
enum DataTransferKey {
  messageId,
  syncFilePath,
  fileSyncResponse,
}

@Collection()
class DataTransferTask {
  Id get isarId => fastHash(id);

  @Index(unique: true, replace: true)
  String id;

  String fileName;

  String filePath;

  int fileSize;

  @Index()
  String targetUserId;

  String targetUserName;

  @Enumerated(EnumType.ordinal)
  DataTransferStatus status;

  int transferredBytes;

  DateTime createdAt;

  DateTime? startedAt;

  DateTime? completedAt;

  String? errorMessage;

  bool isOutgoing;

  String? savePath;

  @Index()
  String? batchId; // Links to file transfer request

  /// Metadata mở rộng cho transfer (ví dụ: messageId, custom keys...)
  @ignore
  Map<String, dynamic>? data;

  DataTransferTask({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.targetUserId,
    required this.targetUserName,
    this.status = DataTransferStatus.pending,
    this.transferredBytes = 0,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    required this.isOutgoing,
    this.savePath,
    this.batchId,
    this.data,
  });

  factory DataTransferTask.create({
    required String fileName,
    required String filePath,
    required int fileSize,
    required String targetUserId,
    required String targetUserName,
    DataTransferStatus status = DataTransferStatus.pending,
    int transferredBytes = 0,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    required bool isOutgoing,
    String? savePath,
    String? batchId,
    Map<String, dynamic>? data,
  }) =>
      DataTransferTask(
        id: const Uuid().v4(),
        fileName: fileName,
        filePath: filePath,
        fileSize: fileSize,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        status: status,
        transferredBytes: transferredBytes,
        createdAt: createdAt ?? DateTime.now(),
        startedAt: startedAt,
        completedAt: completedAt,
        errorMessage: errorMessage,
        isOutgoing: isOutgoing,
        savePath: savePath,
        batchId: batchId,
        data: data,
      );

  @ignore
  double get progress => fileSize > 0 ? transferredBytes / fileSize : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'filePath': filePath,
        'fileSize': fileSize,
        'targetUserId': targetUserId,
        'targetUserName': targetUserName,
        'status': status.index,
        'transferredBytes': transferredBytes,
        'createdAt': createdAt.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'errorMessage': errorMessage,
        'isOutgoing': isOutgoing,
        'savePath': savePath,
        'batchId': batchId,
        'data': data,
      };

  factory DataTransferTask.fromJson(Map<String, dynamic> json) =>
      DataTransferTask(
        id: json['id'],
        fileName: json['fileName'],
        filePath: json['filePath'],
        fileSize: json['fileSize'],
        targetUserId: json['targetUserId'],
        targetUserName: json['targetUserName'],
        status: DataTransferStatus.values[json['status']],
        transferredBytes: json['transferredBytes'],
        createdAt: DateTime.parse(json['createdAt']),
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'])
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        errorMessage: json['errorMessage'],
        isOutgoing: json['isOutgoing'],
        savePath: json['savePath'],
        batchId: json['batchId'],
        data: json['data'] != null
            ? Map<String, dynamic>.from(json['data'])
            : {"errorAsString": "No data provided"},
      );
}

class NetworkInfo {
  final String? wifiName;
  final String? wifiSSID;
  final String? ipAddress;
  final String? gatewayAddress;
  final bool isWiFi;
  final bool isMobile;
  final bool isSecure;
  final NetworkSecurityLevel securityLevel;
  final int? signalStrength;
  final String? securityType;

  NetworkInfo({
    this.wifiName,
    this.wifiSSID,
    this.ipAddress,
    this.gatewayAddress,
    required this.isWiFi,
    required this.isMobile,
    required this.isSecure,
    required this.securityLevel,
    this.signalStrength,
    this.securityType,
  });
}

class P2PMessage {
  final String type;
  final String fromUserId;
  final String toUserId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  P2PMessage({
    required this.type,
    required this.fromUserId,
    required this.toUserId,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': type,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  factory P2PMessage.fromJson(Map<String, dynamic> json) => P2PMessage(
        type: json['type'] as String? ?? '',
        fromUserId: json['fromUserId'] as String? ?? '',
        toUserId: json['toUserId'] as String? ?? '',
        data: json['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['data'])
            : <String, dynamic>{},
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// Model for file information in transfer request
@embedded
class FileTransferInfo {
  late String fileName;
  late int fileSize;
  int? messageId; // Dùng để truyền metadata cho file message (nếu có)

  // Add a no-arg constructor for Isar
  FileTransferInfo({
    this.fileName = '',
    this.fileSize = 0,
    this.messageId,
  });

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'fileSize': fileSize,
        if (messageId != null) 'messageId': messageId,
      };

  factory FileTransferInfo.fromJson(Map<String, dynamic> json) =>
      FileTransferInfo(
        fileName: json['fileName'] as String,
        fileSize: json['fileSize'] as int,
        messageId: json['messageId'] as int?,
      );
}

/// File transfer request model
@Collection()
class FileTransferRequest {
  Id get isarId => fastHash(requestId);

  @Index(unique: true, replace: true)
  String requestId;

  @Index()
  String batchId; // ID for grouping multiple files in one transfer session

  String fromUserId;

  String fromUserName;

  List<FileTransferInfo> files;

  int totalSize;

  String protocol; // 'tcp' or 'udp' or 'quic' (plan)

  DateTime requestTime;

  bool isProcessed;

  int? maxChunkSize; // Sender's preferred chunk size in KB

  DateTime?
      receivedTime; // Time when request was received at the receiver device

  bool useEncryption; // Whether sender uses encryption for this transfer

  @ignore
  Map<String, dynamic>? metadata; // Additional metadata for transfer

  FileTransferRequest({
    required this.requestId,
    required this.batchId,
    required this.fromUserId,
    required this.fromUserName,
    required this.files,
    required this.totalSize,
    this.protocol = 'tcp',
    required this.requestTime,
    this.isProcessed = false,
    this.maxChunkSize,
    this.receivedTime,
    this.useEncryption = false,
    this.metadata,
  });

  factory FileTransferRequest.create({
    required String fromUserId,
    required String fromUserName,
    required List<FileTransferInfo> files,
    required int totalSize,
    String protocol = 'tcp',
    DateTime? requestTime,
    bool isProcessed = false,
    int? maxChunkSize,
    DateTime? receivedTime,
    bool useEncryption = true,
  }) =>
      FileTransferRequest(
        requestId: const Uuid().v4(),
        batchId: const Uuid().v4(),
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        files: files,
        totalSize: totalSize,
        protocol: protocol,
        requestTime: requestTime ?? DateTime.now(),
        isProcessed: isProcessed,
        maxChunkSize: maxChunkSize,
        receivedTime: receivedTime,
        useEncryption: useEncryption,
      );

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'batchId': batchId,
        'fromUserId': fromUserId,
        'fromUserName': fromUserName,
        'files': files.map((f) => f.toJson()).toList(),
        'totalSize': totalSize,
        'protocol': protocol,
        'requestTime': requestTime.toIso8601String(),
        'isProcessed': isProcessed,
        'maxChunkSize': maxChunkSize,
        'receivedTime': receivedTime?.toIso8601String(),
        'useEncryption': useEncryption,
      };

  factory FileTransferRequest.fromJson(Map<String, dynamic> json) =>
      FileTransferRequest(
        requestId: json['requestId'] as String,
        batchId: json['batchId'] as String,
        fromUserId: json['fromUserId'] as String,
        fromUserName: json['fromUserName'] as String,
        files: (json['files'] as List<dynamic>)
            .map((f) => FileTransferInfo.fromJson(f as Map<String, dynamic>))
            .toList(),
        totalSize: json['totalSize'] as int,
        protocol: json['protocol'] as String? ?? 'tcp',
        requestTime: DateTime.parse(json['requestTime'] as String),
        isProcessed: json['isProcessed'] as bool? ?? false,
        maxChunkSize: json['maxChunkSize'] as int?,
        receivedTime: json['receivedTime'] != null
            ? DateTime.parse(json['receivedTime'] as String)
            : null,
        useEncryption: json['useEncryption'] as bool? ?? false,
      );
}

/// File transfer response model
class FileTransferResponse {
  final String requestId;
  final String batchId;
  final bool accepted;
  final FileTransferRejectReason? rejectReason;
  final String? rejectMessage;
  final String? downloadPath; // Path where files will be saved if accepted
  final String? sessionKeyBase64; // AES session key for encrypted transfers

  const FileTransferResponse({
    required this.requestId,
    required this.batchId,
    required this.accepted,
    this.rejectReason,
    this.rejectMessage,
    this.downloadPath,
    this.sessionKeyBase64,
  });

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'batchId': batchId,
        'accepted': accepted,
        'rejectReason': rejectReason?.name,
        'rejectMessage': rejectMessage,
        'downloadPath': downloadPath,
        'sessionKeyBase64': sessionKeyBase64,
      };

  factory FileTransferResponse.fromJson(Map<String, dynamic> json) =>
      FileTransferResponse(
        requestId: json['requestId'] as String,
        batchId: json['batchId'] as String,
        accepted: json['accepted'] as bool,
        rejectReason: json['rejectReason'] != null
            ? FileTransferRejectReason.values
                .firstWhere((e) => e.name == json['rejectReason'])
            : null,
        rejectMessage: json['rejectMessage'] as String?,
        downloadPath: json['downloadPath'] as String?,
        sessionKeyBase64: json['sessionKeyBase64'] as String?,
      );
}

// Message types
class P2PMessageTypes {
  static const String discovery = 'discovery';
  static const String discoveryResponse = 'discovery_response';
  static const String discoveryScanRequest = 'discovery_scan_request';
  static const String profileSyncRequest = 'profile_sync_request';
  static const String pairingRequest = 'pairing_request';
  static const String pairingResponse = 'pairing_response';
  static const String dataTransferInit = 'data_transfer_init';
  static const String dataTransferRequest = 'data_transfer_request';
  static const String dataTransferResponse = 'data_transfer_response';
  static const String dataChunk = 'data_chunk';
  static const String dataTransferComplete = 'data_transfer_complete';
  static const String dataTransferCancel = 'data_transfer_cancel';
  static const String heartbeat = 'heartbeat';
  static const String disconnect = 'disconnect';
  static const String trustRequest = 'trust_request';
  // ECDH Key Exchange messages
  static const String keyExchangeRequest = 'key_exchange_request';
  static const String keyExchangeResponse = 'key_exchange_response';
  static const String encryptedDataChunk = 'encrypted_data_chunk';
  static const String trustResponse = 'trust_response';
  // File transfer pre-request messages
  static const String fileTransferRequest = 'file_transfer_request';
  static const String fileTransferResponse = 'file_transfer_response';
  // Chat messages
  static const String sendChatMessage = 'send_chat_message';
  static const String chatMessageAck = 'chat_message_ack';
  static const String chatRequestFileBackward = 'chat_request_file_backward';
  static const String chatRequestFileLost = 'chat_response_file_lost';
  static const String chatFileTransferRequest = 'chat_file_transfer_request';
  // Remote control messages
  static const String remoteControlRequest = 'remote_control_request';
  static const String remoteControlResponse = 'remote_control_response';
  static const String remoteControlEvent = 'remote_control_event';
  static const String remoteControlDisconnect = 'remote_control_disconnect';
  // Screen sharing messages
  static const String screenSharingRequest = 'screen_sharing_request';
  static const String screenSharingResponse = 'screen_sharing_response';
  static const String screenSharingData = 'screen_sharing_data';
  static const String screenSharingDisconnect = 'screen_sharing_disconnect';
}

// Workmanager task constants
const String p2pKeepAliveTask = "p2pKeepAliveTask";

// REMOVED: P2PFileStorageSettings - Merged into ExtensibleSettings as P2PTransferSettingsData

// REMOVED: P2PDataTransferSettings - Merged into ExtensibleSettings as P2PTransferSettingsData

// Backward compatibility aliases - these will be populated by P2PSettingsAdapter
// Đã xóa class P2PFileStorageSettings và mọi tham chiếu đến askBeforeDownload

class P2PDataTransferSettings {
  String downloadPath;
  bool createDateFolders;
  bool createSenderFolders;
  int maxReceiveFileSize; // In bytes
  int maxTotalReceiveSize; // In bytes
  int maxConcurrentTasks;
  String sendProtocol;
  int maxChunkSize; // In kilobytes
  String? customDisplayName;
  int uiRefreshRateSeconds;
  bool enableNotifications;
  EncryptionType encryptionType;
  bool autoCleanupCompletedTasks; // Auto cleanup completed transfer tasks
  bool autoCleanupCancelledTasks; // Auto cleanup cancelled transfer tasks
  bool autoCleanupFailedTasks; // Auto cleanup failed transfer tasks
  int autoCleanupDelaySeconds; // Delay before auto cleanup (seconds)
  bool clearTransfersAtStartup; // Clear stale transfers at app startup

  P2PDataTransferSettings({
    required this.downloadPath,
    required this.createDateFolders,
    required this.maxReceiveFileSize,
    required this.maxTotalReceiveSize,
    required this.maxConcurrentTasks,
    required this.sendProtocol,
    required this.maxChunkSize,
    this.customDisplayName,
    this.uiRefreshRateSeconds = 0,
    this.enableNotifications =
        false, // Default to false to reduce notification spam
    this.createSenderFolders = false,
    this.encryptionType = EncryptionType.none,
    this.autoCleanupCompletedTasks =
        false, // Auto cleanup completed tasks by default
    this.autoCleanupCancelledTasks =
        true, // Auto cleanup cancelled tasks by default
    this.autoCleanupFailedTasks = true, // Auto cleanup failed tasks by default
    this.autoCleanupDelaySeconds = 5, // Default 5 seconds delay
    this.clearTransfersAtStartup = false,
  });

  // Helper getters for UI display
  double get maxReceiveFileSizeInMB => maxReceiveFileSize / (1024 * 1024);
  double get maxTotalReceiveSizeInGB =>
      maxTotalReceiveSize / (1024 * 1024 * 1024);

  // Backward compatibility getter
  bool get enableEncryption => encryptionType != EncryptionType.none;

  P2PDataTransferSettings copyWith({
    String? downloadPath,
    bool? createDateFolders,
    int? maxReceiveFileSize,
    int? maxTotalReceiveSize,
    int? maxConcurrentTasks,
    String? sendProtocol,
    int? maxChunkSize,
    String? customDisplayName,
    int? uiRefreshRateSeconds,
    bool? enableNotifications,
    bool? createSenderFolders,
    EncryptionType? encryptionType,
    bool? autoCleanupCompletedTasks,
    bool? autoCleanupCancelledTasks,
    bool? autoCleanupFailedTasks,
    int? autoCleanupDelaySeconds,
  }) {
    return P2PDataTransferSettings(
      downloadPath: downloadPath ?? this.downloadPath,
      createDateFolders: createDateFolders ?? this.createDateFolders,
      maxReceiveFileSize: maxReceiveFileSize ?? this.maxReceiveFileSize,
      maxTotalReceiveSize: maxTotalReceiveSize ?? this.maxTotalReceiveSize,
      maxConcurrentTasks: maxConcurrentTasks ?? this.maxConcurrentTasks,
      sendProtocol: sendProtocol ?? this.sendProtocol,
      maxChunkSize: maxChunkSize ?? this.maxChunkSize,
      customDisplayName: customDisplayName ?? this.customDisplayName,
      uiRefreshRateSeconds: uiRefreshRateSeconds ?? this.uiRefreshRateSeconds,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      createSenderFolders: createSenderFolders ?? this.createSenderFolders,
      encryptionType: encryptionType ?? this.encryptionType,
      autoCleanupCompletedTasks:
          autoCleanupCompletedTasks ?? this.autoCleanupCompletedTasks,
      autoCleanupCancelledTasks:
          autoCleanupCancelledTasks ?? this.autoCleanupCancelledTasks,
      autoCleanupFailedTasks:
          autoCleanupFailedTasks ?? this.autoCleanupFailedTasks,
      autoCleanupDelaySeconds:
          autoCleanupDelaySeconds ?? this.autoCleanupDelaySeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'downloadPath': downloadPath,
      'createDateFolders': createDateFolders,
      'createSenderFolders': createSenderFolders,
      'maxReceiveFileSize': maxReceiveFileSize,
      'maxTotalReceiveSize': maxTotalReceiveSize,
      'maxConcurrentTasks': maxConcurrentTasks,
      'sendProtocol': sendProtocol,
      'maxChunkSize': maxChunkSize,
      'customDisplayName': customDisplayName,
      'uiRefreshRateSeconds': uiRefreshRateSeconds,
      'enableNotifications': enableNotifications,
      'encryptionType': encryptionType.name,
      'autoCleanupCompletedTasks': autoCleanupCompletedTasks,
      'autoCleanupCancelledTasks': autoCleanupCancelledTasks,
      'autoCleanupFailedTasks': autoCleanupFailedTasks,
      'autoCleanupDelaySeconds': autoCleanupDelaySeconds,
      'clearTransfersAtStartup': clearTransfersAtStartup,
    };
  }

  factory P2PDataTransferSettings.fromJson(Map<String, dynamic> json) {
    return P2PDataTransferSettings(
      downloadPath: json['downloadPath'],
      createDateFolders: json['createDateFolders'],
      maxReceiveFileSize: json['maxReceiveFileSize'],
      maxTotalReceiveSize: json['maxTotalReceiveSize'],
      maxConcurrentTasks: json['maxConcurrentTasks'],
      sendProtocol: json['sendProtocol'],
      maxChunkSize: json['maxChunkSize'],
      customDisplayName: json['customDisplayName'],
      uiRefreshRateSeconds: json['uiRefreshRateSeconds'] ?? 0,
      enableNotifications:
          json['enableNotifications'] ?? false, // Default to false
      createSenderFolders: json['createSenderFolders'] ?? false,
      encryptionType: json['encryptionType'] != null
          ? EncryptionType.values.firstWhere(
              (e) => e.name == json['encryptionType'],
              orElse: () => EncryptionType.none,
            )
          : (json['enableEncryption'] == true
              ? EncryptionType
                  .aesGcm // 🚀 Ưu tiên AES-GCM cho performance tốt hơn
              : EncryptionType.none),

      autoCleanupCompletedTasks: json['autoCleanupCompletedTasks'] ?? false,
      autoCleanupCancelledTasks: json['autoCleanupCancelledTasks'] ?? true,
      autoCleanupFailedTasks: json['autoCleanupFailedTasks'] ?? true,
      autoCleanupDelaySeconds: json['autoCleanupDelaySeconds'] ?? 5,
      clearTransfersAtStartup: json['clearTransfersAtStartup'] ?? false,
    );
  }
}

/// Discovery response codes for optimized discovery
enum DiscoveryResponseCode {
  /// Device is completely new (not in storage)
  deviceNew,

  /// Device exists in storage (coming back online)
  deviceUpdate,

  /// Error occurred during processing
  error,
}

/// Discovery scan request for optimized single-device broadcasting
class DiscoveryScanRequest {
  final String fromUserId;
  final String fromUserName;
  final String fromAppInstallationId;
  final String ipAddress;
  final int port;
  final int timestamp;
  final UserPlatform platform;

  const DiscoveryScanRequest({
    required this.fromUserId,
    required this.fromUserName,
    required this.fromAppInstallationId,
    required this.ipAddress,
    required this.port,
    required this.timestamp,
    required this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromAppInstallationId': fromAppInstallationId,
      'ipAddress': ipAddress,
      'port': port,
      'timestamp': timestamp,
      'platform': platform.name,
    };
  }

  factory DiscoveryScanRequest.fromJson(Map<String, dynamic> json) {
    return DiscoveryScanRequest(
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      fromAppInstallationId: json['fromAppInstallationId'] as String,
      ipAddress: json['ipAddress'] as String,
      port: json['port'] as int,
      timestamp: json['timestamp'] as int,
      platform: json['platform'] != null
          ? UserPlatform.values.firstWhere(
              (p) => p.name == json['platform'],
              orElse: () => UserPlatform.unknown,
            )
          : UserPlatform.unknown,
    );
  }
}

/// Discovery response with profile info and status code
class DiscoveryResponse {
  final String toUserId;
  final DiscoveryResponseCode responseCode;
  final P2PUser userProfile;
  final String? errorMessage;
  final int timestamp;

  const DiscoveryResponse({
    required this.toUserId,
    required this.responseCode,
    required this.userProfile,
    this.errorMessage,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'toUserId': toUserId,
      'responseCode': responseCode.name,
      'userProfile': userProfile.toJson(),
      'errorMessage': errorMessage,
      'timestamp': timestamp,
    };
  }

  factory DiscoveryResponse.fromJson(Map<String, dynamic> json) {
    return DiscoveryResponse(
      toUserId: json['toUserId'] as String,
      responseCode: DiscoveryResponseCode.values.firstWhere(
        (e) => e.name == json['responseCode'],
        orElse: () => DiscoveryResponseCode.error,
      ),
      userProfile:
          P2PUser.fromJson(json['userProfile'] as Map<String, dynamic>),
      errorMessage: json['errorMessage'] as String?,
      timestamp: json['timestamp'] as int,
    );
  }
}

/// Enhanced P2PUser with discovery state tracking
extension P2PUserDiscoveryState on P2PUser {
  /// Check if this is a newly discovered device (blue background)
  bool get isNewDevice => !isStored && isOnline && !isPaired;

  /// Check if this is an online saved device (green background)
  bool get isOnlineSaved => isStored && isOnline;

  /// Check if this is an offline saved device (gray background)
  bool get isOfflineSaved => isStored && !isOnline;

  /// Get device category for UI grouping
  P2PDeviceCategory get deviceCategory {
    if (isNewDevice) return P2PDeviceCategory.newDevices;
    if (isOnlineSaved) return P2PDeviceCategory.onlineDevices;
    if (isOfflineSaved) return P2PDeviceCategory.savedDevices;
    return P2PDeviceCategory.unknown;
  }
}

/// Device categories for UI organization
enum P2PDeviceCategory {
  onlineDevices, // Green - online saved devices
  newDevices, // Blue - newly discovered devices
  savedDevices, // Gray - offline saved devices
  unknown,
}

// =============================================================================
// REMOTE CONTROL MODELS
// =============================================================================

/// Remote control request model
class RemoteControlRequest {
  final String requestId;
  final String fromUserId;
  final String fromUserName;
  final DateTime requestTime;
  final String? reason; // Optional reason message

  RemoteControlRequest({
    required this.requestId,
    required this.fromUserId,
    required this.fromUserName,
    required this.requestTime,
    this.reason,
  });

  factory RemoteControlRequest.create({
    required String fromUserId,
    required String fromUserName,
    String? reason,
  }) =>
      RemoteControlRequest(
        requestId: 'rcr_${const Uuid().v4()}',
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        requestTime: DateTime.now(),
        reason: reason,
      );

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'fromUserId': fromUserId,
        'fromUserName': fromUserName,
        'requestTime': requestTime.toIso8601String(),
        'reason': reason,
      };

  factory RemoteControlRequest.fromJson(Map<String, dynamic> json) =>
      RemoteControlRequest(
        requestId: json['requestId'] as String,
        fromUserId: json['fromUserId'] as String,
        fromUserName: json['fromUserName'] as String,
        requestTime: DateTime.parse(json['requestTime'] as String),
        reason: json['reason'] as String?,
      );
}

/// Remote control response model
class RemoteControlResponse {
  final String requestId;
  final bool accepted;
  final String? rejectReason;

  RemoteControlResponse({
    required this.requestId,
    required this.accepted,
    this.rejectReason,
  });

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'accepted': accepted,
        'rejectReason': rejectReason,
      };

  factory RemoteControlResponse.fromJson(Map<String, dynamic> json) =>
      RemoteControlResponse(
        requestId: json['requestId'] as String,
        accepted: json['accepted'] as bool,
        rejectReason: json['rejectReason'] as String?,
      );
}

/// Remote control event types
enum RemoteControlEventType {
  mouseMove,
  leftClick,
  rightClick,
  middleClick,
  startLeftLongClick,
  stopLeftLongClick,
  startMiddleLongClick,
  stopMiddleLongClick,
  startRightLongClick,
  stopRightLongClick,
  scroll,
  scrollUp,
  scrollDown,
  disconnect,
  // New touchpad gestures
  twoFingerScroll,
  twoFingerTap,
  twoFingerSlowTap,
  twoFingerDragDrop,
  threeFingerSwipeUp,
  threeFingerSwipeDown,
  threeFingerSwipeLeft,
  threeFingerSwipeRight,
  threeFingerTap,
  fourFingerTap,
  // Keyboard
  keyDown,
  keyUp,
  // Text sending
  sendText,
}

/// Remote control event model
class RemoteControlEvent {
  final RemoteControlEventType type;
  final double? x; // Mouse position X (0.0 - 1.0 normalized)
  final double? y; // Mouse position Y (0.0 - 1.0 normalized)
  final double? deltaX; // Scroll delta X
  final double? deltaY; // Scroll delta Y
  final int? fingerCount; // Number of fingers for gesture
  final String? direction; // Direction for swipe gestures
  final int? keyCode; // Virtual-Key code for keyboard events
  final String? text; // Text content for sendText events
  final DateTime timestamp;

  RemoteControlEvent({
    required this.type,
    this.x,
    this.y,
    this.deltaX,
    this.deltaY,
    this.fingerCount,
    this.direction,
    this.keyCode,
    this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory RemoteControlEvent.mouseMove(double x, double y) =>
      RemoteControlEvent(type: RemoteControlEventType.mouseMove, x: x, y: y);

  factory RemoteControlEvent.leftClick() =>
      RemoteControlEvent(type: RemoteControlEventType.leftClick);

  factory RemoteControlEvent.rightClick() =>
      RemoteControlEvent(type: RemoteControlEventType.rightClick);

  factory RemoteControlEvent.middleClick() =>
      RemoteControlEvent(type: RemoteControlEventType.middleClick);

  factory RemoteControlEvent.startLeftLongClick() =>
      RemoteControlEvent(type: RemoteControlEventType.startLeftLongClick);

  factory RemoteControlEvent.stopLeftLongClick() =>
      RemoteControlEvent(type: RemoteControlEventType.stopLeftLongClick);

  factory RemoteControlEvent.startMiddleLongClick() =>
      RemoteControlEvent(type: RemoteControlEventType.startMiddleLongClick);

  factory RemoteControlEvent.stopMiddleLongClick() =>
      RemoteControlEvent(type: RemoteControlEventType.stopMiddleLongClick);

  factory RemoteControlEvent.startRightLongClick() =>
      RemoteControlEvent(type: RemoteControlEventType.startRightLongClick);

  factory RemoteControlEvent.stopRightLongClick() =>
      RemoteControlEvent(type: RemoteControlEventType.stopRightLongClick);

  factory RemoteControlEvent.scroll(double deltaX, double deltaY) =>
      RemoteControlEvent(
          type: RemoteControlEventType.scroll, deltaX: deltaX, deltaY: deltaY);

  factory RemoteControlEvent.scrollUp() =>
      RemoteControlEvent(type: RemoteControlEventType.scrollUp);

  factory RemoteControlEvent.scrollDown() =>
      RemoteControlEvent(type: RemoteControlEventType.scrollDown);

  factory RemoteControlEvent.disconnect() =>
      RemoteControlEvent(type: RemoteControlEventType.disconnect);

  // Keyboard events
  factory RemoteControlEvent.keyDown(int keyCode) => RemoteControlEvent(
      type: RemoteControlEventType.keyDown, keyCode: keyCode);

  factory RemoteControlEvent.keyUp(int keyCode) =>
      RemoteControlEvent(type: RemoteControlEventType.keyUp, keyCode: keyCode);

  factory RemoteControlEvent.sendText(String text) =>
      RemoteControlEvent(type: RemoteControlEventType.sendText, text: text);

  // New touchpad gesture factories
  factory RemoteControlEvent.twoFingerScroll(double deltaX, double deltaY) =>
      RemoteControlEvent(
          type: RemoteControlEventType.twoFingerScroll,
          deltaX: deltaX,
          deltaY: deltaY,
          fingerCount: 2);

  factory RemoteControlEvent.twoFingerTap() => RemoteControlEvent(
      type: RemoteControlEventType.twoFingerTap, fingerCount: 2);

  factory RemoteControlEvent.twoFingerSlowTap() => RemoteControlEvent(
      type: RemoteControlEventType.twoFingerSlowTap, fingerCount: 2);

  factory RemoteControlEvent.twoFingerDragDrop(double x, double y) =>
      RemoteControlEvent(
          type: RemoteControlEventType.twoFingerDragDrop,
          x: x,
          y: y,
          fingerCount: 2);

  factory RemoteControlEvent.threeFingerSwipe(String direction) =>
      RemoteControlEvent(
          type: _getThreeFingerSwipeType(direction),
          direction: direction,
          fingerCount: 3);

  factory RemoteControlEvent.threeFingerTap() => RemoteControlEvent(
      type: RemoteControlEventType.threeFingerTap, fingerCount: 3);

  factory RemoteControlEvent.fourFingerTap() => RemoteControlEvent(
      type: RemoteControlEventType.fourFingerTap, fingerCount: 4);

  static RemoteControlEventType _getThreeFingerSwipeType(String direction) {
    switch (direction) {
      case 'up':
        return RemoteControlEventType.threeFingerSwipeUp;
      case 'down':
        return RemoteControlEventType.threeFingerSwipeDown;
      case 'left':
        return RemoteControlEventType.threeFingerSwipeLeft;
      case 'right':
        return RemoteControlEventType.threeFingerSwipeRight;
      default:
        return RemoteControlEventType.threeFingerSwipeUp;
    }
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'x': x,
        'y': y,
        'deltaX': deltaX,
        'deltaY': deltaY,
        'fingerCount': fingerCount,
        'direction': direction,
        'keyCode': keyCode,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  factory RemoteControlEvent.fromJson(Map<String, dynamic> json) =>
      RemoteControlEvent(
        type: RemoteControlEventType.values
            .firstWhere((e) => e.name == json['type']),
        x: json['x'] as double?,
        y: json['y'] as double?,
        deltaX: json['deltaX'] as double?,
        deltaY: json['deltaY'] as double?,
        fingerCount: json['fingerCount'] as int?,
        direction: json['direction'] as String?,
        keyCode: json['keyCode'] as int?,
        text: json['text'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

/// Remote control session information
class RemoteControlSession {
  final String sessionId;
  final P2PUser controllerUser; // User who is controlling
  final P2PUser controlledUser; // User being controlled
  final DateTime startTime;
  final bool isActive;

  const RemoteControlSession({
    required this.sessionId,
    required this.controllerUser,
    required this.controlledUser,
    required this.startTime,
    this.isActive = true,
  });

  Duration get duration => DateTime.now().difference(startTime);

  RemoteControlSession copyWith({
    String? sessionId,
    P2PUser? controllerUser,
    P2PUser? controlledUser,
    DateTime? startTime,
    bool? isActive,
  }) =>
      RemoteControlSession(
        sessionId: sessionId ?? this.sessionId,
        controllerUser: controllerUser ?? this.controllerUser,
        controlledUser: controlledUser ?? this.controlledUser,
        startTime: startTime ?? this.startTime,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'controllerUser': controllerUser.toJson(),
        'controlledUser': controlledUser.toJson(),
        'startTime': startTime.toIso8601String(),
        'isActive': isActive,
      };

  factory RemoteControlSession.fromJson(Map<String, dynamic> json) =>
      RemoteControlSession(
        sessionId: json['sessionId'] as String,
        controllerUser:
            P2PUser.fromJson(json['controllerUser'] as Map<String, dynamic>),
        controlledUser:
            P2PUser.fromJson(json['controlledUser'] as Map<String, dynamic>),
        startTime: DateTime.parse(json['startTime'] as String),
        isActive: json['isActive'] as bool? ?? true,
      );
}

// =============================================================================
// SCREEN SHARING MODELS
// =============================================================================

/// Screen sharing request model
class ScreenSharingRequest {
  final String requestId;
  final String fromUserId;
  final String fromUserName;
  final DateTime requestTime;
  final String? reason; // Optional reason message
  final ScreenSharingQuality quality; // Quality preference

  ScreenSharingRequest({
    required this.requestId,
    required this.fromUserId,
    required this.fromUserName,
    required this.requestTime,
    this.reason,
    this.quality = ScreenSharingQuality.medium,
  });

  factory ScreenSharingRequest.create({
    required String fromUserId,
    required String fromUserName,
    String? reason,
    ScreenSharingQuality quality = ScreenSharingQuality.medium,
  }) =>
      ScreenSharingRequest(
        requestId: 'ssr_${const Uuid().v4()}',
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        requestTime: DateTime.now(),
        reason: reason,
        quality: quality,
      );

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'fromUserId': fromUserId,
        'fromUserName': fromUserName,
        'requestTime': requestTime.toIso8601String(),
        'reason': reason,
        'quality': quality.name,
      };

  factory ScreenSharingRequest.fromJson(Map<String, dynamic> json) =>
      ScreenSharingRequest(
        requestId: json['requestId'] as String,
        fromUserId: json['fromUserId'] as String,
        fromUserName: json['fromUserName'] as String,
        requestTime: DateTime.parse(json['requestTime'] as String),
        reason: json['reason'] as String?,
        quality: ScreenSharingQuality.values.firstWhere(
            (e) => e.name == json['quality'],
            orElse: () => ScreenSharingQuality.medium),
      );
}

/// Screen sharing response model
class ScreenSharingResponse {
  final String requestId;
  final bool accepted;
  final String? rejectReason;
  final ScreenSharingQuality? quality; // Accepted quality

  ScreenSharingResponse({
    required this.requestId,
    required this.accepted,
    this.rejectReason,
    this.quality,
  });

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'accepted': accepted,
        'rejectReason': rejectReason,
        'quality': quality?.name,
      };

  factory ScreenSharingResponse.fromJson(Map<String, dynamic> json) =>
      ScreenSharingResponse(
        requestId: json['requestId'] as String,
        accepted: json['accepted'] as bool,
        rejectReason: json['rejectReason'] as String?,
        quality: json['quality'] != null
            ? ScreenSharingQuality.values
                .firstWhere((e) => e.name == json['quality'])
            : null,
      );
}

/// Screen sharing quality levels
enum ScreenSharingQuality {
  low(width: 640, height: 480, fps: 15, bitrate: 500),
  medium(width: 1280, height: 720, fps: 20, bitrate: 1000),
  high(width: 1920, height: 1080, fps: 25, bitrate: 2000),
  auto(width: 0, height: 0, fps: 0, bitrate: 0); // Auto-detect based on network

  const ScreenSharingQuality({
    required this.width,
    required this.height,
    required this.fps,
    required this.bitrate,
  });

  final int width;
  final int height;
  final int fps;
  final int bitrate; // kbps
}

/// Screen sharing session information
class ScreenSharingSession {
  final String sessionId;
  final P2PUser senderUser; // User who is sharing screen
  final P2PUser receiverUser; // User receiving the screen
  final DateTime startTime;
  final bool isActive;
  final ScreenSharingQuality quality;
  final int? selectedScreenIndex; // For Windows multi-screen support

  const ScreenSharingSession({
    required this.sessionId,
    required this.senderUser,
    required this.receiverUser,
    required this.startTime,
    this.isActive = true,
    this.quality = ScreenSharingQuality.medium,
    this.selectedScreenIndex,
  });

  Duration get duration => DateTime.now().difference(startTime);

  ScreenSharingSession copyWith({
    String? sessionId,
    P2PUser? senderUser,
    P2PUser? receiverUser,
    DateTime? startTime,
    bool? isActive,
    ScreenSharingQuality? quality,
    int? selectedScreenIndex,
  }) =>
      ScreenSharingSession(
        sessionId: sessionId ?? this.sessionId,
        senderUser: senderUser ?? this.senderUser,
        receiverUser: receiverUser ?? this.receiverUser,
        startTime: startTime ?? this.startTime,
        isActive: isActive ?? this.isActive,
        quality: quality ?? this.quality,
        selectedScreenIndex: selectedScreenIndex ?? this.selectedScreenIndex,
      );

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'senderUser': senderUser.toJson(),
        'receiverUser': receiverUser.toJson(),
        'startTime': startTime.toIso8601String(),
        'isActive': isActive,
        'quality': quality.name,
        'selectedScreenIndex': selectedScreenIndex,
      };

  factory ScreenSharingSession.fromJson(Map<String, dynamic> json) =>
      ScreenSharingSession(
        sessionId: json['sessionId'] as String,
        senderUser:
            P2PUser.fromJson(json['senderUser'] as Map<String, dynamic>),
        receiverUser:
            P2PUser.fromJson(json['receiverUser'] as Map<String, dynamic>),
        startTime: DateTime.parse(json['startTime'] as String),
        isActive: json['isActive'] as bool? ?? true,
        quality: ScreenSharingQuality.values.firstWhere(
            (e) => e.name == json['quality'],
            orElse: () => ScreenSharingQuality.medium),
        selectedScreenIndex: json['selectedScreenIndex'] as int?,
      );
}

/// Screen information for multi-screen support (Windows)
class ScreenInfo {
  final int index;
  final String name;
  final int width;
  final int height;
  final bool isPrimary;
  final int left;
  final int top;

  const ScreenInfo({
    required this.index,
    required this.name,
    required this.width,
    required this.height,
    this.isPrimary = false,
    this.left = 0,
    this.top = 0,
  });

  Map<String, dynamic> toJson() => {
        'index': index,
        'name': name,
        'width': width,
        'height': height,
        'isPrimary': isPrimary,
        'left': left,
        'top': top,
      };

  factory ScreenInfo.fromJson(Map<String, dynamic> json) => ScreenInfo(
        index: json['index'] as int,
        name: json['name'] as String,
        width: json['width'] as int,
        height: json['height'] as int,
        isPrimary: json['isPrimary'] as bool? ?? false,
        left: json['left'] as int? ?? 0,
        top: json['top'] as int? ?? 0,
      );
}
