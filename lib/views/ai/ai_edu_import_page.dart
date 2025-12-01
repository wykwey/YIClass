import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/ai/ai_config_service.dart';
import '../../services/ai/ai_service.dart';
import '../../services/file_service.dart';
import '../../states/timetable_state.dart';
import '../../components/feedback/notifications.dart';
import '../../components/layout/appbar.dart';

/// AI 教务导入页
class AiEduImportPage extends StatefulWidget {
  final String initialUrl;

  const AiEduImportPage({
    super.key,
    this.initialUrl = '',
  });

  @override
  State<AiEduImportPage> createState() => _AiEduImportPageState();
}

class _AiEduImportPageState extends State<AiEduImportPage> {
  late final WebViewController _controller;
  final TextEditingController _urlController = TextEditingController();
  String _currentUrl = '';
  bool _isDesktopMode = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// 加载指定 URL
  void _loadUrl(String url) {
    final normalizedUrl = _normalizeUrl(url);
    if (normalizedUrl != 'about:blank') {
      _controller.loadRequest(Uri.parse(normalizedUrl));
    }
  }

  /// 标准化URL，确保包含协议
  String _normalizeUrl(String url) {
    if (url.isEmpty) return 'about:blank';
    
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    
    return 'https://$trimmed';
  }

  void _initializeWebView() {
    final initialUrl = widget.initialUrl.isNotEmpty 
        ? _normalizeUrl(widget.initialUrl)
        : 'about:blank';
    
    _currentUrl = initialUrl;
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _currentUrl = url;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));
  }

  /// 获取页面文本内容
  Future<String> _getPageContent() async {
    // 获取页面的结构化表格数据
    const script = '''
      (function() {
        var result = [];
        var tables = document.querySelectorAll('table');
        tables.forEach(function(table, idx) {
          var rows = table.querySelectorAll('tr');
          var tableData = [];
          rows.forEach(function(row) {
            var cells = row.querySelectorAll('td, th');
            var rowData = [];
            cells.forEach(function(cell) {
              rowData.push(cell.innerText.trim());
            });
            if (rowData.length > 0) {
              tableData.push(rowData.join('\\t'));
            }
          });
          if (tableData.length > 0) {
            result.push('=== 表格 ' + (idx + 1) + ' ===\\n' + tableData.join('\\n'));
          }
        });
        if (result.length > 0) {
          return result.join('\\n\\n');
        }
        // 如果没有表格，返回页面文本
        return document.body.innerText;
      })();
    ''';
    
    final result = await _controller.runJavaScriptReturningResult(script);
    // 移除结果两端的引号
    String content = result.toString();
    if (content.startsWith('"') && content.endsWith('"')) {
      content = content.substring(1, content.length - 1);
    }
    // 处理转义字符
    content = content.replaceAll('\\n', '\n').replaceAll('\\t', '\t');
    return content;
  }

  /// AI 分析页面内容
  Future<void> _analyzeWithAI() async {
    if (_isAnalyzing) return;

    setState(() => _isAnalyzing = true);

    try {
      // 检查 AI 配置
      final config = await AIConfigService.getConfig();
      if (!mounted) return;
      if (!config.enabled || !config.enableWebImport) {
        Notifications.sonner(context, message: '请先启用 AI 教务导入功能');
        setState(() => _isAnalyzing = false);
        return;
      }

      if (!config.isValid) {
        Notifications.sonner(context, message: '请先配置 AI 服务');
        setState(() => _isAnalyzing = false);
        return;
      }

      Notifications.sonner(context, message: '正在获取页面内容...');

      // 获取页面内容
      final content = await _getPageContent();
      
      if (!mounted) return;
      if (content.isEmpty) {
        Notifications.sonner(context, message: '页面内容为空');
        setState(() => _isAnalyzing = false);
        return;
      }

      Notifications.sonner(context, message: '正在 AI 导入...');

      // 调用 AI 分析（使用表格分析，因为提取的是结构化数据）
      final timetableData = await AIService.analyzeTable(content);

      // 转换并保存
      final timetable = FileService.fromMap(timetableData);
      final result = await FileService.save(timetable);

      if (mounted) {
        if (result) {
          final timetableState = context.read<TimetableState>();
          await timetableState.reload();
          if (!mounted) return;
          Notifications.sonner(context, message: '导入成功');
          Navigator.pop(context);
        } else {
          Notifications.sonner(context, message: '保存失败');
          setState(() => _isAnalyzing = false);
        }
      }
    } catch (e) {
      if (mounted) {
        Notifications.sonner(context, message: '分析失败: $e');
        setState(() => _isAnalyzing = false);
      }
    }
  }

  /// 切换 User Agent
  Future<void> _toggleUserAgent() async {
    setState(() => _isDesktopMode = !_isDesktopMode);

    String userAgent;
    if (_isDesktopMode) {
      userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    } else {
      userAgent = 'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
    }

    await _controller.setUserAgent(userAgent);
    await _controller.reload();
  }

  /// 刷新 WebView
  Future<void> _reloadWebView() async {
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    // 同步 URL 到输入框
    if (_urlController.text != _currentUrl && _currentUrl != 'about:blank') {
      _urlController.text = _currentUrl;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            hintText: '请输入教务网址',
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          style: const TextStyle(fontSize: 14),
          onSubmitted: _loadUrl,
        ),
        actions: [
          // 导入按钮
          _isAnalyzing
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : YicoreAppBarAction(
                  icon: Icons.download,
                  onPressed: _isAnalyzing ? null : _analyzeWithAI,
                ),
          // 切换 User Agent 按钮
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
      body: _currentUrl == 'about:blank' || _currentUrl.isEmpty
          ? Center(
              child: Text(
                '请在上方输入教务网址',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            )
          : WebViewWidget(controller: _controller),
    );
  }
}
