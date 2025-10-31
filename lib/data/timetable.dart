import 'package:isar_plus/isar_plus.dart';
import 'timetable_settings.dart';
import 'course.dart';
import 'class_time.dart';
import 'course_schedule.dart';

part 'timetable.g.dart';

/// 课表模型，支持嵌套课程和设置
@collection
class Timetable {
  /// 课表唯一ID（自增）
  late int id;

  /// 课表名称
  late String name;

  /// 是否为默认课表
  late bool isDefault;

  /// 课表设置（嵌入式）
  late TimetableSettings settings;

  /// 课程列表（嵌入式）
  late List<Course> courses;

  Timetable();
}

