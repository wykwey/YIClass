/// 安全调用工具类
/// 提供统一的 try-catch 封装，避免代码中大量重复的 try-catch 块
class SafeCall {
  /// 安全执行同步操作，失败时返回 null
  static T? sync<T>(T Function() action) {
    try {
      return action();
    } catch (_) {
      return null;
    }
  }

  /// 安全执行异步操作，失败时返回 null
  static Future<T?> async<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      return null;
    }
  }

  /// 安全执行同步操作，返回成功/失败布尔值
  static bool run(void Function() action) {
    try {
      action();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 安全执行异步操作，返回成功/失败布尔值
  static Future<bool> runAsync(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 安全执行，忽略任何异常（用于清理操作）
  static void ignore(void Function() action) {
    try {
      action();
    } catch (_) {}
  }

  /// 安全执行异步操作，忽略任何异常
  static Future<void> ignoreAsync(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }

  /// 安全执行，失败时返回默认值
  static T orDefault<T>(T Function() action, T defaultValue) {
    try {
      return action();
    } catch (_) {
      return defaultValue;
    }
  }

  /// 安全执行异步操作，失败时返回默认值
  static Future<T> orDefaultAsync<T>(
    Future<T> Function() action,
    T defaultValue,
  ) async {
    try {
      return await action();
    } catch (_) {
      return defaultValue;
    }
  }
}
