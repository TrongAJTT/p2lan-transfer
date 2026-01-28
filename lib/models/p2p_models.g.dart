// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetP2PUserCollection on Isar {
  IsarCollection<P2PUser> get p2PUsers => this.collection();
}

const P2PUserSchema = CollectionSchema(
  name: r'P2PUser',
  id: 566369171815177019,
  properties: {
    r'appInstallationId': PropertySchema(
      id: 0,
      name: r'appInstallationId',
      type: IsarType.string,
    ),
    r'deviceId': PropertySchema(
      id: 1,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'displayName': PropertySchema(
      id: 2,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 3,
      name: r'id',
      type: IsarType.string,
    ),
    r'ipAddress': PropertySchema(
      id: 4,
      name: r'ipAddress',
      type: IsarType.string,
    ),
    r'isBlocked': PropertySchema(
      id: 5,
      name: r'isBlocked',
      type: IsarType.bool,
    ),
    r'isOnline': PropertySchema(
      id: 6,
      name: r'isOnline',
      type: IsarType.bool,
    ),
    r'isPaired': PropertySchema(
      id: 7,
      name: r'isPaired',
      type: IsarType.bool,
    ),
    r'isStored': PropertySchema(
      id: 8,
      name: r'isStored',
      type: IsarType.bool,
    ),
    r'isTempStored': PropertySchema(
      id: 9,
      name: r'isTempStored',
      type: IsarType.bool,
    ),
    r'isTrusted': PropertySchema(
      id: 10,
      name: r'isTrusted',
      type: IsarType.bool,
    ),
    r'keyExchangeStatus': PropertySchema(
      id: 11,
      name: r'keyExchangeStatus',
      type: IsarType.byte,
      enumMap: _P2PUserkeyExchangeStatusEnumValueMap,
    ),
    r'lastSeen': PropertySchema(
      id: 12,
      name: r'lastSeen',
      type: IsarType.dateTime,
    ),
    r'pairedAt': PropertySchema(
      id: 13,
      name: r'pairedAt',
      type: IsarType.dateTime,
    ),
    r'platform': PropertySchema(
      id: 14,
      name: r'platform',
      type: IsarType.byte,
      enumMap: _P2PUserplatformEnumValueMap,
    ),
    r'port': PropertySchema(
      id: 15,
      name: r'port',
      type: IsarType.long,
    ),
    r'profileId': PropertySchema(
      id: 16,
      name: r'profileId',
      type: IsarType.string,
    ),
    r'publicKeyFingerprint': PropertySchema(
      id: 17,
      name: r'publicKeyFingerprint',
      type: IsarType.string,
    )
  },
  estimateSize: _p2PUserEstimateSize,
  serialize: _p2PUserSerialize,
  deserialize: _p2PUserDeserialize,
  deserializeProp: _p2PUserDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'profileId': IndexSchema(
      id: 6052971939042612300,
      name: r'profileId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'profileId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _p2PUserGetId,
  getLinks: _p2PUserGetLinks,
  attach: _p2PUserAttach,
  version: '3.1.0+1',
);

int _p2PUserEstimateSize(
  P2PUser object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.appInstallationId.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.displayName.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.ipAddress.length * 3;
  bytesCount += 3 + object.profileId.length * 3;
  {
    final value = object.publicKeyFingerprint;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _p2PUserSerialize(
  P2PUser object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.appInstallationId);
  writer.writeString(offsets[1], object.deviceId);
  writer.writeString(offsets[2], object.displayName);
  writer.writeString(offsets[3], object.id);
  writer.writeString(offsets[4], object.ipAddress);
  writer.writeBool(offsets[5], object.isBlocked);
  writer.writeBool(offsets[6], object.isOnline);
  writer.writeBool(offsets[7], object.isPaired);
  writer.writeBool(offsets[8], object.isStored);
  writer.writeBool(offsets[9], object.isTempStored);
  writer.writeBool(offsets[10], object.isTrusted);
  writer.writeByte(offsets[11], object.keyExchangeStatus.index);
  writer.writeDateTime(offsets[12], object.lastSeen);
  writer.writeDateTime(offsets[13], object.pairedAt);
  writer.writeByte(offsets[14], object.platform.index);
  writer.writeLong(offsets[15], object.port);
  writer.writeString(offsets[16], object.profileId);
  writer.writeString(offsets[17], object.publicKeyFingerprint);
}

P2PUser _p2PUserDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = P2PUser(
    displayName: reader.readString(offsets[2]),
    id: reader.readString(offsets[3]),
    ipAddress: reader.readString(offsets[4]),
    isBlocked: reader.readBoolOrNull(offsets[5]) ?? false,
    isOnline: reader.readBoolOrNull(offsets[6]) ?? false,
    isPaired: reader.readBoolOrNull(offsets[7]) ?? false,
    isStored: reader.readBoolOrNull(offsets[8]) ?? false,
    isTempStored: reader.readBoolOrNull(offsets[9]) ?? false,
    isTrusted: reader.readBoolOrNull(offsets[10]) ?? false,
    keyExchangeStatus: _P2PUserkeyExchangeStatusValueEnumMap[
            reader.readByteOrNull(offsets[11])] ??
        KeyExchangeStatus.none,
    lastSeen: reader.readDateTime(offsets[12]),
    pairedAt: reader.readDateTimeOrNull(offsets[13]),
    platform:
        _P2PUserplatformValueEnumMap[reader.readByteOrNull(offsets[14])] ??
            UserPlatform.unknown,
    port: reader.readLong(offsets[15]),
    profileId: reader.readString(offsets[16]),
    publicKeyFingerprint: reader.readStringOrNull(offsets[17]),
  );
  return object;
}

P _p2PUserDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 8:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 10:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 11:
      return (_P2PUserkeyExchangeStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          KeyExchangeStatus.none) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (_P2PUserplatformValueEnumMap[reader.readByteOrNull(offset)] ??
          UserPlatform.unknown) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _P2PUserkeyExchangeStatusEnumValueMap = {
  'none': 0,
  'requested': 1,
  'exchanging': 2,
  'completed': 3,
  'failed': 4,
};
const _P2PUserkeyExchangeStatusValueEnumMap = {
  0: KeyExchangeStatus.none,
  1: KeyExchangeStatus.requested,
  2: KeyExchangeStatus.exchanging,
  3: KeyExchangeStatus.completed,
  4: KeyExchangeStatus.failed,
};
const _P2PUserplatformEnumValueMap = {
  'android': 0,
  'ios': 1,
  'windows': 2,
  'macos': 3,
  'linux': 4,
  'web': 5,
  'unknown': 6,
};
const _P2PUserplatformValueEnumMap = {
  0: UserPlatform.android,
  1: UserPlatform.ios,
  2: UserPlatform.windows,
  3: UserPlatform.macos,
  4: UserPlatform.linux,
  5: UserPlatform.web,
  6: UserPlatform.unknown,
};

Id _p2PUserGetId(P2PUser object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _p2PUserGetLinks(P2PUser object) {
  return [];
}

void _p2PUserAttach(IsarCollection<dynamic> col, Id id, P2PUser object) {}

extension P2PUserByIndex on IsarCollection<P2PUser> {
  Future<P2PUser?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  P2PUser? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<P2PUser?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<P2PUser?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(P2PUser object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(P2PUser object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<P2PUser> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<P2PUser> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension P2PUserQueryWhereSort on QueryBuilder<P2PUser, P2PUser, QWhere> {
  QueryBuilder<P2PUser, P2PUser, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension P2PUserQueryWhere on QueryBuilder<P2PUser, P2PUser, QWhereClause> {
  QueryBuilder<P2PUser, P2PUser, QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterWhereClause> isarIdGreaterThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterWhereClause> isarIdLessThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterWhereClause> idNotEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterWhereClause> profileIdEqualTo(
      String profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterWhereClause> profileIdNotEqualTo(
      String profileId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [],
              upper: [profileId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [profileId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [profileId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [],
              upper: [profileId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension P2PUserQueryFilter
    on QueryBuilder<P2PUser, P2PUser, QFilterCondition> {
  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      appInstallationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appInstallationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      appInstallationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'appInstallationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      appInstallationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'appInstallationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      appInstallationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'appInstallationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      appInstallationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'appInstallationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      appInstallationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'appInstallationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      appInstallationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appInstallationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      appInstallationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appInstallationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      appInstallationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appInstallationId',
        value: '',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      appInstallationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appInstallationId',
        value: '',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> deviceIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> deviceIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> displayNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> displayNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> displayNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> displayNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> displayNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> idContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> ipAddressEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> ipAddressGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> ipAddressLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> ipAddressBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ipAddress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> ipAddressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> ipAddressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> ipAddressContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ipAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> ipAddressMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ipAddress',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> ipAddressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ipAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> ipAddressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ipAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> isBlockedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBlocked',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> isOnlineEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOnline',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> isPairedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPaired',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> isStoredEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isStored',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> isTempStoredEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isTempStored',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> isTrustedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isTrusted',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      keyExchangeStatusEqualTo(KeyExchangeStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyExchangeStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      keyExchangeStatusGreaterThan(
    KeyExchangeStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'keyExchangeStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      keyExchangeStatusLessThan(
    KeyExchangeStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'keyExchangeStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      keyExchangeStatusBetween(
    KeyExchangeStatus lower,
    KeyExchangeStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'keyExchangeStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> lastSeenEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> lastSeenGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> lastSeenLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> lastSeenBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSeen',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> pairedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pairedAt',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> pairedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pairedAt',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> pairedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pairedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> pairedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pairedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> pairedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pairedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> pairedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pairedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> platformEqualTo(
      UserPlatform value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'platform',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> platformGreaterThan(
    UserPlatform value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'platform',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> platformLessThan(
    UserPlatform value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'platform',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> platformBetween(
    UserPlatform lower,
    UserPlatform upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'platform',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> portEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'port',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> portGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'port',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> portLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'port',
        value: value,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> portBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'port',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> profileIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> profileIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'profileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> profileIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'profileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> profileIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'profileId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> profileIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'profileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> profileIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'profileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> profileIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'profileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> profileIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'profileId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> profileIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: '',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition> profileIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'profileId',
        value: '',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      publicKeyFingerprintIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'publicKeyFingerprint',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      publicKeyFingerprintIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'publicKeyFingerprint',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      publicKeyFingerprintEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publicKeyFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      publicKeyFingerprintGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'publicKeyFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      publicKeyFingerprintLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'publicKeyFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      publicKeyFingerprintBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'publicKeyFingerprint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      publicKeyFingerprintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'publicKeyFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      publicKeyFingerprintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'publicKeyFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      publicKeyFingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'publicKeyFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      publicKeyFingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'publicKeyFingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      publicKeyFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publicKeyFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterFilterCondition>
      publicKeyFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'publicKeyFingerprint',
        value: '',
      ));
    });
  }
}

extension P2PUserQueryObject
    on QueryBuilder<P2PUser, P2PUser, QFilterCondition> {}

extension P2PUserQueryLinks
    on QueryBuilder<P2PUser, P2PUser, QFilterCondition> {}

extension P2PUserQuerySortBy on QueryBuilder<P2PUser, P2PUser, QSortBy> {
  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByAppInstallationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appInstallationId', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByAppInstallationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appInstallationId', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIpAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ipAddress', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIpAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ipAddress', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIsBlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBlocked', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIsBlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBlocked', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIsOnline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOnline', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIsOnlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOnline', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIsPaired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaired', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIsPairedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaired', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIsStored() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStored', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIsStoredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStored', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIsTempStored() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTempStored', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIsTempStoredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTempStored', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIsTrusted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrusted', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByIsTrustedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrusted', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByKeyExchangeStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyExchangeStatus', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByKeyExchangeStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyExchangeStatus', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByPairedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAt', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByPairedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAt', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByPlatformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> sortByPublicKeyFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicKeyFingerprint', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy>
      sortByPublicKeyFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicKeyFingerprint', Sort.desc);
    });
  }
}

extension P2PUserQuerySortThenBy
    on QueryBuilder<P2PUser, P2PUser, QSortThenBy> {
  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByAppInstallationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appInstallationId', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByAppInstallationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appInstallationId', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIpAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ipAddress', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIpAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ipAddress', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsBlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBlocked', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsBlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBlocked', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsOnline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOnline', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsOnlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOnline', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsPaired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaired', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsPairedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaired', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsStored() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStored', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsStoredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStored', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsTempStored() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTempStored', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsTempStoredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTempStored', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsTrusted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrusted', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsTrustedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrusted', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByKeyExchangeStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyExchangeStatus', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByKeyExchangeStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyExchangeStatus', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByPairedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAt', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByPairedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAt', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByPlatformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy> thenByPublicKeyFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicKeyFingerprint', Sort.asc);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QAfterSortBy>
      thenByPublicKeyFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicKeyFingerprint', Sort.desc);
    });
  }
}

extension P2PUserQueryWhereDistinct
    on QueryBuilder<P2PUser, P2PUser, QDistinct> {
  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByAppInstallationId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appInstallationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByIpAddress(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ipAddress', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByIsBlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBlocked');
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByIsOnline() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOnline');
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByIsPaired() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPaired');
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByIsStored() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isStored');
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByIsTempStored() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isTempStored');
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByIsTrusted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isTrusted');
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByKeyExchangeStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keyExchangeStatus');
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeen');
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByPairedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pairedAt');
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'platform');
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'port');
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByProfileId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<P2PUser, P2PUser, QDistinct> distinctByPublicKeyFingerprint(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publicKeyFingerprint',
          caseSensitive: caseSensitive);
    });
  }
}

extension P2PUserQueryProperty
    on QueryBuilder<P2PUser, P2PUser, QQueryProperty> {
  QueryBuilder<P2PUser, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<P2PUser, String, QQueryOperations> appInstallationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appInstallationId');
    });
  }

  QueryBuilder<P2PUser, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<P2PUser, String, QQueryOperations> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<P2PUser, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<P2PUser, String, QQueryOperations> ipAddressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ipAddress');
    });
  }

  QueryBuilder<P2PUser, bool, QQueryOperations> isBlockedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBlocked');
    });
  }

  QueryBuilder<P2PUser, bool, QQueryOperations> isOnlineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOnline');
    });
  }

  QueryBuilder<P2PUser, bool, QQueryOperations> isPairedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPaired');
    });
  }

  QueryBuilder<P2PUser, bool, QQueryOperations> isStoredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isStored');
    });
  }

  QueryBuilder<P2PUser, bool, QQueryOperations> isTempStoredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isTempStored');
    });
  }

  QueryBuilder<P2PUser, bool, QQueryOperations> isTrustedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isTrusted');
    });
  }

  QueryBuilder<P2PUser, KeyExchangeStatus, QQueryOperations>
      keyExchangeStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keyExchangeStatus');
    });
  }

  QueryBuilder<P2PUser, DateTime, QQueryOperations> lastSeenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeen');
    });
  }

  QueryBuilder<P2PUser, DateTime?, QQueryOperations> pairedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pairedAt');
    });
  }

  QueryBuilder<P2PUser, UserPlatform, QQueryOperations> platformProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'platform');
    });
  }

  QueryBuilder<P2PUser, int, QQueryOperations> portProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'port');
    });
  }

  QueryBuilder<P2PUser, String, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<P2PUser, String?, QQueryOperations>
      publicKeyFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publicKeyFingerprint');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPairingRequestCollection on Isar {
  IsarCollection<PairingRequest> get pairingRequests => this.collection();
}

