import 'package:flutter/material.dart';
import 'notifications.dart';
import 'components.dart';
import 'navigation.dart';
import 'cards.dart';
import 'settingscard.dart';
import 'dialogs.dart';
import 'datepicker.dart';
import 'timepicker.dart';
import 'fab.dart';
import 'dropdown.dart';
import 'schedule_manager.dart';
import 'appbar.dart';
import 'segmented_control.dart';

void main() {
  runApp(MaterialApp(
    home: ComponentDemoPage(),
  ));
}

// ================== 主演示页面 ==================
class ComponentDemoPage extends StatefulWidget {
  @override
  _ComponentDemoPageState createState() => _ComponentDemoPageState();
}

class _ComponentDemoPageState extends State<ComponentDemoPage> {
  bool _switchValue = false;
  double _sliderValue = 50.0;
  int _currentIndex = 0;
  DateTime? _selectedDate;
  TimeRange? _selectedRange;
  String? _selectedLanguage;
  String? _selectedCountry;
  List<Schedule> _schedules = [
    Schedule(id: '1', name: '课表1'),
    Schedule(id: '2', name: '课表2'),
  ];
  String? _currentScheduleId = '1';
  String _selectedSegment = 'type';
  String _selectedSegmentSmall = 'type';
  String _selectedSegmentLarge = 'type';
  String _notificationStyle = 'banner';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                if (_currentIndex == 0) ...[
                  // 基础组件
                  _buildAppBarDemo(),
                  SizedBox(height: 50),
                  _buildSegmentedControlDemo(),
                  SizedBox(height: 50),
                  _buildSettingsBlockDemo(),
                  SizedBox(height: 50),
                  _buildSliderDemo(),
                  SizedBox(height: 50),
                  _buildCardDemo(),
                  SizedBox(height: 50),
                  _buildButtonDemo(),
                  SizedBox(height: 50),
                  _buildTextFieldDemo(),
                  SizedBox(height: 50),
                  _buildDropdownDemo(),
                ] else if (_currentIndex == 1) ...[
                  // 进阶组件
                  _buildNotificationDemo(),
                  SizedBox(height: 50),
                  _buildDialogDemo(),
                  SizedBox(height: 50),
                  _buildDatePickerDemo(),
                  SizedBox(height: 50),
                  _buildTimeRangePickerDemo(),
                ] else if (_currentIndex == 2) ...[
                  // 高级组件
                  _buildNavigationDemo(),
                ],
                SizedBox(height: 100),
              ],
            ),
          ),
          // 悬浮窗按钮演示
          YicoreFab(
            icon: Icons.add,
            menuItems: [
              YicoreFabItem(
                icon: Icons.edit,
                label: '编辑',
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了编辑',
                  );
                },
              ),
              YicoreFabItem(
                icon: Icons.favorite,
                label: '收藏',

                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了收藏',
                  );
                },
              ),
              YicoreFabItem(
                icon: Icons.share,
                label: '分享',
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了分享',
                  );
                },
              ),
            ],
            onPressed: () {
              Notifications.sonner(
                context,
                message: '点击了主按钮',
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: YicoreBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavItem(
            icon: Icons.widgets,
            label: '基础组件',
          ),
          BottomNavItem(
            icon: Icons.extension,
            label: '进阶组件',
          ),
          BottomNavItem(
            icon: Icons.workspace_premium,
            label: '高级组件',
          ),
        ],
      ),
    );
  }

  // ================== AppBar 组件演示 ==================
  Widget _buildAppBarDemo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'AppBar 组件',
            subtitle: '自定义顶部导航栏样式',
          ),
          SizedBox(height: 20),
          // 基础 AppBar
          Text(
            '基础 AppBar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          YicoreAppBar(
            title: '页面标题',
            showBackButton: true,
            onBackPressed: () {
              Notifications.sonner(
                context,
                message: '点击了返回按钮',
              );
            },
          ),
          SizedBox(height: 24),
          // 带操作按钮的 AppBar
          Text(
            '带操作按钮的 AppBar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          YicoreAppBar(
            title: '设置',
            showBackButton: true,
            onBackPressed: () {
              Notifications.sonner(
                context,
                message: '点击了返回按钮',
              );
            },
            actions: [
              YicoreAppBarAction(
                icon: Icons.search,
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了搜索',
                  );
                },
              ),
              YicoreAppBarAction(
                icon: Icons.more_vert,
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了更多',
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 24),
          // 居中标题的 AppBar
          Text(
            '居中标题的 AppBar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          YicoreAppBar(
            title: '个人中心',
            centerTitle: true,
            showBackButton: true,
            onBackPressed: () {
              Notifications.sonner(
                context,
                message: '点击了返回按钮',
              );
            },
            actions: [
              YicoreAppBarAction(
                icon: Icons.edit,
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了编辑',
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 24),
          // 无返回按钮的 AppBar
          Text(
            '无返回按钮的 AppBar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          YicoreAppBar(
            title: '首页',
            showBackButton: false,
            actions: [
              YicoreAppBarAction(
                icon: Icons.notifications_outlined,
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了通知',
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 24),
          // 自定义标题的 AppBar
          Text(
            '自定义标题的 AppBar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          YicoreAppBar(
            titleWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 20, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  '收藏',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            showBackButton: true,
            onBackPressed: () {
              Notifications.sonner(
                context,
                message: '点击了返回按钮',
              );
            },
            actions: [
              YicoreAppBarAction(
                icon: Icons.share,
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了分享',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================== 切换控制器演示 ==================
  Widget _buildSegmentedControlDemo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: '切换控制器',
            subtitle: '分段控制器组件',
          ),
          SizedBox(height: 20),
          Text(
            '小尺寸（带边框）',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          SizedBox(height: 8),
          YicoreSegmentedControl(
            size: SegmentedControlSize.small,
            showBorder: true,
            items: [
              SegmentedItem(label: '类型', value: 'type'),
              SegmentedItem(label: '视图', value: 'view'),
              SegmentedItem(label: '示例', value: 'example'),
            ],
            selectedValue: _selectedSegmentSmall,
            onChanged: (value) {
              setState(() {
                _selectedSegmentSmall = value;
              });
              Notifications.sonner(
                context,
                message: '小尺寸：已切换到：${value == 'type' ? '类型' : value == 'view' ? '视图' : '示例'}',
              );
            },
          ),
          SizedBox(height: 16),
          Text(
            '中等尺寸（无边框）',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          SizedBox(height: 8),
          YicoreSegmentedControl(
            size: SegmentedControlSize.medium,
            showBorder: false,
            items: [
              SegmentedItem(label: '类型', value: 'type'),
              SegmentedItem(label: '视图', value: 'view'),
              SegmentedItem(label: '示例', value: 'example'),
            ],
            selectedValue: _selectedSegment,
            onChanged: (value) {
              setState(() {
                _selectedSegment = value;
              });
              Notifications.sonner(
                context,
                message: '中等尺寸：已切换到：${value == 'type' ? '类型' : value == 'view' ? '视图' : '示例'}',
              );
            },
          ),
          SizedBox(height: 16),
          Text(
            '大尺寸（带边框）',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          SizedBox(height: 8),
          YicoreSegmentedControl(
            size: SegmentedControlSize.large,
            showBorder: true,
            items: [
              SegmentedItem(label: '类型', value: 'type'),
              SegmentedItem(label: '视图', value: 'view'),
              SegmentedItem(label: '示例', value: 'example'),
            ],
            selectedValue: _selectedSegmentLarge,
            onChanged: (value) {
              setState(() {
                _selectedSegmentLarge = value;
              });
              Notifications.sonner(
                context,
                message: '大尺寸：已切换到：${value == 'type' ? '类型' : value == 'view' ? '视图' : '示例'}',
              );
            },
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              '当前选择（中等）：${_selectedSegment == 'type' ? '类型' : _selectedSegment == 'view' ? '视图' : '示例'}',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== 设置区块演示 ==================
  Widget _buildSettingsBlockDemo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SettingsBlock(
            title: '通知设置',
            children: [
              SettingsItem.switch_(
                title: '推送通知',
                description: '接收应用推送通知',
                value: _switchValue,
                onChanged: (val) => setState(() => _switchValue = val),
              ),
              SettingsItem.switch_(
                title: '声音提醒',
                description: '开启声音提醒',
                value: _switchValue,
                onChanged: (val) => setState(() => _switchValue = val),
              ),
              SettingsItem.switch_(
                title: '夜间免打扰',
                description: '22:00-8:00 期间不接收通知',
                value: false,
                onChanged: (_) {},
                enabled: false,  // 禁用示例
              ),
              SettingsItem.slider(
                title: '音量大小',
                description: '调整通知音量',
                value: _sliderValue,
                min: 0,
                max: 100,
                onChanged: (val) => setState(() => _sliderValue = val),
              ),
              SettingsItem.slider(
                title: '震动强度',
                description: '调整震动强度（功能暂未开放）',
                value: 50,
                min: 0,
                max: 100,
                onChanged: (_) {},
                enabled: false,  // 禁用示例
              ),
              SettingsItem.segmented(
                title: '通知样式',
                description: '选择通知显示方式',
                items: [
                  SegmentedItem(label: '横幅', value: 'banner'),
                  SegmentedItem(label: '弹窗', value: 'popup'),
                  SegmentedItem(label: '静音', value: 'silent'),
                ],
                selectedValue: _notificationStyle,
                onChanged: (value) {
                  setState(() {
                    _notificationStyle = value;
                  });
                },
              ),
            ],
        ),
        SizedBox(height: 20),
          SettingsBlock(
            title: '账户设置',
            children: [
              SettingsItem.value(
                title: '用户名',
                description: '当前登录用户名',
                value: 'user123',
                onTap: () {
                  Notifications.sonner(
                    context,
                    title: '用户名',
                    message: '点击了用户名设置项',
                  );
                },
              ),
              SettingsItem.value(
                title: '语言',
                value: '简体中文',
                onTap: () {
                  Notifications.sonner(
                    context,
                    title: '语言设置',
                    message: '点击了语言设置项',
                  );
                },
              ),
              SettingsItem.value(
                title: '会员等级',
                description: '当前会员等级',
                value: 'VIP',
                enabled: false,  // 禁用示例
              ),
              SettingsItem.text(
                title: '关于我们',
                description: '查看应用信息和版本',
                onTap: () {
                  YicoreAlert.show(
                    context,
                    title: '关于我们',
                    message: 'YIClass v2.1.0\n\n一个课表管理工具，支持多种课程表格式导入，支持多种平台。',
                  );
                },
                showArrow: true,
              ),
              SettingsItem.text(
                title: '高级功能',
                description: '此功能需要会员权限',
                enabled: false,  // 禁用示例
                showArrow: true,
              ),
              SettingsItem.text(
                title: '退出登录',
                description: '退出当前账户',
                onTap: () {
                  YicoreConfirm.show(
                    context,
                    title: '退出登录',
                    message: '确定要退出登录吗？',
                    onConfirm: () {
                      Notifications.sonner(
                        context,
                        title: '已退出',
                        message: '您已成功退出登录',
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================== 滑块组件演示 ==================
  Widget _buildSliderDemo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: '滑块组件',
            subtitle: '自定义滑块样式',
          ),
          SizedBox(height: 20),
          YicoreSlider(
            value: _sliderValue,
            min: 0,
            max: 100,
            onChanged: (val) => setState(() => _sliderValue = val),
          ),
          SizedBox(height: 12),
          Center(
            child: Text(
              '当前值: ${_sliderValue.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== 卡片组件演示 ==================
  Widget _buildCardDemo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: '卡片组件',
            subtitle: '自定义卡片样式',
          ),
          SizedBox(height: 20),
          YicoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '卡片标题',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '这是一个卡片组件的示例内容。卡片可以包含任意内容，支持标题、描述、图片等多种元素。',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    YicoreSwitch(
                      value: _switchValue,
                      onChanged: (val) => setState(() => _switchValue = val),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '启用选项',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== 按钮组件演示 ==================
  Widget _buildButtonDemo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          _SectionTitle(
            title: '按钮组件',
            subtitle: '自定义按钮样式示例',
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: [
              YicoreButton(
                text: '主要按钮',
                onPressed: () {},
              ),
              YicoreButton(
                text: '次要按钮',
                isSecondary: true,
                onPressed: () {},
              ),
              YicoreButton(
                text: '轮廓按钮',
                isOutlined: true,
                onPressed: () {},
              ),
              YicoreButton(
                text: '加载中',
                isLoading: true,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================== 输入框组件演示 ==================
  Widget _buildTextFieldDemo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: '输入框组件',
            subtitle: '自定义输入框样式',
          ),
          SizedBox(height: 20),
          YicoreTextField(
            labelText: '用户名',
            hintText: '请输入用户名',
          ),
          SizedBox(height: 16),
          YicoreTextField(
            labelText: '禁用状态',
            hintText: '此输入框已禁用',
            enabled: false,
          ),
          SizedBox(height: 16),
          YicoreTextField(
            labelText: '错误状态',
            hintText: '请输入内容',
            errorText: '此字段为必填项',
          ),
        ],
      ),
    );
  }

  // ================== 下拉组件演示 ==================
  Widget _buildDropdownDemo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: '下拉组件',
            subtitle: '自定义下拉选择样式',
          ),
          SizedBox(height: 20),
          YicoreDropdown<String>(
            labelText: '选择语言',
            hintText: '请选择语言',
            value: _selectedLanguage,
            items: [
              YicoreDropdownItem(
                value: 'zh',
                label: '简体中文',
                icon: Icons.language,
              ),
              YicoreDropdownItem(
                value: 'en',
                label: 'English',
                icon: Icons.language,
              ),
              YicoreDropdownItem(
                value: 'ja',
                label: '日本語',
                icon: Icons.language,
              ),
              YicoreDropdownItem(
                value: 'ko',
                label: '한국어',
                icon: Icons.language,
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value;
              });
              Notifications.sonner(
                context,
                message: '已选择: ${value == 'zh' ? '简体中文' : value == 'en' ? 'English' : value == 'ja' ? '日本語' : '한국어'}',
              );
            },
          ),
          SizedBox(height: 16),
          YicoreDropdown<String>(
            labelText: '选择国家',
            hintText: '请选择国家',
            value: _selectedCountry,
            items: [
              YicoreDropdownItem(
                value: 'cn',
                label: '中国',
                icon: Icons.flag,
              ),
              YicoreDropdownItem(
                value: 'us',
                label: '美国',
                icon: Icons.flag,
              ),
              YicoreDropdownItem(
                value: 'jp',
                label: '日本',
                icon: Icons.flag,
              ),
              YicoreDropdownItem(
                value: 'kr',
                label: '韩国',
                icon: Icons.flag,
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCountry = value;
              });
              Notifications.sonner(
                context,
                message: '已选择国家',
              );
            },
          ),
          SizedBox(height: 16),
          YicoreDropdown<String>(
            labelText: '禁用状态',
            hintText: '此下拉框已禁用',
            value: 'zh',
            enabled: false,
            items: [
              YicoreDropdownItem(
                value: 'zh',
                label: '简体中文',
              ),
              YicoreDropdownItem(
                value: 'en',
                label: 'English',
              ),
            ],
            onChanged: (value) {},
          ),
          SizedBox(height: 16),
          YicoreDropdown<String>(
            labelText: '错误状态',
            hintText: '请选择选项',
            errorText: '此字段为必填项',
            items: [
              YicoreDropdownItem(
                value: 'option1',
                label: '选项1',
              ),
              YicoreDropdownItem(
                value: 'option2',
                label: '选项2',
              ),
            ],
            onChanged: (value) {},
          ),
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
            subtitle: 'Alert、Confirm、Modal、课表管理',
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

  // ================== 导航组件演示 ==================
  Widget _buildNavigationDemo() {
    int demoIndex = 0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: '底部导航栏',
            subtitle: '自定义底部导航样式演示',
          ),
          SizedBox(height: 20),
          StatefulBuilder(
            builder: (context, setDemoState) {
              return YicoreBottomNavigationBar(
                currentIndex: demoIndex,
                onTap: (index) {
                  setDemoState(() {
                    demoIndex = index;
                  });
                },
                items: [
                  BottomNavItem(
                    icon: Icons.home,
                    label: '首页',
                  ),
                  BottomNavItem(
                    icon: Icons.calendar_today,
                    label: '课表',
                  ),
                  BottomNavItem(
                    icon: Icons.settings,
                    label: '设置',
                  ),
                ],
              );
            },
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

