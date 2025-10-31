// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_settings.dart';

// **************************************************************************
// _IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

final TimetableSettingsSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'TimetableSettings',
    embedded: true,
    properties: [
      IsarPropertySchema(
        name: 'startDate',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'totalWeeks',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'showWeekend',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'classTimes',
        type: IsarType.objectList,
        target: 'ClassTime',
      ),
      IsarPropertySchema(
        name: 'holidays',
        type: IsarType.dateTimeList,
      ),
      IsarPropertySchema(
        name: 'extraClassDays',
        type: IsarType.dateTimeList,
      ),
      IsarPropertySchema(
        name: 'maxPeriods',
        type: IsarType.long,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<void, TimetableSettings>(
    serialize: serializeTimetableSettings,
    deserialize: deserializeTimetableSettings,
  ),
);

@isarProtected
int serializeTimetableSettings(IsarWriter writer, TimetableSettings object) {
  IsarCore.writeLong(
      writer, 1, object.startDate.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(writer, 2, object.totalWeeks);
  IsarCore.writeBool(writer, 3, object.showWeekend);
  IsarCore.writeLong(writer, 7, object.maxPeriods);
  {
    final list = object.classTimes;
    final listWriter = IsarCore.beginList(writer, 4, list.length);
    for (var i = 0; i < list.length; i++) {
      {
        final value = list[i];
        final objectWriter = IsarCore.beginObject(listWriter, i);
        serializeClassTime(objectWriter, value);
        IsarCore.endObject(listWriter, objectWriter);
      }
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final list = object.holidays;
    final listWriter = IsarCore.beginList(writer, 5, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeLong(listWriter, i, list[i].toUtc().microsecondsSinceEpoch);
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final list = object.extraClassDays;
    final listWriter = IsarCore.beginList(writer, 6, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeLong(listWriter, i, list[i].toUtc().microsecondsSinceEpoch);
    }
    IsarCore.endList(writer, listWriter);
  }
  return 0;
}

@isarProtected
TimetableSettings deserializeTimetableSettings(IsarReader reader) {
  final object = TimetableSettings();
  {
    final value = IsarCore.readLong(reader, 1);
    if (value == -9223372036854775808) {
      object.startDate =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.startDate =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.totalWeeks = IsarCore.readLong(reader, 2);
  object.showWeekend = IsarCore.readBool(reader, 3);
  object.maxPeriods = IsarCore.readLong(reader, 7);
  {
    final length = IsarCore.readList(reader, 4, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.classTimes = const <ClassTime>[];
      } else {
        final list =
            List<ClassTime>.filled(length, ClassTime(), growable: true);
        for (var i = 0; i < length; i++) {
          {
            final objectReader = IsarCore.readObject(reader, i);
            if (objectReader.isNull) {
              list[i] = ClassTime();
            } else {
              final embedded = deserializeClassTime(objectReader);
              IsarCore.freeReader(objectReader);
              list[i] = embedded;
            }
          }
        }
        IsarCore.freeReader(reader);
        object.classTimes = list;
      }
    }
  }
  {
    final length = IsarCore.readList(reader, 5, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.holidays = const <DateTime>[];
      } else {
        final list = List<DateTime>.filled(length,
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
            growable: true);
        for (var i = 0; i < length; i++) {
          {
            final value = IsarCore.readLong(reader, i);
            if (value == -9223372036854775808) {
              list[i] =
                  DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
            } else {
              list[i] = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
                  .toLocal();
            }
          }
        }
        IsarCore.freeReader(reader);
        object.holidays = list;
      }
    }
  }
  {
    final length = IsarCore.readList(reader, 6, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.extraClassDays = const <DateTime>[];
      } else {
        final list = List<DateTime>.filled(length,
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
            growable: true);
        for (var i = 0; i < length; i++) {
          {
            final value = IsarCore.readLong(reader, i);
            if (value == -9223372036854775808) {
              list[i] =
                  DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
            } else {
              list[i] = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
                  .toLocal();
            }
          }
        }
        IsarCore.freeReader(reader);
        object.extraClassDays = list;
      }
    }
  }
  return object;
}

extension TimetableSettingsQueryFilter
    on QueryBuilder<TimetableSettings, TimetableSettings, QFilterCondition> {
  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      startDateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      startDateGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      startDateGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      startDateLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      startDateLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      startDateBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      totalWeeksEqualTo(
    int value,
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

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      totalWeeksGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      totalWeeksGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      totalWeeksLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      totalWeeksLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      totalWeeksBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      showWeekendEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      classTimesIsEmpty() {
    return not().classTimesIsNotEmpty();
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      classTimesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 4, value: null),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      holidaysElementEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      holidaysElementGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      holidaysElementGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      holidaysElementLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      holidaysElementLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      holidaysElementBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      holidaysIsEmpty() {
    return not().holidaysIsNotEmpty();
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      holidaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 5, value: null),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      extraClassDaysElementEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      extraClassDaysElementGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      extraClassDaysElementGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      extraClassDaysElementLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      extraClassDaysElementLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      extraClassDaysElementBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      extraClassDaysIsEmpty() {
    return not().extraClassDaysIsNotEmpty();
  }

  QueryBuilder<TimetableSettings, TimetableSettings, QAfterFilterCondition>
      extraClassDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 6, value: null),
      );
    });
  }
}

extension TimetableSettingsQueryObject
    on QueryBuilder<TimetableSettings, TimetableSettings, QFilterCondition> {}