const PairingRequestSchema = CollectionSchema(
  name: r'PairingRequest',
  id: 1782595776270177333,
  properties: {
    r'fromIpAddress': PropertySchema(
      id: 0,
      name: r'fromIpAddress',
      type: IsarType.string,
    ),
    r'fromPort': PropertySchema(
      id: 1,
      name: r'fromPort',
      type: IsarType.long,
    ),
    r'fromProfileId': PropertySchema(
      id: 2,
      name: r'fromProfileId',
      type: IsarType.string,
    ),
    r'fromUserId': PropertySchema(
      id: 3,
      name: r'fromUserId',
      type: IsarType.string,
    ),
    r'fromUserName': PropertySchema(
      id: 4,
      name: r'fromUserName',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 5,
      name: r'id',
      type: IsarType.string,
    ),
    r'isProcessed': PropertySchema(
      id: 6,
      name: r'isProcessed',
      type: IsarType.bool,
    ),
    r'requestTime': PropertySchema(
      id: 7,
      name: r'requestTime',
      type: IsarType.dateTime,
    ),
    r'wantsSaveConnection': PropertySchema(
      id: 8,
      name: r'wantsSaveConnection',
      type: IsarType.bool,
    )
  },
  estimateSize: _pairingRequestEstimateSize,
  serialize: _pairingRequestSerialize,
  deserialize: _pairingRequestDeserialize,
  deserializeProp: _pairingRequestDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pairingRequestGetId,
  getLinks: _pairingRequestGetLinks,
  attach: _pairingRequestAttach,
  version: '3.1.0+1',
);

