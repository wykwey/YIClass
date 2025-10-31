// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetTimetableCollection on Isar {
  IsarCollection<int, Timetable> get timetables => this.collection();
}

final TimetableSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'Timetable',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'name',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'isDefault',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'settings',
        type: IsarType.object,
        target: 'TimetableSettings',
      ),
      IsarPropertySchema(
        name: 'courses',
        type: IsarType.objectList,
        target: 'Course',
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, Timetable>(
    serialize: serializeTimetable,
    deserialize: deserializeTimetable,
    deserializeProperty: deserializeTimetableProp,
  ),
  getEmbeddedSchemas: () => [
    TimetableSettingsSchema,
    ClassTimeSchema,
    CourseSchema,
    CourseScheduleSchema
  ],
);

@isarProtected
int serializeTimetable(IsarWriter writer, Timetable object) {
  IsarCore.writeString(writer, 1, object.name);
  IsarCore.writeBool(writer, 2, object.isDefault);
  {
    final value = object.settings;
    final objectWriter = IsarCore.beginObject(writer, 3);
    serializeTimetableSettings(objectWriter, value);
    IsarCore.endObject(writer, objectWriter);
  }
  {
    final list = object.courses;
    final listWriter = IsarCore.beginList(writer, 4, list.length);
    for (var i = 0; i < list.length; i++) {
      {
        final value = list[i];
        final objectWriter = IsarCore.beginObject(listWriter, i);
        serializeCourse(objectWriter, value);
        IsarCore.endObject(listWriter, objectWriter);
      }
    }
    IsarCore.endList(writer, listWriter);
  }
  return object.id;
}

@isarProtected
Timetable deserializeTimetable(IsarReader reader) {
  final object = Timetable();
  object.id = IsarCore.readId(reader);
  object.name = IsarCore.readString(reader, 1) ?? '';
  object.isDefault = IsarCore.readBool(reader, 2);
  {
    final objectReader = IsarCore.readObject(reader, 3);
    if (objectReader.isNull) {
      object.settings = TimetableSettings();
    } else {
      final embedded = deserializeTimetableSettings(objectReader);
      IsarCore.freeReader(objectReader);
      object.settings = embedded;
    }
  }
  {
    final length = IsarCore.readList(reader, 4, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.courses = const <Course>[];
      } else {
        final list = List<Course>.filled(length, Course(), growable: true);
        for (var i = 0; i < length; i++) {
          {
            final objectReader = IsarCore.readObject(reader, i);
            if (objectReader.isNull) {
              list[i] = Course();
            } else {
              final embedded = deserializeCourse(objectReader);
              IsarCore.freeReader(objectReader);
              list[i] = embedded;
            }
          }
        }
        IsarCore.freeReader(reader);
        object.courses = list;
      }
    }
  }
  return object;
}

@isarProtected
dynamic deserializeTimetableProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readBool(reader, 2);
    case 3:
      {
        final objectReader = IsarCore.readObject(reader, 3);
        if (objectReader.isNull) {
          return TimetableSettings();
        } else {
          final embedded = deserializeTimetableSettings(objectReader);
          IsarCore.freeReader(objectReader);
          return embedded;
        }
      }
    case 4:
      {
        final length = IsarCore.readList(reader, 4, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <Course>[];
          } else {
            final list = List<Course>.filled(length, Course(), growable: true);
            for (var i = 0; i < length; i++) {
              {
                final objectReader = IsarCore.readObject(reader, i);
                if (objectReader.isNull) {
                  list[i] = Course();
                } else {
                  final embedded = deserializeCourse(objectReader);
                  IsarCore.freeReader(objectReader);
                  list[i] = embedded;
                }
              }
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _TimetableUpdate {
  bool call({
    required int id,
    String? name,
    bool? isDefault,
  });
}

class _TimetableUpdateImpl implements _TimetableUpdate {
  const _TimetableUpdateImpl(this.collection);

  final IsarCollection<int, Timetable> collection;

  @override
  bool call({
    required int id,
    Object? name = ignore,
    Object? isDefault = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (name != ignore) 1: name as String?,
          if (isDefault != ignore) 2: isDefault as bool?,
        }) >
        0;
  }
}

sealed class _TimetableUpdateAll {
  int call({
    required List<int> id,
    String? name,
    bool? isDefault,
  });
}

class _TimetableUpdateAllImpl implements _TimetableUpdateAll {
  const _TimetableUpdateAllImpl(this.collection);

  final IsarCollection<int, Timetable> collection;

  @override
  int call({
    required List<int> id,
    Object? name = ignore,
    Object? isDefault = ignore,
  }) {
    return collection.updateProperties(id, {
      if (name != ignore) 1: name as String?,
      if (isDefault != ignore) 2: isDefault as bool?,
    });
  }
}

extension TimetableUpdate on IsarCollection<int, Timetable> {
  _TimetableUpdate get update => _TimetableUpdateImpl(this);

  _TimetableUpdateAll get updateAll => _TimetableUpdateAllImpl(this);
}

sealed class _TimetableQueryUpdate {
  int call({
    String? name,
    bool? isDefault,
  });
}

class _TimetableQueryUpdateImpl implements _TimetableQueryUpdate {
  const _TimetableQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<Timetable> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
    Object? isDefault = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (name != ignore) 1: name as String?,
      if (isDefault != ignore) 2: isDefault as bool?,
    });
  }
}

