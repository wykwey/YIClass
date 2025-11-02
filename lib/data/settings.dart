import 'package:isar_plus/isar_plus.dart';

part 'settings.g.dart';

/// 全局应用设置模型（Isar Plus 版本）
/// 
/// 用于存储应用的全局配置
@Collection()
class AppSettings {
  
  // ================= 属性 =================
  late int id; // 固定ID，只有一个全局设置实例
  late String currentTimetableId; // 当前选中的课表ID
  
  // 通知设置
  late bool notificationEnabled; // 是否启用通知
  late bool courseReminder; // 课程提醒
  
  // AI功能开关
  late bool aiEnabled; // 是否启用AI功能
  late bool aiImageImport; // 是否启用AI图片导入
  late bool aiTableImport; // 是否启用AI表格导入
  late bool aiTextImport; // 是否启用AI文本导入
  
  // AI配置
  late String aiApiKey; // AI API密钥
  late String aiEndpoint; // AI API端点
  late String aiVisionModel; // 视觉模型名称
  late String aiTextModel; // 文本模型名称
  
  // 高级功能开关
  late bool advancedFeaturesEnabled; // 是否启用高级功能

  // 仓库配置（教务导入）
  late String repositoryUrl; // 仓库URL
  late String repositoryType; // 仓库类型：'official', 'custom', 'private'
  late String indexBranch; // 索引文件所在分支
  late String scriptsBranch; // 脚本文件所在分支
  late String tokenKey; // Token Key（私有仓库）
  late String tokenValue; // Token Value（私有仓库）
  late bool repositoryImportEnabled; // 是否启用教务导入

  // ================= 构造 =================
  AppSettings({
    this.id = 1, // 固定为1，确保只有一个实例
    this.currentTimetableId = '',
    this.notificationEnabled = false,
    this.courseReminder = false,
    this.aiEnabled = false,
    this.aiImageImport = false,
    this.aiTableImport = false,
    this.aiTextImport = false,
    this.aiApiKey = '',
    this.aiEndpoint = '',
    this.aiVisionModel = 'gpt-4-vision-preview',
    this.aiTextModel = 'gpt-4',
    this.advancedFeaturesEnabled = false,
    this.repositoryUrl = '',
    this.repositoryType = 'official',
    this.indexBranch = 'index-data',
    this.scriptsBranch = 'main',
    this.tokenKey = '',
    this.tokenValue = '',
    this.repositoryImportEnabled = false,
  });

  // ================= JSON 转换 =================
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id'] ?? 1,
      currentTimetableId: json['currentTimetableId']?.toString() ?? '',
      notificationEnabled: json['notificationEnabled'] ?? false,
      courseReminder: json['courseReminder'] ?? false,
      aiEnabled: json['aiEnabled'] ?? false,
      aiImageImport: json['aiImageImport'] ?? false,
      aiTableImport: json['aiTableImport'] ?? false,
      aiTextImport: json['aiTextImport'] ?? false,
      aiApiKey: json['aiApiKey']?.toString() ?? '',
      aiEndpoint: json['aiEndpoint']?.toString() ?? '',
      aiVisionModel: json['aiVisionModel']?.toString() ?? 'gpt-4-vision-preview',
      aiTextModel: json['aiTextModel']?.toString() ?? 'gpt-4',
      advancedFeaturesEnabled: json['advancedFeaturesEnabled'] ?? false,
      repositoryUrl: json['repositoryUrl']?.toString() ?? '',
      repositoryType: json['repositoryType']?.toString() ?? 'official',
      indexBranch: json['indexBranch']?.toString() ?? 'index-data',
      scriptsBranch: json['scriptsBranch']?.toString() ?? 'main',
      tokenKey: json['tokenKey']?.toString() ?? '',
      tokenValue: json['tokenValue']?.toString() ?? '',
      repositoryImportEnabled: json['repositoryImportEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'currentTimetableId': currentTimetableId,
        'notificationEnabled': notificationEnabled,
        'courseReminder': courseReminder,
        'aiEnabled': aiEnabled,
        'aiImageImport': aiImageImport,
        'aiTableImport': aiTableImport,
        'aiTextImport': aiTextImport,
        'aiApiKey': aiApiKey,
        'aiEndpoint': aiEndpoint,
        'aiVisionModel': aiVisionModel,
        'aiTextModel': aiTextModel,
        'advancedFeaturesEnabled': advancedFeaturesEnabled,
        'repositoryUrl': repositoryUrl,
        'repositoryType': repositoryType,
        'indexBranch': indexBranch,
        'scriptsBranch': scriptsBranch,
        'tokenKey': tokenKey,
        'tokenValue': tokenValue,
        'repositoryImportEnabled': repositoryImportEnabled,
      };

