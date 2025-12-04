import 'package:flutter/material.dart';
import '../../services/ai/ai_config_service.dart';
import '../../services/ai/ai_service.dart';
import '../../components/feedback/notifications.dart';
import '../../components/layout/appbar.dart';
import '../../components/layout/settingscard.dart';
import '../../components/inputs/components.dart';
import '../../components/layout/cards.dart';

class AIConfigPage extends StatefulWidget {
  const AIConfigPage({super.key});

  @override
  State<AIConfigPage> createState() => _AIConfigPageState();
}

class _AIConfigPageState extends State<AIConfigPage> {
  final _apiKeyController = TextEditingController();
  final _endpointController = TextEditingController();
  final _visionModelController = TextEditingController();
  final _textModelController = TextEditingController();
  
  bool _enableImageImport = true;
  bool _enableTableImport = true;
  bool _enableTextImport = true;
  bool _enableWebImport = false;
  bool _isLoading = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _endpointController.dispose();
    _visionModelController.dispose();
    _textModelController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    
    try {
      final config = await AIConfigService.getConfig();
      _apiKeyController.text = config.apiKey;
      _endpointController.text = config.endpoint;
      _visionModelController.text = config.visionModel;
      _textModelController.text = config.textModel;
      _enableImageImport = config.enableImageImport;
      _enableTableImport = config.enableTableImport;
      _enableTextImport = config.enableTextImport;
      _enableWebImport = config.enableWebImport;
    } catch (e) {
      if (mounted) {
        Notifications.sonner(context, message: '加载配置失败: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    final config = AIConfig(
      apiKey: _apiKeyController.text.trim(),
      endpoint: _endpointController.text.trim(),
      visionModel: _visionModelController.text.trim(),
      textModel: _textModelController.text.trim(),
      enabled: true,
      enableImageImport: _enableImageImport,
      enableTableImport: _enableTableImport,
      enableTextImport: _enableTextImport,
      enableWebImport: _enableWebImport,
    );

    if (!config.isValid) {
      Notifications.sonner(context, message: '请填写API Key、接口地址和文本模型');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AIConfigService.saveConfig(config);
      if (!mounted) return;
      Notifications.sonner(context, message: '配置保存成功');
    } catch (e) {
      if (!mounted) return;
      Notifications.sonner(context, message: '保存配置失败: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _testConfig() async {
    if (_apiKeyController.text.isEmpty || _endpointController.text.isEmpty) {
      Notifications.sonner(context, message: '请先填写API Key和接口地址');
      return;
    }

    if (_textModelController.text.isEmpty) {
      Notifications.sonner(context, message: '请先填写文本模型');
      return;
    }

    setState(() => _isTesting = true);

    try {
      // 创建临时配置进行测试
      final tempConfig = AIConfig(
        apiKey: _apiKeyController.text,
        endpoint: _endpointController.text,
        visionModel: _visionModelController.text,
        textModel: _textModelController.text,
        enabled: true,
        enableImageImport: _enableImageImport,
        enableTableImport: _enableTableImport,
        enableTextImport: _enableTextImport,
      );
      
      // 临时保存配置用于测试
      await AIConfigService.saveConfig(tempConfig);
      
      // 测试配置
      final success = await AIService.testConfig();
      
      if (!mounted) return;
      if (success) {
        Notifications.sonner(context, message: '配置测试成功');
      } else {
        Notifications.sonner(context, message: '配置测试失败');
      }
    } catch (e) {
      if (!mounted) return;
      Notifications.sonner(context, message: '配置测试失败: $e');
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YicoreAppBar(
        title: 'AI导入配置',
        centerTitle: true,
        actions: [
          YicoreAppBarAction(
            icon: Icons.save,
            onPressed: _isLoading ? null : _saveConfig,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'API Key',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _apiKeyController,
                            obscureText: true,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: '输入你的API Key',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: YicoreTextField(
                        labelText: '接口地址',
                        controller: _endpointController,
                        hintText: '输入API接口地址',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: YicoreTextField(
                        labelText: '视觉模型',
                        controller: _visionModelController,
                        hintText: '如: gpt-4-vision-preview',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: YicoreTextField(
                        labelText: '文本模型',
                        controller: _textModelController,
                        hintText: '如: gpt-4',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 功能开关
                SettingsBlock(
                  title: '功能开关',
                  children: [
                    SettingsItem.switch_(
                      title: '图片导入',
                      description: '支持课程表图片识别',
                      value: _enableImageImport,
                      onChanged: (value) => setState(() => _enableImageImport = value),
                      inBlock: true,
                    ),
                    SettingsItem.switch_(
                      title: '表格导入',
                      description: '支持表格数据解析',
                      value: _enableTableImport,
                      onChanged: (value) => setState(() => _enableTableImport = value),
                      inBlock: true,
                    ),
                    SettingsItem.switch_(
                      title: '文字导入',
                      description: '支持文字描述解析',
                      value: _enableTextImport,
                      onChanged: (value) => setState(() => _enableTextImport = value),
                      inBlock: true,
                    ),
                    SettingsItem.switch_(
                      title: 'AI 教务导入',
                      description: '支持教务网页 AI 分析导入',
                      value: _enableWebImport,
                      onChanged: (value) => setState(() => _enableWebImport = value),
                      inBlock: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 预设配置
                YicoreCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '预设配置',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          YicoreButton(
                            text: 'OpenAI',
                            isOutlined: true,
                            onPressed: () => _setPreset('openai'),
                          ),
                          YicoreButton(
                            text: 'Claude',
                            isOutlined: true,
                            onPressed: () => _setPreset('claude'),
                          ),
                          YicoreButton(
                            text: 'Gemini',
                            isOutlined: true,
                            onPressed: () => _setPreset('gemini'),
                          ),
                          YicoreButton(
                            text: 'DeepSeek',
                            isOutlined: true,
                            onPressed: () => _setPreset('deepseek'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: YicoreButton(
                        text: _isTesting ? '测试中...' : '测试配置',
                        onPressed: _isTesting ? null : _testConfig,
                        isLoading: _isTesting,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: YicoreButton(
                        text: '保存配置',
                        onPressed: _isLoading ? null : _saveConfig,
                        isOutlined: true,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }


  void _setPreset(String provider) {
    final preset = AIConfig.getPresetConfig(provider);
    setState(() {
      _endpointController.text = preset.endpoint;
      _visionModelController.text = preset.visionModel;
      _textModelController.text = preset.textModel;
    });
  }
}
