import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import '../../components/layout/settingscard.dart';
import '../../components/layout/appbar.dart';
import '../../components/feedback/notifications.dart';
import '../../components/feedback/advanced_features_dialog.dart';
import '../../routes/route_utils.dart';

/// 高级功能页面
class AdvancedFeaturesPage extends StatefulWidget {
  const AdvancedFeaturesPage({super.key});

  @override
  State<AdvancedFeaturesPage> createState() => _AdvancedFeaturesPageState();
}

class _AdvancedFeaturesPageState extends State<AdvancedFeaturesPage> {
  bool _advancedEnabled = false;
  bool _eduImportEnabled = false;
  bool _aiImportEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await SettingsService.instance.isAdvancedFeaturesEnabled();
    final eduEnabled = await SettingsService.instance.isEduImportEnabled();
    final aiEnabled = await SettingsService.instance.isAiImportEnabled();
    if (mounted) {
      setState(() {
        _advancedEnabled = enabled;
        _eduImportEnabled = eduEnabled;
        _aiImportEnabled = aiEnabled;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YicoreAppBar(
        title: '高级功能',
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 功能开关
                SettingsBlock(
                  title: '功能开关',
                  children: [
                    _buildAdvancedToggle(),
                    _buildEduImportToggle(),
                    _buildAiImportToggle(),
                  ],
                ),

                const SizedBox(height: 16),

                // 配置管理
                SettingsBlock(
                  title: '配置管理',
                  children: [
                    _buildScriptRepositoryTile(),
                    _buildAiConfigTile(),
                  ],
                ),

                const SizedBox(height: 16),

                // 说明
                _buildInfoCard(),
              ],
            ),
    );
  }

  /// 高级功能总开关
  Widget _buildAdvancedToggle() {
    return SettingsItem.switch_(
      title: '启用高级功能',
      description: _advancedEnabled 
          ? '已启用 AI 导入、教务脚本等功能' 
          : '启用后可使用 AI 导入、教务脚本等功能',
      value: _advancedEnabled,
      onChanged: (value) async {
        if (value) {
          // 打开开关前显示确认弹窗
          final confirmed = await AdvancedFeaturesDialog.show(context);
          if (!confirmed) return;
        }

        await SettingsService.instance.updateAdvancedFeaturesEnabled(value);
        if (!value) {
          // 关闭高级功能时，同时关闭子开关
          await SettingsService.instance.updateEduImportEnabled(false);
          await SettingsService.instance.updateAiImportEnabled(false);
        }
        if (!mounted) return;
        setState(() {
          _advancedEnabled = value;
          if (!value) {
            _eduImportEnabled = false;
            _aiImportEnabled = false;
          }
        });
        Notifications.sonner(
          context,
          message: value ? '高级功能已启用' : '高级功能已禁用',
        );
      },
      inBlock: true,
    );
  }

  /// 教务导入开关
  Widget _buildEduImportToggle() {
    return SettingsItem.switch_(
      title: '教务系统导入',
      description: '通过脚本从教务系统获取课表',
      value: _eduImportEnabled,
      enabled: _advancedEnabled,
      onChanged: (value) async {
        await SettingsService.instance.updateEduImportEnabled(value);
        if (!mounted) return;
        setState(() => _eduImportEnabled = value);
      },
      inBlock: true,
    );
  }

  /// AI 导入开关
  Widget _buildAiImportToggle() {
    return SettingsItem.switch_(
      title: 'AI 智能导入',
      description: '使用 AI 识别图片或文档中的课表',
      value: _aiImportEnabled,
      enabled: _advancedEnabled,
      onChanged: (value) async {
        await SettingsService.instance.updateAiImportEnabled(value);
        if (!mounted) return;
        setState(() => _aiImportEnabled = value);
      },
      inBlock: true,
    );
  }

  /// 脚本仓库配置
  Widget _buildScriptRepositoryTile() {
    return SettingsItem.text(
      title: '脚本仓库配置',
      description: _advancedEnabled ? '配置教务导入脚本仓库' : '需要启用高级功能',
      showArrow: true,
      enabled: _advancedEnabled,
      onTap: () {
        RouteUtils.pushRepositoryConfig(context);
      },
      inBlock: true,
    );
  }

  /// AI 配置
  Widget _buildAiConfigTile() {
    return SettingsItem.text(
      title: 'AI 服务配置',
      description: _advancedEnabled ? '配置 AI 服务用于课程表识别' : '需要启用高级功能',
      showArrow: true,
      enabled: _advancedEnabled,
      onTap: () {
        RouteUtils.pushAIConfig(context);
      },
      inBlock: true,
    );
  }

  /// 说明卡片
  Widget _buildInfoCard() {
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
          Text(
            '关于高级功能',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '高级功能包括：\n'
            '教务系统导入：通过脚本自动从教务系统获取课表\n'
            'AI 智能导入：使用 AI 识别图片、表格或文字中的课程信息\n\n'
            '使用这些功能可能需要配置第三方服务，请确保了解相关隐私政策。',
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
}
