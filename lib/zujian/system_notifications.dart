import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notifications.dart';

/// 系统通知服务
/// 
/// 支持平台：
/// - Web: 使用 Sonner（页面内通知）
/// - Android/iOS/macOS: 使用原生系统通知
/// 
/// 功能：
/// - 即时通知（简单/带按钮）
/// - 定时通知（简单/带按钮，支持后台）
/// - 课程提醒（根据课程时间安排自动设置提醒）
class SystemNotifications {
  SystemNotifications._();

  static SystemNotifications? _instance;

  /// 获取单例实例
  static SystemNotifications get instance {
    _instance ??= SystemNotifications._();
    return _instance!;
  }

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  BuildContext? _context;

  // ==================== 初始化 ====================
  
  Future<void> _ensureInitialized() async {
    if (_initialized || kIsWeb) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios, macOS: ios),
    );

    _initialized = true;
  }

  /// 设置上下文（Web 平台需要用于显示 Sonner）
  void setContext(BuildContext context) => _context = context;

  // ==================== 权限管理 ====================

  /// 请求通知权限
  Future<bool> requestPermission() async {
    if (kIsWeb) return true;

    await _ensureInitialized();

    // Android
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    // iOS/macOS
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return true;
  }

  // ==================== 即时通知 ====================

  /// 显示简单通知
  Future<void> show({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (kIsWeb) {
      _showSonner(title, body);
      return;
    }

    await _ensureInitialized();

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: _androidDetails(),
        iOS: _iosDetails(),
        macOS: _iosDetails(),
      ),
    );
  }

  /// 显示带操作按钮的通知（仅 Android）
  Future<void> showWithActions({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (kIsWeb) return;

    await _ensureInitialized();

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: _androidDetailsWithActions(),
      ),
    );
  }

  // ==================== 定时通知（后台支持）====================

  /// 定时通知
  Future<void> schedule({
    required String title,
    required String body,
    required Duration delay,
    int id = 0,
  }) async {
    if (kIsWeb) {
      Future.delayed(delay, () => _showSonner(title, body));
      return;
    }

    await _ensureInitialized();

    final time = tz.TZDateTime.now(tz.local).add(delay);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      time,
      NotificationDetails(
        android: _androidDetails(),
        iOS: _iosDetails(),
        macOS: _iosDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 定时通知（带操作按钮，仅 Android）
  Future<void> scheduleWithActions({
    required String title,
    required String body,
    required Duration delay,
    int id = 0,
  }) async {
    if (kIsWeb) {
      Future.delayed(delay, () => _showSonner(title, body));
      return;
    }

    await _ensureInitialized();

    final time = tz.TZDateTime.now(tz.local).add(delay);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      time,
      NotificationDetails(
        android: _androidDetailsWithActions(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ==================== 课程提醒 ====================

  /// 根据指定时间安排课程提醒
  /// 
  /// - courseName: 课程名称
  /// - location: 上课地点（可选）
  /// - teacher: 授课教师（可选）
  /// - scheduledTime: 课程开始时间
  /// - reminderMinutes: 提前提醒分钟数（默认30分钟）
  /// - id: 通知ID（默认使用时间戳）
  Future<void> scheduleCourseReminder({
    required String courseName,
    String? location,
    String? teacher,
    required DateTime scheduledTime,
    int reminderMinutes = 30,
    int? id,
  }) async {
    if (kIsWeb) {
      final delay = scheduledTime.difference(DateTime.now()) - Duration(minutes: reminderMinutes);
      if (delay.isNegative) return;
      Future.delayed(delay, () {
        final body = _buildCourseReminderBody(location: location, teacher: teacher);
        _showSonner('课程提醒', body);
      });
      return;
    }

    await _ensureInitialized();

    final reminderTime = scheduledTime.subtract(Duration(minutes: reminderMinutes));
    if (reminderTime.isBefore(DateTime.now())) {
      // 提醒时间已过，不设置
      return;
    }

    final body = _buildCourseReminderBody(location: location, teacher: teacher);
    final notificationId = id ?? scheduledTime.millisecondsSinceEpoch ~/ 1000;

    final time = tz.TZDateTime.from(reminderTime, tz.local);

    await _plugin.zonedSchedule(
      notificationId,
      '课程提醒：$courseName',
      body,
      time,
      NotificationDetails(
        android: _androidDetails(),
        iOS: _iosDetails(),
        macOS: _iosDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 取消指定课程的所有提醒
  /// 
  /// - courseId: 课程ID（用于生成通知ID范围）
  Future<void> cancelCourseReminders(int courseId) async {
    if (kIsWeb) return;
    // 课程提醒使用时间戳作为ID，这里取消一个范围
    // 实际实现中可能需要维护一个课程ID到通知ID的映射
    await _plugin.cancel(courseId);
  }

  // ==================== 取消通知 ====================

  /// 取消指定通知
  Future<void> cancel(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id);
  }

  /// 取消所有通知
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  // ==================== 私有辅助方法 ====================

  void _showSonner(String title, String body) {
    if (_context != null && _context!.mounted) {
      Notifications.sonner(_context!, title: title, message: body);
    }
  }

  /// 构建课程提醒内容
  String _buildCourseReminderBody({String? location, String? teacher}) {
    final parts = <String>[];
    if (location != null && location.isNotEmpty) {
      parts.add('地点：$location');
    }
    if (teacher != null && teacher.isNotEmpty) {
      parts.add('教师：$teacher');
    }
    return parts.isEmpty ? '即将开始上课' : parts.join(' | ');
  }

  AndroidNotificationDetails _androidDetails() {
    return const AndroidNotificationDetails(
      'yiclass_channel',
      'YiClass 通知',
      channelDescription: 'YiClass 课表管理应用通知频道',
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  AndroidNotificationDetails _androidDetailsWithActions() {
    return const AndroidNotificationDetails(
      'yiclass_actions_channel',
      'YiClass 操作通知',
      channelDescription: 'YiClass 带操作按钮的通知频道',
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction('accept', '接受'),
        AndroidNotificationAction('decline', '拒绝'),
      ],
    );
  }

  DarwinNotificationDetails _iosDetails() {
    return const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
  }
}

// ==================== 全局实例 ====================
final systemNotifications = SystemNotifications.instance;
