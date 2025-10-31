import 'package:flutter/foundation.dart';
import '../data/timetable.dart';
import '../data/course.dart';
import '../services/query_service.dart';

/// WeekState
/// 
/// - 管理当前的周与日
/// - 基于 QueryService 提供按周/日/节次的查询便捷方法（需要传入当前 Timetable）
class WeekState extends ChangeNotifier {
  int _week = 1;
  int _day = 1; // 1-7

  /// 当前周
  int get week => _week;

  /// 当前周几（1-7）
  int get day => _day;

  /// 设置当前周
  void setWeek(int value) {
    if (value <= 0) return;
    _week = value;
    notifyListeners();
  }

  /// 设置当前周几（1-7）
  void setDay(int value) {
    if (value < 1 || value > 7) return;
    _day = value;
    notifyListeners();
  }

  /// 获取当前周的课程（需传入当前课表）
  List<Course> weekCourses(Timetable t) {
    return QueryService.weekCourses(t, _week);
  }

  /// 获取当前周/日的课程（需传入当前课表）
  List<Course> dayCourses(Timetable t) {
    return QueryService.dayCourses(t, _week, _day);
  }

  /// 获取当前周/日/指定节次的课程（首个）（需传入当前课表）
  Course? periodCourse(Timetable t, int period) {
    return QueryService.periodCourse(t, _week, _day, period);
  }

  /// 计算当前周/日指定节次起的连续节次数量（需传入当前课表）
  int consecutivePeriods(Timetable t, int startPeriod) {
    return QueryService.consecutivePeriods(t, _week, _day, startPeriod);
  }

  /// 判断当前周/日/节次是否存在课程冲突（需传入当前课表）
  bool hasConflict(Timetable t, int period) {
    return QueryService.hasConflict(t, _week, _day, period);
  }
}

