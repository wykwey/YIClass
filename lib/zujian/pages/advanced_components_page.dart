import 'package:flutter/material.dart';
import '../components.dart';
import '../notifications.dart';
import '../dialogs.dart';
import '../datepicker.dart';
import '../timepicker.dart';
import '../schedule_manager.dart';
import '../course_selector.dart';

// ================== 进阶组件页面 ==================
class AdvancedComponentsPage extends StatefulWidget {
  @override
  _AdvancedComponentsPageState createState() => _AdvancedComponentsPageState();
}

class _AdvancedComponentsPageState extends State<AdvancedComponentsPage> {
  DateTime? _selectedDate;
  TimeRange? _selectedRange;
  List<Schedule> _schedules = [
    Schedule(id: '1', name: '课表1'),
    Schedule(id: '2', name: '课表2'),
  ];
  String? _currentScheduleId = '1';
  
  // 课程选择器演示数据
  List<CourseItem> _courses = [
    CourseItem(id: '1', name: '高等数学'),
    CourseItem(id: '2', name: '大学英语'),
    CourseItem(id: '3', name: '计算机科学'),
  ];
  String? _currentCourseId = '1';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          _buildNotificationDemo(),
          SizedBox(height: 50),
          _buildDialogDemo(),
          SizedBox(height: 50),
          _buildDatePickerDemo(),
          SizedBox(height: 50),
          _buildTimeRangePickerDemo(),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  // ================== 通知组件演示 ==================
  Widget _buildNotificationDemo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: '通知组件',
            subtitle: 'Sonner 通知系统演示',
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              YicoreButton(
                text: '带标题和按钮',
                onPressed: () => Notifications.sonner(
                  context,
                  title: '操作成功',
                  message: '您的操作已成功完成',
                  actionText: '撤销',
                  onAction: () {
                    Notifications.sonner(
                      context,
                      message: '操作已撤销',
                    );
                  },
                ),
              ),
              YicoreButton(
                text: '带操作按钮',
                onPressed: () => Notifications.sonner(
                  context,
                  title: '发生错误',
                  message: '操作失败，请重试',
                  actionText: '重试',
                  onAction: () {
                    Notifications.sonner(
                      context,
                      message: '正在重试...',
                    );
                  },
                ),
              ),
              YicoreButton(
                text: '仅消息',
                onPressed: () => Notifications.sonner(
                  context,
                  message: '这是一条简单的通知消息',
                ),
              ),
              YicoreButton(
                text: '仅标题',
                onPressed: () => Notifications.sonner(
                  context,
                  title: '通知标题',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================== 对话框组件演示 ==================
  Widget _buildDialogDemo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: '对话框组件',
            subtitle: 'Alert、Confirm、Modal、课表管理、课程选择',
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              YicoreButton(
                text: '课表管理',
                onPressed: () {
                  YicoreScheduleManager.show(
                    context,
                    schedules: _schedules,
                    currentScheduleId: _currentScheduleId,
                    onSchedulesChanged: (updatedSchedules) {
                      setState(() {
                        _schedules = updatedSchedules;
                      });
                    },
                  );
                },
              ),
              YicoreButton(
                text: '课程选择',
                onPressed: () async {
                  final selectedId = await YicoreCourseSelector.show(
                    context,
                    courses: _courses,
                    currentCourseId: _currentCourseId,
                    title: '选择课程',
                  );
                  if (selectedId != null && mounted) {
                    setState(() {
                      _currentCourseId = selectedId;
                    });
                    final selectedCourse = _courses.firstWhere((c) => c.id == selectedId);
                    Notifications.sonner(
                      context,
                      title: '已选择课程',
                      message: selectedCourse.name,
                    );
                  }
                },
              ),
              YicoreButton(
                text: 'Alert 提示',
                onPressed: () => YicoreAlert.show(
                  context,
                  title: '提示',
                  message: '这是一个 Alert 对话框示例',
                  onConfirm: () {
                    print('Alert 确认');
                  },
                ),
              ),
              YicoreButton(
                text: 'Confirm 确认',
                onPressed: () async {
                  final result = await YicoreConfirm.show(
                    context,
                    title: '确认操作',
                    message: '确定要执行此操作吗？',
                    onConfirm: () {
                      print('Confirm 确认');
                    },
                    onCancel: () {
                      print('Confirm 取消');
                    },
                  );
                  if (mounted && result) {
                    Notifications.sonner(
                      context,
                      message: '已确认操作',
                    );
                  }
                },
              ),
              YicoreButton(
                text: 'Modal 模态',
                onPressed: () => YicoreModal.show(
                  context,
                  title: '模态对话框',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '这是一个模态对话框示例',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '可以在这里放置任何内容，如表单、列表、图片等。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  footer: Builder(
                    builder: (dialogContext) => Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        YicoreButton(
                          text: '取消',
                          isOutlined: true,
                          onPressed: () {
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext, rootNavigator: true).pop();
                            }
                          },
                        ),
                        SizedBox(width: 12),
                        YicoreButton(
                          text: '确定',
                          onPressed: () {
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext, rootNavigator: true).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              YicoreButton(
                text: '公告对话框',
                onPressed: () => YicoreAnnouncement.show(
                  context,
                  title: '系统公告',
                  message: '本周末将进行系统维护，期间可能出现短暂不可用。给您带来不便，敬请谅解。',
                  primaryText: '我知道了',
                  secondaryText: '稍后提醒',
                  onPrimary: () {
                    Notifications.sonner(
                      context,
                      message: '已确认公告',
                    );
                  },
                  onSecondary: () {
                    Notifications.sonner(
                      context,
                      message: '将稍后提醒',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================== 日期选择器演示 ==================
  Widget _buildDatePickerDemo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: '日期选择器',
            subtitle: '日期选择组件演示',
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate != null
                              ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                              : '请选择日期',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedDate != null ? Colors.black : Colors.grey[400],
                          ),
                        ),
                      ),
                      Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              YicoreButton(
                text: '选择',
                onPressed: () async {
                  final DateTime? picked = await YicoreDatePicker.show(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                  );
                  if (picked != null && mounted) {
                    setState(() {
                      _selectedDate = picked;
                    });
                    Notifications.sonner(
                      context,
                      message: '已选择日期：${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
                    );
                  }
                },
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================== 时间范围选择器演示 ==================
  Widget _buildTimeRangePickerDemo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: '时间范围选择器',
            subtitle: '底部弹窗，格式 xx:xx-xx:xx',
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Text(
                    _selectedRange != null
                        ? _selectedRange!.format()
                        : '未选择',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedRange != null ? Colors.black : Colors.grey[400],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              YicoreButton(
                text: '选择时间',
                onPressed: () async {
                  final picked = await YicoreTimeRangePicker.show(
                    context: context,
                    initial: _selectedRange,
                  );
                  if (picked != null && mounted) {
                    setState(() => _selectedRange = picked);
                    Notifications.sonner(
                      context,
                      message: '已选择 ${picked.format()}',
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================== 节标题组件 ==================
class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionTitle({
    required this.title,
    this.subtitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 0.3,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

