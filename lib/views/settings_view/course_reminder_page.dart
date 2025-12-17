import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';

import '../../components/feedback/notifications.dart';
import '../../components/inputs/dropdown.dart';
import '../../components/layout/appbar.dart';
import '../../components/layout/cards.dart';
import '../../components/layout/settingscard.dart';
import '../../services/course_reminder_service.dart';
import '../../services/settings_service.dart';
import '../../states/timetable_state.dart';

/// 课程提醒设置页面
class CourseReminderPage extends StatefulWidget {
  const CourseReminderPage({super.key});

  @override
  State<CourseReminderPage> createState() => _CourseReminderPageState();
}

class _CourseReminderPageState extends State<CourseReminderPage> {
  bool _reminderEnabled = false;
  int _advanceMinutes = 5;
  bool _isLoading = false;

  static const _advanceTimeOptions = [
    YicoreDropdownItem(value: 5, label: '5分钟'),
    YicoreDropdownItem(value: 10, label: '10分钟'),
    YicoreDropdownItem(value: 15, label: '15分钟'),
    YicoreDropdownItem(value: 30, label: '30分钟'),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ==================== 数据操作 ====================

  Future<void> _loadSettings() async {
    try {
      final appSettings = await SettingsService.instance.loadSettings();
      if (!mounted) return;

      final timetable = context.read<TimetableState>().current;
      setState(() {
        _reminderEnabled = appSettings.courseReminder;
        _advanceMinutes = timetable?.settings.reminderMinutes ?? 5;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('加载失败', '无法加载提醒设置');
    }
  }

  Future<void> _saveReminderEnabled(bool enabled) async {
    final success = await SettingsService.instance.updateNotificationSettings(
      courseReminder: enabled,
    );
    if (!mounted) return;

    if (!success) {
      _showMessage('保存失败', '无法保存提醒设置');
      return;
    }

    setState(() => _reminderEnabled = enabled);

    final timetable = context.read<TimetableState>().current;
    if (timetable == null) return;

    if (enabled) {
      await CourseReminderService.instance.scheduleTodayReminders(timetable);
      if (mounted) _showMessage('提醒已开启', '已为今日课程设置提醒');
    } else {
      await CourseReminderService.instance.cancelAllReminders();
      if (mounted) _showMessage('提醒已关闭', '已取消所有课程提醒');
    }
  }

  Future<void> _saveAdvanceMinutes(int minutes) async {
    final timetableState = context.read<TimetableState>();
    final timetable = timetableState.current;

    if (timetable == null) {
      _showMessage('保存失败', '当前没有选中的课表');
      return;
    }

    timetable.settings.reminderMinutes = minutes;
    final success = await timetableState.put(timetable);
    if (!mounted) return;

    if (!success) {
      _showMessage('保存失败', '无法保存提醒时间设置');
      return;
    }

    setState(() => _advanceMinutes = minutes);

    if (_reminderEnabled) {
      await CourseReminderService.instance.scheduleTodayReminders(timetable);
      if (mounted) _showMessage('设置已更新', '已更新提醒时间为提前$minutes分钟');
    }
  }

  // ==================== 权限申请 ====================

  Future<void> _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }
    if (!mounted) return;

    _showMessage(
      status.isGranted ? '权限已授予' : '权限被拒绝',
      status.isGranted ? '通知权限已开启' : '请授予通知权限以接收课程提醒',
    );
  }

  Future<void> _requestAlarmPermission() async {
    if (kIsWeb || !Platform.isAndroid) {
      if (mounted) _showMessage('无需设置', '当前平台不需要此权限');
      return;
    }

    final status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) {
      if (mounted) _showMessage('权限已授予', '精确闹钟权限已开启');
      return;
    }

    // Android 12+ 跳转到系统设置
    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );
    await intent.launch();
  }

  // ==================== 辅助方法 ====================

  void _showMessage(String title, String message) {
    Notifications.sonner(context, title: title, message: message);
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YicoreAppBar(
        title: '课程提醒',
        centerTitle: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 80),
              children: [
                _buildReminderSettings(),
                const SizedBox(height: 16),
                _buildPermissionSettings(),
                const SizedBox(height: 16),
                _buildExplanationCard(),
              ],
            ),
    );
  }

  Widget _buildReminderSettings() {
    return SettingsBlock(
      title: '提醒设置',
      children: [
        SettingsItem.switch_(
          title: '课程提醒',
          description: '在课程开始前提醒您',
          value: _reminderEnabled,
          onChanged: _saveReminderEnabled,
          inBlock: true,
        ),
        SettingsItem(
          title: '提前提醒时间',
          description: '设置课程开始前多久提醒',
          inBlock: true,
          enabled: _reminderEnabled,
          trailing: SizedBox(
            width: 180,
            child: YicoreDropdown<int>(
              hintText: '请选择',
              value: _advanceMinutes,
              items: _advanceTimeOptions,
              enabled: _reminderEnabled,
              onChanged: (v) => v != null ? _saveAdvanceMinutes(v) : null,
            ),
          ),
          isLastInBlock: true,
        ),
      ],
    );
  }

  Widget _buildPermissionSettings() {
    return SettingsBlock(
      title: '权限设置',
      children: [
        SettingsItem.text(
          title: '通知权限',
          description: '需要通知权限以发送课程提醒',
          showArrow: true,
          enabled: _reminderEnabled,
          onTap: _requestNotificationPermission,
          inBlock: true,
        ),
        SettingsItem(
          title: '精确闹钟权限',
          description: '需要精确闹钟权限以确保提醒准时触发',
          showArrow: true,
          enabled: _reminderEnabled,
          onTap: _requestAlarmPermission,
          inBlock: true,
          isLastInBlock: true,
        ),
      ],
    );
  }

  Widget _buildExplanationCard() {
    const items = [
      ('课程提醒', '开启后，系统会在课程开始前根据您设置的时间提前提醒您。每次启动应用时自动刷新今日课程提醒。'),
      ('提前提醒时间', '您可以设置提前5分钟、10分钟、15分钟或30分钟提醒，确保您有足够的时间准备。'),
      ('连续课程', '对于连续多节的课程（如第1-3节），只会在第一节课开始前提醒一次。'),
      ('通知权限', '需要授予通知权限，系统才能发送课程提醒通知。'),
      ('精确闹钟权限', '需要授予精确闹钟权限，确保课程提醒能够准时触发（Android 12+ 需要）。'),
    ];

    return YicoreCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '功能说明',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child:
                    _buildExplanationItem(title: item.$1, description: item.$2),
              )),
        ],
      ),
    );
  }

  Widget _buildExplanationItem(
      {required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
        ),
      ],
    );
  }
}
