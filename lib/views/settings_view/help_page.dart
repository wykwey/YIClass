import 'package:flutter/material.dart';
import '../../components/layout/appbar.dart';
import '../../components/layout/settingscard.dart';

/// 使用帮助页面
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YicoreAppBar(
        title: '使用帮助',
        centerTitle: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        children: [
          // 快速入门
          SettingsBlock(
            title: '快速入门',
            children: [
              _buildFaqItem(
                title: '如何添加课程？',
                content: '在周视图或日视图中，点击空白格子即可添加新课程。填写课程名称、教室、教师等信息后保存即可。',
              ),
              _buildFaqItem(
                title: '如何编辑或删除课程？',
                content: '点击已有的课程卡片，进入编辑页面。可以修改课程信息或点击删除按钮移除课程。',
              ),
              _buildFaqItem(
                title: '如何切换周次？',
                content: '在周视图顶部，左右滑动周次选择器，或点击具体周次数字快速跳转。',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 课表管理
          SettingsBlock(
            title: '课表管理',
            children: [
              _buildFaqItem(
                title: '如何创建多个课表？',
                content: '进入 设置 课表管理，点击"新建课表"按钮。可以为不同学期或不同用途创建独立的课表。',
              ),
              _buildFaqItem(
                title: '如何导入课表？',
                content: '支持多种导入方式：\n JSON文件导入：设置 导入课表\n 教务系统导入：需先启用高级功能\n AI智能导入：拍照或上传图片识别',
              ),
              _buildFaqItem(
                title: '如何导出课表？',
                content: '进入 设置 导出课表，将当前课表保存为JSON文件，方便备份或分享给他人。',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 高级功能
          SettingsBlock(
            title: '高级功能',
            children: [
              _buildFaqItem(
                title: '什么是高级功能？',
                content: '高级功能包括教务系统导入和AI智能导入。需要在 设置 高级功能 中启用，并配置相关服务。',
              ),
              _buildFaqItem(
                title: '如何使用教务系统导入？',
                content: '1. 启用高级功能并开启教务系统导入\n2. 配置脚本仓库地址\n3. 选择学校和对应脚本\n4. 登录教务系统后自动获取课表',
              ),
              _buildFaqItem(
                title: '如何使用AI导入？',
                content: '1. 启用高级功能并开启AI导入\n2. 配置AI服务（API地址和密钥）\n3. 拍照或选择课表图片\n4. AI自动识别并生成课程',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 其他设置
          SettingsBlock(
            title: '其他设置',
            children: [
              _buildFaqItem(
                title: '如何设置上课时间？',
                content: '进入 设置 上课时间，可以自定义每节课的开始和结束时间，支持添加或删除节次。',
              ),
              _buildFaqItem(
                title: '如何开启课程提醒？',
                content: '进入 设置 课程提醒，开启通知权限后，可以设置提前提醒时间，在上课前收到通知。',
              ),
              _buildFaqItem(
                title: '如何更换主题？',
                content: '进入 设置 主题设置，可以切换浅色/深色模式，或自定义课程卡片的配色方案。',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 常见问题
          SettingsBlock(
            title: '常见问题',
            children: [
              _buildFaqItem(
                title: '课表数据会丢失吗？',
                content: '课表数据保存在本地设备中。建议定期使用导出功能备份数据，防止意外丢失。',
              ),
              _buildFaqItem(
                title: '支持哪些平台？',
                content: 'YIClass 支持 Android、iOS、Windows、macOS 和 Linux 平台。',
              ),
              _buildFaqItem(
                title: '遇到问题怎么办？',
                content: '可以在 关于应用 意见反馈 中提交问题报告，或访问项目 GitHub 页面提交 Issue。',
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 构建FAQ项目（直接显示，无折叠）
  Widget _buildFaqItem({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
