import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../views/main_view/week_view.dart';
import '../views/main_view/day_view.dart';
import '../views/main_view/list_view.dart';
import '../views/settings_view/settings_view.dart';
import '../views/settings_view/course_edit_page.dart';
import '../views/settings_view/time_settings_page.dart';
import '../views/repository/repository_config_page.dart';
import '../views/ai/ai_config_page.dart';
import '../views/ai/ai_import_page.dart';
import '../views/repository/edu_import_page.dart';
import '../views/repository/school_select_page.dart';
import '../views/repository/script_select_page.dart';
import '../views/settings_view/license_page.dart';
import '../views/settings_view/course_reminder_page.dart';
import '../views/settings_view/advanced_features_page.dart';
import '../views/settings_view/theme_settings_page.dart';
import '../views/settings_view/about_page.dart';
import '../data/course.dart';
import '../data/school_index.dart';
import '../states/view_state.dart';
import '../states/timetable_state.dart';
import '../components/layout/appbar.dart';
import '../components/layout/navigation.dart';
import '../components/feedback/notifications.dart';
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
          builder: (_) => const OpenSourceLicensePage(),
          settings: settings,
        );

      // 课程提醒页面
      case RouteNames.courseReminder:
        return MaterialPageRoute(
          builder: (_) => const CourseReminderPage(),
          settings: settings,
        );

      // 高级功能页面
      case RouteNames.advancedFeatures:
        return MaterialPageRoute(
          builder: (_) => const AdvancedFeaturesPage(),
          settings: settings,
        );

      // 主题设置页面
      case RouteNames.themeSettings:
        return MaterialPageRoute(
          builder: (_) => const ThemeSettingsPage(),
          settings: settings,
        );

      // 关于应用页面
      case RouteNames.about:
        return MaterialPageRoute(
          builder: (_) => const AboutPage(),
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
  /// 返回主页面并显示错误提示
  static Route<dynamic> _errorRoute(RouteSettings settings, String message) {
    return MaterialPageRoute(
      builder: (context) {
        // 显示错误提示
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Notifications.sonner(
              context,
              title: '路由错误',
              message: message,
            );
          }
        });
        return const _CourseScheduleScreen();
      },
      settings: const RouteSettings(
        name: RouteNames.home,
      ),
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
    final timetableState = context.watch<TimetableState>();
    final idx = _getViewIndex(viewState.selectedView);

    // 显示加载指示器（数据未初始化时）
    if (!timetableState.initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: idx == 0 ? const CustomAppBar() : null,
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

