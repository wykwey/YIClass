import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/ai/ai_config_service.dart';
import '../services/ai/ai_service.dart';
import '../services/file_service.dart';
import '../states/timetable_state.dart';
import '../utils/feedback_utils.dart';

class AIImportPage extends StatefulWidget {
  const AIImportPage({super.key});

  @override
  State<AIImportPage> createState() => _AIImportPageState();
}

class _AIImportPageState extends State<AIImportPage> {
  AIConfig? _config;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final config = await AIConfigService.getConfig();
      setState(() {
        _config = config;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI智能导入'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('加载配置中...'),
                ],
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final config = _config ?? AIConfig();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 导入选项列表
          _buildImportOptions(config),
          
          const SizedBox(height: 24),
          
          // 注意事项
          _buildPrivacyNotice(),
        ],
      ),
    );
  }

  Widget _buildImportOptions(AIConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择导入方式',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildImportOption(
          title: '图片导入',
          subtitle: '上传课程表图片，AI自动识别课程信息',
          icon: Icons.image,
          enabled: config.enableImageImport,
          onTap: () => _handleImageImport(),
        ),
        const SizedBox(height: 12),
        _buildImportOption(
          title: '表格/CSV导入',
          subtitle: '粘贴表格数据或CSV格式的课程信息',
          icon: Icons.table_chart,
          enabled: config.enableTableImport,
          onTap: () => _handleTableImport(),
        ),
        const SizedBox(height: 12),
        _buildImportOption(
          title: '文字导入',
          subtitle: '输入课程描述，AI解析课程安排',
          icon: Icons.text_fields,
          enabled: config.enableTextImport,
          onTap: () => _handleTextImport(),
        ),
      ],
    );
  }

  Widget _buildImportOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? Colors.blue.shade200 : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: enabled ? [
          BoxShadow(
            color: Colors.blue.shade50,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: enabled ? Colors.blue.shade50 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: enabled ? Colors.blue.shade600 : Colors.grey.shade500,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: enabled ? Colors.black87 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: enabled ? Colors.black54 : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: enabled ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.privacy_tip_outlined, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                '隐私注意事项',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '上传的图片和数据将发送到您配置的AI服务进行分析，请确保不包含敏感个人信息\n'
            '建议在上传前检查图片内容，避免泄露个人隐私\n'
            '应用不会存储您上传的数据，但请确认您使用的AI服务提供商的隐私政策\n'
            '如发现隐私泄露风险，请立即停止使用并检查AI服务配置',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ================= 导入逻辑 =================

  Future<void> _handleImageImport() async {
    final config = await AIConfigService.getConfig();
    if (!_checkConfig(context, config.enabled && config.enableImageImport, '图片导入')) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    await _handleAIImport(
      context: context,
      importType: '图片',
      analyzer: () => AIService.analyzeImage(base64Image),
    );
  }

  Future<void> _handleTableImport() async {
    final config = await AIConfigService.getConfig();
    if (!_checkConfig(context, config.enabled && config.enableTableImport, '表格导入')) return;

    final tableText = await _showTableInputDialog(context);
    if (tableText == null || tableText.isEmpty) return;

    await _handleAIImport(
      context: context,
      importType: '表格',
      analyzer: () => AIService.analyzeTable(tableText),
    );
  }

  Future<void> _handleTextImport() async {
    final config = await AIConfigService.getConfig();
    if (!_checkConfig(context, config.enabled && config.enableTextImport, '文字导入')) return;

    final text = await _showTextInputDialog(context);
    if (text == null || text.isEmpty) return;

    await _handleAIImport(
      context: context,
      importType: '文字',
      analyzer: () => AIService.analyzeText(text),
    );
  }

  // ================= 通用逻辑 =================

  Future<void> _handleAIImport({
    required BuildContext context,
    required String importType,
    required Future<Map<String, dynamic>> Function() analyzer,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    if (!context.mounted) return;
    _showProcessingDialog(context, '正在分析$importType...');

    try {
      final timetableData = await analyzer();

      if (!context.mounted) return;
      Navigator.pop(context); // 关闭"分析中"

      FeedbackUtils.show(context, '导入中...');
      await Future.delayed(const Duration(milliseconds: 300));

      // AI 直接返回格式，直接使用
      final timetable = FileService.fromMap(timetableData);
      
      // 保存到数据库
      final result = await FileService.save(timetable);
      
      if (result && context.mounted) {
        // 刷新课表状态
        final timetableState = context.read<TimetableState>();
        await timetableState.reload();
        
        FeedbackUtils.show(context, '导入成功');
        
        // 导入成功后返回上一页
        Navigator.pop(context);
      } else {
        FeedbackUtils.show(context, '导入失败');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        FeedbackUtils.show(context, '分析失败: $e');
      }
    }
  }

  bool _checkConfig(BuildContext context, bool isValid, String importType) {
    if (!isValid) {
      FeedbackUtils.show(context, '$importType功能未启用，请先在设置中配置AI服务');
      return false;
    }
    return true;
  }

  // ================= 对话框 =================

  Future<String?> _showTableInputDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入表格数据'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '请粘贴表格数据或CSV格式的课程信息：',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '课程名称,时间,地点,教师\n高等数学,周一1-2节,教学楼A101,张老师',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('确定')),
        ],
      ),
    );
  }

  Future<String?> _showTextInputDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入课程描述'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '例如：\n周一上午有高等数学课，在A101教室，老师是张老师\n周二下午有英语课，在B201教室，老师是李老师',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('确定')),
        ],
      ),
    );
  }

  void _showProcessingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}
