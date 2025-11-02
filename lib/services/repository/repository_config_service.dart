import '../../services/settings_service.dart';

/// 仓库配置模型
class RepositoryConfig {
  final String repositoryUrl;
  final String repositoryType; // 'official', 'custom', 'private'
  final String indexBranch; // 索引文件所在分支，默认 'index-data'
  final String scriptsBranch; // 脚本文件所在分支，默认 'main'
  final String tokenKey;
  final String tokenValue;
  final bool enabled;

  const RepositoryConfig({
    this.repositoryUrl = '',
    this.repositoryType = 'official',
    this.indexBranch = 'index-data',
    this.scriptsBranch = 'main',
    this.tokenKey = '',
    this.tokenValue = '',
    this.enabled = false,
  });

  /// 验证配置是否完整
  bool get isValid {
    // 官方仓库始终有效（使用固定URL）
    if (repositoryType == 'official') return true;
    if (repositoryUrl.isEmpty) return false;
    if (repositoryType == 'private') {
      return tokenKey.isNotEmpty && tokenValue.isNotEmpty;
    }
    return true;
  }

  /// 验证私有仓库配置
  bool get isPrivateValid {
    return repositoryType == 'private' &&
           tokenKey.isNotEmpty &&
           tokenValue.isNotEmpty;
  }
}

/// 仓库配置服务
class RepositoryConfigService {
  /// 官方仓库URL
  static const String officialRepositoryUrl = 'https://github.com/wykwey/YiScripts';

  /// 官方索引分支名称
  static const String officialIndexBranch = 'index-data';

  /// 获取配置
  static Future<RepositoryConfig> getConfig() async {
    try {
      final settingsService = SettingsService.instance;
      final settings = await settingsService.loadSettings();
      
      // 如果是官方仓库，使用固定的URL
      final repositoryUrl = settings.repositoryType == 'official'
          ? officialRepositoryUrl
          : settings.repositoryUrl;
      
      return RepositoryConfig(
        repositoryUrl: repositoryUrl,
        repositoryType: settings.repositoryType,
        indexBranch: settings.indexBranch,
        scriptsBranch: settings.scriptsBranch,
        tokenKey: settings.tokenKey,
        tokenValue: settings.tokenValue,
        enabled: settings.repositoryImportEnabled,
      );
    } catch (e) {
      // 如果读取失败，返回默认配置
      return const RepositoryConfig();
    }
  }

  /// 保存配置
  static Future<void> saveConfig(RepositoryConfig config) async {
    try {
      final settingsService = SettingsService.instance;
      
      // 对于官方仓库，不保存URL（使用固定值）
      final repositoryUrl = config.repositoryType == 'official'
          ? '' // 官方仓库不保存URL
          : config.repositoryUrl;
      
      await settingsService.updateRepositoryConfig(
        repositoryUrl: repositoryUrl,
        repositoryType: config.repositoryType,
        indexBranch: config.indexBranch,
        scriptsBranch: config.scriptsBranch,
        tokenKey: config.tokenKey,
        tokenValue: config.tokenValue,
        repositoryImportEnabled: config.enabled,
      );
    } catch (e) {
      throw Exception('保存仓库配置失败: $e');
    }
  }

  /// 清除配置
  static Future<void> clearConfig() async {
    // TODO: 清除配置
    await saveConfig(const RepositoryConfig());
  }

  /// 验证配置
  static Future<bool> validateConfig(RepositoryConfig config) async {
    if (!config.isValid) {
      return false;
    }
    try {
      // TODO: 可以添加更多验证逻辑，如验证仓库URL格式、测试连接等
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
      'hasRepositoryUrl': config.repositoryUrl.isNotEmpty,
      'repositoryType': config.repositoryType,
      'indexBranch': config.indexBranch,
      'scriptsBranch': config.scriptsBranch,
      'isValid': config.isValid,
    };
  }
}

