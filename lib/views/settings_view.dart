import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../states/timetable_state.dart';
import '../states/view_state.dart';
import '../components/start_date_picker.dart';
import './time_settings_page.dart';
import './license_page.dart' as license;
import './ai_config_page.dart';
import '../components/bottom_nav_bar.dart';
import '../data/data_constants.dart';
import '../components/timetable_management_dialog.dart';
import '../components/advanced_features_dialog.dart';
import './ai_import_page.dart';
import '../utils/feedback_utils.dart';
import '../services/settings_service.dart';
import '../services/file_service.dart';
import '../data/timetable.dart';
import '../data/class_time.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 局部状态管理，避免全局广播冲突
  int _localTotalWeeks = DataConstants.defaultTotalWeeks;
  int _localMaxPeriods = DataConstants.defaultMaxPeriods;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // 初始化局部状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocalState();
    });
  }

  void _initializeLocalState() {
    final timetableState = Provider.of<TimetableState>(context, listen: false);
    final viewState = Provider.of<ViewState>(context, listen: false);
    
    final timetable = timetableState.current;
    if (timetable != null && !_isInitialized) {
      setState(() {
        _localTotalWeeks = timetable.settings.totalWeeks;
        _localMaxPeriods = (timetable.settings.maxPeriods) > 0
            ? timetable.settings.maxPeriods
            : DataConstants.defaultMaxPeriods;
        _isInitialized = true;
      });
      
      // 确保ViewState也正确加载了设置
      viewState.loadFromTimetable(timetable);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timetableState = Provider.of<TimetableState>(context, listen: false);
    final viewState = Provider.of<ViewState>(context, listen: false);
    
    final timetable = timetableState.current;
    if (timetable == null) return const SizedBox();

    final selectedView = viewState.selectedView;
    final showWeekend = timetable.settings.showWeekend;
    
    // 统一使用局部状态，避免混乱
    final totalWeeks = _localTotalWeeks;
    final maxPeriods = _localMaxPeriods;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: const ListTileThemeData(
            visualDensity: VisualDensity.compact,
          ),
        ),
        child: ListView(
          children: [
          // 基础功能分区
          _buildSectionCard(
            title: '基础功能',
            icon: Icons.settings,
            children: [
              _buildViewModeTile(selectedView, viewState, timetable, timetableState),
              _buildStartDateTile(),
              _buildTotalWeeksTile(timetable, totalWeeks, timetableState),
              _buildShowWeekendTile(showWeekend, viewState, timetable, timetableState),
              _buildMaxPeriodsTile(maxPeriods, timetableState),
              _buildTimeSettingsTile(),
            ],
          ),
          
          // 课表管理分区
          _buildSectionCard(
            title: '课表管理',
            icon: Icons.import_export,
            children: [
              _buildImportTimetableTile(),
              _buildEduSystemImportTile(),
              _buildAiImportTile(),
              _buildExportTimetableTile(),
              _buildTimetableManagementTile(),
            ],
          ),
          
          // 扩展功能分区
          _buildSectionCard(
            title: '扩展功能',
            icon: Icons.extension,
            children: [
              _buildThemeSettingsTile(),
              _buildNotificationSettingsTile(),
              _buildWidgetSettingsTile(),
              _buildSyncSettingsTile(),
            ],
          ),
          
          // 高级功能分区
          _buildSectionCard(
            title: '高级功能',
            icon: Icons.build,
            children: [
              _buildAdvancedFeaturesToggleTile(),
              _buildScriptRepositoryTile(),
              _buildAiSettingsTile(),
              _buildDeveloperOptionsTile(),
            ],
          ),
          
          // 关于我们分区
          _buildSectionCard(
            title: '关于我们',
            icon: Icons.info,
            children: [
              _buildAboutTile(),
              _buildHelpTile(),
              _buildFeedbackTile(),
              _buildPrivacyPolicyTile(),
            ],
          ),
        ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTabChanged: (index) {
          if (index != 2) {
            final views = ['周视图', '日视图'];
            final viewState = Provider.of<ViewState>(context, listen: false);
            viewState.changeView(views[index]);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  /// 构建分区卡片
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // 分区标题放在卡片外面
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
        // 白色卡片内容
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          elevation: 2,
          color: Colors.white,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  /// 构建视图模式设置
  Widget _buildViewModeTile(String selectedView, ViewState viewState, Timetable timetable, TimetableState timetableState) {
    return ListTile(
      title: const Text('视图模式'),
      subtitle: Text('当前: $selectedView'),
            trailing: ToggleButtons(
              borderRadius: BorderRadius.circular(8),
              borderColor: Colors.grey,
              selectedColor: Colors.white,
              fillColor: Colors.blue.shade400,
              color: Colors.black87,
              isSelected: [
                selectedView == '周视图',
                selectedView == '日视图',
                selectedView == '列表视图'
              ],
              splashColor: Colors.transparent,
              onPressed: (index) async {
                if (!mounted) return;
                final view = index == 0 ? '周视图' : index == 1 ? '日视图' : '列表视图';
                viewState.changeView(view);
                if (mounted) setState(() {});
                Navigator.pop(context);
              },
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('周')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('日')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('列表')),
              ],
            ),
    );
  }

  /// 构建开始日期设置
  Widget _buildStartDateTile() {
    return const StartDatePicker();
  }

  /// 构建总周数设置
  Widget _buildTotalWeeksTile(Timetable timetable, int totalWeeks, TimetableState timetableState) {
    return ListTile(
      title: const Text('总周数'),
            subtitle: Builder(
              builder: (context) {
                final startDate = timetable.settings.startDate;
                final firstWeek = DateFormat('MM/dd').format(startDate);
                final lastWeek = DateFormat('MM/dd').format(
                  startDate.add(Duration(days: 7 * (totalWeeks - 1)))
                );
                return Text('$firstWeek - $lastWeek');
              },
            ),
            trailing: SizedBox(
        width: 120,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.blue.shade400,
                  inactiveTrackColor: Colors.blue.shade100,
                  thumbColor: Colors.blue.shade400,
                  overlayColor: Colors.blue.shade100.withOpacity(0.2),
                  valueIndicatorColor: Colors.blue.shade400,
                ),
                child: Slider(
                  value: totalWeeks.toDouble(),
                  min: DataConstants.minTotalWeeks.toDouble(),
                  max: DataConstants.maxTotalWeeks.toDouble(),
                  divisions: DataConstants.maxTotalWeeks - DataConstants.minTotalWeeks,
                  label: '$totalWeeks',
                  onChanged: (value) {
                    setState(() {
                      _localTotalWeeks = value.round();
                    });
                  },
                  onChangeEnd: (value) async {
                    if (mounted) {
                      timetable.settings.totalWeeks = value.round();
                      await timetableState.put(timetable);
                    }
                  },
                ),
              ),
            ),
    );
  }

  /// 构建显示周末设置
  Widget _buildShowWeekendTile(bool showWeekend, ViewState viewState, Timetable timetable, TimetableState timetableState) {
    return SwitchListTile(
      title: const Text('显示周末'),
      subtitle: const Text('在课程表中显示周六和周日'),
            value: showWeekend,
            onChanged: (value) async {
              timetable.settings.showWeekend = value;
              await timetableState.put(timetable);
              viewState.loadFromTimetable(timetable);
              if (mounted) setState(() {});
            },
    );
  }

  /// 构建最大节数设置
  Widget _buildMaxPeriodsTile(int maxPeriods, TimetableState timetableState) {
    return ListTile(
      title: const Text('课程节数'),
            subtitle: Text('当前最大节数: $maxPeriods'),
            trailing: SizedBox(
        width: 120,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.blue.shade400,
                  inactiveTrackColor: Colors.blue.shade100,
                  thumbColor: Colors.blue.shade400,
                  overlayColor: Colors.blue.shade100.withOpacity(0.2),
                  valueIndicatorColor: Colors.blue.shade400,
                ),
                child: Slider(
                  value: maxPeriods.toDouble(),
                  min: DataConstants.minMaxPeriods.toDouble(),
                  max: DataConstants.maxMaxPeriods.toDouble(),
                  divisions: DataConstants.maxMaxPeriods - DataConstants.minMaxPeriods,
                  label: '$maxPeriods',
                  onChanged: (value) {
                    setState(() {
                      _localMaxPeriods = value.round();
                    });
                  },
                  onChangeEnd: (value) async {
                    if (!mounted) return;
                    final timetable = timetableState.current;
                    if (timetable == null) return;

                    final newMax = value.round();
                    timetable.settings.maxPeriods = newMax;
                    final existing = {for (final ct in timetable.settings.classTimes) ct.period: ct};

                    final List<ClassTime> updated = [];
                    for (int i = 1; i <= newMax; i++) {
                      if (existing.containsKey(i)) {
                        updated.add(existing[i]!);
                      } else {
                        final def = DataConstants.defaultPeriodTimes[i.toString()] ?? '08:00-08:45';
                        final parts = def.split('-');
                        final ct = ClassTime()
                          ..period = i
                          ..startTime = parts.isNotEmpty ? parts.first : '08:00'
                          ..endTime = parts.length > 1 ? parts.last : '08:45';
                        updated.add(ct);
                      }
                    }

                    timetable.settings.classTimes = updated;
                    await timetableState.put(timetable);
                    if (mounted) {
                      setState(() {
                        _localMaxPeriods = newMax;
                      });
                    }
                  },
                ),
              ),
            ),
    );
  }

  /// 构建时间设置
  Widget _buildTimeSettingsTile() {
    return ListTile(
      title: const Text('设置上课时间'),
      subtitle: const Text('自定义每节课的时间'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TimeSettingsPage(),
                ),
              );
              if (mounted) setState(() {});
            },
    );
  }

  // ==================== 课表管理分区 ====================

  /// 构建课表管理
  Widget _buildTimetableManagementTile() {
    return Consumer<TimetableState>(
      builder: (context, timetableState, child) {
        return ListTile(
          title: const Text('课表管理'),
          subtitle: Text('当前: ${timetableState.current?.name ?? '无'}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showTimetableManagementDialog(timetableState);
          },
        );
      },
    );
  }

  /// 显示课表管理对话框
  void _showTimetableManagementDialog(TimetableState timetableState) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => const TimetableManagementDialog(),
    );
  }

  /// 构建导入课表
  Widget _buildImportTimetableTile() {
    return ListTile(
      title: const Text('导入课表'),
      subtitle: const Text('从JSON文件导入课表数据'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final ok = await FileService.importAndSave();
        if (!mounted) return;
        if (ok) {
          await Provider.of<TimetableState>(context, listen: false).reload();
          FeedbackUtils.show(context, '导入成功');
        } else {
          FeedbackUtils.show(context, '已取消或导入失败');
        }
      },
    );
  }

  /// 构建教务系统导入
  Widget _buildEduSystemImportTile() {
    return FutureBuilder<bool>(
      future: SettingsService.instance.isAdvancedFeaturesEnabled(),
      builder: (context, snapshot) {
        final advancedEnabled = snapshot.data ?? false;
        
        return ListTile(
          title: const Text('教务系统导入'),
          subtitle: const Text('从学校教务系统导入课表'),
          trailing: const Icon(Icons.chevron_right),
          enabled: advancedEnabled,
          onTap: advancedEnabled ? () {
            FeedbackUtils.show(context, '教务系统导入功能暂未实现');
          } : null,
        );
      },
    );
  }

  /// 构建AI导入
  Widget _buildAiImportTile() {
    return FutureBuilder<bool>(
      future: SettingsService.instance.isAdvancedFeaturesEnabled(),
      builder: (context, snapshot) {
        final advancedEnabled = snapshot.data ?? false;
        
        return ListTile(
          title: const Text('AI智能导入'),
          subtitle: const Text('使用AI识别图片或文档中的课表信息'),
          trailing: const Icon(Icons.chevron_right),
          enabled: advancedEnabled,
          onTap: advancedEnabled ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AIImportPage(),
              ),
            );
          } : null,
        );
      },
    );
  }

  /// 构建导出课表
  Widget _buildExportTimetableTile() {
    return ListTile(
      title: const Text('导出课表'),
      subtitle: const Text('将课表数据导出为JSON文件'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final timetableState = Provider.of<TimetableState>(context, listen: false);
        final timetable = timetableState.current;
        if (timetable == null) {
          FeedbackUtils.show(context, '请先选择一个课表');
          return;
        }
        final pathOrName = await FileService.exportTimetable(timetable);
        if (!mounted) return;
        if (pathOrName != null) {
          FeedbackUtils.show(context, '导出成功: $pathOrName');
        } else {
          FeedbackUtils.show(context, '已取消或当前平台不支持');
        }
      },
    );
  }


  // ==================== 扩展功能分区 ====================

  /// 构建主题设置
  Widget _buildThemeSettingsTile() {
    return ListTile(
      title: const Text('主题设置'),
      subtitle: const Text('自定义应用外观和颜色'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showComingSoonDialog('主题设置功能');
      },
    );
  }

  /// 构建通知设置
  Widget _buildNotificationSettingsTile() {
    return ListTile(
      title: const Text('通知设置'),
      subtitle: const Text('课程提醒和通知管理'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showComingSoonDialog('通知设置功能');
      },
    );
  }

  /// 构建小组件设置
  Widget _buildWidgetSettingsTile() {
    return ListTile(
      title: const Text('桌面小组件'),
      subtitle: const Text('在主屏幕显示课程信息'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showComingSoonDialog('桌面小组件功能');
      },
    );
  }

  /// 构建同步设置
  Widget _buildSyncSettingsTile() {
    return ListTile(
      title: const Text('数据同步'),
      subtitle: const Text('多设备间同步课表数据'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showComingSoonDialog('数据同步功能');
      },
    );
  }

  // ==================== 高级功能分区 ====================

  /// 构建高级功能总开关
  Widget _buildAdvancedFeaturesToggleTile() {
    return FutureBuilder<bool>(
      future: SettingsService.instance.isAdvancedFeaturesEnabled(),
      builder: (context, snapshot) {
        final advancedEnabled = snapshot.data ?? false;
        
        return SwitchListTile(
          title: const Text('高级功能'),
          subtitle: Text(advancedEnabled ? '已启用高级功能' : '启用高级功能'),
          value: advancedEnabled,
          onChanged: (value) async {
            if (value) {
              // 打开开关前显示确认弹窗
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => const AdvancedFeaturesDialog(),
              );
              if (confirmed != true) {
                return; // 用户取消，不执行开关操作
              }
            }
            
            // 使用SettingsService更新全局设置
            await SettingsService.instance.updateAdvancedFeaturesEnabled(value);
            if (!mounted) return;
            setState(() {});
            if (!mounted) return;
            FeedbackUtils.show(context, value ? '高级功能已启用' : '高级功能已禁用');
          },
        );
      },
    );
  }

  /// 构建脚本仓库
  Widget _buildScriptRepositoryTile() {
    return FutureBuilder<bool>(
      future: SettingsService.instance.isAdvancedFeaturesEnabled(),
      builder: (context, snapshot) {
        final advancedEnabled = snapshot.data ?? false;
        
        return ListTile(
          title: const Text('脚本仓库'),
          subtitle: const Text('管理和安装自定义脚本'),
          trailing: const Icon(Icons.chevron_right),
          enabled: advancedEnabled,
          onTap: advancedEnabled ? () {
            FeedbackUtils.show(context, '脚本仓库功能暂未实现');
          } : null,
        );
      },
    );
  }

  /// 构建AI设置
  Widget _buildAiSettingsTile() {
    return FutureBuilder<bool>(
      future: SettingsService.instance.isAdvancedFeaturesEnabled(),
      builder: (context, snapshot) {
        final advancedEnabled = snapshot.data ?? false;
        
        return ListTile(
          title: const Text('AI导入配置'),
          subtitle: const Text('配置AI服务用于课程表识别'),
          trailing: const Icon(Icons.chevron_right),
          enabled: advancedEnabled,
          onTap: advancedEnabled ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AIConfigPage(),
              ),
            );
          } : null,
        );
      },
    );
  }

  /// 构建开发者选项
  Widget _buildDeveloperOptionsTile() {
    return ListTile(
      title: const Text('开发者选项'),
      subtitle: const Text('高级调试和开发工具'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showComingSoonDialog('开发者选项');
      },
    );
  }

  // ==================== 关于我们分区 ====================

  /// 构建关于页面
  Widget _buildAboutTile() {
    return ListTile(
      title: const Text('关于应用'),
      subtitle: const Text('版本信息和应用详情'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAboutDialog,
    );
  }

  /// 构建帮助页面
  Widget _buildHelpTile() {
    return ListTile(
      title: const Text('使用帮助'),
      subtitle: const Text('常见问题和使用指南'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showComingSoonDialog('使用帮助功能');
      },
    );
  }

  /// 构建反馈页面
  Widget _buildFeedbackTile() {
    return ListTile(
      title: const Text('意见反馈'),
      subtitle: const Text('提交建议和问题报告'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showComingSoonDialog('意见反馈功能');
      },
    );
  }

  /// 构建开源许可证
  Widget _buildPrivacyPolicyTile() {
    return ListTile(
      title: const Text('开源许可证'),
      subtitle: const Text('查看项目使用的开源许可证'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const license.OpenSourceLicensePage(),
          ),
        );
      },
    );
  }

  /// 显示即将推出对话框
  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('功能开发中'),
        content: Text('$featureName 正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog() {
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('关于'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.school, size: 48),
                SizedBox(height: 8),
                Text('课程表应用', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('版本: v1.0.2'),
                Text('© 2025 wykwe'),
                SizedBox(height: 16),
                Text('这是一个用于查看课程表的应用，支持每日、每周、列表等视图，并可设置课程周数、开课时间、是否显示周末等。'),
                SizedBox(height: 8),
                Text('开发者: wykwe'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}