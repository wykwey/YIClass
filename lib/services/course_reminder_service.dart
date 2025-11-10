import '../data/timetable.dart';
import '../data/course.dart';
import '../data/course_schedule.dart';
import '../data/class_time.dart';
import '../zujian/system_notifications.dart';
import '../utils/get_weekday.dart';
import 'query_service.dart';

/// 课程提醒服务
///
/// 功能：为今日课程设置提醒通知
///
/// 调用时机：
/// 1. 应用启动时
/// 2. 课表切换时
/// 3. 课程修改时
/// 4. 提醒设置更改时
class CourseReminderService {
  CourseReminderService._();
  static final instance = CourseReminderService._();

  // ==================== 公共接口 ====================

  /// 设置今日的课程提醒
  ///
  /// 流程：
  /// 1. 计算当前周次和星期几
  /// 2. 获取今日课程（使用 QueryService）
  /// 3. 取消所有旧提醒
  /// 4. 为每个课程时间段设置新提醒
  Future<void> scheduleTodayReminders(Timetable timetable) async {
    final now = DateTime.now();
    
    // 计算当前周次和星期几
    final weekInfo = getWeekInfo(
      now,
      timetable.settings.startDate,
      timetable.settings.totalWeeks,
    );

    // 学期未开始或已结束
    if (weekInfo == null) return;

    final weekNumber = weekInfo['weekIndex']!;
    final weekday = weekInfo['weekday']!;

    // 获取今日课程
    final todayCourses = QueryService.dayCourses(timetable, weekNumber, weekday);
    if (todayCourses.isEmpty) return;

    // 取消所有旧提醒
    await SystemNotifications.instance.cancelAll();

    // 为每个课程设置提醒
    for (final course in todayCourses) {
      await _scheduleCourseReminders(
        course: course,
        weekNumber: weekNumber,
        weekday: weekday,
        date: now,
        classTimes: timetable.settings.classTimes,
        reminderMinutes: timetable.settings.reminderMinutes,
      );
    }
  }

  /// 取消所有课程提醒
  Future<void> cancelAllReminders() async {
    await SystemNotifications.instance.cancelAll();
  }

  // ==================== 私有方法 ====================

  /// 为单个课程的所有时间段设置提醒
  ///
  /// 说明：
  /// - 对于连续课程（如第1-3节），只提醒第一节
  /// - 对于同一天多个时间段（如第1-2节和第6-7节），分别提醒
  Future<void> _scheduleCourseReminders({
    required Course course,
    required int weekNumber,
    required int weekday,
    required DateTime date,
    required List<ClassTime> classTimes,
    required int reminderMinutes,
  }) async {
    // 遍历课程的所有时间段
    for (final schedule in course.schedules) {
      // 只处理今日的时间段
      if (schedule.weekday != weekday) continue;
      if (!schedule.weekPattern.contains(weekNumber)) continue;

      // 计算课程开始时间
      final courseTime = _calculateCourseStartTime(
        schedule: schedule,
        date: date,
        classTimes: classTimes,
      );

      // 只为未来的课程设置提醒
      if (courseTime == null || courseTime.isBefore(DateTime.now())) continue;

      // 注册通知
      await _scheduleNotification(
        course: course,
        courseTime: courseTime,
        reminderMinutes: reminderMinutes,
      );
    }
  }

  /// 计算课程开始时间
  ///
  /// 对于连续课程（如第1-3节），只提醒第一节的开始时间
  /// 例如：第1-3节（08:00-10:25）→ 只在08:00前提醒
  DateTime? _calculateCourseStartTime({
    required CourseSchedule schedule,
    required DateTime date,
    required List<ClassTime> classTimes,
  }) {
    if (schedule.periods.isEmpty) return null;

    // 只提醒连续课程的第一节
    final firstPeriod = schedule.periods.first;

    // 查找对应的上课时间配置
    ClassTime? classTime;
    try {
      classTime = classTimes.firstWhere((ct) => ct.period == firstPeriod);
    } catch (_) {
      return null; // 未找到对应节次
    }

    // 解析时间字符串 "HH:mm"
    final timeParts = classTime.startTime.split(':');
    if (timeParts.length != 2) return null;

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) return null;

    // 组合日期和时间
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// 注册通知
  Future<void> _scheduleNotification({
    required Course course,
    required DateTime courseTime,
    required int reminderMinutes,
  }) async {
    final notificationId = _generateNotificationId(course, courseTime);

    await SystemNotifications.instance.scheduleCourseReminder(
      courseName: course.name,
      location: course.location.isNotEmpty ? course.location : null,
      teacher: course.teacher.isNotEmpty ? course.teacher : null,
      scheduledTime: courseTime,
      reminderMinutes: reminderMinutes,
      id: notificationId,
    );
  }

  /// 生成唯一的通知 ID
  ///
  /// 使用时间戳和课程名称哈希组合生成
  int _generateNotificationId(Course course, DateTime courseTime) {
    final timePart = courseTime.millisecondsSinceEpoch % 1000000;
    final courseHash = course.name.hashCode.abs() % 1000;
    return (timePart + courseHash).abs();
  }
}
