import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../data/school_index.dart';

/// 学校索引服务
/// 负责读取和管理下载的索引数据库
class SchoolIndexService {
  static SchoolIndexService? _instance;
  Isar? _indexIsar;
  String? _indexFilePath;

  SchoolIndexService._();

  static SchoolIndexService get instance {
    _instance ??= SchoolIndexService._();
    return _instance!;
  }

  /// 打开索引数据库
  /// 
  /// [indexFilePath] 索引文件路径，如果为null则尝试从默认位置加载
  /// 返回：成功返回true，失败返回false
  Future<bool> openIndex(String? indexFilePath) async {
    try {
      // 如果已打开且是同一个文件，直接返回
      if (_indexIsar != null && _indexFilePath == indexFilePath) {
        return true;
      }

      // 关闭之前的数据库
      await closeIndex();

      // 确定文件路径
      String filePath;
      if (indexFilePath != null && indexFilePath.isNotEmpty) {
        filePath = indexFilePath;
      } else {
        // 尝试从默认位置加载
        final appDir = await _getAppDirectory();
        filePath = path.join(appDir.path, 'repository', 'index.isar');
      }

      // 检查文件是否存在
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('索引文件不存在: $filePath');
      }

      // 打开数据库
      _indexIsar = await Isar.open(
        schemas: [SchoolIndexSchema],
        directory: path.dirname(filePath),
        name: path.basenameWithoutExtension(filePath),
      );

      _indexFilePath = filePath;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 关闭索引数据库
  Future<void> closeIndex() async {
    if (_indexIsar != null) {
      await _indexIsar!.close();
      _indexIsar = null;
      _indexFilePath = null;
    }
  }

  /// 获取索引数据库实例
  Isar? get indexIsar => _indexIsar;

  /// 检查索引数据库是否已打开
  bool get isOpened => _indexIsar != null;

  /// 获取索引数据
  /// 
  /// 返回：SchoolIndex对象，失败返回null
  Future<SchoolIndex?> getIndex() async {
    if (_indexIsar == null) {
      // 尝试自动打开
      final opened = await openIndex(null);
      if (!opened) {
        return null;
      }
    }

    try {
      // 使用 Isar 的集合访问（从生成的 school_index.g.dart 中可以看到集合名称是 schoolIndexs）
      final collection = _indexIsar!.schoolIndexs;
      final index = await collection.get(1);
      return index;
    } catch (e) {
      return null;
    }
  }

  /// 获取所有学校列表
  /// 
  /// 返回：学校列表，失败返回空列表
  Future<List<SchoolEntry>> getAllSchools() async {
    final index = await getIndex();
    if (index == null) {
      return [];
    }
    return index.schools;
  }

  /// 按字母索引分组学校
  /// 
  /// 返回：`Map<String, List<SchoolEntry>>`，key为字母索引（如'A', 'B'）
  Future<Map<String, List<SchoolEntry>>> getSchoolsGroupedByLetter() async {
    final schools = await getAllSchools();
    final Map<String, List<SchoolEntry>> grouped = {};

    for (final school in schools) {
      final letter = school.letterIndex.toUpperCase();
      if (!grouped.containsKey(letter)) {
        grouped[letter] = [];
      }
      grouped[letter]!.add(school);
    }

    // 按字母排序
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedMap = <String, List<SchoolEntry>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }

  /// 搜索学校
  /// 
  /// [query] 搜索关键词
  /// 返回：匹配的学校列表
  Future<List<SchoolEntry>> searchSchools(String query) async {
    final schools = await getAllSchools();
    final lowerQuery = query.toLowerCase();
    return schools.where((school) {
      return school.school.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 获取应用文档目录
  static Future<Directory> _getAppDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('Web平台不支持本地文件存储');
    }
    return await getApplicationDocumentsDirectory();
  }
}