int _pairingRequestEstimateSize(
  PairingRequest object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fromIpAddress.length * 3;
  bytesCount += 3 + object.fromProfileId.length * 3;
  bytesCount += 3 + object.fromUserId.length * 3;
  bytesCount += 3 + object.fromUserName.length * 3;
  bytesCount += 3 + object.id.length * 3;
  return bytesCount;
}

void _pairingRequestSerialize(
  PairingRequest object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.fromIpAddress);
  writer.writeLong(offsets[1], object.fromPort);
  writer.writeString(offsets[2], object.fromProfileId);
  writer.writeString(offsets[3], object.fromUserId);
  writer.writeString(offsets[4], object.fromUserName);
  writer.writeString(offsets[5], object.id);
  writer.writeBool(offsets[6], object.isProcessed);
  writer.writeDateTime(offsets[7], object.requestTime);
  writer.writeBool(offsets[8], object.wantsSaveConnection);
}

PairingRequest _pairingRequestDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PairingRequest(
    fromIpAddress: reader.readString(offsets[0]),
    fromPort: reader.readLong(offsets[1]),
    fromProfileId: reader.readString(offsets[2]),
    fromUserId: reader.readString(offsets[3]),
    fromUserName: reader.readString(offsets[4]),
    id: reader.readString(offsets[5]),
    isProcessed: reader.readBoolOrNull(offsets[6]) ?? false,
    requestTime: reader.readDateTime(offsets[7]),
    wantsSaveConnection: reader.readBoolOrNull(offsets[8]) ?? false,
  );
  return object;
}

