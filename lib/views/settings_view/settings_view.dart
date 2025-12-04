import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../states/timetable_state.dart';
import '../../states/view_state.dart';
import '../../data/data_constants.dart';
import '../../components/feedback/timetable_management_dialog.dart';
import '../../services/settings_service.dart';
import '../../services/file_service.dart';
import '../../data/timetable.dart';
import '../../components/layout/settingscard.dart';
import '../../components/inputs/datepicker.dart';
import '../../components/feedback/notifications.dart';
import '../../routes/route_utils.dart';
import '../../components/feedback/dialogs.dart';
import '../../components/layout/appbar.dart';
import '../../components/inputs/segmented_control.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 局部状态管理，避免全局广播冲突
  int _localTotalWeeks = DataConstants.defaultTotalWeeks;
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
    
    final timetable = timetableState.current;
    if (timetable != null && !_isInitialized) {
      setState(() {
        _localTotalWeeks = timetable.settings.totalWeeks;
        _isInitialized = true;
      });
      // ViewState 已在 main.dart 启动时初始化，此处无需重复加载
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以支持 AutomaticKeepAliveClientMixin
    
    final timetableState = Provider.of<TimetableState>(context, listen: false);
    final viewState = Provider.of<ViewState>(context, listen: false);
    
    final timetable = timetableState.current;
    if (timetable == null) return const SizedBox();

    final selectedView = viewState.selectedView;
    final showWeekend = timetable.settings.showWeekend;
    
    // 统一使用局部状态，避免混乱
    final totalWeeks = _localTotalWeeks;

    return Scaffold(
      appBar: YicoreAppBar(
        title: '设置',
        centerTitle: true,
        onBackPressed: () {
          viewState.changeView('周视图');
        },
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        children: [
          // 基础功能分区
          SettingsBlock(
            title: '基础功能',
            children: [
              _buildViewModeTile(selectedView, viewState, timetable, timetableState),
              _buildStartDateTile(),
              _buildTotalWeeksTile(timetable, totalWeeks, timetableState),
              _buildShowWeekendTile(showWeekend, viewState, timetable, timetableState),
              _buildTimeSettingsTile(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 课表管理分区
          SettingsBlock(
            title: '课表管理',
            children: [
              _buildImportTimetableTile(),
              _buildEduSystemImportTile(),
              _buildAiImportTile(),
              _buildExportTimetableTile(),
              _buildTimetableManagementTile(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 扩展功能分区
          SettingsBlock(
            title: '扩展功能',
            children: [
              _buildAdvancedFeaturesTile(),
              _buildThemeSettingsTile(),
              _buildNotificationSettingsTile(),
              _buildWidgetSettingsTile(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 关于我们分区
          SettingsBlock(
            title: '关于我们',
            children: [
              _buildAboutTile(),
              _buildHelpTile(),
              _buildPrivacyPolicyTile(),
            ],
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 构建视图模式设置
  Widget _buildViewModeTile(String selectedView, ViewState viewState, Timetable timetable, TimetableState timetableState) {
    // 在设置页面时，锁定显示为"周视图"，避免重复计算滑块位置
    // 这样可以减少不必要的UI计算，提升性能
    const lockedView = '周视图';

    return SettingsItem.segmented(
      title: '视图模式',
      description: '切换课表显示方式',
      items: const [
        SegmentedItem(label: '周视图', value: '周视图'),
        SegmentedItem(label: '日视图', value: '日视图'),
        SegmentedItem(label: '列表', value: '列表视图'),
      ],
      selectedValue: lockedView,
      onChanged: (value) {
        if (!mounted) return;
        if (value == '列表视图') {
          // 跳转到列表视图页面
          RouteUtils.pushListView(context);
        } else {
          // 切换主界面视图
          viewState.changeView(value);
        }
      },
      inBlock: true,
    );
  }

  /// 构建开始日期设置
  Widget _buildStartDateTile() {
    final timetableState = Provider.of<TimetableState>(context);
    final timetable = timetableState.current;
    if (timetable == null) return const SizedBox();

    final dateStr = DateFormat('yyyy-MM-dd').format(timetable.settings.startDate);

    return SettingsItem.value(
      title: '开始上课日期',
      value: dateStr,
      showArrow: true,
      onTap: () async {
        final currentDate = timetable.settings.startDate;
        
        final picked = await YicoreDatePicker.show(
          context: context,
          initialDate: currentDate,
          firstDate: DateTime(2020, 1, 1),
          lastDate: DateTime(2099, 12, 31),
        );

        if (picked != null && mounted) {
          try {
            timetable.settings.startDate = picked;
            await timetableState.put(timetable);
            
            if (mounted) {
              Notifications.sonner(context, message: '开始日期已设置为 ${DateFormat('yyyy-MM-dd').format(picked)}');
              setState(() {}); // 刷新显示
            }
          } catch (e) {
            if (mounted) {
              Notifications.sonner(context, title: '保存失败', message: e.toString());
            }
          }
        }
      },
    );
  }
  
  String _formatDateRange(DateTime startDate, int weeks) {
    final firstWeek = DateFormat('MM/dd').format(startDate);
    final lastWeek = DateFormat('MM/dd').format(
      startDate.add(Duration(days: 7 * (weeks - 1)))
    );
    return '$firstWeek - $lastWeek';
  }

  /// 构建总周数设置
  Widget _buildTotalWeeksTile(Timetable timetable, int totalWeeks, TimetableState timetableState) {
    return SettingsItem.slider(
      title: '总周数 ($totalWeeks周)',
      description: _formatDateRange(timetable.settings.startDate, totalWeeks),
      value: totalWeeks.toDouble(),
      min: DataConstants.minTotalWeeks.toDouble(),
      max: DataConstants.maxTotalWeeks.toDouble(),
      onChanged: (value) {
        setState(() {
          _localTotalWeeks = value.round();
        });
        
        // 延迟保存以避免频繁写入
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mounted && _localTotalWeeks == value.round()) {
            timetable.settings.totalWeeks = value.round();
            await timetableState.put(timetable);
          }
        });
      },
    );
  }

  /// 构建显示周末设置
  Widget _buildShowWeekendTile(bool showWeekend, ViewState viewState, Timetable timetable, TimetableState timetableState) {
    return SettingsItem.switch_(
      title: '显示周末',
      description: '在课程表中显示周六和周日',
      value: showWeekend,
      onChanged: (value) async {
        timetable.settings.showWeekend = value;
        await timetableState.put(timetable);
        if (mounted) setState(() {});
      },
    );
  }


  /// 构建时间设置
  Widget _buildTimeSettingsTile() {
    return SettingsItem.value(
      title: '上课时间',
      description: '自定义每节课的开始和结束时间',
      value: '点击设置',
      showArrow: true,
      onTap: () async {
        await RouteUtils.pushTimeSettings(context);
        if (mounted) setState(() {});
      },
    );
  }

  // ==================== 课表管理分区 ====================

  /// 构建课表管理
  Widget _buildTimetableManagementTile() {
    return Consumer<TimetableState>(
      builder: (context, timetableState, child) {
        return SettingsItem.value(
          title: '课表管理',
          description: '创建、切换、删除课表',
          value: timetableState.current?.name ?? '无',
          showArrow: true,
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

    TimetableManagementDialog.show(context);
  }

  /// 构建导入课表
  Widget _buildImportTimetableTile() {
    return SettingsItem.text(
      title: '导入课表',
      description: '从JSON文件导入课表数据',
      showArrow: true,
      onTap: () async {
        final ok = await FileService.importAndSave();
        if (!mounted) return;
        if (ok) {
          final timetableState = Provider.of<TimetableState>(context, listen: false);
          await timetableState.reload();
          if (!mounted) return;
          Notifications.sonner(context, message: '导入成功');
        } else {
          Notifications.sonner(context, message: '已取消或导入失败');
        }
      },
    );
  }

  /// 构建教务系统导入
  Widget _buildEduSystemImportTile() {
    return FutureBuilder<List<bool>>(
      future: Future.wait([
        SettingsService.instance.isAdvancedFeaturesEnabled(),
        SettingsService.instance.isEduImportEnabled(),
      ]),
      builder: (context, snapshot) {
        final results = snapshot.data ?? [false, false];
        final advancedEnabled = results[0];
        final eduEnabled = results[1];
        final visible = advancedEnabled && eduEnabled;
        
        if (!visible) return const SizedBox.shrink();
        
        return SettingsItem.text(
          title: '教务系统导入',
          description: '从学校教务系统导入课表',
          showArrow: true,
          onTap: () {
            RouteUtils.pushSchoolSelect(context);
          },
        );
      },
    );
  }

  /// 构建AI导入
  Widget _buildAiImportTile() {
    return FutureBuilder<List<bool>>(
      future: Future.wait([
        SettingsService.instance.isAdvancedFeaturesEnabled(),
        SettingsService.instance.isAiImportEnabled(),
      ]),
      builder: (context, snapshot) {
        final results = snapshot.data ?? [false, false];
        final advancedEnabled = results[0];
        final aiEnabled = results[1];
        final visible = advancedEnabled && aiEnabled;
        
        if (!visible) return const SizedBox.shrink();
        
        return SettingsItem.text(
          title: 'AI 智能导入',
          description: '使用 AI 识别图片或文档中的课表',
          showArrow: true,
          onTap: () {
            RouteUtils.pushAIImport(context);
          },
        );
      },
    );
  }

  /// 构建导出课表
  Widget _buildExportTimetableTile() {
    return SettingsItem.text(
      title: '导出课表',
      description: '将课表数据导出为JSON文件',
      showArrow: true,
      onTap: () async {
        final timetableState = Provider.of<TimetableState>(context, listen: false);
        final timetable = timetableState.current;
        if (timetable == null) {
          Notifications.sonner(context, message: '请先选择一个课表');
          return;
        }
        final pathOrName = await FileService.exportTimetable(timetable);
        if (!mounted) return;
        if (pathOrName != null) {
          Notifications.sonner(context, message: '导出成功: $pathOrName');
        } else {
          Notifications.sonner(context, message: '已取消或当前平台不支持');
        }
      },
    );
  }


  // ==================== 扩展功能分区 ====================

  /// 构建主题设置
  Widget _buildThemeSettingsTile() {
    return SettingsItem.text(
      title: '主题设置',
      description: '自定义应用外观和颜色',
      showArrow: true,
      onTap: () {
        RouteUtils.pushThemeSettings(context);
      },
    );
  }

  /// 构建通知设置
  Widget _buildNotificationSettingsTile() {
    return SettingsItem.text(
      title: '课程提醒',
      description: '课程提醒和通知管理',
      showArrow: true,
      onTap: () {
        RouteUtils.pushCourseReminder(context);
      },
    );
  }

  /// 构建小组件设置
  Widget _buildWidgetSettingsTile() {
    return SettingsItem.text(
      title: '桌面小组件',
      description: '在主屏幕显示课程信息',
      showArrow: true,
      onTap: () {
        _showComingSoonDialog('桌面小组件功能');
      },
    );
  }

  // ==================== 高级功能分区 ====================

  /// 构建高级功能入口
  Widget _buildAdvancedFeaturesTile() {
    return FutureBuilder<bool>(
      future: SettingsService.instance.isAdvancedFeaturesEnabled(),
      builder: (context, snapshot) {
        final advancedEnabled = snapshot.data ?? false;
        
        return SettingsItem.text(
          title: '高级功能',
          description: advancedEnabled ? '已启用 AI 导入、教务脚本等' : '启用后可使用 AI 导入、教务脚本等功能',
          showArrow: true,
          onTap: () {
            RouteUtils.pushAdvancedFeatures(context).then((_) {
              if (mounted) setState(() {});
            });
          },
          inBlock: true,
        );
      },
    );
  }

  // ==================== 关于我们分区 ====================

  /// 构建关于页面
  Widget _buildAboutTile() {
    return SettingsItem.value(
      title: '关于应用',
      description: '版本信息和应用详情',
      value: 'v2.0.1',
      showArrow: true,
      onTap: () {
        RouteUtils.pushAbout(context);
      },
    );
  }

  /// 构建帮助页面
  Widget _buildHelpTile() {
    return SettingsItem.text(
      title: '使用帮助',
      description: '常见问题和使用指南',
      showArrow: true,
      onTap: () {
        _showComingSoonDialog('使用帮助功能');
      },
    );
  }

  /// 构建开源许可证
  Widget _buildPrivacyPolicyTile() {
    return SettingsItem.text(
      title: '开源许可证',
      description: '查看项目使用的开源许可证',
      showArrow: true,
      onTap: () {
        RouteUtils.pushLicense(context);
      },
    );
  }

  /// 显示即将推出对话框
  void _showComingSoonDialog(String featureName) {
    YicoreAlert.show(
      context,
      title: '功能开发中',
      message: '$featureName 正在开发中，敬请期待！',
    );
  }
}