  // ================= 辅助方法 =================
  AppSettings copyWith({
    int? id,
    String? currentTimetableId,
    bool? notificationEnabled,
    bool? courseReminder,
    bool? aiEnabled,
    bool? aiImageImport,
    bool? aiTableImport,
    bool? aiTextImport,
    String? aiApiKey,
    String? aiEndpoint,
    String? aiVisionModel,
    String? aiTextModel,
    bool? advancedFeaturesEnabled,
    String? repositoryUrl,
    String? repositoryType,
    String? indexBranch,
    String? scriptsBranch,
    String? tokenKey,
    String? tokenValue,
    bool? repositoryImportEnabled,
  }) {
    return AppSettings(
      id: id ?? this.id,
      currentTimetableId: currentTimetableId ?? this.currentTimetableId,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      courseReminder: courseReminder ?? this.courseReminder,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      aiImageImport: aiImageImport ?? this.aiImageImport,
      aiTableImport: aiTableImport ?? this.aiTableImport,
      aiTextImport: aiTextImport ?? this.aiTextImport,
      aiApiKey: aiApiKey ?? this.aiApiKey,
      aiEndpoint: aiEndpoint ?? this.aiEndpoint,
      aiVisionModel: aiVisionModel ?? this.aiVisionModel,
      aiTextModel: aiTextModel ?? this.aiTextModel,
      advancedFeaturesEnabled: advancedFeaturesEnabled ?? this.advancedFeaturesEnabled,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      repositoryType: repositoryType ?? this.repositoryType,
      indexBranch: indexBranch ?? this.indexBranch,
      scriptsBranch: scriptsBranch ?? this.scriptsBranch,
      tokenKey: tokenKey ?? this.tokenKey,
      tokenValue: tokenValue ?? this.tokenValue,
      repositoryImportEnabled: repositoryImportEnabled ?? this.repositoryImportEnabled,
    );
  }

  /// 创建默认设置
  factory AppSettings.defaultSettings() {
    return AppSettings(
      id: 1,
      currentTimetableId: '',
      notificationEnabled: false,
      courseReminder: false,
      aiEnabled: false,
      aiImageImport: false,
      aiTableImport: false,
      aiTextImport: false,
      aiApiKey: '',
      aiEndpoint: '',
      aiVisionModel: 'gpt-4-vision-preview',
      aiTextModel: 'gpt-4',
      advancedFeaturesEnabled: false,
      repositoryUrl: '',
      repositoryType: 'official',
      indexBranch: 'index-data',
      scriptsBranch: 'main',
      tokenKey: '',
      tokenValue: '',
      repositoryImportEnabled: false,
    );
  }

  /// 验证设置是否有效
  bool get isValid {
    return id == 1; // 确保ID为1
  }

  @override
  String toString() {
    return 'AppSettings(id: $id, currentTimetableId: $currentTimetableId, '
        'notificationEnabled: $notificationEnabled, courseReminder: $courseReminder, '
        'aiEnabled: $aiEnabled, '
        'aiImageImport: $aiImageImport, aiTableImport: $aiTableImport, aiTextImport: $aiTextImport, '
        'aiApiKey: ${aiApiKey.isNotEmpty ? "${aiApiKey.substring(0, 8)}..." : "未配置"}, '
        'aiEndpoint: $aiEndpoint, aiVisionModel: $aiVisionModel, aiTextModel: $aiTextModel, '
        'advancedFeaturesEnabled: $advancedFeaturesEnabled, '
        'repositoryUrl: $repositoryUrl, repositoryType: $repositoryType, '
        'repositoryImportEnabled: $repositoryImportEnabled)';
  }
}
