import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'repository_config_service.dart';

/// 仓库下载服务
class RepositoryDownloadService {
  /// 下载索引文件
  /// 
  /// 从指定仓库的 index-data 分支下载 index.isar 文件
  /// 
  /// [config] 仓库配置
  /// 返回：下载的文件路径，失败时返回 null
  static Future<String?> downloadIndex(RepositoryConfig config) async {
    try {
      // 解析仓库URL获取owner和repo
      final repoInfo = _parseRepositoryUrl(config.repositoryUrl);
      if (repoInfo == null) {
        throw Exception('无效的仓库URL格式');
      }

      final fileName = 'index.isar';

      // 获取文件内容
      final bytes = await _downloadFile(
        repositoryUrl: config.repositoryUrl,
        branch: config.indexBranch,
        filePath: fileName, // index-data分支根目录
        tokenKey: config.repositoryType == 'private' ? config.tokenKey : null,
        tokenValue: config.repositoryType == 'private' ? config.tokenValue : null,
      );

      if (bytes == null) {
        throw Exception('下载文件失败');
      }

      // 保存到本地
      final localPath = await _saveFile(
        fileName: fileName,
        bytes: bytes,
        subdirectory: 'repository',
      );

      return localPath;
    } catch (e) {
      throw Exception('下载索引失败: $e');
    }
  }

  /// 下载完整仓库
  /// 
  /// 下载索引文件 + scripts 文件夹
  /// 
  /// [config] 仓库配置
  /// 返回：包含索引文件路径和scripts目录路径的Map，失败时抛出异常
  static Future<Map<String, String?>> downloadFullRepository(RepositoryConfig config) async {
    try {
      // 解析仓库URL获取owner和repo
      final repoInfo = _parseRepositoryUrl(config.repositoryUrl);
      if (repoInfo == null) {
        throw Exception('无效的仓库URL格式');
      }

      // 1. 下载索引文件
      final indexPath = await downloadIndex(config);

      // 2. 下载scripts文件夹
      final scriptsPath = await _downloadScriptsFolder(
        repositoryUrl: config.repositoryUrl,
        branch: config.scriptsBranch,
        tokenKey: config.repositoryType == 'private' ? config.tokenKey : null,
        tokenValue: config.repositoryType == 'private' ? config.tokenValue : null,
      );

      return {
        'index': indexPath,
        'scripts': scriptsPath,
      };
    } catch (e) {
      throw Exception('下载完整仓库失败: $e');
    }
  }

