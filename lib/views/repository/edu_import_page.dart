import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../data/school_index.dart';
import '../../services/repository/script_file_service.dart';
import '../../services/file_service.dart';
import '../../states/timetable_state.dart';
import '../../components/feedback/notifications.dart';
import '../../components/layout/appbar.dart';
import '../../components/inputs/components.dart';

/// 教务系统脚本导入页
class EduImportPage extends StatefulWidget {
  final ScriptEntry script;
  const EduImportPage({super.key, required this.script});

  @override
  State<EduImportPage> createState() => _EduImportPageState();
}

class _EduImportPageState extends State<EduImportPage> {
  late final WebViewController _controller;
  String _pageTitle = '';
  bool _isDesktopMode = false;
  bool _isImporting = false;

  static const _desktopUA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36';
  static const _mobileUA = 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  String _normalizeUrl(String url) {
    if (url.isEmpty) return url;
    final trimmed = url.trim();
    return trimmed.startsWith('http') ? trimmed : 'https://$trimmed';
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _pageTitle = '加载中...'),
        onPageFinished: (_) async {
          final title = await _controller.getTitle();
          if (title != null && title.isNotEmpty && mounted) {
            setState(() => _pageTitle = title);
          }
        },
      ))
      ..addJavaScriptChannel('YiClassChannel', onMessageReceived: (msg) => _handleData(msg.message))
      ..loadRequest(Uri.parse(_normalizeUrl(widget.script.url)));
  }

  Future<void> _handleData(String jsonData) async {
    try {
      final data = Map<String, dynamic>.from(jsonDecode(jsonData) as Map);
      if (!mounted) return;

      // 错误回调
      final error = data['error'] as String?;
      if (error != null) {
        Notifications.sonner(context, message: error);
        Navigator.pop(context);
        return;
      }

      // 成功：保存课表
      final timetable = FileService.fromMap(data);
      await FileService.save(timetable);
      if (!mounted) return;
      await context.read<TimetableState>().reload();
      if (!mounted) return;
      Notifications.sonner(context, message: '导入成功');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _runScript() async {
    if (_isImporting) return;
    setState(() => _isImporting = true);

    try {
      final content = await ScriptFileService.readScriptContent(widget.script.scriptName);
      if (content == null || content.isEmpty) {
        if (!mounted) return;
        Notifications.sonner(context, message: '脚本不存在');
        setState(() => _isImporting = false);
        return;
      }

      await _controller.runJavaScript(content);
    } catch (e) {
      if (mounted) {
        Notifications.sonner(context, message: '执行失败: $e');
        setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _toggleUA() async {
    setState(() => _isDesktopMode = !_isDesktopMode);
    await _controller.setUserAgent(_isDesktopMode ? _desktopUA : _mobileUA);
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: YicoreAppBar(
        title: _pageTitle.isEmpty ? widget.script.name : _pageTitle,
        centerTitle: true,
        actions: [
          _isImporting
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                )
              : YicoreIconButton(icon: Icons.download, onPressed: _runScript, showBorder: false),
          YicoreIconButton(
            icon: _isDesktopMode ? Icons.phone_android : Icons.computer,
            onPressed: _toggleUA,
            showBorder: false,
          ),
          YicoreIconButton(icon: Icons.refresh, onPressed: () => _controller.reload(), showBorder: false),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

