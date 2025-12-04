import 'package:flutter/material.dart';
import '../../components/layout/appbar.dart';
import '../../components/layout/settingscard.dart';
import '../../components/feedback/notifications.dart';
import '../../services/settings_service.dart';

/// 主题设置页面
class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  String _selectedTheme = 'system';
  bool _disableAdaptiveFontColor = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.instance.loadSettings();
    setState(() {
      _disableAdaptiveFontColor = settings.disableAdaptiveFontColor;
    });
  }

  Future<void> _updateDisableAdaptiveFontColor(bool value) async {
    setState(() => _disableAdaptiveFontColor = value);
    final settings = await SettingsService.instance.loadSettings();
    settings.disableAdaptiveFontColor = value;
    await SettingsService.instance.saveSettings(settings);
    if (mounted) {
      Notifications.sonner(
        context,
        message: '切换课表或重启应用生效',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YicoreAppBar(
        title: '主题设置',
        centerTitle: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        children: [
          // 主题模式
          SettingsBlock(
            title: '主题模式',
            children: [
              _buildThemeModeItem('system', '跟随系统', '自动跟随系统深浅色设置'),
              _buildThemeModeItem('light', '浅色模式', '始终使用浅色主题'),
              _buildThemeModeItem('dark', '深色模式', '始终使用深色主题'),
            ],
          ),

          const SizedBox(height: 16),

          // 课程显示
          SettingsBlock(
            title: '课程显示',
            children: [
              SettingsItem.switch_(
                title: '关闭字体自适应颜色',
                description: '关闭后课程卡片文字将使用固定颜色',
                value: _disableAdaptiveFontColor,
                onChanged: _updateDisableAdaptiveFontColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeItem(String value, String title, String description) {
    final isSelected = _selectedTheme == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTheme = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, size: 20, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
