import 'package:flutter/material.dart';
import '../data/course.dart';
import '../data/school_index.dart';
import 'route_names.dart';

/// 路由工具类
/// 提供便捷的页面导航方法
class RouteUtils {
  /// 导航到课程编辑页面
  static Future<dynamic> pushCourseEdit(
    BuildContext context, {
    required Course course,
    required int timetableId,
  }) {
    return Navigator.pushNamed(
      context,
      RouteNames.courseEdit,
      arguments: {
        'course': course,
        'timetableId': timetableId,
      },
    );
  }

  /// 导航到列表视图页面
  static Future<dynamic> pushListView(BuildContext context) {
    return Navigator.pushNamed(context, RouteNames.listView);
  }

  /// 导航到时间设置页面
  static Future<dynamic> pushTimeSettings(BuildContext context) {
    return Navigator.pushNamed(context, RouteNames.timeSettings);
  }

  /// 导航到仓库配置页面
  static Future<dynamic> pushRepositoryConfig(BuildContext context) {
    return Navigator.pushNamed(context, RouteNames.repositoryConfig);
  }

  /// 导航到AI配置页面
  static Future<dynamic> pushAIConfig(BuildContext context) {
    return Navigator.pushNamed(context, RouteNames.aiConfig);
  }

  /// 导航到许可证页面
  static Future<dynamic> pushLicense(BuildContext context) {
    return Navigator.pushNamed(context, RouteNames.license);
  }

  /// 导航到AI导入页面
  static Future<dynamic> pushAIImport(BuildContext context) {
    return Navigator.pushNamed(context, RouteNames.aiImport);
  }

  /// 导航到教务系统导入页面
  static Future<dynamic> pushEduImport(
    BuildContext context, {
    required ScriptEntry script,
  }) {
    return Navigator.pushNamed(
      context,
      RouteNames.eduImport,
      arguments: {
        'script': script,
      },
    );
  }

  /// 导航到学校选择页面
  static Future<dynamic> pushSchoolSelect(BuildContext context) {
    return Navigator.pushNamed(context, RouteNames.schoolSelect);
  }

  /// 导航到脚本选择页面
  static Future<dynamic> pushScriptSelect(
    BuildContext context, {
    required SchoolEntry school,
  }) {
    return Navigator.pushNamed(
      context,
      RouteNames.scriptSelect,
      arguments: {
        'school': school,
      },
    );
  }

  /// 返回上一页
  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  /// 返回并替换当前页面
  static Future<dynamic> pushReplacementNamed(
    BuildContext context,
    String routeName, {
    dynamic arguments,
  }) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }
}

