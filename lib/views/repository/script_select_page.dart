import 'package:flutter/material.dart';
import '../../data/school_index.dart';
import '../../services/repository/script_file_service.dart';
import '../../services/repository/repository_config_service.dart';
import '../../services/repository/repository_download_service.dart';
import '../../utils/feedback_utils.dart';
import 'edu_import_page.dart';

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
        FeedbackUtils.show(context, '请先配置仓库信息');
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
          FeedbackUtils.show(context, '成功下载 $successCount/${scriptNames.length} 个脚本');
          // 重新检查脚本文件状态
          await _checkScriptsExist();
        } else {
          FeedbackUtils.show(context, '下载失败，请检查网络连接或仓库配置');
        }
      }
    } catch (e) {
      if (mounted) {
        FeedbackUtils.show(context, '下载失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.school.school),
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
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadAllScripts,
              tooltip: '下载所有脚本',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _checkScriptsExist,
              tooltip: '刷新',
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
                return _buildScriptCard(context, script, isDownloaded);
              },
            ),
    );
  }

  Widget _buildScriptCard(
    BuildContext context,
    ScriptEntry script,
    bool isDownloaded,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
        child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EduImportPage(script: script),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 名称和下载状态图标
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      script.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDownloaded ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDownloaded ? Icons.check : Icons.download,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // 说明
              if (script.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  script.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

