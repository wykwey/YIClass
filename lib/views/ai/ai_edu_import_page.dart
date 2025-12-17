import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/ai/ai_config_service.dart';
import '../../services/ai/ai_service.dart';
import '../../services/file_service.dart';
import '../../states/timetable_state.dart';
import '../../components/feedback/notifications.dart';
import '../../components/feedback/dialogs.dart';
import '../../components/inputs/components.dart';

/// AI 教务导入页
class AiEduImportPage extends StatefulWidget {
  final String initialUrl;
  const AiEduImportPage({super.key, this.initialUrl = ''});

  @override
  State<AiEduImportPage> createState() => _AiEduImportPageState();
}

class _AiEduImportPageState extends State<AiEduImportPage> {
  late final WebViewController _controller;
  final _urlController = TextEditingController();
  String _currentUrl = '';
  bool _isDesktopMode = false;
  bool _isAnalyzing = false;

  static const _desktopUA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36';
  static const _mobileUA = 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36';

  static const _extractScript = '''
    (function() {
      var result = [];
      document.querySelectorAll('table').forEach(function(table, idx) {
        var rows = [];
        table.querySelectorAll('tr').forEach(function(row) {
          var cells = [];
          row.querySelectorAll('td, th').forEach(function(cell) {
            cells.push(cell.innerText.trim());
          });
          if (cells.length > 0) rows.push(cells.join('\\t'));
        });
        if (rows.length > 0) result.push('=== 表格 ' + (idx + 1) + ' ===\\n' + rows.join('\\n'));
      });
      return result.length > 0 ? result.join('\\n\\n') : document.body.innerText;
    })();
  ''';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String _normalizeUrl(String url) {
    if (url.isEmpty) return 'about:blank';
    final trimmed = url.trim();
    return trimmed.startsWith('http') ? trimmed : 'https://$trimmed';
  }

  void _initWebView() {
    _currentUrl = widget.initialUrl.isNotEmpty ? _normalizeUrl(widget.initialUrl) : 'about:blank';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) => setState(() => _currentUrl = url),
        onPageFinished: (url) => setState(() => _currentUrl = url),
      ))
      ..loadRequest(Uri.parse(_currentUrl));
  }

  void _loadUrl(String url) {
    final normalized = _normalizeUrl(url);
    if (normalized != 'about:blank') {
      _controller.loadRequest(Uri.parse(normalized));
    }
  }

  Future<String> _getPageContent() async {
    final result = await _controller.runJavaScriptReturningResult(_extractScript);
    var content = result.toString();
    if (content.startsWith('"') && content.endsWith('"')) {
      content = content.substring(1, content.length - 1);
    }
    return content.replaceAll('\\n', '\n').replaceAll('\\t', '\t');
  }

  Future<void> _analyze() async {
    if (_isAnalyzing) return;
    setState(() => _isAnalyzing = true);
    
    YicoreAlert.show(
      context,
      title: 'AI 分析',
      message: '正在分析页面内容...',
      barrierDismissible: false,
    );

    try {
      final config = await AIConfigService.getConfig();
      if (!mounted) return;

      if (!config.enabled || !config.enableWebImport) {
        Navigator.of(context, rootNavigator: true).pop();
        Notifications.sonner(context, message: '请先启用 AI 教务导入');
        setState(() => _isAnalyzing = false);
        return;
      }
      if (!config.isValid) {
        Navigator.of(context, rootNavigator: true).pop();
        Notifications.sonner(context, message: '请先配置 AI 服务');
        setState(() => _isAnalyzing = false);
        return;
      }

      final content = await _getPageContent();

      if (!mounted) return;
      if (content.isEmpty) {
        Navigator.of(context, rootNavigator: true).pop();
        Notifications.sonner(context, message: '页面内容为空');
        setState(() => _isAnalyzing = false);
        return;
      }
      final data = await AIService.analyzeTable(content);
      final timetable = FileService.fromMap(data);
      final ok = await FileService.save(timetable);

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      if (ok) {
        await context.read<TimetableState>().reload();
        if (!mounted) return;
        Notifications.sonner(context, message: '导入成功');
        Navigator.pop(context);
      } else {
        Notifications.sonner(context, message: '保存失败');
        setState(() => _isAnalyzing = false);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Notifications.sonner(context, message: '分析失败: $e');
        setState(() => _isAnalyzing = false);
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
          YicoreIconButton(icon: Icons.download, onPressed: _isAnalyzing ? null : _analyze, showBorder: false),
          YicoreIconButton(
            icon: _isDesktopMode ? Icons.phone_android : Icons.computer,
            onPressed: _toggleUA,
            showBorder: false,
          ),
          YicoreIconButton(icon: Icons.refresh, onPressed: () => _controller.reload(), showBorder: false),
        ],
      ),
      body: _currentUrl == 'about:blank' || _currentUrl.isEmpty
          ? Center(child: Text('请在上方输入教务网址', style: TextStyle(fontSize: 16, color: Colors.grey[500])))
          : WebViewWidget(controller: _controller),
    );
  }
}
