import 'package:flutter/material.dart';
import '../../components/feedback/notifications.dart';
import '../../components/layout/settingscard.dart';
import '../../components/inputs/components.dart';
import '../../components/layout/appbar.dart';
import '../../components/inputs/segmented_control.dart';
import '../../services/repository/repository_config_service.dart';
import '../../services/repository/repository_download_service.dart';

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
    } catch (e) {
      if (mounted) {
        Notifications.sonner(context, message: '加载配置失败: $e');
      }
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
      enabled: true,
    );

    if (!config.isValid) {
      Notifications.sonner(context, message: '请填写完整的配置信息');
      return;
    }

    if (config.repositoryType == 'private' && !config.isPrivateValid) {
      Notifications.sonner(context, message: '私有仓库需要填写Token Key和Token Value');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await RepositoryConfigService.saveConfig(config);
      if (!mounted) return;
      Notifications.sonner(context, message: '配置保存成功');
    } catch (e) {
      if (!mounted) return;
      Notifications.sonner(context, message: '保存配置失败: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
      enabled: true,
    );

    if (!config.isValid) {
      Notifications.sonner(context, message: '请填写完整的配置信息');
      return;
    }

    if (config.repositoryType == 'private' && !config.isPrivateValid) {
      Notifications.sonner(context, message: '私有仓库需要填写Token Key和Token Value');
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final filePath = await RepositoryDownloadService.downloadIndex(config);
      if (!mounted) return;
      if (filePath != null) {
        Notifications.sonner(context, message: '索引下载成功\n保存位置: $filePath');
      } else {
        Notifications.sonner(context, message: '下载失败: 未返回文件路径');
      }
    } catch (e) {
      if (!mounted) return;
      Notifications.sonner(context, message: '下载失败: $e');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
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
      enabled: true,
    );

    if (!config.isValid) {
      Notifications.sonner(context, message: '请填写完整的配置信息');
      return;
    }

    if (config.repositoryType == 'private' && !config.isPrivateValid) {
      Notifications.sonner(context, message: '私有仓库需要填写Token Key和Token Value');
      return;
    }

    setState(() => _isDownloadingFull = true);

    try {
      final result = await RepositoryDownloadService.downloadFullRepository(config);
      final indexPath = result['index'];
      final scriptsPath = result['scripts'];
      
      if (!mounted) return;
      if (indexPath != null && scriptsPath != null) {
        Notifications.sonner(
          context,
          message: '下载完成\n索引文件: $indexPath\n脚本目录: $scriptsPath',
        );
      } else {
        Notifications.sonner(context, message: '下载完成，但部分文件可能未下载成功');
      }
    } catch (e) {
      if (!mounted) return;
      Notifications.sonner(context, message: '下载失败: $e');
    } finally {
      if (mounted) setState(() => _isDownloadingFull = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YicoreAppBar(
        title: '教务导入配置',
        centerTitle: true,
        actions: [
          YicoreIconButton(
            icon: Icons.save,
            onPressed: _isLoading || _isSaving ? null : _saveConfig,
            showBorder: false,
          ),
        ],
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // 基础配置
                SettingsBlock(
                  title: '基础配置',
                  children: [
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
                  ],
                ),

                const SizedBox(height: 16),

                // 操作按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: YicoreButton(
                          text: _isDownloading ? '下载中...' : '下载索引',
                          onPressed: (_isDownloading || _isDownloadingFull || _isSaving) ? null : _downloadIndex,
                          isLoading: _isDownloading,
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: YicoreButton(
                          text: _isDownloadingFull ? '下载中...' : '下载完整仓库',
                          onPressed: (_isDownloading || _isDownloadingFull || _isSaving) ? null : _downloadFullRepository,
                          isLoading: _isDownloadingFull,
                          isOutlined: true,
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildRepositoryTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '仓库类型',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          YicoreSegmentedControl(
            items: const [
              SegmentedItem(label: '官方', value: 'official'),
              SegmentedItem(label: '镜像', value: 'mirror'),
              SegmentedItem(label: '自定义', value: 'custom'),
              SegmentedItem(label: '私有', value: 'private'),
            ],
            selectedValue: _repositoryType,
            onChanged: (value) {
              setState(() {
                _repositoryType = value;
              });
            },
            size: SegmentedControlSize.medium,
            showBorder: true,
          ),
        ],
      ),
    );
  }
}


