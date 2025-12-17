import 'package:flutter/material.dart';
import '../../components/layout/appbar.dart';
import '../../components/layout/settingscard.dart';
import '../../components/layout/cards.dart';

/// 关于应用页面
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YicoreAppBar(
        title: '关于应用',
        centerTitle: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        children: [
          // 应用信息
          _buildAppInfo(),

          const SizedBox(height: 16),

          // 版本信息
          SettingsBlock(
            title: '版本信息',
            children: [
              SettingsItem.value(
                title: '当前版本',
                value: 'v2.3.6',
                inBlock: true,
              ),
              SettingsItem.text(
                title: '检查更新',
                description: '查看是否有新版本可用',
                showArrow: true,
                onTap: () {
                  // TODO: 实现版本更新检查功能
                },
                inBlock: true,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 意见反馈
          SettingsBlock(
            title: '反馈与支持',
            children: [
              SettingsItem.text(
                title: '意见反馈',
                description: '提交建议和问题报告',
                showArrow: true,
                onTap: () {
                  // TODO: 实现意见反馈功能
                },
                inBlock: true,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 版权信息
          _buildCopyright(),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return YicoreCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 应用名称
          const Text(
            'YIClass',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '智能课程表应用',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyright() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              '© 2025 wykwe',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Made with Flutter',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
