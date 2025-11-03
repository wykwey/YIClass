// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_schedule.dart';

// **************************************************************************
// _IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

final CourseScheduleSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'CourseSchedule',
    embedded: true,
    properties: [
      IsarPropertySchema(
        name: 'weekday',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'periods',
        type: IsarType.longList,
      ),
      IsarPropertySchema(
        name: 'weekPattern',
        type: IsarType.longList,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<void, CourseSchedule>(
    serialize: serializeCourseSchedule,
    deserialize: deserializeCourseSchedule,
  ),
);

@isarProtected
int serializeCourseSchedule(IsarWriter writer, CourseSchedule object) {
  IsarCore.writeLong(writer, 1, object.weekday);
  {
    final list = object.periods;
    final listWriter = IsarCore.beginList(writer, 2, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeLong(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final list = object.weekPattern;
    final listWriter = IsarCore.beginList(writer, 3, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeLong(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  return 0;
}

@isarProtected
CourseSchedule deserializeCourseSchedule(IsarReader reader) {
  final object = CourseSchedule();
  object.weekday = IsarCore.readLong(reader, 1);
  {
    final length = IsarCore.readList(reader, 2, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.periods = const <int>[];
      } else {
        final list =
            List<int>.filled(length, -9223372036854775808, growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readLong(reader, i);
        }
        IsarCore.freeReader(reader);
        object.periods = list;
      }
    }
  }
  {
    final length = IsarCore.readList(reader, 3, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.weekPattern = const <int>[];
      } else {
        final list =
            List<int>.filled(length, -9223372036854775808, growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readLong(reader, i);
        }
        IsarCore.freeReader(reader);
        object.weekPattern = list;
      }
    }
  }
  return object;
}

extension CourseScheduleQueryFilter
    on QueryBuilder<CourseSchedule, CourseSchedule, QFilterCondition> {
  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekdayEqualTo(
    int value,
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

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekdayGreaterThan(
    int value,
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

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekdayGreaterThanOrEqualTo(
    int value,
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

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekdayLessThan(
    int value,
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

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekdayLessThanOrEqualTo(
    int value,
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

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekdayBetween(
    int lower,
    int upper,
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

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      periodsElementEqualTo(
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

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      periodsElementGreaterThan(
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

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      periodsElementGreaterThanOrEqualTo(
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

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      periodsElementLessThan(
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

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      periodsElementLessThanOrEqualTo(
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

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      periodsElementBetween(
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

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      periodsIsEmpty() {
    return not().periodsIsNotEmpty();
  }

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      periodsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 2, value: null),
      );
    });
  }

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekPatternElementEqualTo(
    int value,
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

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekPatternElementGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekPatternElementGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekPatternElementLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekPatternElementLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekPatternElementBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekPatternIsEmpty() {
    return not().weekPatternIsNotEmpty();
  }

  QueryBuilder<CourseSchedule, CourseSchedule, QAfterFilterCondition>
      weekPatternIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 3, value: null),
      );
    });
  }
}

extension CourseScheduleQueryObject
    on QueryBuilder<CourseSchedule, CourseSchedule, QFilterCondition> {}