P _pairingRequestDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pairingRequestGetId(PairingRequest object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _pairingRequestGetLinks(PairingRequest object) {
  return [];
}

void _pairingRequestAttach(
    IsarCollection<dynamic> col, Id id, PairingRequest object) {}

extension PairingRequestByIndex on IsarCollection<PairingRequest> {
  Future<PairingRequest?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  PairingRequest? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<PairingRequest?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<PairingRequest?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(PairingRequest object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(PairingRequest object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<PairingRequest> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<PairingRequest> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension PairingRequestQueryWhereSort
    on QueryBuilder<PairingRequest, PairingRequest, QWhere> {
  QueryBuilder<PairingRequest, PairingRequest, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PairingRequestQueryWhere
    on QueryBuilder<PairingRequest, PairingRequest, QWhereClause> {
  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterWhereClause> idNotEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PairingRequestQueryFilter
    on QueryBuilder<PairingRequest, PairingRequest, QFilterCondition> {
  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromIpAddressEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromIpAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromIpAddressGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromIpAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromIpAddressLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromIpAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromIpAddressBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromIpAddress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromIpAddressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fromIpAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromIpAddressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fromIpAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromIpAddressContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fromIpAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromIpAddressMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fromIpAddress',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromIpAddressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromIpAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromIpAddressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fromIpAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromPortEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromPort',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromPortGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromPort',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromPortLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromPort',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromPortBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromPort',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromProfileIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromProfileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromProfileIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromProfileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromProfileIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromProfileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromProfileIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromProfileId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromProfileIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fromProfileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromProfileIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fromProfileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromProfileIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fromProfileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromProfileIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fromProfileId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromProfileIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromProfileId',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromProfileIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fromProfileId',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fromUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fromUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fromUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fromUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fromUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromUserName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fromUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fromUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fromUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fromUserName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromUserName',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      fromUserNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fromUserName',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      isProcessedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isProcessed',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      requestTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterFilterCondition>
      wantsSaveConnectionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wantsSaveConnection',
        value: value,
      ));
    });
  }
}

extension PairingRequestQueryObject
    on QueryBuilder<PairingRequest, PairingRequest, QFilterCondition> {}

extension PairingRequestQueryLinks
    on QueryBuilder<PairingRequest, PairingRequest, QFilterCondition> {}

extension PairingRequestQuerySortBy
    on QueryBuilder<PairingRequest, PairingRequest, QSortBy> {
  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByFromIpAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromIpAddress', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByFromIpAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromIpAddress', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy> sortByFromPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromPort', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByFromPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromPort', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByFromProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromProfileId', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByFromProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromProfileId', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByFromUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserId', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByFromUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserId', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByFromUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserName', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByFromUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserName', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByIsProcessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByIsProcessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByRequestTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestTime', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByRequestTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestTime', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByWantsSaveConnection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wantsSaveConnection', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      sortByWantsSaveConnectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wantsSaveConnection', Sort.desc);
    });
  }
}

extension PairingRequestQuerySortThenBy
    on QueryBuilder<PairingRequest, PairingRequest, QSortThenBy> {
  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByFromIpAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromIpAddress', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByFromIpAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromIpAddress', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy> thenByFromPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromPort', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByFromPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromPort', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByFromProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromProfileId', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByFromProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromProfileId', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByFromUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserId', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByFromUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserId', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByFromUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserName', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByFromUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserName', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByIsProcessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByIsProcessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByRequestTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestTime', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByRequestTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestTime', Sort.desc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByWantsSaveConnection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wantsSaveConnection', Sort.asc);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QAfterSortBy>
      thenByWantsSaveConnectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wantsSaveConnection', Sort.desc);
    });
  }
}

extension PairingRequestQueryWhereDistinct
    on QueryBuilder<PairingRequest, PairingRequest, QDistinct> {
  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByFromIpAddress({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromIpAddress',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct> distinctByFromPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromPort');
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByFromProfileId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromProfileId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct> distinctByFromUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromUserId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByFromUserName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromUserName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByIsProcessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isProcessed');
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByRequestTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestTime');
    });
  }

  QueryBuilder<PairingRequest, PairingRequest, QDistinct>
      distinctByWantsSaveConnection() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wantsSaveConnection');
    });
  }
}

extension PairingRequestQueryProperty
    on QueryBuilder<PairingRequest, PairingRequest, QQueryProperty> {
  QueryBuilder<PairingRequest, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<PairingRequest, String, QQueryOperations>
      fromIpAddressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromIpAddress');
    });
  }

  QueryBuilder<PairingRequest, int, QQueryOperations> fromPortProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromPort');
    });
  }

  QueryBuilder<PairingRequest, String, QQueryOperations>
      fromProfileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromProfileId');
    });
  }

  QueryBuilder<PairingRequest, String, QQueryOperations> fromUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromUserId');
    });
  }

  QueryBuilder<PairingRequest, String, QQueryOperations>
      fromUserNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromUserName');
    });
  }

  QueryBuilder<PairingRequest, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PairingRequest, bool, QQueryOperations> isProcessedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isProcessed');
    });
  }

  QueryBuilder<PairingRequest, DateTime, QQueryOperations>
      requestTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestTime');
    });
  }

  QueryBuilder<PairingRequest, bool, QQueryOperations>
      wantsSaveConnectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wantsSaveConnection');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDataTransferTaskCollection on Isar {
  IsarCollection<DataTransferTask> get dataTransferTasks => this.collection();
}

