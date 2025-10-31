import 'package:isar_plus/isar_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../data/timetable.dart';
import '../data/settings.dart';

/// 统一数据库服务
/// 
/// 负责 Isar 数据库的初始化和关闭
class DatabaseService {
  static DatabaseService? _instance;
  Isar? _isar;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// 初始化数据库
  /// 
  /// 包含：
  /// - TimetableSchema（及其所有嵌入式 Schemas：TimetableSettingsSchema、ClassTimeSchema、CourseSchema、CourseScheduleSchema）
  /// - AppSettingsSchema
  Future<bool> initialize() async {
    try {
      // 根据平台选择数据库目录
      String directory;
      if (kIsWeb) {
        // Web平台使用默认目录
        directory = 'isar_data';
      } else {
        // 移动平台使用应用文档目录
        final dir = await getApplicationDocumentsDirectory();
        directory = dir.path;
      }

      // 打开Isar数据库
      _isar = await Isar.open(
        schemas: [
          TimetableSchema,  // 包含所有嵌入式 Schemas
          AppSettingsSchema,
        ],
        engine: IsarEngine.sqlite,
        directory: directory,
      );

      return true;
    } catch (e) {
      print('初始化数据库失败: $e');
      return false;
    }
  }

  /// 获取 Isar 实例
  Isar get isar {
    if (_isar == null) {
      throw Exception('数据库未初始化，请先调用 initialize()');
    }
    return _isar!;
  }

  /// 关闭数据库
  Future<void> close() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
    }
  }
}

