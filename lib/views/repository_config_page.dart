import 'package:flutter/material.dart';
import '../utils/feedback_utils.dart';
import '../services/repository/repository_config_service.dart';
import '../services/repository/repository_download_service.dart';

class RepositoryConfigPage extends StatefulWidget {
  const RepositoryConfigPage({super.key});

  @override
  State<RepositoryConfigPage> createState() => _RepositoryConfigPageState();
}

class _RepositoryConfigPageState extends State<RepositoryConfigPage> {
  final _repositoryUrlController = TextEditingController();
  final _scriptsBranchController = TextEditingController();
  final _tokenKeyController = TextEditingController();
  final _tokenValueController = TextEditingController();
  
  String _repositoryType = 'official'; // 'official', 'mirror', 'custom', 'private'
  bool _enableImport = false;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDownloading = false;
  bool _isDownloadingFull = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _repositoryUrlController.dispose();
    _scriptsBranchController.dispose();
    _tokenKeyController.dispose();
    _tokenValueController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    
    try {
      final config = await RepositoryConfigService.getConfig();
      // 官方仓库和镜像仓库不加载URL和分支（使用固定值）
      if (config.repositoryType != 'official' && config.repositoryType != 'mirror') {
        _repositoryUrlController.text = config.repositoryUrl;
        _scriptsBranchController.text = config.scriptsBranch;
      }
      _tokenKeyController.text = config.tokenKey;
      _tokenValueController.text = config.tokenValue;
      _repositoryType = config.repositoryType;
      _enableImport = config.enabled;
    } catch (e) {
      _showErrorSnackBar('加载配置失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    final config = RepositoryConfig(
      repositoryUrl: _repositoryType == 'official'
          ? RepositoryConfigService.officialRepositoryUrl
          : _repositoryType == 'mirror'
              ? RepositoryConfigService.mirrorRepositoryUrl
              : _repositoryUrlController.text.trim(),
      repositoryType: _repositoryType,
      indexBranch: RepositoryConfigService.officialIndexBranch, // 索引分支固定为 index-data
      scriptsBranch: (_repositoryType == 'official' || _repositoryType == 'mirror')
          ? 'main' // 官方仓库和镜像仓库使用默认分支
          : (_scriptsBranchController.text.trim().isEmpty 
              ? 'main' 
              : _scriptsBranchController.text.trim()),
      tokenKey: _tokenKeyController.text.trim(),
      tokenValue: _tokenValueController.text.trim(),
      enabled: _enableImport,
    );

    if (!config.isValid) {
      FeedbackUtils.show(context, '请填写完整的配置信息');
      return;
    }

    if (config.repositoryType == 'private' && !config.isPrivateValid) {
      FeedbackUtils.show(context, '私有仓库需要填写Token Key和Token Value');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await RepositoryConfigService.saveConfig(config);
      FeedbackUtils.show(context, '配置保存成功');
    } catch (e) {
      FeedbackUtils.show(context, '保存配置失败: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _downloadIndex() async {
    final config = RepositoryConfig(
      repositoryUrl: _repositoryType == 'official'
          ? RepositoryConfigService.officialRepositoryUrl
          : _repositoryType == 'mirror'
              ? RepositoryConfigService.mirrorRepositoryUrl
              : _repositoryUrlController.text.trim(),
      repositoryType: _repositoryType,
      indexBranch: RepositoryConfigService.officialIndexBranch, // 索引分支固定为 index-data
      scriptsBranch: (_repositoryType == 'official' || _repositoryType == 'mirror')
          ? 'main' // 官方仓库和镜像仓库使用默认分支
          : (_scriptsBranchController.text.trim().isEmpty 
              ? 'main' 
              : _scriptsBranchController.text.trim()),
      tokenKey: _tokenKeyController.text.trim(),
      tokenValue: _tokenValueController.text.trim(),
      enabled: _enableImport,
    );

    if (!config.isValid) {
      FeedbackUtils.show(context, '请填写完整的配置信息');
      return;
    }

    if (config.repositoryType == 'private' && !config.isPrivateValid) {
      FeedbackUtils.show(context, '私有仓库需要填写Token Key和Token Value');
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final filePath = await RepositoryDownloadService.downloadIndex(config);
      if (filePath != null) {
        FeedbackUtils.show(context, '索引下载成功\n保存位置: $filePath');
      } else {
        FeedbackUtils.show(context, '下载失败: 未返回文件路径');
      }
    } catch (e) {
      FeedbackUtils.show(context, '下载失败: $e');
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _downloadFullRepository() async {
    final config = RepositoryConfig(
      repositoryUrl: _repositoryType == 'official'
          ? RepositoryConfigService.officialRepositoryUrl
          : _repositoryType == 'mirror'
              ? RepositoryConfigService.mirrorRepositoryUrl
              : _repositoryUrlController.text.trim(),
      repositoryType: _repositoryType,
      indexBranch: RepositoryConfigService.officialIndexBranch, // 索引分支固定为 index-data
      scriptsBranch: (_repositoryType == 'official' || _repositoryType == 'mirror')
          ? 'main' // 官方仓库和镜像仓库使用默认分支
          : (_scriptsBranchController.text.trim().isEmpty 
              ? 'main' 
              : _scriptsBranchController.text.trim()),
      tokenKey: _tokenKeyController.text.trim(),
      tokenValue: _tokenValueController.text.trim(),
      enabled: _enableImport,
    );

    if (!config.isValid) {
      FeedbackUtils.show(context, '请填写完整的配置信息');
      return;
    }

    if (config.repositoryType == 'private' && !config.isPrivateValid) {
      FeedbackUtils.show(context, '私有仓库需要填写Token Key和Token Value');
      return;
    }

    setState(() => _isDownloadingFull = true);

    try {
      final result = await RepositoryDownloadService.downloadFullRepository(config);
      final indexPath = result['index'];
      final scriptsPath = result['scripts'];
      
      if (indexPath != null && scriptsPath != null) {
        FeedbackUtils.show(
          context,
          '下载完成\n索引文件: $indexPath\n脚本目录: $scriptsPath',
        );
      } else {
        FeedbackUtils.show(context, '下载完成，但部分文件可能未下载成功');
      }
    } catch (e) {
      FeedbackUtils.show(context, '下载失败: $e');
    } finally {
      setState(() => _isDownloadingFull = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('教务导入配置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading || _isSaving ? null : _saveConfig,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 基础配置
                _buildSection('基础配置', [
                  _buildRepositoryTypeSelector(),
                  // 官方仓库和镜像仓库不显示URL和分支输入框
                  if (_repositoryType != 'official' && _repositoryType != 'mirror') ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      'GitHub仓库URL',
                      _repositoryUrlController,
                      hintText: '',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      '脚本分支名称',
                      _scriptsBranchController,
                      hintText: '如: main, master',
                    ),
                  ],
                  if (_repositoryType == 'private') ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Token Key',
                      _tokenKeyController,
                      hintText: '输入Token Key',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Token Value',
                      _tokenValueController,
                      obscureText: true,
                      hintText: '输入Token Value',
                    ),
                  ],
                ]),

                const SizedBox(height: 24),

                // 功能开关
                _buildSection('功能开关', [
                  SwitchListTile(
                    title: const Text('启用教务导入'),
                    subtitle: const Text('启用教务系统数据导入功能'),
                    value: _enableImport,
                    onChanged: (value) => setState(() => _enableImport = value),
                  ),
                ]),

                const SizedBox(height: 24),

                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (_isDownloading || _isDownloadingFull || _isSaving) ? null : _downloadIndex,
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.download),
                        label: Text(_isDownloading ? '下载中...' : '下载索引'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: (_isDownloading || _isDownloadingFull || _isSaving) ? null : _downloadFullRepository,
                        icon: _isDownloadingFull
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.download_for_offline),
                        label: Text(_isDownloadingFull ? '下载中...' : '下载完整仓库'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildRepositoryTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '仓库类型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            const spacing = 8.0; // 分段间隙
            final buttonWidth = (totalWidth - spacing * 3) / 4; // 4段，3个间隙

            return SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'official',
                  label: Text('官方'),
                ),
                ButtonSegment(
                  value: 'mirror',
                  label: Text('官方镜像'),
                ),
                ButtonSegment(
                  value: 'custom',
                  label: Text('自定义'),
                ),
                ButtonSegment(
                  value: 'private',
                  label: Text('私有'),
                ),
              ],
              selected: {_repositoryType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _repositoryType = newSelection.first;
                });
              },
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                minimumSize: Size(buttonWidth, 40),
                maximumSize: Size(buttonWidth, 40),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ));
          },
        ),
      ],
    );
  }
}