const DataTransferTaskSchema = CollectionSchema(
  name: r'DataTransferTask',
  id: 3546441473027873409,
  properties: {
    r'batchId': PropertySchema(
      id: 0,
      name: r'batchId',
      type: IsarType.string,
    ),
    r'completedAt': PropertySchema(
      id: 1,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'errorMessage': PropertySchema(
      id: 3,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'fileName': PropertySchema(
      id: 4,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'filePath': PropertySchema(
      id: 5,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'fileSize': PropertySchema(
      id: 6,
      name: r'fileSize',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 7,
      name: r'id',
      type: IsarType.string,
    ),
    r'isOutgoing': PropertySchema(
      id: 8,
      name: r'isOutgoing',
      type: IsarType.bool,
    ),
    r'savePath': PropertySchema(
      id: 9,
      name: r'savePath',
      type: IsarType.string,
    ),
    r'startedAt': PropertySchema(
      id: 10,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 11,
      name: r'status',
      type: IsarType.byte,
      enumMap: _DataTransferTaskstatusEnumValueMap,
    ),
    r'targetUserId': PropertySchema(
      id: 12,
      name: r'targetUserId',
      type: IsarType.string,
    ),
    r'targetUserName': PropertySchema(
      id: 13,
      name: r'targetUserName',
      type: IsarType.string,
    ),
    r'transferredBytes': PropertySchema(
      id: 14,
      name: r'transferredBytes',
      type: IsarType.long,
    )
  },
  estimateSize: _dataTransferTaskEstimateSize,
  serialize: _dataTransferTaskSerialize,
  deserialize: _dataTransferTaskDeserialize,
  deserializeProp: _dataTransferTaskDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'targetUserId': IndexSchema(
      id: 5291302338887778262,
      name: r'targetUserId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'targetUserId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'batchId': IndexSchema(
      id: -5468368523860846432,
      name: r'batchId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'batchId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dataTransferTaskGetId,
  getLinks: _dataTransferTaskGetLinks,
  attach: _dataTransferTaskAttach,
  version: '3.1.0+1',
);

int _dataTransferTaskEstimateSize(
  DataTransferTask object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.batchId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.errorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.fileName.length * 3;
  bytesCount += 3 + object.filePath.length * 3;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.savePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.targetUserId.length * 3;
  bytesCount += 3 + object.targetUserName.length * 3;
  return bytesCount;
}

void _dataTransferTaskSerialize(
  DataTransferTask object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.batchId);
  writer.writeDateTime(offsets[1], object.completedAt);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.errorMessage);
  writer.writeString(offsets[4], object.fileName);
  writer.writeString(offsets[5], object.filePath);
  writer.writeLong(offsets[6], object.fileSize);
  writer.writeString(offsets[7], object.id);
  writer.writeBool(offsets[8], object.isOutgoing);
  writer.writeString(offsets[9], object.savePath);
  writer.writeDateTime(offsets[10], object.startedAt);
  writer.writeByte(offsets[11], object.status.index);
  writer.writeString(offsets[12], object.targetUserId);
  writer.writeString(offsets[13], object.targetUserName);
  writer.writeLong(offsets[14], object.transferredBytes);
}

DataTransferTask _dataTransferTaskDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DataTransferTask(
    batchId: reader.readStringOrNull(offsets[0]),
    completedAt: reader.readDateTimeOrNull(offsets[1]),
    createdAt: reader.readDateTime(offsets[2]),
    errorMessage: reader.readStringOrNull(offsets[3]),
    fileName: reader.readString(offsets[4]),
    filePath: reader.readString(offsets[5]),
    fileSize: reader.readLong(offsets[6]),
    id: reader.readString(offsets[7]),
    isOutgoing: reader.readBool(offsets[8]),
    savePath: reader.readStringOrNull(offsets[9]),
    startedAt: reader.readDateTimeOrNull(offsets[10]),
    status: _DataTransferTaskstatusValueEnumMap[
            reader.readByteOrNull(offsets[11])] ??
        DataTransferStatus.pending,
    targetUserId: reader.readString(offsets[12]),
    targetUserName: reader.readString(offsets[13]),
    transferredBytes: reader.readLongOrNull(offsets[14]) ?? 0,
  );
  return object;
}

P _dataTransferTaskDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (_DataTransferTaskstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          DataTransferStatus.pending) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DataTransferTaskstatusEnumValueMap = {
  'pending': 0,
  'requesting': 1,
  'waitingForApproval': 2,
  'transferring': 3,
  'completed': 4,
  'failed': 5,
  'cancelled': 6,
  'rejected': 7,
};
const _DataTransferTaskstatusValueEnumMap = {
  0: DataTransferStatus.pending,
  1: DataTransferStatus.requesting,
  2: DataTransferStatus.waitingForApproval,
  3: DataTransferStatus.transferring,
  4: DataTransferStatus.completed,
  5: DataTransferStatus.failed,
  6: DataTransferStatus.cancelled,
  7: DataTransferStatus.rejected,
};

Id _dataTransferTaskGetId(DataTransferTask object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _dataTransferTaskGetLinks(DataTransferTask object) {
  return [];
}

void _dataTransferTaskAttach(
    IsarCollection<dynamic> col, Id id, DataTransferTask object) {}

extension DataTransferTaskByIndex on IsarCollection<DataTransferTask> {
  Future<DataTransferTask?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  DataTransferTask? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<DataTransferTask?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<DataTransferTask?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(DataTransferTask object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(DataTransferTask object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<DataTransferTask> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<DataTransferTask> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension DataTransferTaskQueryWhereSort
    on QueryBuilder<DataTransferTask, DataTransferTask, QWhere> {
  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DataTransferTaskQueryWhere
    on QueryBuilder<DataTransferTask, DataTransferTask, QWhereClause> {
  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhereClause>
      idNotEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhereClause>
      targetUserIdEqualTo(String targetUserId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'targetUserId',
        value: [targetUserId],
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhereClause>
      targetUserIdNotEqualTo(String targetUserId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetUserId',
              lower: [],
              upper: [targetUserId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetUserId',
              lower: [targetUserId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetUserId',
              lower: [targetUserId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetUserId',
              lower: [],
              upper: [targetUserId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhereClause>
      batchIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'batchId',
        value: [null],
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhereClause>
      batchIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'batchId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhereClause>
      batchIdEqualTo(String? batchId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'batchId',
        value: [batchId],
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterWhereClause>
      batchIdNotEqualTo(String? batchId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchId',
              lower: [],
              upper: [batchId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchId',
              lower: [batchId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchId',
              lower: [batchId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchId',
              lower: [],
              upper: [batchId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DataTransferTaskQueryFilter
    on QueryBuilder<DataTransferTask, DataTransferTask, QFilterCondition> {
  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      batchIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'batchId',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      batchIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'batchId',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      batchIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      batchIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      batchIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      batchIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batchId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      batchIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      batchIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      batchIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      batchIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'batchId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      batchIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchId',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      batchIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'batchId',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      errorMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      errorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      errorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      errorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      errorMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      errorMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      errorMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      errorMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      filePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      filePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      filePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      filePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      filePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      filePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      filePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      filePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileSizeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileSize',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileSizeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileSize',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileSizeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileSize',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      fileSizeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      isOutgoingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOutgoing',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      savePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'savePath',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      savePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'savePath',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      savePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'savePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      savePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'savePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      savePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'savePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      savePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'savePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      savePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'savePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      savePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'savePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      savePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'savePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      savePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'savePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      savePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'savePath',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      savePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'savePath',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      startedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startedAt',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      startedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startedAt',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      startedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      startedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      startedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      startedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      statusEqualTo(DataTransferStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      statusGreaterThan(
    DataTransferStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      statusLessThan(
    DataTransferStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      statusBetween(
    DataTransferStatus lower,
    DataTransferStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetUserName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetUserName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetUserName',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      targetUserNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetUserName',
        value: '',
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      transferredBytesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transferredBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      transferredBytesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'transferredBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      transferredBytesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'transferredBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterFilterCondition>
      transferredBytesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'transferredBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DataTransferTaskQueryObject
    on QueryBuilder<DataTransferTask, DataTransferTask, QFilterCondition> {}

extension DataTransferTaskQueryLinks
    on QueryBuilder<DataTransferTask, DataTransferTask, QFilterCondition> {}

extension DataTransferTaskQuerySortBy
    on QueryBuilder<DataTransferTask, DataTransferTask, QSortBy> {
  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByBatchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByBatchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByFileSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByIsOutgoing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutgoing', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByIsOutgoingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutgoing', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortBySavePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savePath', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortBySavePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savePath', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByTargetUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetUserId', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByTargetUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetUserId', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByTargetUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetUserName', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByTargetUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetUserName', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByTransferredBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferredBytes', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      sortByTransferredBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferredBytes', Sort.desc);
    });
  }
}

extension DataTransferTaskQuerySortThenBy
    on QueryBuilder<DataTransferTask, DataTransferTask, QSortThenBy> {
  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByBatchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByBatchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByFileSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByIsOutgoing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutgoing', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByIsOutgoingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutgoing', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenBySavePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savePath', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenBySavePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savePath', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByTargetUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetUserId', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByTargetUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetUserId', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByTargetUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetUserName', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByTargetUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetUserName', Sort.desc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByTransferredBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferredBytes', Sort.asc);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QAfterSortBy>
      thenByTransferredBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferredBytes', Sort.desc);
    });
  }
}

extension DataTransferTaskQueryWhereDistinct
    on QueryBuilder<DataTransferTask, DataTransferTask, QDistinct> {
  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct> distinctByBatchId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batchId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct>
      distinctByErrorMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct>
      distinctByFileName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct>
      distinctByFilePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct>
      distinctByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileSize');
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct>
      distinctByIsOutgoing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOutgoing');
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct>
      distinctBySavePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct>
      distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct>
      distinctByTargetUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetUserId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct>
      distinctByTargetUserName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetUserName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DataTransferTask, DataTransferTask, QDistinct>
      distinctByTransferredBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transferredBytes');
    });
  }
}

extension DataTransferTaskQueryProperty
    on QueryBuilder<DataTransferTask, DataTransferTask, QQueryProperty> {
  QueryBuilder<DataTransferTask, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<DataTransferTask, String?, QQueryOperations> batchIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batchId');
    });
  }

  QueryBuilder<DataTransferTask, DateTime?, QQueryOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<DataTransferTask, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DataTransferTask, String?, QQueryOperations>
      errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<DataTransferTask, String, QQueryOperations> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<DataTransferTask, String, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<DataTransferTask, int, QQueryOperations> fileSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileSize');
    });
  }

  QueryBuilder<DataTransferTask, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DataTransferTask, bool, QQueryOperations> isOutgoingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOutgoing');
    });
  }

  QueryBuilder<DataTransferTask, String?, QQueryOperations> savePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savePath');
    });
  }

  QueryBuilder<DataTransferTask, DateTime?, QQueryOperations>
      startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<DataTransferTask, DataTransferStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<DataTransferTask, String, QQueryOperations>
      targetUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetUserId');
    });
  }

  QueryBuilder<DataTransferTask, String, QQueryOperations>
      targetUserNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetUserName');
    });
  }

  QueryBuilder<DataTransferTask, int, QQueryOperations>
      transferredBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transferredBytes');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFileTransferRequestCollection on Isar {
  IsarCollection<FileTransferRequest> get fileTransferRequests =>
      this.collection();
}

