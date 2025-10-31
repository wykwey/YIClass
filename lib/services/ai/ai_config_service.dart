import '../settings_service.dart';

/// AI配置模型（轻量级，包装 AppSettings）
class AIConfig {
  final String apiKey;
  final String endpoint;
  final String visionModel;
  final String textModel;
  final bool enabled;
  final bool enableImageImport;
  final bool enableTableImport;
  final bool enableTextImport;

  const AIConfig({
    this.apiKey = '',
    this.endpoint = '',
    this.visionModel = 'gpt-4-vision-preview',
    this.textModel = 'gpt-4',
    this.enabled = false,
    this.enableImageImport = false,
    this.enableTableImport = false,
    this.enableTextImport = false,
  });

  /// 验证配置是否完整
  bool get isValid {
    return apiKey.isNotEmpty && 
           endpoint.isNotEmpty && 
           textModel.isNotEmpty;
  }

  /// 验证文本功能配置
  bool get isTextValid {
    return apiKey.isNotEmpty && 
           endpoint.isNotEmpty && 
           textModel.isNotEmpty;
  }

  /// 验证视觉功能配置
  bool get isVisionValid {
    return apiKey.isNotEmpty && 
           endpoint.isNotEmpty && 
           visionModel.isNotEmpty;
  }

  /// 获取预设的API端点
  static List<String> getPresetEndpoints() {
    return [
      'https://api.openai.com/v1',
      'https://api.deepseek.com/chat/completions',
      'https://api.moonshot.cn/v1',
    ];
  }

  /// 获取预设的视觉模型
  static List<String> getPresetVisionModels() {
    return [
      'gpt-4-vision-preview',
      'gpt-4o',
      'gpt-4o-mini',
    ];
  }

  /// 获取预设的文本模型
  static List<String> getPresetTextModels() {
    return [
      'gpt-4',
      'gpt-4-turbo',
      'gpt-3.5-turbo',
      'deepseek-chat',
    ];
  }
}

/// AI配置服务（轻量级包装 SettingsService）
class AIConfigService {
  /// 获取配置（从 SettingsService 读取）
  static Future<AIConfig> getConfig() async {
    final settings = await SettingsService.instance.loadSettings();
    
    return AIConfig(
      apiKey: settings.aiApiKey,
      endpoint: settings.aiEndpoint,
      visionModel: settings.aiVisionModel,
      textModel: settings.aiTextModel,
      enabled: settings.aiEnabled,
      enableImageImport: settings.aiImageImport,
      enableTableImport: settings.aiTableImport,
      enableTextImport: settings.aiTextImport,
    );
  }

  /// 保存配置（保存到 SettingsService）
  static Future<void> saveConfig(AIConfig config) async {
    await SettingsService.instance.updateAiEnabled(config.enabled);
    await SettingsService.instance.updateAiSettings(
      imageImport: config.enableImageImport,
      tableImport: config.enableTableImport,
      textImport: config.enableTextImport,
    );
    await SettingsService.instance.updateAiConfig(
      apiKey: config.apiKey,
      endpoint: config.endpoint,
      visionModel: config.visionModel,
      textModel: config.textModel,
    );
  }

  /// 清除配置
  static Future<void> clearConfig() async {
    await SettingsService.instance.updateAiEnabled(false);
    await SettingsService.instance.updateAiSettings(
      imageImport: false,
      tableImport: false,
      textImport: false,
    );
    await SettingsService.instance.updateAiConfig(
      apiKey: '',
      endpoint: '',
      visionModel: 'gpt-4-vision-preview',
      textModel: 'gpt-4',
    );
  }

  /// 验证配置
  static Future<bool> validateConfig(AIConfig config) async {
    if (!config.isValid) {
      return false;
    }
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取配置状态
  static Future<Map<String, dynamic>> getConfigStatus() async {
    final config = await getConfig();
    return {
      'enabled': config.enabled,
      'hasApiKey': config.apiKey.isNotEmpty,
      'hasEndpoint': config.endpoint.isNotEmpty,
      'isValid': config.isValid,
    };
  }
}
