/// 路由名称常量
/// 统一管理所有路由路径
class RouteNames {
  // 主页面
  static const String home = '/';
  
  // 课程相关
  static const String courseEdit = '/course/edit';
  static const String listView = '/list';
  
  // 设置相关
  static const String settings = '/settings';
  static const String timeSettings = '/settings/time';
  static const String repositoryConfig = '/settings/repository';
  static const String aiConfig = '/settings/ai';
  static const String license = '/settings/license';
  
  // 导入相关
  static const String aiImport = '/import/ai';
  static const String eduImport = '/import/edu';
  static const String schoolSelect = '/import/school';
  static const String scriptSelect = '/import/script';
  
  // 私有构造函数，防止实例化
  RouteNames._();
}