extension TimetableQueryUpdate on IsarQuery<Timetable> {
  _TimetableQueryUpdate get updateFirst =>
      _TimetableQueryUpdateImpl(this, limit: 1);

  _TimetableQueryUpdate get updateAll => _TimetableQueryUpdateImpl(this);
}

class _TimetableQueryBuilderUpdateImpl implements _TimetableQueryUpdate {
  const _TimetableQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<Timetable, Timetable, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
    Object? isDefault = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (name != ignore) 1: name as String?,
        if (isDefault != ignore) 2: isDefault as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension TimetableQueryBuilderUpdate
    on QueryBuilder<Timetable, Timetable, QOperations> {
  _TimetableQueryUpdate get updateFirst =>
      _TimetableQueryBuilderUpdateImpl(this, limit: 1);

  _TimetableQueryUpdate get updateAll => _TimetableQueryBuilderUpdateImpl(this);
}

extension TimetableQueryFilter
    on QueryBuilder<Timetable, Timetable, QFilterCondition> {
  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition>
      nameGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> nameLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition>
      nameLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> isDefaultEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> coursesIsEmpty() {
    return not().coursesIsNotEmpty();
  }

  QueryBuilder<Timetable, Timetable, QAfterFilterCondition>
      coursesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 4, value: null),
      );
    });
  }
}

extension TimetableQueryObject
    on QueryBuilder<Timetable, Timetable, QFilterCondition> {
  QueryBuilder<Timetable, Timetable, QAfterFilterCondition> settings(
      FilterQuery<TimetableSettings> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, 3);
    });
  }
}

extension TimetableQuerySortBy on QueryBuilder<Timetable, Timetable, QSortBy> {
  QueryBuilder<Timetable, Timetable, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterSortBy> sortByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterSortBy> sortByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterSortBy> sortByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterSortBy> sortByIsDefaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension TimetableQuerySortThenBy
    on QueryBuilder<Timetable, Timetable, QSortThenBy> {
  QueryBuilder<Timetable, Timetable, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterSortBy> thenByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterSortBy> thenByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterSortBy> thenByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterSortBy> thenByIsDefaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension TimetableQueryWhereDistinct
    on QueryBuilder<Timetable, Timetable, QDistinct> {
  QueryBuilder<Timetable, Timetable, QAfterDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Timetable, Timetable, QAfterDistinct> distinctByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }
}

extension TimetableQueryProperty1
    on QueryBuilder<Timetable, Timetable, QProperty> {
  QueryBuilder<Timetable, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<Timetable, String, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Timetable, bool, QAfterProperty> isDefaultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Timetable, TimetableSettings, QAfterProperty>
      settingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Timetable, List<Course>, QAfterProperty> coursesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension TimetableQueryProperty2<R>
    on QueryBuilder<Timetable, R, QAfterProperty> {
  QueryBuilder<Timetable, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<Timetable, (R, String), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Timetable, (R, bool), QAfterProperty> isDefaultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Timetable, (R, TimetableSettings), QAfterProperty>
      settingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Timetable, (R, List<Course>), QAfterProperty> coursesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension TimetableQueryProperty3<R1, R2>
    on QueryBuilder<Timetable, (R1, R2), QAfterProperty> {
  QueryBuilder<Timetable, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<Timetable, (R1, R2, String), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Timetable, (R1, R2, bool), QOperations> isDefaultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Timetable, (R1, R2, TimetableSettings), QOperations>
      settingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Timetable, (R1, R2, List<Course>), QOperations>
      coursesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}
