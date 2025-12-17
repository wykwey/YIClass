import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notifications.dart';

/// 系统通知服务（原生推送通知）
/// 
/// 支持平台：
/// - Web: 降级使用 Sonner（应用内通知）
/// - Android/iOS/macOS: 使用原生系统通知
class SystemNotifications {
  SystemNotifications._();

  static SystemNotifications? _instance;
  static SystemNotifications get instance {
    _instance ??= SystemNotifications._();
    return _instance!;
  }

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  BuildContext? _context;

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

  void setContext(BuildContext context) => _context = context;

  Future<bool> requestPermission() async {
    if (kIsWeb) return true;

    await _ensureInitialized();

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }

    return true;
  }

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
    await _plugin.show(id, title, body, NotificationDetails(
      android: _androidDetails(),
      iOS: _iosDetails(),
      macOS: _iosDetails(),
    ));
  }

  Future<void> showWithActions({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (kIsWeb) return;

    await _ensureInitialized();
    await _plugin.show(id, title, body, NotificationDetails(
      android: _androidDetailsWithActions(),
    ));
  }

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
      id, title, body, time,
      NotificationDetails(android: _androidDetails(), iOS: _iosDetails(), macOS: _iosDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

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
    if (reminderTime.isBefore(DateTime.now())) return;

    final body = _buildCourseReminderBody(location: location, teacher: teacher);
    final notificationId = id ?? scheduledTime.millisecondsSinceEpoch ~/ 1000;
    final time = tz.TZDateTime.from(reminderTime, tz.local);

    await _plugin.zonedSchedule(
      notificationId, '课程提醒：$courseName', body, time,
      NotificationDetails(android: _androidDetails(), iOS: _iosDetails(), macOS: _iosDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelCourseReminders(int courseId) async {
    if (kIsWeb) return;
    await _plugin.cancel(courseId);
  }

  Future<void> cancel(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  void _showSonner(String title, String body) {
    if (_context != null && _context!.mounted) {
      Notifications.sonner(_context!, title: title, message: body);
    }
  }

  String _buildCourseReminderBody({String? location, String? teacher}) {
    final parts = <String>[];
    if (location != null && location.isNotEmpty) parts.add('地点：$location');
    if (teacher != null && teacher.isNotEmpty) parts.add('教师：$teacher');
    return parts.isEmpty ? '即将开始上课' : parts.join(' | ');
  }

  AndroidNotificationDetails _androidDetails() {
    return const AndroidNotificationDetails(
      'yiclass_channel', 'YiClass 通知',
      channelDescription: 'YiClass 课表管理应用通知频道',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
  }

  AndroidNotificationDetails _androidDetailsWithActions() {
    return const AndroidNotificationDetails(
      'yiclass_actions_channel', 'YiClass 操作通知',
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

final systemNotifications = SystemNotifications.instance;
