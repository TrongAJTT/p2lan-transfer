import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:p2lan/utils/isar_utils.dart';

part 'p2p_cache_models.g.dart';

/// Generic, reusable P2P data cache model
@Collection()
class P2PDataCache {
  Id get isarId => fastHash(id);

  @Index(unique: true, replace: true)
  String id;

  /// Cache type identifier (e.g., 'chat_pins', 'pairing_cache', ...)
  @Index()
  String cacheType;

  /// Primary payload JSON string
  String data;

  /// Optional metadata JSON string
  String meta;

  /// Created timestamp
  @Index()
  DateTime createdAt;

  /// Last updated timestamp
  DateTime updatedAt;

  /// Optional expiry timestamp
  @Index()
  DateTime? expiresAt;

  /// Optional status string
  String? status;

  P2PDataCache({
    required this.id,
    required this.cacheType,
    required this.data,
    this.meta = '{}',
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    this.status,
  });

  /// Get metadata as Map
  Map<String, dynamic> getMetaAsMap() {
    try {
      return Map<String, dynamic>.from(jsonDecode(meta));
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  /// Set metadata from Map
  void setMetaFromMap(Map<String, dynamic> metaMap) {
    meta = jsonEncode(metaMap);
    updatedAt = DateTime.now();
  }

  /// Get value as Map
  Map<String, dynamic> getDataAsMap() {
    try {
      return Map<String, dynamic>.from(jsonDecode(data));
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  /// Set value from Map
  void setDataFromMap(Map<String, dynamic> dataMap) {
    data = jsonEncode(dataMap);
    updatedAt = DateTime.now();
  }

  /// Check if this cache entry is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Mark as processed
  void updateStatus(String newStatus) {
    status = newStatus;
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cacheType': cacheType,
        'data': data,
        'meta': meta,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'status': status,
      };

  factory P2PDataCache.fromJson(Map<String, dynamic> json) => P2PDataCache(
        id: json['id'] as String,
        cacheType: json['cacheType'] as String,
        data: json['data'] as String,
        meta: json['meta'] as String? ?? '{}',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
        status: json['status'] as String?,
      );

  /// Factory methods bellow if needed
}

// Note: Pinned chat list is stored inside P2PDataCache with id 'chat_pins'
