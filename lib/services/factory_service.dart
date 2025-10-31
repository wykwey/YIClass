import '../data/timetable.dart';
import '../data/timetable_settings.dart';
import '../data/class_time.dart';
import '../data/course.dart';
import '../data/course_schedule.dart';
import '../data/data_constants.dart';

/// 工厂：快速创建模型实例
/// 提供 Timetable/Settings/ClassTime/Course/CourseSchedule 的便捷构建方法
class FactoryService {
  /// 创建课时时间
  /// - period: 第几节
  /// - startTime/endTime: 24h 字符串（如 "08:00"）
  /// - reminderMinutes: 上课前提醒分钟数
  static ClassTime createClassTime({
    required int period,
    required String startTime,
    required String endTime,
    int reminderMinutes = 0,
  }) {
    final ct = ClassTime()
      ..period = period
      ..startTime = startTime
      ..endTime = endTime
      ..reminderMinutes = reminderMinutes;
    return ct;
  }

  /// 由 DataConstants.defaultPeriodTimes 生成默认课时时间列表
  static List<ClassTime> createDefaultClassTimesFromConstants() {
    final List<ClassTime> list = [];
    DataConstants.defaultPeriodTimes.forEach((k, v) {
      final period = int.tryParse(k) ?? 0;
      final parts = v.split('-');
      final start = parts.isNotEmpty ? parts.first : '';
      final end = parts.length > 1 ? parts.last : '';
      if (period > 0 && start.isNotEmpty && end.isNotEmpty) {
        list.add(createClassTime(period: period, startTime: start, endTime: end));
      }
    });
    // 按节次排序
    list.sort((a, b) => a.period.compareTo(b.period));
    return list;
  }

  /// 创建课表设置（默认值来源于 DataConstants）
  /// - startDate: 学期开始日期（默认 DateTime.now()）
  /// - totalWeeks: 默认 DataConstants.defaultTotalWeeks
  /// - showWeekend: 默认 DataConstants.defaultShowWeekend
  /// - classTimes: 默认由 DataConstants.defaultPeriodTimes 生成
  static TimetableSettings createSettings({
    DateTime? startDate,
    int? totalWeeks,
    bool? showWeekend,
    List<ClassTime>? classTimes,
    int? maxPeriods,
  }) {
    final s = TimetableSettings()
      ..startDate = startDate ?? DateTime.now()
      ..totalWeeks = totalWeeks ?? DataConstants.defaultTotalWeeks
      ..showWeekend = showWeekend ?? DataConstants.defaultShowWeekend
      ..maxPeriods = maxPeriods ?? DataConstants.defaultMaxPeriods
      ..classTimes = classTimes ?? createDefaultClassTimesFromConstants()
      ..holidays = <DateTime>[]
      ..extraClassDays = <DateTime>[];
    return s;
  }

  /// 创建课程时间（排课）
  /// - day: 周几（1-7）
  /// - periods: 节次列表
  /// - weekPattern: 周次数组
  /// - reminder: 自定义提醒配置字符串
  static CourseSchedule createSchedule({
    required int day,
    required List<int> periods,
    required List<int> weekPattern,
    String reminder = '',
  }) {
    final sch = CourseSchedule()
      ..day = day
      ..periods = periods
      ..weekPattern = weekPattern
      ..reminder = reminder;
    return sch;
  }

  /// 创建课程
  /// - name/location/teacher/color: 课程基本信息
  /// - schedules: 上课时间安排（可为空）
  static Course createCourse({
    required String name,
    String location = '',
    String teacher = '',
    // 默认使用与调色盘一致的柔和蓝色，便于在编辑页默认选中
    int color = 0xFFBBDEFB,
    List<CourseSchedule>? schedules,
  }) {
    final c = Course()
      ..name = name
      ..location = location
      ..teacher = teacher
      ..color = color
      ..schedules = schedules ?? <CourseSchedule>[];
    return c;
  }

  /// 创建空课表
  /// - name: 课表名称（默认 DataConstants.defaultTimetableName）
  /// - isDefault: 是否默认
  /// - settings: 课表设置（默认 createSettings()）
  static Timetable createTimetable({
    String? name,
    bool isDefault = false,
    TimetableSettings? settings,
  }) {
    final t = Timetable()
      ..id = 0  // 新对象的 ID 设为 0，Isar 会自动分配新 ID
      ..name = name ?? DataConstants.defaultTimetableName
      ..isDefault = isDefault
      ..settings = settings ?? createSettings()
      ..courses = <Course>[];
    return t;
  }
}

