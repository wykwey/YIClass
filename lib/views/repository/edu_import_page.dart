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

/// 教务系统导入页
class EduImportPage extends StatefulWidget {
  final ScriptEntry script;

  const EduImportPage({
    super.key,
    required this.script,
  });

  @override
  State<EduImportPage> createState() => _EduImportPageState();
}

class _EduImportPageState extends State<EduImportPage> {
  late final WebViewController _controller;
  String _pageTitle = '';
  bool _isDesktopMode = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  /// 标准化URL，确保包含协议
  /// 如果URL没有协议，默认添加 https://
  String _normalizeUrl(String url) {
    if (url.isEmpty) return url;
    
    // 检查是否已有协议
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    
    // 如果没有协议，添加 https://
    return 'https://$trimmed';
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _pageTitle = '加载中...';
            });
          },
          onPageFinished: (String url) async {
            // 页面加载完成后获取标题
            try {
              final title = await _controller.getTitle();
              if (title != null && title.isNotEmpty && mounted) {
                setState(() {
                  _pageTitle = title;
                });
              }
            } catch (e) {
              // 获取标题失败，使用默认值
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'YiClassChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleTimetableData(message.message);
        },
      )
      ..loadRequest(Uri.parse(_normalizeUrl(widget.script.url)));
  }

  /// 处理从WebView接收到的课表数据
  /// 
  /// [jsonData] 完整的课表JSON字符串，格式与FileService.fromMap()要求的格式一致
  Future<void> _handleTimetableData(String jsonData) async {
    if (_isImporting) return; // 防止重复导入

    try {
      // 解析JSON数据（脚本直接返回完整的课表JSON）
      final Map<String, dynamic> timetableData = 
          Map<String, dynamic>.from(
            jsonDecode(jsonData) as Map
          );

      // 转换为Timetable并保存
      final timetable = FileService.fromMap(timetableData);

      // 保存到数据库
      final result = await FileService.save(timetable);

      if (mounted) {
        if (result) {
          // 刷新课表状态
          final timetableState = context.read<TimetableState>();
          await timetableState.reload();

          Notifications.sonner(context, message: '导入成功');

          // 导入成功后返回上一页
          Navigator.pop(context);
        } else {
          Notifications.sonner(context, message: '导入失败');
          setState(() => _isImporting = false);
        }
      }
    } catch (e) {
      if (mounted) {
        Notifications.sonner(context, message: '导入失败: $e');
        setState(() => _isImporting = false);
      }
    }
  }

  /// 执行脚本并导入课表
  Future<void> _executeScriptAndImport() async {
    if (_isImporting) return;

    setState(() => _isImporting = true);
    Notifications.sonner(context, message: '正在导入...');

    try {
      // 检查脚本文件是否存在
      final scriptExists = await ScriptFileService.checkScriptExists(
        widget.script.scriptName,
      );

      if (!scriptExists) {
        Notifications.sonner(context, message: '脚本文件不存在，请先下载脚本');
        setState(() => _isImporting = false);
        return;
      }

      // 读取脚本内容
      final scriptContent = await ScriptFileService.readScriptContent(
        widget.script.scriptName,
      );

      if (scriptContent == null || scriptContent.isEmpty) {
        Notifications.sonner(context, message: '脚本文件读取失败');
        setState(() => _isImporting = false);
        return;
      }

      // 直接执行脚本
      // 脚本应该自己调用 YiClassChannel.postMessage(data) 来传递数据
      await _controller.runJavaScript(scriptContent);

      // 注意：实际的数据接收在 JavaScriptChannel 的 onMessageReceived 中处理
      // 这里设置超时，避免无限等待
      await Future.delayed(const Duration(seconds: 10));
      
      if (_isImporting && mounted) {
        // 如果10秒后还在导入状态，可能是脚本没有正确返回数据
        Notifications.sonner(context, message: '导入超时，请检查脚本是否正确执行');
        setState(() => _isImporting = false);
      }
    } catch (e) {
      if (mounted) {
        Notifications.sonner(context, message: '执行脚本失败: $e');
        setState(() => _isImporting = false);
      }
    }
  }

  /// 切换User Agent（桌面/移动端）
  Future<void> _toggleUserAgent() async {
    setState(() => _isDesktopMode = !_isDesktopMode);

    String userAgent;
    if (_isDesktopMode) {
      // 桌面端User Agent
      userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    } else {
      // 移动端User Agent（Android）
      userAgent = 'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
    }

    await _controller.setUserAgent(userAgent);
    await _controller.reload();
  }

  /// 刷新WebView
  Future<void> _reloadWebView() async {
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
          // 导入按钮
          _isImporting
              ? Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : YicoreAppBarAction(
                  icon: Icons.download,
                  onPressed: _isImporting ? null : _executeScriptAndImport,
                ),
          // 切换User Agent按钮
          YicoreAppBarAction(
            icon: _isDesktopMode ? Icons.phone_android : Icons.computer,
            onPressed: _toggleUserAgent,
          ),
          // 刷新按钮
          YicoreAppBarAction(
            icon: Icons.refresh,
            onPressed: _reloadWebView,
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

