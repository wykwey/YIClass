import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'components/bottom_nav_bar.dart';
import 'components/custom_app_bar.dart';
import 'views/week_view.dart';
import 'views/day_view.dart';
import 'views/list_view.dart';
import 'package:provider/provider.dart';
import 'states/timetable_state.dart';
import 'states/view_state.dart';
import 'states/week_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/database_service.dart';
import 'services/timetable_service.dart';
import 'services/course_service.dart';
import 'services/settings_service.dart';
import 'package:isar_plus/isar_plus.dart';

/// 自定义 ScrollBehavior 完全禁用滚动条
class NoScrollbarBehavior extends MaterialScrollBehavior {
  const NoScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    // 返回原始的 child，不包装 Scrollbar
    return child;
  }
}

/// 应用入口函数
/// 初始化应用
/// 初始化Isar数据库
/// 请求存储权限
/// 使用MultiProvider注册多个状态管理类
/// 启动应用
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web平台特殊初始化
  if (kIsWeb) {
    await Isar.initialize();
  }

  // 初始化 Isar 数据库
  final dbService = DatabaseService.instance;
  final success = await dbService.initialize();
  if (!success) {
    print('数据库初始化失败，应用可能无法正常工作');
  }

  final isar = dbService.isar;

  // 初始化服务
  await TimetableService.instance.init(isar);
  await CourseService.instance.init(isar);
  await SettingsService.instance.init(isar);

  // 创建状态实例
  final timetableState = TimetableState();
  final weekState = WeekState();
  final viewState = ViewState();

  // 初始化状态（注入 Isar，内部已调用 reload()）
  await timetableState.init(isar);
  
  // 同步视图状态
  if (timetableState.current != null) {
    await viewState.loadFromTimetable(timetableState.current);
  }

  // 仅在非Web平台请求存储权限
  if (!kIsWeb) {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      // 如果权限被拒绝，可以在这里处理
    }
  }

  // 使用MultiProvider注册多个状态管理类
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: timetableState),
        ChangeNotifierProvider.value(value: weekState),
        ChangeNotifierProvider.value(value: viewState),
      ],
      child: const MyApp(),
    ),
  );
}

/// 应用根组件
///
/// 负责配置应用的全局设置，包括：
/// - 主题样式(字体、颜色方案)
/// - 本地化支持(中文)
/// - 路由导航设置
/// - 调试标志控制
///
/// 使用MaterialApp作为基础框架，集成所有子组件
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PingFang',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // 全局禁用波纹效果
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        // 全局隐藏滚动条
        scrollbarTheme: const ScrollbarThemeData(
          thumbVisibility: WidgetStatePropertyAll(false),
          trackVisibility: WidgetStatePropertyAll(false),
          interactive: false,
          thickness: WidgetStatePropertyAll(0.0),
        ),
      ),
      // 使用自定义 ScrollBehavior 完全禁用滚动条
      scrollBehavior: const NoScrollbarBehavior(),
      home: const CourseScheduleScreen(),
    );
  }
}

/// 课程表主界面
/// 显示当前视图
/// 周视图、日视图、列表视图
 
class CourseScheduleScreen extends StatelessWidget {
  const CourseScheduleScreen({super.key});

  /// 获取视图对应的索引
  /// 0: 周视图, 1: 日视图, 2: 列表视图
  int _getViewIndex(String viewName) {
    switch (viewName) {
      case '周视图':
        return 0;
      case '日视图':
        return 1;
      case '列表视图':
        return 2;
      default:
        return 0; // 默认返回周视图
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewState = context.watch<ViewState>();
    final idx = _getViewIndex(viewState.selectedView);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: idx == 2 ? null : const CustomAppBar(),
      bottomNavigationBar: const AppBottomNavBar(),
      body: IndexedStack(
        index: idx,
        children: const [
          // 0: 周视图
          WeekView(),
          // 1: 日视图
          DayView(),
          // 2: 列表视图
          CourseListView(),
        ],
      ),
    );
  }
}
