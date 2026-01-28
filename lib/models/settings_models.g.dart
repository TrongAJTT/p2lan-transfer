// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExtensibleSettingsCollection on Isar {
  IsarCollection<ExtensibleSettings> get extensibleSettings =>
      this.collection();
}

const ExtensibleSettingsSchema = CollectionSchema(
  name: r'ExtensibleSettings',
  id: 5655895684797682385,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'modelCode': PropertySchema(
      id: 1,
      name: r'modelCode',
      type: IsarType.string,
    ),
    r'settingsJson': PropertySchema(
      id: 2,
      name: r'settingsJson',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _extensibleSettingsEstimateSize,
  serialize: _extensibleSettingsSerialize,
  deserialize: _extensibleSettingsDeserialize,
  deserializeProp: _extensibleSettingsDeserializeProp,
  idName: r'id',
  indexes: {
    r'modelCode': IndexSchema(
      id: -3170135809371865501,
      name: r'modelCode',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'modelCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _extensibleSettingsGetId,
  getLinks: _extensibleSettingsGetLinks,
  attach: _extensibleSettingsAttach,
  version: '3.1.0+1',
);

int _extensibleSettingsEstimateSize(
  ExtensibleSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.modelCode.length * 3;
  bytesCount += 3 + object.settingsJson.length * 3;
  return bytesCount;
}

void _extensibleSettingsSerialize(
  ExtensibleSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.modelCode);
  writer.writeString(offsets[2], object.settingsJson);
  writer.writeDateTime(offsets[3], object.updatedAt);
}

ExtensibleSettings _extensibleSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExtensibleSettings(
    modelCode: reader.readString(offsets[1]),
    settingsJson: reader.readString(offsets[2]),
  );
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.updatedAt = reader.readDateTime(offsets[3]);
  return object;
}

P _extensibleSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _extensibleSettingsGetId(ExtensibleSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _extensibleSettingsGetLinks(
    ExtensibleSettings object) {
  return [];
}

void _extensibleSettingsAttach(
    IsarCollection<dynamic> col, Id id, ExtensibleSettings object) {
  object.id = id;
}

extension ExtensibleSettingsByIndex on IsarCollection<ExtensibleSettings> {
  Future<ExtensibleSettings?> getByModelCode(String modelCode) {
    return getByIndex(r'modelCode', [modelCode]);
  }

  ExtensibleSettings? getByModelCodeSync(String modelCode) {
    return getByIndexSync(r'modelCode', [modelCode]);
  }

  Future<bool> deleteByModelCode(String modelCode) {
    return deleteByIndex(r'modelCode', [modelCode]);
  }

  bool deleteByModelCodeSync(String modelCode) {
    return deleteByIndexSync(r'modelCode', [modelCode]);
  }

  Future<List<ExtensibleSettings?>> getAllByModelCode(
      List<String> modelCodeValues) {
    final values = modelCodeValues.map((e) => [e]).toList();
    return getAllByIndex(r'modelCode', values);
  }

  List<ExtensibleSettings?> getAllByModelCodeSync(
      List<String> modelCodeValues) {
    final values = modelCodeValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'modelCode', values);
  }

  Future<int> deleteAllByModelCode(List<String> modelCodeValues) {
    final values = modelCodeValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'modelCode', values);
  }

  int deleteAllByModelCodeSync(List<String> modelCodeValues) {
    final values = modelCodeValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'modelCode', values);
  }

  Future<Id> putByModelCode(ExtensibleSettings object) {
    return putByIndex(r'modelCode', object);
  }

  Id putByModelCodeSync(ExtensibleSettings object, {bool saveLinks = true}) {
    return putByIndexSync(r'modelCode', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByModelCode(List<ExtensibleSettings> objects) {
    return putAllByIndex(r'modelCode', objects);
  }

  List<Id> putAllByModelCodeSync(List<ExtensibleSettings> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'modelCode', objects, saveLinks: saveLinks);
  }
}

extension ExtensibleSettingsQueryWhereSort
    on QueryBuilder<ExtensibleSettings, ExtensibleSettings, QWhere> {
  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ExtensibleSettingsQueryWhere
    on QueryBuilder<ExtensibleSettings, ExtensibleSettings, QWhereClause> {
  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterWhereClause>
      modelCodeEqualTo(String modelCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'modelCode',
        value: [modelCode],
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterWhereClause>
      modelCodeNotEqualTo(String modelCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'modelCode',
              lower: [],
              upper: [modelCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'modelCode',
              lower: [modelCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'modelCode',
              lower: [modelCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'modelCode',
              lower: [],
              upper: [modelCode],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ExtensibleSettingsQueryFilter
    on QueryBuilder<ExtensibleSettings, ExtensibleSettings, QFilterCondition> {
  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
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

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
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

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
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

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      modelCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modelCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      modelCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'modelCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      modelCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'modelCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      modelCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'modelCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      modelCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'modelCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      modelCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'modelCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      modelCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'modelCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      modelCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'modelCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      modelCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modelCode',
        value: '',
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      modelCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'modelCode',
        value: '',
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      settingsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      settingsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      settingsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      settingsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settingsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      settingsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      settingsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      settingsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settingsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      settingsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settingsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      settingsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      settingsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settingsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ExtensibleSettingsQueryObject
    on QueryBuilder<ExtensibleSettings, ExtensibleSettings, QFilterCondition> {}

extension ExtensibleSettingsQueryLinks
    on QueryBuilder<ExtensibleSettings, ExtensibleSettings, QFilterCondition> {}

extension ExtensibleSettingsQuerySortBy
    on QueryBuilder<ExtensibleSettings, ExtensibleSettings, QSortBy> {
  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      sortByModelCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelCode', Sort.asc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      sortByModelCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelCode', Sort.desc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      sortBySettingsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsJson', Sort.asc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      sortBySettingsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsJson', Sort.desc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ExtensibleSettingsQuerySortThenBy
    on QueryBuilder<ExtensibleSettings, ExtensibleSettings, QSortThenBy> {
  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      thenByModelCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelCode', Sort.asc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      thenByModelCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelCode', Sort.desc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      thenBySettingsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsJson', Sort.asc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      thenBySettingsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsJson', Sort.desc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ExtensibleSettingsQueryWhereDistinct
    on QueryBuilder<ExtensibleSettings, ExtensibleSettings, QDistinct> {
  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QDistinct>
      distinctByModelCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modelCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QDistinct>
      distinctBySettingsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExtensibleSettings, ExtensibleSettings, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ExtensibleSettingsQueryProperty
    on QueryBuilder<ExtensibleSettings, ExtensibleSettings, QQueryProperty> {
  QueryBuilder<ExtensibleSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExtensibleSettings, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ExtensibleSettings, String, QQueryOperations>
      modelCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modelCode');
    });
  }

  QueryBuilder<ExtensibleSettings, String, QQueryOperations>
      settingsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingsJson');
    });
  }

  QueryBuilder<ExtensibleSettings, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
