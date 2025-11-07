import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../views/week_view.dart';
import '../views/day_view.dart';
import '../views/list_view.dart';
import '../views/settings_view.dart';
import '../views/course_edit_page.dart';
import '../views/time_settings_page.dart';
import '../views/repository_config_page.dart';
import '../views/ai_config_page.dart';
import '../views/ai_import_page.dart';
import '../views/repository/edu_import_page.dart';
import '../views/repository/school_select_page.dart';
import '../views/repository/script_select_page.dart';
import '../data/course.dart';
import '../data/school_index.dart';
import '../states/view_state.dart';
import '../components/custom_app_bar.dart';
import '../components/bottom_nav_bar.dart';
import 'route_names.dart';

/// 路由生成器
/// 统一管理所有页面的路由配置
class AppRoutes {
  /// 生成路由
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // 主页面
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const _CourseScheduleScreen(),
          settings: settings,
        );

      // 列表视图页面
      case RouteNames.listView:
        return MaterialPageRoute(
          builder: (_) => const CourseListView(),
          settings: settings,
        );

      // 课程编辑页面
      case RouteNames.courseEdit:
        if (args is Map<String, dynamic>) {
          final course = args['course'] as Course;
          final timetableId = args['timetableId'] as int;
          return MaterialPageRoute(
            builder: (_) => CourseEditPage(
              course: course,
              timetableId: timetableId,
            ),
            settings: settings,
          );
        }
        return _errorRoute(settings, '课程编辑页面需要 course 和 timetableId 参数');

      // 时间设置页面
      case RouteNames.timeSettings:
        return MaterialPageRoute(
          builder: (_) => const TimeSettingsPage(),
          settings: settings,
        );

      // 仓库配置页面
      case RouteNames.repositoryConfig:
        return MaterialPageRoute(
          builder: (_) => const RepositoryConfigPage(),
          settings: settings,
        );

      // AI配置页面
      case RouteNames.aiConfig:
        return MaterialPageRoute(
          builder: (_) => const AIConfigPage(),
          settings: settings,
        );

      // 许可证页面
      case RouteNames.license:
        return MaterialPageRoute(
          builder: (_) => const LicensePage(),
          settings: settings,
        );

      // AI导入页面
      case RouteNames.aiImport:
        return MaterialPageRoute(
          builder: (_) => const AIImportPage(),
          settings: settings,
        );

      // 教务系统导入页面
      case RouteNames.eduImport:
        if (args is Map<String, dynamic>) {
          final script = args['script'] as ScriptEntry?;
          if (script != null) {
            return MaterialPageRoute(
              builder: (_) => EduImportPage(script: script),
              settings: settings,
            );
          }
        }
        return _errorRoute(settings, '教务系统导入页面需要 script 参数');

      // 学校选择页面
      case RouteNames.schoolSelect:
        return MaterialPageRoute(
          builder: (_) => const SchoolSelectPage(),
          settings: settings,
        );

      // 脚本选择页面
      case RouteNames.scriptSelect:
        if (args is Map<String, dynamic>) {
          final school = args['school'] as SchoolEntry?;
          if (school != null) {
            return MaterialPageRoute(
              builder: (_) => ScriptSelectPage(school: school),
              settings: settings,
            );
          }
        }
        return _errorRoute(settings, '脚本选择页面需要 school 参数');

      default:
        return _errorRoute(settings, '未找到路由: ${settings.name}');
    }
  }

  /// 错误路由
  static Route<dynamic> _errorRoute(RouteSettings settings, String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('路由错误'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(_).pop(),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      ),
      settings: settings,
    );
  }
}

/// 课程表主界面
/// 显示当前视图：周视图、日视图、设置
class _CourseScheduleScreen extends StatelessWidget {
  const _CourseScheduleScreen();

  /// 获取视图对应的索引
  /// 0: 周视图, 1: 日视图, 2: 设置
  int _getViewIndex(String viewName) {
    switch (viewName) {
      case '周视图':
        return 0;
      case '日视图':
        return 1;
      case '设置':
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
          // 2: 设置
          SettingsPage(),
        ],
      ),
    );
  }
}

