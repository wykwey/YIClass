import 'package:isar_plus/isar_plus.dart';
import 'course_schedule.dart';

part 'course.g.dart';

/// 课程模型（嵌入式）
@embedded
class Course {
  /// 课程名称
  late String name;

  /// 上课地点
  late String location;

  /// 授课教师
  late String teacher;

  /// 课程颜色（用于UI展示）
  late int color;

  /// 上课时间安排（嵌套对象列表）
  late List<CourseSchedule> schedules;

  Course();
}