  /// 下载scripts文件夹
  static Future<String?> _downloadScriptsFolder({
    required String repositoryUrl,
    required String branch,
    String? tokenKey,
    String? tokenValue,
  }) async {
    try {
      final repoInfo = _parseRepositoryUrl(repositoryUrl);
      if (repoInfo == null) {
        throw Exception('无效的仓库URL格式');
      }
      
      final platform = repoInfo['platform'];
      if (platform == null) {
        throw Exception('无法确定仓库平台');
      }
      
      // 使用API获取scripts目录下的所有文件
      String apiUrl;
      if (platform == 'github') {
        apiUrl = 'https://api.github.com/repos/${repoInfo['owner']}/${repoInfo['repo']}/contents/scripts?ref=$branch';
      } else if (platform == 'gitee') {
        apiUrl = 'https://gitee.com/api/v5/repos/${repoInfo['owner']}/${repoInfo['repo']}/contents/scripts?ref=$branch';
      } else {
        throw Exception('不支持的平台');
      }
      
      final headers = _buildHeaders(tokenKey, tokenValue, platform);
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode != 200) {
        throw Exception('获取scripts目录失败: ${response.statusCode}');
      }

      final List<dynamic> contents = jsonDecode(response.body);
      
      // 获取应用文档目录
      final appDir = await _getAppDirectory();
      final scriptsDir = Directory(path.join(appDir.path, 'repository', 'scripts'));
      if (!await scriptsDir.exists()) {
        await scriptsDir.create(recursive: true);
      }

      // 下载每个文件
      for (final item in contents) {
        if (item['type'] == 'file') {
          final fileName = item['name'];
          
          // 对于公开仓库，使用raw URL下载（更快且兼容性好）
          String downloadUrl;
          final platformValue = platform;
          if (tokenKey == null || tokenValue == null) {
            // 公开仓库：使用raw URL
            downloadUrl = _convertToRawUrl(repositoryUrl, branch, 'scripts/$fileName', platformValue);
          } else {
            // 私有仓库：使用API返回的download_url
            if (platformValue == 'github') {
              downloadUrl = item['download_url'] ?? '';
            } else if (platformValue == 'gitee') {
              // Gitee API 可能没有 download_url，使用 raw URL + token
              downloadUrl = _convertToRawUrl(repositoryUrl, branch, 'scripts/$fileName', platformValue);
            } else {
              downloadUrl = '';
            }
          }

          if (downloadUrl.isNotEmpty) {
            final headers = tokenKey != null && tokenValue != null 
                ? _buildHeaders(tokenKey, tokenValue, platformValue)
                : <String, String>{};
            final fileResponse = await http.get(Uri.parse(downloadUrl), headers: headers);
            if (fileResponse.statusCode == 200) {
              final filePath = path.join(scriptsDir.path, fileName);
              final file = File(filePath);
              await file.writeAsBytes(fileResponse.bodyBytes);
            }
          }
        } else if (item['type'] == 'dir') {
          // 递归下载子目录（如果需要）
          // 当前实现只下载scripts根目录下的文件
        }
      }

      return scriptsDir.path;
    } catch (e) {
      throw Exception('下载scripts文件夹失败: $e');
    }
  }

  /// 下载单个文件
  /// 
  /// [repositoryUrl] 仓库URL（从配置中传入）
  /// [branch] 分支名称
  /// [filePath] 文件路径
  /// [tokenKey] Token Key（私有仓库需要）
  /// [tokenValue] Token Value（私有仓库需要）
  static Future<Uint8List?> _downloadFile({
    required String repositoryUrl,
    required String branch,
    required String filePath,
    String? tokenKey,
    String? tokenValue,
  }) async {
    try {
      final uri = Uri.parse(repositoryUrl);
      
      final repoInfo = _parseRepositoryUrl(repositoryUrl);
      if (repoInfo == null) {
        throw Exception('无法解析仓库URL');
      }
      
      final platform = repoInfo['platform'];
      
      // 检查是否是raw URL格式
      bool isRawUrl = uri.host == 'raw.githubusercontent.com' || 
                      uri.host == 'gitee.com' ||
                      uri.host.contains('raw.');
      
      // 对于公开仓库，使用raw链接（更快）
      // 对于私有仓库，使用API
      if (tokenKey == null || tokenValue == null) {
        String rawUrl;
        
        if (isRawUrl && platform == 'github') {
          // 如果已经是raw URL，直接使用，但需要更新分支和文件路径
          rawUrl = _buildRawUrl(repositoryUrl, branch, filePath);
        } else {
          // 从标准URL转换为raw URL
          rawUrl = _convertToRawUrl(repositoryUrl, branch, filePath, platform!);
        }
        
        final response = await http.get(Uri.parse(rawUrl));
        
        if (response.statusCode == 200) {
          return response.bodyBytes;
        } else {
          throw Exception('下载文件失败: ${response.statusCode}');
        }
      } else {
        // 私有仓库：使用API
        String apiUrl;
        if (platform == 'github') {
          apiUrl = 'https://api.github.com/repos/${repoInfo['owner']}/${repoInfo['repo']}/contents/$filePath?ref=$branch';
        } else if (platform == 'gitee') {
          apiUrl = 'https://gitee.com/api/v5/repos/${repoInfo['owner']}/${repoInfo['repo']}/contents/$filePath?ref=$branch';
        } else {
          throw Exception('不支持的平台');
        }
        
        final headers = _buildHeaders(tokenKey, tokenValue, platform!);
        final response = await http.get(Uri.parse(apiUrl), headers: headers);

        if (response.statusCode != 200) {
          throw Exception('获取文件失败: ${response.statusCode}');
        }

        final Map<String, dynamic> fileInfo = jsonDecode(response.body);
        if (fileInfo['encoding'] == 'base64' && fileInfo['content'] != null) {
          return base64Decode(fileInfo['content']);
        } else {
          throw Exception('不支持的文件编码格式');
        }
      }
    } catch (e) {
      throw Exception('下载文件失败: $e');
    }
  }
  
  /// 将标准仓库URL转换为raw URL
  /// 
  /// 例如：
  /// - https://github.com/owner/repo -> https://raw.githubusercontent.com/owner/repo/branch/path
  /// - https://gitee.com/owner/repo -> https://gitee.com/owner/repo/raw/branch/path
  static String _convertToRawUrl(String repositoryUrl, String branch, String filePath, String platform) {
    final uri = Uri.parse(repositoryUrl);
    
    // 如果已经是raw URL
    if (uri.host == 'raw.githubusercontent.com' && platform == 'github') {
      // raw URL格式: raw.githubusercontent.com/owner/repo/branch/path
      // 需要替换分支和文件路径
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2) {
        return 'https://raw.githubusercontent.com/${pathSegments[0]}/${pathSegments[1]}/$branch/$filePath';
      }
      return '$repositoryUrl/$branch/$filePath';
    }
    
    // 从标准URL提取路径
    final pathSegments = uri.pathSegments;
    if (pathSegments.length < 2) {
      throw Exception('无效的仓库URL格式，需要包含owner和repo');
    }
    
    String owner = pathSegments[0];
    String repo = pathSegments[1];
    
    // 移除.git后缀
    if (repo.endsWith('.git')) {
      repo = repo.substring(0, repo.length - 4);
    }
    
    // 根据平台构建raw URL
    if (platform == 'github') {
      // GitHub raw URL: https://raw.githubusercontent.com/owner/repo/branch/path
      return 'https://raw.githubusercontent.com/$owner/$repo/$branch/$filePath';
    } else if (platform == 'gitee') {
      // Gitee raw URL: https://gitee.com/owner/repo/raw/branch/path
      return 'https://gitee.com/$owner/$repo/raw/$branch/$filePath';
    } else {
      throw Exception('不支持的平台: $platform');
    }
  }
  
  /// 从现有raw URL构建新的raw URL（更新分支和文件路径）
  static String _buildRawUrl(String rawUrl, String branch, String filePath) {
    final uri = Uri.parse(rawUrl);
    final pathSegments = uri.pathSegments;
    
    // raw URL格式: raw.githubusercontent.com/owner/repo/branch/path
    if (pathSegments.length >= 2) {
      return 'https://raw.githubusercontent.com/${pathSegments[0]}/${pathSegments[1]}/$branch/$filePath';
    }
    
    throw Exception('无效的raw URL格式');
  }

  /// 保存文件到本地
  static Future<String> _saveFile({
    required String fileName,
    required Uint8List bytes,
    required String subdirectory,
  }) async {
    final appDir = await _getAppDirectory();
    final targetDir = Directory(path.join(appDir.path, subdirectory));
    
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final filePath = path.join(targetDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  /// 解析GitHub/Gitee仓库URL，提取owner和repo
  /// 
  /// 支持的格式：
  /// - https://github.com/owner/repo
  /// - https://github.com/owner/repo.git
  /// - https://gitee.com/owner/repo
  /// - https://gitee.com/owner/repo.git
  /// 
  /// 返回：包含'owner'、'repo'和'platform'的Map，失败时返回null
  static Map<String, String>? _parseRepositoryUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      // 验证域名（支持GitHub和Gitee）
      String? platform;
      if (uri.host == 'github.com') {
        platform = 'github';
      } else if (uri.host == 'gitee.com') {
        platform = 'gitee';
      } else {
        return null;
      }

      final pathSegments = uri.pathSegments;
      if (pathSegments.length < 2) {
        return null;
      }

      String repo = pathSegments[1];
      // 移除.git后缀（如果有）
      if (repo.endsWith('.git')) {
        repo = repo.substring(0, repo.length - 4);
      }

      return {
        'owner': pathSegments[0],
        'repo': repo,
        'platform': platform,
      };
    } catch (e) {
      return null;
    }
  }

  /// 构建HTTP请求头
  static Map<String, String> _buildHeaders(String? tokenKey, String? tokenValue, String platform) {
    final headers = <String, String>{};
    
    // 根据平台设置Accept header
    if (platform == 'github') {
      headers['Accept'] = 'application/vnd.github.v3+json';
    } else if (platform == 'gitee') {
      // Gitee API 不需要特殊的 Accept header
    }

    // 如果有token，添加到请求头
    if (tokenKey != null && tokenKey.isNotEmpty && 
        tokenValue != null && tokenValue.isNotEmpty) {
      // 如果是标准的Authorization header
      if (tokenKey.toLowerCase() == 'authorization' || tokenKey.toLowerCase() == 'token') {
        if (platform == 'gitee') {
          // Gitee API 使用 Bearer token
          headers['Authorization'] = 'Bearer $tokenValue';
        } else {
          // GitHub API 使用 token 前缀
          headers['Authorization'] = 'token $tokenValue';
        }
      } else {
        // 自定义header
        headers[tokenKey] = tokenValue;
      }
    }

    return headers;
  }

  /// 获取应用目录
  static Future<Directory> _getAppDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('Web平台不支持本地文件存储');
    }
    return await getApplicationDocumentsDirectory();
  }
}