const FileTransferRequestSchema = CollectionSchema(
  name: r'FileTransferRequest',
  id: 6889281268088159415,
  properties: {
    r'batchId': PropertySchema(
      id: 0,
      name: r'batchId',
      type: IsarType.string,
    ),
    r'files': PropertySchema(
      id: 1,
      name: r'files',
      type: IsarType.objectList,
      target: r'FileTransferInfo',
    ),
    r'fromUserId': PropertySchema(
      id: 2,
      name: r'fromUserId',
      type: IsarType.string,
    ),
    r'fromUserName': PropertySchema(
      id: 3,
      name: r'fromUserName',
      type: IsarType.string,
    ),
    r'isProcessed': PropertySchema(
      id: 4,
      name: r'isProcessed',
      type: IsarType.bool,
    ),
    r'maxChunkSize': PropertySchema(
      id: 5,
      name: r'maxChunkSize',
      type: IsarType.long,
    ),
    r'protocol': PropertySchema(
      id: 6,
      name: r'protocol',
      type: IsarType.string,
    ),
    r'receivedTime': PropertySchema(
      id: 7,
      name: r'receivedTime',
      type: IsarType.dateTime,
    ),
    r'requestId': PropertySchema(
      id: 8,
      name: r'requestId',
      type: IsarType.string,
    ),
    r'requestTime': PropertySchema(
      id: 9,
      name: r'requestTime',
      type: IsarType.dateTime,
    ),
    r'totalSize': PropertySchema(
      id: 10,
      name: r'totalSize',
      type: IsarType.long,
    ),
    r'useEncryption': PropertySchema(
      id: 11,
      name: r'useEncryption',
      type: IsarType.bool,
    )
  },
  estimateSize: _fileTransferRequestEstimateSize,
  serialize: _fileTransferRequestSerialize,
  deserialize: _fileTransferRequestDeserialize,
  deserializeProp: _fileTransferRequestDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'requestId': IndexSchema(
      id: 938047444593699237,
      name: r'requestId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'requestId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'batchId': IndexSchema(
      id: -5468368523860846432,
      name: r'batchId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'batchId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'FileTransferInfo': FileTransferInfoSchema},
  getId: _fileTransferRequestGetId,
  getLinks: _fileTransferRequestGetLinks,
  attach: _fileTransferRequestAttach,
  version: '3.1.0+1',
);

int _fileTransferRequestEstimateSize(
  FileTransferRequest object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.batchId.length * 3;
  bytesCount += 3 + object.files.length * 3;
  {
    final offsets = allOffsets[FileTransferInfo]!;
    for (var i = 0; i < object.files.length; i++) {
      final value = object.files[i];
      bytesCount +=
          FileTransferInfoSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.fromUserId.length * 3;
  bytesCount += 3 + object.fromUserName.length * 3;
  bytesCount += 3 + object.protocol.length * 3;
  bytesCount += 3 + object.requestId.length * 3;
  return bytesCount;
}

void _fileTransferRequestSerialize(
  FileTransferRequest object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.batchId);
  writer.writeObjectList<FileTransferInfo>(
    offsets[1],
    allOffsets,
    FileTransferInfoSchema.serialize,
    object.files,
  );
  writer.writeString(offsets[2], object.fromUserId);
  writer.writeString(offsets[3], object.fromUserName);
  writer.writeBool(offsets[4], object.isProcessed);
  writer.writeLong(offsets[5], object.maxChunkSize);
  writer.writeString(offsets[6], object.protocol);
  writer.writeDateTime(offsets[7], object.receivedTime);
  writer.writeString(offsets[8], object.requestId);
  writer.writeDateTime(offsets[9], object.requestTime);
  writer.writeLong(offsets[10], object.totalSize);
  writer.writeBool(offsets[11], object.useEncryption);
}

FileTransferRequest _fileTransferRequestDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FileTransferRequest(
    batchId: reader.readString(offsets[0]),
    files: reader.readObjectList<FileTransferInfo>(
          offsets[1],
          FileTransferInfoSchema.deserialize,
          allOffsets,
          FileTransferInfo(),
        ) ??
        [],
    fromUserId: reader.readString(offsets[2]),
    fromUserName: reader.readString(offsets[3]),
    isProcessed: reader.readBoolOrNull(offsets[4]) ?? false,
    maxChunkSize: reader.readLongOrNull(offsets[5]),
    protocol: reader.readStringOrNull(offsets[6]) ?? 'tcp',
    receivedTime: reader.readDateTimeOrNull(offsets[7]),
    requestId: reader.readString(offsets[8]),
    requestTime: reader.readDateTime(offsets[9]),
    totalSize: reader.readLong(offsets[10]),
    useEncryption: reader.readBoolOrNull(offsets[11]) ?? false,
  );
  return object;
}

P _fileTransferRequestDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readObjectList<FileTransferInfo>(
            offset,
            FileTransferInfoSchema.deserialize,
            allOffsets,
            FileTransferInfo(),
          ) ??
          []) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset) ?? 'tcp') as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _fileTransferRequestGetId(FileTransferRequest object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _fileTransferRequestGetLinks(
    FileTransferRequest object) {
  return [];
}

void _fileTransferRequestAttach(
    IsarCollection<dynamic> col, Id id, FileTransferRequest object) {}

extension FileTransferRequestByIndex on IsarCollection<FileTransferRequest> {
  Future<FileTransferRequest?> getByRequestId(String requestId) {
    return getByIndex(r'requestId', [requestId]);
  }

  FileTransferRequest? getByRequestIdSync(String requestId) {
    return getByIndexSync(r'requestId', [requestId]);
  }

  Future<bool> deleteByRequestId(String requestId) {
    return deleteByIndex(r'requestId', [requestId]);
  }

  bool deleteByRequestIdSync(String requestId) {
    return deleteByIndexSync(r'requestId', [requestId]);
  }

  Future<List<FileTransferRequest?>> getAllByRequestId(
      List<String> requestIdValues) {
    final values = requestIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'requestId', values);
  }

  List<FileTransferRequest?> getAllByRequestIdSync(
      List<String> requestIdValues) {
    final values = requestIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'requestId', values);
  }

  Future<int> deleteAllByRequestId(List<String> requestIdValues) {
    final values = requestIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'requestId', values);
  }

  int deleteAllByRequestIdSync(List<String> requestIdValues) {
    final values = requestIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'requestId', values);
  }

  Future<Id> putByRequestId(FileTransferRequest object) {
    return putByIndex(r'requestId', object);
  }

  Id putByRequestIdSync(FileTransferRequest object, {bool saveLinks = true}) {
    return putByIndexSync(r'requestId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRequestId(List<FileTransferRequest> objects) {
    return putAllByIndex(r'requestId', objects);
  }

  List<Id> putAllByRequestIdSync(List<FileTransferRequest> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'requestId', objects, saveLinks: saveLinks);
  }
}

