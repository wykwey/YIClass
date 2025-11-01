import 'package:isar_plus/isar_plus.dart';
import 'class_time.dart';

part 'timetable_settings.g.dart';

/// 课表设置模型（嵌入式对象，不再使用结束日期，支持节假日）
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

  /// 上课前提醒分钟数
  late int reminderMinutes;

  TimetableSettings();
}
