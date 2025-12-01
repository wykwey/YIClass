import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../components/layout/appbar.dart';
import '../../components/layout/settingscard.dart';
import '../../components/inputs/dropdown.dart';
import '../../components/layout/cards.dart';
import '../../components/feedback/notifications.dart';
import '../../services/settings_service.dart';
import '../../services/course_reminder_service.dart';
import '../../states/timetable_state.dart';

/// 课程提醒设置页面
/// 
/// 功能：
/// - 课程提醒功能开关
/// - 提前提醒时间设置
/// - 申请通知权限
/// - 申请精确闹钟权限
/// - 功能说明
class CourseReminderPage extends StatefulWidget {
  const CourseReminderPage({super.key});

  @override
  State<CourseReminderPage> createState() => _CourseReminderPageState();
}

class _CourseReminderPageState extends State<CourseReminderPage> {
  // ==================== 状态变量 ====================
  bool _reminderEnabled = false;
  int _advanceMinutes = 5;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    try {
      // 加载全局课程提醒开关
      final appSettings = await SettingsService.instance.loadSettings();
      
      if (!mounted) return;
      // 加载当前课表的提前提醒时间
      final timetableState = context.read<TimetableState>();
      final currentTimetable = timetableState.current;
      
      if (mounted) {
        setState(() {
          _reminderEnabled = appSettings.courseReminder;
          _advanceMinutes = currentTimetable?.settings.reminderMinutes ?? 5;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Notifications.sonner(
          context,
          title: '加载失败',
          message: '无法加载提醒设置',
        );
      }
    }
  }

  /// 保存提醒开关
  Future<void> _saveReminderEnabled(bool enabled) async {
    final success = await SettingsService.instance.updateNotificationSettings(
      courseReminder: enabled,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _reminderEnabled = enabled;
      });

      final timetableState = context.read<TimetableState>();
      final currentTimetable = timetableState.current;
      
      if (currentTimetable != null) {
        if (enabled) {
          // 开启提醒，刷新今日提醒
          await CourseReminderService.instance.scheduleTodayReminders(currentTimetable);
          if (mounted) {
            Notifications.sonner(
              context,
              title: '提醒已开启',
              message: '已为今日课程设置提醒',
            );
          }
        } else {
          // 关闭提醒，取消所有提醒
          await CourseReminderService.instance.cancelAllReminders();
          if (mounted) {
            Notifications.sonner(
              context,
              title: '提醒已关闭',
              message: '已取消所有课程提醒',
            );
          }
        }
      }
    } else {
      if (mounted) {
        Notifications.sonner(
          context,
          title: '保存失败',
          message: '无法保存提醒设置',
        );
      }
    }
  }

  /// 保存提前提醒时间
  Future<void> _saveAdvanceMinutes(int minutes) async {
    final timetableState = context.read<TimetableState>();
    final currentTimetable = timetableState.current;

    if (currentTimetable == null) {
      if (mounted) {
        Notifications.sonner(
          context,
          title: '保存失败',
          message: '当前没有选中的课表',
        );
      }
      return;
    }

    // 更新提前提醒时间
    currentTimetable.settings.reminderMinutes = minutes;
    final success = await timetableState.put(currentTimetable);

    if (!mounted) return;

    if (success) {
      setState(() {
        _advanceMinutes = minutes;
      });

      // 如果提醒已开启，刷新今日提醒
      if (_reminderEnabled) {
        await CourseReminderService.instance.scheduleTodayReminders(currentTimetable);
        if (mounted) {
          Notifications.sonner(
            context,
            title: '设置已更新',
            message: '已更新提醒时间为提前$minutes分钟',
          );
        }
      } else {
        if (mounted) {
          Notifications.sonner(
            context,
            title: '设置已保存',
            message: '提前提醒时间已更新',
          );
        }
      }
    } else {
      if (mounted) {
        Notifications.sonner(
          context,
          title: '保存失败',
          message: '无法保存提醒时间设置',
        );
      }
    }
  }

  // ==================== 提前提醒时间选项 ====================
  final List<YicoreDropdownItem<int>> _advanceTimeOptions = const [
    YicoreDropdownItem(value: 5, label: '5分钟'),
    YicoreDropdownItem(value: 10, label: '10分钟'),
    YicoreDropdownItem(value: 15, label: '15分钟'),
    YicoreDropdownItem(value: 30, label: '30分钟'),
  ];

  // ==================== UI 构建 ====================
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: YicoreAppBar(
          title: '课程提醒',
          centerTitle: true,
          onBackPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFFF7F7F7),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: YicoreAppBar(
        title: '课程提醒',
        centerTitle: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        children: [
          // 提醒设置
          SettingsBlock(
            title: '提醒设置',
            children: [
              SettingsItem.switch_(
                title: '课程提醒',
                description: '在课程开始前提醒您',
                value: _reminderEnabled,
                onChanged: _handleReminderToggle,
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
                    onChanged: (value) {
                      if (value != null) {
                        _saveAdvanceMinutes(value);
                      }
                    },
                  ),
                ),
                isLastInBlock: true,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 权限设置
          SettingsBlock(
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
          ),
          
          const SizedBox(height: 16),
          
          // 功能说明
          YicoreCard(
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
                _buildExplanationItem(
                  title: '课程提醒',
                  description: '开启后，系统会在课程开始前根据您设置的时间提前提醒您。每次启动应用时自动刷新今日课程提醒。',
                ),
                const SizedBox(height: 16),
                _buildExplanationItem(
                  title: '提前提醒时间',
                  description: '您可以设置提前5分钟、10分钟、15分钟或30分钟提醒，确保您有足够的时间准备。',
                ),
                const SizedBox(height: 16),
                _buildExplanationItem(
                  title: '连续课程',
                  description: '对于连续多节的课程（如第1-3节），只会在第一节课开始前提醒一次。',
                ),
                const SizedBox(height: 16),
                _buildExplanationItem(
                  title: '通知权限',
                  description: '需要授予通知权限，系统才能发送课程提醒通知。',
                ),
                const SizedBox(height: 16),
                _buildExplanationItem(
                  title: '精确闹钟权限',
                  description: '需要授予精确闹钟权限，确保课程提醒能够准时触发（Android 12+ 需要）。',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ==================== 辅助方法 ====================
  
  /// 处理提醒开关切换
  void _handleReminderToggle(bool value) {
    _saveReminderEnabled(value);
  }

  /// 构建说明项
  Widget _buildExplanationItem({
    required String title,
    required String description,
  }) {
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
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ==================== 权限申请 ====================
  
  /// 申请通知权限
  Future<void> _requestNotificationPermission() async {
    await Permission.notification.request();
    if (mounted) {
      Notifications.sonner(
        context,
        title: '权限申请',
        message: '请在弹出的对话框中授予通知权限',
      );
    }
  }

  /// 申请精确闹钟权限
  Future<void> _requestAlarmPermission() async {
    await Permission.scheduleExactAlarm.request();
    if (mounted) {
      Notifications.sonner(
        context,
        title: '权限申请',
        message: '请在弹出的对话框中授予精确闹钟权限',
      );
    }
  }
}
