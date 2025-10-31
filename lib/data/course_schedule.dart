import 'package:isar_plus/isar_plus.dart';

part 'course_schedule.g.dart';

/// 课程时间模型（嵌入式）
/// 用于描述一门课在一周中具体上课的时间安排
@embedded
class CourseSchedule {
  /// 周几（1~7, 1代表星期一，7代表星期日）
  late int day;

  /// 节次列表，例如 [1,2,3] 代表第1/2/3节
  late List<int> periods;

  /// 周次列表，例如 [1,2,3,4,5] 表示第1-5周上课
  late List<int> weekPattern;

  /// 课程提醒配置字符串
  late String reminder;

  CourseSchedule();
}