extension FileTransferRequestQueryWhereSort
    on QueryBuilder<FileTransferRequest, FileTransferRequest, QWhere> {
  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FileTransferRequestQueryWhere
    on QueryBuilder<FileTransferRequest, FileTransferRequest, QWhereClause> {
  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterWhereClause>
      requestIdEqualTo(String requestId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'requestId',
        value: [requestId],
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterWhereClause>
      requestIdNotEqualTo(String requestId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'requestId',
              lower: [],
              upper: [requestId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'requestId',
              lower: [requestId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'requestId',
              lower: [requestId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'requestId',
              lower: [],
              upper: [requestId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterWhereClause>
      batchIdEqualTo(String batchId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'batchId',
        value: [batchId],
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterWhereClause>
      batchIdNotEqualTo(String batchId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchId',
              lower: [],
              upper: [batchId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchId',
              lower: [batchId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchId',
              lower: [batchId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchId',
              lower: [],
              upper: [batchId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension FileTransferRequestQueryFilter on QueryBuilder<FileTransferRequest,
    FileTransferRequest, QFilterCondition> {
  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      batchIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      batchIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      batchIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      batchIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batchId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      batchIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      batchIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      batchIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      batchIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'batchId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      batchIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchId',
        value: '',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      batchIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'batchId',
        value: '',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      filesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'files',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      filesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'files',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      filesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'files',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      filesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'files',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      filesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'files',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      filesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'files',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fromUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fromUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fromUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fromUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fromUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromUserName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fromUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fromUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fromUserName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fromUserName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromUserName',
        value: '',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      fromUserNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fromUserName',
        value: '',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      isProcessedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isProcessed',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      maxChunkSizeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maxChunkSize',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      maxChunkSizeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maxChunkSize',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      maxChunkSizeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxChunkSize',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      maxChunkSizeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxChunkSize',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      maxChunkSizeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxChunkSize',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      maxChunkSizeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxChunkSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      protocolEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'protocol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      protocolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'protocol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      protocolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'protocol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      protocolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'protocol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      protocolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'protocol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      protocolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'protocol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      protocolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'protocol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      protocolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'protocol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      protocolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'protocol',
        value: '',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      protocolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'protocol',
        value: '',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      receivedTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'receivedTime',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      receivedTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'receivedTime',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      receivedTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receivedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      receivedTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receivedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      receivedTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receivedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      receivedTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receivedTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requestId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestId',
        value: '',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requestId',
        value: '',
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      requestTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      totalSizeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSize',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      totalSizeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSize',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      totalSizeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSize',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      totalSizeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      useEncryptionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'useEncryption',
        value: value,
      ));
    });
  }
}

extension FileTransferRequestQueryObject on QueryBuilder<FileTransferRequest,
    FileTransferRequest, QFilterCondition> {
  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterFilterCondition>
      filesElement(FilterQuery<FileTransferInfo> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'files');
    });
  }
}

extension FileTransferRequestQueryLinks on QueryBuilder<FileTransferRequest,
    FileTransferRequest, QFilterCondition> {}

extension FileTransferRequestQuerySortBy
    on QueryBuilder<FileTransferRequest, FileTransferRequest, QSortBy> {
  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByBatchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByBatchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByFromUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserId', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByFromUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserId', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByFromUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserName', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByFromUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserName', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByIsProcessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByIsProcessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByMaxChunkSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxChunkSize', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByMaxChunkSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxChunkSize', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByProtocol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protocol', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByProtocolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protocol', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByReceivedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedTime', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByReceivedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedTime', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByRequestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByRequestIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByRequestTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestTime', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByRequestTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestTime', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByTotalSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSize', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByTotalSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSize', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByUseEncryption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useEncryption', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      sortByUseEncryptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useEncryption', Sort.desc);
    });
  }
}

extension FileTransferRequestQuerySortThenBy
    on QueryBuilder<FileTransferRequest, FileTransferRequest, QSortThenBy> {
  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByBatchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByBatchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByFromUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserId', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByFromUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserId', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByFromUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserName', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByFromUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromUserName', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByIsProcessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByIsProcessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByMaxChunkSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxChunkSize', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByMaxChunkSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxChunkSize', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByProtocol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protocol', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByProtocolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protocol', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByReceivedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedTime', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByReceivedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedTime', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByRequestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByRequestIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByRequestTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestTime', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByRequestTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestTime', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByTotalSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSize', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByTotalSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSize', Sort.desc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByUseEncryption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useEncryption', Sort.asc);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QAfterSortBy>
      thenByUseEncryptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useEncryption', Sort.desc);
    });
  }
}

