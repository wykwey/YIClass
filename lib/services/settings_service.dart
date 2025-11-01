import 'package:isar_plus/isar_plus.dart';
import '../data/settings.dart';

/// 设置服务：管理全局 AppSettings
/// 负责 AppSettings 的 CRUD 操作
class SettingsService {
  static SettingsService? _instance;
  Isar? _isar;

  SettingsService._();

  /// 获取单例实例
  static SettingsService get instance {
    _instance ??= SettingsService._();
    return _instance!;
  }

  /// 注入 Isar 实例
  Future<void> init(Isar isarInstance) async {
    _isar = isarInstance;
  }

  /// 获取内部持有的 Isar 实例
  Isar get isar {
    if (_isar == null) throw Exception('SettingsService 未初始化');
    return _isar!;
  }

  /// 加载设置（获取或创建默认设置）
  Future<AppSettings> loadSettings() async {
    final collection = isar.appSettings;
    final settings = await collection.get(1);
    if (settings != null) {
      return settings;
    }
    
    // 创建默认设置
    final defaultSettings = AppSettings.defaultSettings();
    await isar.write((isar) async {
      isar.appSettings.put(defaultSettings);
    });
    return defaultSettings;
  }

  /// 保存设置
  Future<bool> saveSettings(AppSettings settings) async {
    try {
      await isar.write((isar) async {
        isar.appSettings.put(settings);
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 检查高级功能是否启用
  Future<bool> isAdvancedFeaturesEnabled() async {
    final settings = await loadSettings();
    return settings.advancedFeaturesEnabled;
  }

  /// 更新高级功能开关
  Future<bool> updateAdvancedFeaturesEnabled(bool enabled) async {
    try {
      final settings = await loadSettings();
      settings.advancedFeaturesEnabled = enabled;
      return await saveSettings(settings);
    } catch (_) {
      return false;
    }
  }

  /// 更新AI启用状态
  Future<bool> updateAiEnabled(bool enabled) async {
    try {
      final settings = await loadSettings();
      settings.aiEnabled = enabled;
      return await saveSettings(settings);
    } catch (_) {
      return false;
    }
  }

  /// 更新AI设置
  Future<bool> updateAiSettings({
    bool? imageImport,
    bool? tableImport,
    bool? textImport,
  }) async {
    try {
      final settings = await loadSettings();
      if (imageImport != null) settings.aiImageImport = imageImport;
      if (tableImport != null) settings.aiTableImport = tableImport;
      if (textImport != null) settings.aiTextImport = textImport;
      return await saveSettings(settings);
    } catch (_) {
      return false;
    }
  }

  /// 更新AI配置
  Future<bool> updateAiConfig({
    String? apiKey,
    String? endpoint,
    String? visionModel,
    String? textModel,
  }) async {
    try {
      final settings = await loadSettings();
      if (apiKey != null) settings.aiApiKey = apiKey;
      if (endpoint != null) settings.aiEndpoint = endpoint;
      if (visionModel != null) settings.aiVisionModel = visionModel;
      if (textModel != null) settings.aiTextModel = textModel;
      return await saveSettings(settings);
    } catch (_) {
      return false;
    }
  }

  /// 更新通知设置
  Future<bool> updateNotificationSettings({
    bool? enabled,
    bool? courseReminder,
  }) async {
    try {
      final settings = await loadSettings();
      if (enabled != null) settings.notificationEnabled = enabled;
      if (courseReminder != null) settings.courseReminder = courseReminder;
      return await saveSettings(settings);
    } catch (_) {
      return false;
    }
  }
}

