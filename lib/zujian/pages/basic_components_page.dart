import 'package:flutter/material.dart';
import '../components.dart';
import '../cards.dart';
import '../appbar.dart';
import '../segmented_control.dart';
import '../settingscard.dart';
import '../dropdown.dart';
import '../notifications.dart';
import '../dialogs.dart';

// ================== 基础组件页面 ==================
class BasicComponentsPage extends StatefulWidget {
  @override
  _BasicComponentsPageState createState() => _BasicComponentsPageState();
}

class _BasicComponentsPageState extends State<BasicComponentsPage> {
  bool _switchValue = false;
  double _sliderValue = 50.0;
  String? _selectedLanguage;
  String? _selectedCountry;
  String _selectedSegment = 'type';
  String _selectedSegmentSmall = 'type';
  String _selectedSegmentLarge = 'type';
  String _notificationStyle = 'banner';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
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
          SizedBox(height: 100),
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
                enabled: false,
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
                enabled: false,
              ),
              SettingsItem.segmented(
                title: '通知样式',
                description: '选择通知显示方式',
                items: [
                  SegmentedItem(label: '横幅', value: 'banner'),
                  SegmentedItem(label: '弹窗', value: 'popup'),
                  SegmentedItem(label: '静音窗口', value: 'silent'),
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
                enabled: false,
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
                enabled: false,
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
          Text(
            '文字按钮',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: [
              YicoreButton(
                text: '主要按钮',
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了主要按钮',
                  );
                },
              ),
              YicoreButton(
                text: '次要按钮',
                isSecondary: true,
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了次要按钮',
                  );
                },
              ),
              YicoreButton(
                text: '轮廓按钮',
                isOutlined: true,
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了轮廓按钮',
                  );
                },
              ),
              YicoreButton(
                text: '加载中',
                isLoading: true,
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            '图标按钮（有边框）',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: [
              YicoreIconButton(
                icon: Icons.favorite,
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了收藏',
                  );
                },
              ),
              YicoreIconButton(
                icon: Icons.share,
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了分享',
                  );
                },
              ),
              YicoreIconButton(
                icon: Icons.delete,
                iconColor: Colors.red,
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了删除',
                  );
                },
              ),
              YicoreIconButton(
                icon: Icons.lock,
                onPressed: null,
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            '图标按钮（无边框）',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: [
              YicoreIconButton(
                icon: Icons.favorite,
                showBorder: false,
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了收藏',
                  );
                },
              ),
              YicoreIconButton(
                icon: Icons.share,
                showBorder: false,
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了分享',
                  );
                },
              ),
              YicoreIconButton(
                icon: Icons.delete,
                iconColor: Colors.red,
                showBorder: false,
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了删除',
                  );
                },
              ),
              YicoreIconButton(
                icon: Icons.lock,
                showBorder: false,
                onPressed: null,
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

