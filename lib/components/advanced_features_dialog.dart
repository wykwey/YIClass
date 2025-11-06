import 'package:flutter/material.dart';
import 'dart:async';
import '../zujian/dialogs.dart';
import '../zujian/components.dart';

/// 高级功能确认对话框（带计时功能）
class AdvancedFeaturesDialog {
  /// 显示高级功能确认对话框
  static Future<bool> show(BuildContext context) async {
    final result = await YicoreModal.show<bool>(
      context,
      title: '启用高级功能',
      width: 500,
      child: const _DisclaimerContent(),
      footer: const _DialogActions(),
      barrierDismissible: false,
    );
    return result ?? false;
  }
}

/// 免责声明内容
class _DisclaimerContent extends StatelessWidget {
  const _DisclaimerContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '免责声明',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
        const SizedBox(height: 16),
        
        _buildSection(
          '1. 功能说明',
          '本软件提供的高级功能包括但不限于：教务导入、AI 导入/识别，以及使用内置或用户自定义的开源仓库和脚本。使用这些功能需要用户自行配置相关脚本或工具。',
        ),
        
        _buildSection(
          '2. 数据存储与隐私',
          '本软件不会上传或存储用户的任何数据。用户在使用高级功能过程中产生的数据（包括 AI 导入处理的数据）均由用户自行管理。',
        ),
        
        _buildSection(
          '3. AI 导入风险',
          'AI 导入/识别功能可能会将用户数据发送至第三方 AI 服务进行处理，存在数据泄露、隐私暴露或误用的风险。用户必须自行评估风险并承担相关后果。本软件及开发者不对任何隐私泄露或数据使用结果承担责任。',
        ),
        
        _buildSection(
          '4. 仓库与脚本责任',
          '软件内置仓库及脚本仅供参考或辅助使用。无论是内置仓库脚本还是用户自行添加的自定义仓库脚本，其合法性、安全性和适用性均由用户自行负责。本软件及开发者不对其内容或使用效果承担任何责任。',
        ),
        
        _buildSection(
          '5. 合法性责任',
          '用户在使用高级功能时，须确保其操作符合相关法律法规及第三方系统的使用条款。本软件及开发者不对用户行为的合法性承担任何责任。',
        ),
        
        _buildSection(
          '6. 风险承担',
          '因用户使用高级功能（包括教务导入、AI 导入/识别）而导致的任何损失、数据泄露、法律纠纷或其他风险，均由用户自行承担。本软件及开发者不承担任何责任。',
        ),
        
        _buildSection(
          '7. 用户确认',
          '使用高级功能即表示用户已仔细阅读、理解并同意本免责声明，并承诺自行承担使用高级功能的全部风险。',
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              height: 1.5,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

/// 对话框操作按钮（带倒计时）
class _DialogActions extends StatefulWidget {
  const _DialogActions();

  @override
  State<_DialogActions> createState() => _DialogActionsState();
}

class _DialogActionsState extends State<_DialogActions> {
  int _remainingSeconds = 5; // 5秒倒计时
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _remainingSeconds <= 0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        YicoreButton(
          text: '取消',
          isOutlined: true,
          onPressed: () => Navigator.pop(context, false),
        ),
        const SizedBox(width: 12),
        YicoreButton(
          text: canConfirm ? '确定启用' : '确定启用 ($_remainingSeconds)',
          onPressed: canConfirm ? () => Navigator.pop(context, true) : null,
        ),
      ],
    );
  }
}

