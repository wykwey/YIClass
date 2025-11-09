import 'package:flutter/material.dart';
import '../zujian/appbar.dart';
import '../zujian/settingscard.dart';
import '../zujian/dropdown.dart';
import '../zujian/cards.dart';

/// 课程提醒设置页面
/// 
/// 功能：
/// - 课程提醒功能开关
/// - 提前提醒时间设置
/// - 申请闹钟权限
/// - 申请自启动权限
/// - 功能说明
class CourseReminderPage extends StatefulWidget {
  const CourseReminderPage({super.key});

  @override
  State<CourseReminderPage> createState() => _CourseReminderPageState();
}

class _CourseReminderPageState extends State<CourseReminderPage> {
  // ==================== 状态变量 ====================
  bool _reminderEnabled = false;
  String? _advanceTime = '5分钟';
  bool _alarmPermissionGranted = false;
  bool _autoStartPermissionGranted = false;

  // ==================== 提前提醒时间选项 ====================
  final List<YicoreDropdownItem<String>> _advanceTimeOptions = const [
    YicoreDropdownItem(value: '5分钟', label: '5分钟'),
    YicoreDropdownItem(value: '10分钟', label: '10分钟'),
    YicoreDropdownItem(value: '15分钟', label: '15分钟'),
    YicoreDropdownItem(value: '30分钟', label: '30分钟'),
  ];

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
                onChanged: (value) {
                  setState(() {
                    _reminderEnabled = value;
                  });
                  // TODO: 保存设置
                },
                inBlock: true,
              ),
              SettingsItem(
                title: '提前提醒时间',
                description: '设置课程开始前多久提醒',
                inBlock: true,
                enabled: _reminderEnabled,
                trailing: SizedBox(
                  width: 180,
                  child: YicoreDropdown<String>(
                    hintText: '请选择',
                    value: _advanceTime,
                    items: _advanceTimeOptions,
                    enabled: _reminderEnabled,
                    onChanged: (value) {
                      setState(() {
                        _advanceTime = value;
                      });
                      // TODO: 保存设置
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
                title: '闹钟权限',
                description: _alarmPermissionGranted 
                    ? '已授予闹钟权限' 
                    : '需要闹钟权限以确保提醒能够正常触发',
                showArrow: true,
                enabled: _reminderEnabled,
                onTap: () {
                  _requestAlarmPermission();
                },
                inBlock: true,
              ),
              SettingsItem.text(
                title: '自启动权限',
                description: _autoStartPermissionGranted 
                    ? '已授予自启动权限' 
                    : '需要自启动权限以确保应用在后台正常运行',
                showArrow: true,
                enabled: _reminderEnabled,
                onTap: () {
                  _requestAutoStartPermission();
                },
                inBlock: true,
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
                  description: '开启后，系统会在课程开始前根据您设置的时间提前提醒您。',
                ),
                const SizedBox(height: 16),
                _buildExplanationItem(
                  title: '提前提醒时间',
                  description: '您可以设置提前5分钟、10分钟、15分钟或30分钟提醒，确保您有足够的时间准备。',
                ),
                const SizedBox(height: 16),
                _buildExplanationItem(
                  title: '闹钟权限',
                  description: '需要授予闹钟权限，系统才能为您设置提醒。',
                ),
                const SizedBox(height: 16),
                _buildExplanationItem(
                  title: '自启动权限',
                  description: '需要授予自启动权限，确保应用在后台能够正常运行并发送提醒。',
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
  
  /// 申请闹钟权限
  void _requestAlarmPermission() {
    // TODO: 实现闹钟权限申请逻辑
    setState(() {
      _alarmPermissionGranted = true;
    });
  }

  /// 申请自启动权限
  void _requestAutoStartPermission() {
    // TODO: 实现自启动权限申请逻辑
    setState(() {
      _autoStartPermissionGranted = true;
    });
  }
}

