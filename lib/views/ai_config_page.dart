import 'package:flutter/material.dart';
import '../services/ai/ai_config_service.dart';
import '../services/ai/ai_service.dart';
import '../utils/feedback_utils.dart';

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
    } catch (e) {
      _showErrorSnackBar('加载配置失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    if (_apiKeyController.text.isEmpty || _endpointController.text.isEmpty) {
      FeedbackUtils.show(context, '请填写API Key和Endpoint');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final config = AIConfig(
        apiKey: _apiKeyController.text.trim(),
        endpoint: _endpointController.text.trim(),
        visionModel: _visionModelController.text.trim(),
        textModel: _textModelController.text.trim(),
        enabled: true,
        enableImageImport: _enableImageImport,
        enableTableImport: _enableTableImport,
        enableTextImport: _enableTextImport,
      );

      await AIConfigService.saveConfig(config);
      FeedbackUtils.show(context, '配置保存成功');
    } catch (e) {
      FeedbackUtils.show(context, '保存配置失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testConfig() async {
    print('🎯 [UI测试] 用户点击测试配置按钮');
    
    if (_apiKeyController.text.isEmpty || _endpointController.text.isEmpty) {
      print('❌ [UI测试] 验证失败: API Key或Endpoint为空');
      FeedbackUtils.show(context, '请先填写API Key和Endpoint');
      return;
    }

    if (_textModelController.text.isEmpty) {
      print('❌ [UI测试] 验证失败: 文本模型为空');
      FeedbackUtils.show(context, '请先填写文本模型');
      return;
    }

    print('✅ [UI测试] 输入验证通过');
    print('📋 [UI测试] 用户输入信息:');
    print('   - API Key: ${_apiKeyController.text.substring(0, 8)}...');
    print('   - Endpoint: ${_endpointController.text}');
    print('   - 文本模型: ${_textModelController.text}');
    print('   - 视觉模型: ${_visionModelController.text}');
    print('   - 图片导入: $_enableImageImport');
    print('   - 表格导入: $_enableTableImport');
    print('   - 文字导入: $_enableTextImport');

    setState(() => _isTesting = true);
    print('🔄 [UI测试] 设置测试状态为true');

    try {
      print('🚀 [UI测试] 开始调用AI服务测试...');
      
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
      
      if (success) {
        print('🎉 [UI测试] AI服务测试成功');
        FeedbackUtils.show(context, '配置测试成功');
      } else {
        print('❌ [UI测试] AI服务测试失败');
        FeedbackUtils.show(context, '配置测试失败');
      }
    } catch (e) {
      print('💥 [UI测试] 测试过程出现异常: $e');
      print('🔍 [UI测试] 异常类型: ${e.runtimeType}');
      FeedbackUtils.show(context, '配置测试失败: $e');
    } finally {
      setState(() => _isTesting = false);
      print('🔄 [UI测试] 设置测试状态为false');
      print('🏁 [UI测试] 测试流程结束');
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
        title: const Text('AI导入配置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveConfig,
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
                  _buildTextField(
                    'API Key',
                    _apiKeyController,
                    obscureText: true,
                    hintText: '输入你的API Key',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'API Endpoint',
                    _endpointController,
                    hintText: '输入API端点URL',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    '视觉模型',
                    _visionModelController,
                    hintText: '如: gpt-4-vision-preview',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    '文本模型',
                    _textModelController,
                    hintText: '如: gpt-4',
                  ),
                ]),

                const SizedBox(height: 24),

                // 功能开关
                _buildSection('功能开关', [
                  SwitchListTile(
                    title: const Text('图片导入'),
                    subtitle: const Text('支持课程表图片识别'),
                    value: _enableImageImport,
                    onChanged: (value) => setState(() => _enableImageImport = value),
                  ),
                  SwitchListTile(
                    title: const Text('表格导入'),
                    subtitle: const Text('支持表格数据解析'),
                    value: _enableTableImport,
                    onChanged: (value) => setState(() => _enableTableImport = value),
                  ),
                  SwitchListTile(
                    title: const Text('文字导入'),
                    subtitle: const Text('支持文字描述解析'),
                    value: _enableTextImport,
                    onChanged: (value) => setState(() => _enableTextImport = value),
                  ),
                ]),

                const SizedBox(height: 24),

                // 预设配置
                _buildSection('预设配置', [
                  _buildPresetButton('OpenAI', () => _setPresetOpenAI()),
                  const SizedBox(height: 8),
                  _buildPresetButton('Claude', () => _setPresetClaude()),
                  const SizedBox(height: 8),
                  _buildPresetButton('Gemini', () => _setPresetGemini()),
                  const SizedBox(height: 8),
                  _buildPresetButton('DeepSeek', () => _setPresetDeepSeek()),
                ]),

                const SizedBox(height: 24),

                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isTesting ? null : _testConfig,
                        icon: _isTesting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.science),
                        label: Text(_isTesting ? '测试中...' : '测试配置'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _saveConfig,
                        icon: const Icon(Icons.save),
                        label: const Text('保存配置'),
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

  Widget _buildPresetButton(String title, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(title),
    );
  }

  void _setPresetOpenAI() {
    _endpointController.text = 'https://api.openai.com/v1';
    _visionModelController.text = 'gpt-4o-mini';
    _textModelController.text = 'gpt-4o';
  }

  void _setPresetClaude() {
    _endpointController.text = 'https://api.anthropic.com';
    _visionModelController.text = 'claude-3-5-sonnet';
    _textModelController.text = 'claude-3-5-sonnet';
  }

  void _setPresetGemini() {
    _endpointController.text = 'https://generativelanguage.googleapis.com/v1';
    _visionModelController.text = 'gemini-1.5-pro';
    _textModelController.text = 'gemini-1.5-pro';
  }

  void _setPresetDeepSeek() {
    _endpointController.text = 'https://api.deepseek.com/chat/completions';
    _visionModelController.text = ''; 
    _textModelController.text = 'deepseek-chat';
  }
}
