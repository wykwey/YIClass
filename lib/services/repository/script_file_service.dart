import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 脚本文件服务
/// 负责检查和管理本地脚本文件
class ScriptFileService {
  static ScriptFileService? _instance;

  ScriptFileService._();

  static ScriptFileService get instance {
    _instance ??= ScriptFileService._();
    return _instance!;
  }

  /// 获取脚本文件目录路径
  static Future<String> _getScriptsDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('Web平台不支持本地文件存储');
    }
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, 'repository', 'scripts');
  }

  /// 检查脚本文件是否存在
  /// 
  /// [scriptName] 脚本文件名（如 example.js）
  /// 返回：文件存在返回 true，否则返回 false
  static Future<bool> checkScriptExists(String scriptName) async {
    try {
      final scriptsDir = await _getScriptsDirectory();
      final filePath = path.join(scriptsDir, scriptName);
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// 批量检查多个脚本文件是否存在
  /// 
  /// [scriptNames] 脚本文件名列表
  /// 返回：Map<scriptName, exists>
  static Future<Map<String, bool>> checkScriptsExist(List<String> scriptNames) async {
    final Map<String, bool> result = {};
    try {
      final scriptsDir = await _getScriptsDirectory();
      final scriptsDirObj = Directory(scriptsDir);
      
      // 如果目录不存在，所有脚本都不存在
      if (!await scriptsDirObj.exists()) {
        for (final scriptName in scriptNames) {
          result[scriptName] = false;
        }
        return result;
      }

      // 批量检查文件
      for (final scriptName in scriptNames) {
        final filePath = path.join(scriptsDir, scriptName);
        final file = File(filePath);
        result[scriptName] = await file.exists();
      }
    } catch (e) {
      // 出错时默认所有文件都不存在
      for (final scriptName in scriptNames) {
        result[scriptName] = false;
      }
    }
    return result;
  }

  /// 获取脚本文件的完整路径
  /// 
  /// [scriptName] 脚本文件名
  /// 返回：文件路径，如果文件不存在返回 null
  static Future<String?> getScriptPath(String scriptName) async {
    try {
      final scriptsDir = await _getScriptsDirectory();
      final filePath = path.join(scriptsDir, scriptName);
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 读取脚本文件内容
  /// 
  /// [scriptName] 脚本文件名
  /// 返回：文件内容字符串，文件不存在或读取失败返回 null
  static Future<String?> readScriptContent(String scriptName) async {
    try {
      final filePath = await getScriptPath(scriptName);
      if (filePath == null) {
        return null;
      }
      final file = File(filePath);
      return await file.readAsString();
    } catch (e) {
      return null;
    }
  }
}

