import '../data/timetable.dart';
import '../data/course.dart';

/// 查询工具：针对嵌套课程进行筛选
/// 提供按周/日/节次的检索、连续节次数量计算、冲突判断
class QueryService {
  /// 某周的课程
  /// - t: 课表
  /// - week: 周次
  /// 返回：该周上课的课程列表
  static List<Course> weekCourses(Timetable t, int week) {
    return t.courses.where((c) => c.schedules.any((s) => s.weekPattern.contains(week))).toList();
  }

  /// 某周某天的课程
  /// - t: 课表
  /// - week: 周次
  /// - day: 周几（1-7）
  /// 返回：课程列表
  static List<Course> dayCourses(Timetable t, int week, int day) {
    return t.courses.where((c) => c.schedules.any((s) => s.day == day && s.weekPattern.contains(week))).toList();
  }

  /// 某周某天某节的课程（首个匹配）
  /// - t: 课表
  /// - week: 周次
  /// - day: 周几（1-7）
  /// - period: 节次
  /// 返回：首个匹配课程或 null
  static Course? periodCourse(Timetable t, int week, int day, int period) {
    for (final c in t.courses) {
      for (final s in c.schedules) {
        if (s.day == day && s.weekPattern.contains(week) && s.periods.contains(period)) {
          return c;
        }
      }
    }
    return null;
  }

  /// 连续节次数量（同一课程）
  /// - t: 课表
  /// - week: 周次
  /// - day: 周几（1-7）
  /// - startPeriod: 起始节次
  /// 返回：从起始节起连续的同课程节次数量
  static int consecutivePeriods(Timetable t, int week, int day, int startPeriod) {
    final c = periodCourse(t, week, day, startPeriod);
    if (c == null) return 0;
    for (final s in c.schedules) {
      if (s.day == day && s.weekPattern.contains(week) && s.periods.contains(startPeriod)) {
        int count = 0;
        int p = startPeriod;
        while (s.periods.contains(p)) {
          count++;
          p++;
        }
        return count;
      }
    }
    return 0;
  }

  /// 是否有冲突（同一时间超过 1 门课）
  /// - t: 课表
  /// - week: 周次
  /// - day: 周几（1-7）
  /// - period: 节次
  /// 返回：是否存在冲突
  static bool hasConflict(Timetable t, int week, int day, int period) {
    int n = 0;
    for (final c in t.courses) {
      for (final s in c.schedules) {
        if (s.day == day && s.weekPattern.contains(week) && s.periods.contains(period)) {
          n++;
          if (n > 1) return true;
        }
      }
    }
    return false;
  }
}