extension FileTransferRequestQueryWhereDistinct
    on QueryBuilder<FileTransferRequest, FileTransferRequest, QDistinct> {
  QueryBuilder<FileTransferRequest, FileTransferRequest, QDistinct>
      distinctByBatchId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batchId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QDistinct>
      distinctByFromUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromUserId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QDistinct>
      distinctByFromUserName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromUserName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QDistinct>
      distinctByIsProcessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isProcessed');
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QDistinct>
      distinctByMaxChunkSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxChunkSize');
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QDistinct>
      distinctByProtocol({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'protocol', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QDistinct>
      distinctByReceivedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receivedTime');
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QDistinct>
      distinctByRequestId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QDistinct>
      distinctByRequestTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestTime');
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QDistinct>
      distinctByTotalSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSize');
    });
  }

  QueryBuilder<FileTransferRequest, FileTransferRequest, QDistinct>
      distinctByUseEncryption() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'useEncryption');
    });
  }
}

extension FileTransferRequestQueryProperty
    on QueryBuilder<FileTransferRequest, FileTransferRequest, QQueryProperty> {
  QueryBuilder<FileTransferRequest, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<FileTransferRequest, String, QQueryOperations>
      batchIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batchId');
    });
  }

  QueryBuilder<FileTransferRequest, List<FileTransferInfo>, QQueryOperations>
      filesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'files');
    });
  }

  QueryBuilder<FileTransferRequest, String, QQueryOperations>
      fromUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromUserId');
    });
  }

  QueryBuilder<FileTransferRequest, String, QQueryOperations>
      fromUserNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromUserName');
    });
  }

  QueryBuilder<FileTransferRequest, bool, QQueryOperations>
      isProcessedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isProcessed');
    });
  }

  QueryBuilder<FileTransferRequest, int?, QQueryOperations>
      maxChunkSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxChunkSize');
    });
  }

  QueryBuilder<FileTransferRequest, String, QQueryOperations>
      protocolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'protocol');
    });
  }

  QueryBuilder<FileTransferRequest, DateTime?, QQueryOperations>
      receivedTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receivedTime');
    });
  }

  QueryBuilder<FileTransferRequest, String, QQueryOperations>
      requestIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestId');
    });
  }

  QueryBuilder<FileTransferRequest, DateTime, QQueryOperations>
      requestTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestTime');
    });
  }

  QueryBuilder<FileTransferRequest, int, QQueryOperations> totalSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSize');
    });
  }

  QueryBuilder<FileTransferRequest, bool, QQueryOperations>
      useEncryptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'useEncryption');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const FileTransferInfoSchema = Schema(
  name: r'FileTransferInfo',
  id: 4387906420831995680,
  properties: {
    r'fileName': PropertySchema(
      id: 0,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'fileSize': PropertySchema(
      id: 1,
      name: r'fileSize',
      type: IsarType.long,
    ),
    r'messageId': PropertySchema(
      id: 2,
      name: r'messageId',
      type: IsarType.long,
    )
  },
  estimateSize: _fileTransferInfoEstimateSize,
  serialize: _fileTransferInfoSerialize,
  deserialize: _fileTransferInfoDeserialize,
  deserializeProp: _fileTransferInfoDeserializeProp,
);

int _fileTransferInfoEstimateSize(
  FileTransferInfo object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fileName.length * 3;
  return bytesCount;
}

void _fileTransferInfoSerialize(
  FileTransferInfo object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.fileName);
  writer.writeLong(offsets[1], object.fileSize);
  writer.writeLong(offsets[2], object.messageId);
}

FileTransferInfo _fileTransferInfoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FileTransferInfo(
    fileName: reader.readStringOrNull(offsets[0]) ?? '',
    fileSize: reader.readLongOrNull(offsets[1]) ?? 0,
    messageId: reader.readLongOrNull(offsets[2]),
  );
  return object;
}

P _fileTransferInfoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension FileTransferInfoQueryFilter
    on QueryBuilder<FileTransferInfo, FileTransferInfo, QFilterCondition> {
  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileSizeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileSize',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileSizeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileSize',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileSizeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileSize',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      fileSizeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      messageIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'messageId',
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      messageIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'messageId',
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      messageIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageId',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      messageIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messageId',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      messageIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messageId',
        value: value,
      ));
    });
  }

  QueryBuilder<FileTransferInfo, FileTransferInfo, QAfterFilterCondition>
      messageIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FileTransferInfoQueryObject
    on QueryBuilder<FileTransferInfo, FileTransferInfo, QFilterCondition> {}
