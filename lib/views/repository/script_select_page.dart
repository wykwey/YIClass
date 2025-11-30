import 'package:flutter/material.dart';
import '../../data/school_index.dart';
import '../../services/repository/script_file_service.dart';
import '../../services/repository/repository_config_service.dart';
import '../../services/repository/repository_download_service.dart';
import '../../components/feedback/notifications.dart';
import '../../components/layout/appbar.dart';
import '../../components/layout/cards.dart';
import '../../components/inputs/components.dart';
import '../../routes/route_utils.dart';

/// 脚本选择页
class ScriptSelectPage extends StatefulWidget {
  final SchoolEntry school;

  const ScriptSelectPage({
    super.key,
    required this.school,
  });

  @override
  State<ScriptSelectPage> createState() => _ScriptSelectPageState();
}

class _ScriptSelectPageState extends State<ScriptSelectPage> {
  Map<String, bool> _scriptExistsMap = {};
  bool _isChecking = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _checkScriptsExist();
  }

  /// 批量检查脚本文件是否存在
  Future<void> _checkScriptsExist() async {
    setState(() => _isChecking = true);
    
    final scriptNames = widget.school.scripts
        .map((script) => script.scriptName)
        .toList();
    
    final existsMap = await ScriptFileService.checkScriptsExist(scriptNames);
    
    if (mounted) {
      setState(() {
        _scriptExistsMap = existsMap;
        _isChecking = false;
      });
    }
  }

  /// 下载当前学校的所有脚本
  Future<void> _downloadAllScripts() async {
    setState(() => _isDownloading = true);

    try {
      final config = await RepositoryConfigService.getConfig();
      if (!config.isValid) {
        Notifications.sonner(context, message: '请先配置仓库信息');
        return;
      }

      final scriptNames = widget.school.scripts
          .map((script) => script.scriptName)
          .toList();

      final successCount = await RepositoryDownloadService.downloadScripts(
        config,
        scriptNames,
      );

      if (mounted) {
        if (successCount > 0) {
          Notifications.sonner(context, message: '成功下载 $successCount/${scriptNames.length} 个脚本');
          // 重新检查脚本文件状态
          await _checkScriptsExist();
        } else {
          Notifications.sonner(context, message: '下载失败，请检查网络连接或仓库配置');
        }
      }
    } catch (e) {
      if (mounted) {
        Notifications.sonner(context, message: '下载失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  /// 下载单个脚本
  Future<void> _downloadScript(String scriptName) async {
    try {
      final config = await RepositoryConfigService.getConfig();
      if (!config.isValid) {
        if (mounted) {
          Notifications.sonner(context, message: '请先配置仓库信息');
        }
        return;
      }

      final successCount = await RepositoryDownloadService.downloadScripts(
        config,
        [scriptName],
      );

      if (mounted) {
        if (successCount > 0) {
          Notifications.sonner(context, message: '脚本下载成功');
          // 重新检查脚本文件状态
          await _checkScriptsExist();
        } else {
          Notifications.sonner(context, message: '下载失败，请检查网络连接或仓库配置');
        }
      }
    } catch (e) {
      if (mounted) {
        Notifications.sonner(context, message: '下载失败: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: YicoreAppBar(
        title: widget.school.school,
        centerTitle: true,
        actions: [
          if (_isChecking || _isDownloading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            YicoreAppBarAction(
              icon: Icons.download,
              onPressed: _downloadAllScripts,
            ),
            YicoreAppBarAction(
              icon: Icons.refresh,
              onPressed: _checkScriptsExist,
            ),
          ],
        ],
      ),
      body: widget.school.scripts.isEmpty
          ? const Center(
              child: Text('该学校暂无可用脚本'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.school.scripts.length,
              itemBuilder: (context, index) {
                final script = widget.school.scripts[index];
                final isDownloaded = _scriptExistsMap[script.scriptName] ?? false;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildScriptCard(context, script, isDownloaded),
                );
              },
            ),
    );
  }

  Widget _buildScriptCard(
    BuildContext context,
    ScriptEntry script,
    bool isDownloaded,
  ) {
    return Opacity(
      opacity: isDownloaded ? 1.0 : 0.5,
      child: YicoreCard(
        padding: const EdgeInsets.all(16),
        onTap: isDownloaded
            ? () {
                RouteUtils.pushEduImport(
                  context,
                  script: script,
                );
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 名称和右侧按钮
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    script.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDownloaded ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                YicoreIconButton(
                  icon: isDownloaded ? Icons.check_circle : Icons.download,
                  size: 36,
                  showBorder: true,
                  onPressed: isDownloaded ? null : () => _downloadScript(script.scriptName),
                ),
              ],
            ),
            // 说明
            if (script.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                script.description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDownloaded ? Colors.black87 : Colors.grey[500],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // 贡献者
            if (script.author.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '贡献者: ${script.author}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDownloaded ? Colors.grey : Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

