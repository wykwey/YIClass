import 'package:isar_plus/isar_plus.dart';
import 'class_time.dart';

part 'timetable_settings.g.dart';

/// 课表设置模型（嵌入式对象，不再使用结束日期，支持节假日与补课日）
@embedded
class TimetableSettings {
  /// 学期开始日期
  late DateTime startDate;

  /// 学期总周数
  late int totalWeeks;

  /// 是否显示周末
  late bool showWeekend;

  /// 最大节数
  late int maxPeriods;

  /// 每日课时具体上课和下课时间安排
  late List<ClassTime> classTimes;

  /// 放假日历（某些天没有课）
  late List<DateTime> holidays;

  /// 调休/补课日历（某些原本不用上课的日子要上课）
  late List<DateTime> extraClassDays;

  TimetableSettings();
}
