import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_config_service.dart';

class AIService {
  /// 分析图片 - 调用视觉大模型
  static Future<Map<String, dynamic>> analyzeImage(String imageBase64) async {
    final config = await AIConfigService.getConfig();
    if (!config.enabled) {
      throw Exception('AI功能未启用，请先在设置中配置');
    }

    final prompt = _getImagePrompt();
    return await _callVisionAPI(config, imageBase64, prompt);
  }

  /// 分析表格/CSV - 调用文本大模型
  static Future<Map<String, dynamic>> analyzeTable(String tableText) async {
    final config = await AIConfigService.getConfig();
    if (!config.enabled) {
      throw Exception('AI功能未启用，请先在设置中配置');
    }

    final prompt = _getTablePrompt(tableText);
    return await _callTextAPI(config, prompt);
  }

  /// 分析文字 - 调用文本大模型
  static Future<Map<String, dynamic>> analyzeText(String text) async {
    final config = await AIConfigService.getConfig();
    if (!config.enabled) {
      throw Exception('AI功能未启用，请先在设置中配置');
    }

    final prompt = _getTextPrompt(text);
    return await _callTextAPI(config, prompt);
  }

  /// 测试AI配置
  static Future<bool> testConfig() async {
    print('🔍 [AI测试] 开始测试AI配置...');
    
    final config = await AIConfigService.getConfig();
    print('📋 [AI测试] 配置信息:');
    print('   - API Key: ${config.apiKey.isNotEmpty ? "${config.apiKey.substring(0, 8)}..." : "未配置"}');
    print('   - Endpoint: ${config.endpoint}');
    print('   - 文本模型: ${config.textModel}');
    print('   - 视觉模型: ${config.visionModel}');
    print('   - 功能启用: ${config.enabled}');
    print('   - 图片导入: ${config.enableImageImport}');
    print('   - 表格导入: ${config.enableTableImport}');
    print('   - 文字导入: ${config.enableTextImport}');
    
    if (!config.enabled) {
      print(' [AI测试] AI功能未启用');
      return false;
    }

    if (!config.isTextValid) {
      print(' [AI测试] 文本功能配置不完整');
      print('   - API Key: ${config.apiKey.isNotEmpty ? "已配置" : "未配置"}');
      print('   - Endpoint: ${config.endpoint.isNotEmpty ? "已配置" : "未配置"}');
      print('   - 文本模型: ${config.textModel.isNotEmpty ? "已配置" : "未配置"}');
      return false;
    }

    try {
      print(' [AI测试] 发送测试请求...');
      final testPrompt = '请回复"测试成功"';
      print(' [AI测试] 测试提示词: $testPrompt');
      
      final startTime = DateTime.now();
      final response = await _callTextAPIForTest(config, testPrompt);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print(' [AI测试] API调用成功!');
      print(' [AI测试] 响应时间: ${duration.inMilliseconds}ms');
      print(' [AI测试] 响应内容: $response');
      
      // 检查响应是否包含"测试成功"
      if (response.contains('测试成功')) {
        print('🎉 [AI测试] 测试完成，配置验证成功!');
        return true;
      } else {
        print('⚠️ [AI测试] 响应内容不符合预期: $response');
        return false;
      }
    } catch (e) {
      print(' [AI测试] API调用失败: $e');
      print(' [AI测试] 错误类型: ${e.runtimeType}');
      if (e.toString().contains('401')) {
        print('💡 [AI测试] 建议: 检查API Key是否正确');
      } else if (e.toString().contains('404')) {
        print('💡 [AI测试] 建议: 检查Endpoint是否正确');
      } else if (e.toString().contains('429')) {
        print('💡 [AI测试] 建议: API调用频率过高，请稍后重试');
      } else if (e.toString().contains('timeout')) {
        print('💡 [AI测试] 建议: 网络连接超时，检查网络连接');
      }
      return false;
    }
  }

  // ================= 私有方法 =================

  /// 调用视觉API
  static Future<Map<String, dynamic>> _callVisionAPI(AIConfig config, String imageBase64, String prompt) async {
    final requestBody = {
      "model": config.visionModel,
      "messages": [
        {
          "role": "user",
          "content": [
            {"type": "text", "text": prompt},
            {
              "type": "image_url",
              "image_url": {
                "url": "data:image/jpeg;base64,$imageBase64"
              }
            }
          ]
        }
      ],
      "max_tokens": 4000,
      "temperature": 0.1,
    };

    final response = await _makeRequest(config, requestBody);
    return _parseResponse(response);
  }

  /// 调用文本API
  static Future<Map<String, dynamic>> _callTextAPI(AIConfig config, String prompt) async {
    final requestBody = {
      "model": config.textModel,
      "messages": [
        {
          "role": "user",
          "content": prompt
        }
      ],
      "max_tokens": 4000,
      "temperature": 0.1,
    };

    final response = await _makeRequest(config, requestBody);
    return _parseResponse(response);
  }

  /// 调用文本API用于测试（返回原始字符串）
  static Future<String> _callTextAPIForTest(AIConfig config, String prompt) async {
    final requestBody = {
      "model": config.textModel,
      "messages": [
        {
          "role": "user",
          "content": prompt
        }
      ],
      "max_tokens": 100,
      "temperature": 0.1,
    };

    final response = await _makeRequest(config, requestBody);
    return response; // 直接返回原始响应，不解析为课程
  }

  /// 发送HTTP请求
  static Future<String> _makeRequest(AIConfig config, Map<String, dynamic> requestBody) async {
    print('🌐 [HTTP请求] 开始发送请求...');
    print('🔗 [HTTP请求] 目标URL: ${config.endpoint}');
    print('🤖 [HTTP请求] 使用模型: ${requestBody['model']}');
    print('📝 [HTTP请求] 请求内容长度: ${requestBody['messages'][0]['content'].toString().length} 字符');
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${config.apiKey}',
    };

    try {
      final response = await http.post(
        Uri.parse(config.endpoint),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('📡 [HTTP请求] 响应状态码: ${response.statusCode}');
      print('📏 [HTTP请求] 响应内容长度: ${response.body.length} 字符');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        print('✅ [HTTP请求] 请求成功');
        print('📄 [HTTP请求] 响应内容预览: ${content.length > 100 ? content.substring(0, 100) + "..." : content}');
        return content;
      } else {
        print('❌ [HTTP请求] 请求失败');
        print('🔍 [HTTP请求] 错误响应: ${response.body}');
        throw Exception('API调用失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 [HTTP请求] 网络异常: $e');
      rethrow;
    }
  }

  /// 解析AI响应
  static Map<String, dynamic> _parseResponse(String response) {
    print('🔍 [响应解析] 开始解析AI响应...');
    print('📄 [响应解析] 原始响应长度: ${response.length} 字符');
    
    try {
      // 提取JSON部分
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      print('🔍 [响应解析] JSON开始位置: $jsonStart');
      print('🔍 [响应解析] JSON结束位置: $jsonEnd');
      
      if (jsonStart == -1 || jsonEnd == 0) {
        print('❌ [响应解析] 未找到JSON格式');
        throw Exception('响应中未找到JSON格式');
      }

      final jsonString = response.substring(jsonStart, jsonEnd);
      print('📝 [响应解析] 提取的JSON长度: ${jsonString.length} 字符');
      
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      print('✅ [响应解析] JSON解析成功');

      // 验证响应格式（settings 可选）
      if (!data.containsKey('name') || !data.containsKey('courses')) {
        print('❌ [响应解析] 响应格式不正确，缺少 name 或 courses 字段');
        print('🔍 [响应解析] 实际数据结构: ${data.keys.toList()}');
        throw Exception('响应格式不正确');
      }

      final coursesData = data['courses'] as List;
      print('📊 [响应解析] 找到课程数据: ${coursesData.length} 门课程');
      
      // 验证课程数据
      for (final courseData in coursesData) {
        if (courseData is! Map<String, dynamic>) {
          throw Exception('课程数据格式错误');
        }
      }
      
      print('🎉 [响应解析] 课表数据解析完成');
      return data;
    } catch (e) {
      print('💥 [响应解析] 解析失败: $e');
      print('🔍 [响应解析] 错误类型: ${e.runtimeType}');
      throw Exception('解析AI响应失败: $e');
    }
  }

  // ================= 提示词 =================

  /// 图片分析提示词
  static String _getImagePrompt() {
    return '''
你是课表抽取助手。请从这张课表图片中提取完整课程数据，并仅输出符合以下严格模式的 JSON（不要输出任何说明/Markdown/多余文本）：

输出 JSON 严格结构：
{
  "name": "不超过6个字的课表名",
  "isDefault": false,
  "courses": [
    {
      "name": "课程名称",
      "location": "上课地点",
      "teacher": "教师姓名",
      "schedules": [
        {
          "day": 1,                       
          "periods": [1,2],             
          "weekPattern": [1,2,3,4,5,6],   
          "reminder": ""                
        }
      ]
    }
  ]
}

规范要求：
- 仅输出 JSON；不要输出任何多余文字。
- 将周范围（如“1-16周/双周/单周”）展开为具体数字数组 weekPattern。
- day 取值 1..7；periods 取值 1..16；数字均为整数。
- 同一课程同一上课时段仅保留一条 schedule（去重合并）。
- 若同名课程出现在不同时间，应合并到同一课程对象的不同 schedules。
''';
  }

  /// 表格分析提示词
  static String _getTablePrompt(String tableText) {
    return '''
你是课表抽取助手。请解析以下“表格/CSV/Excel文本化内容”，输出符合严格模式的 JSON（不要输出任何说明/Markdown/多余文本）：

源数据：
$tableText

输出 JSON 严格结构：
{
  "name": "不超过6个字的课表名",
  "isDefault": false,
  "courses": [
    {
      "name": "课程名称",
      "location": "上课地点",
      "teacher": "教师姓名",
      "schedules": [
        {
          "day": 1,
          "periods": [1,2],
          "weekPattern": [1,2,3,4,5,6],
          "reminder": ""
        }
      ]
    }
  ]
}

规范要求：
- 仅输出 JSON；不要输出任何多余文字。
- 将“1-16周/单周/双周”等转换为具体 weekPattern 数组。
- day 1..7；periods 1..16；整数。
- 合并同一课程的不同时间到同一课程对象的多个 schedules；去重相同时间的重复记录。
''';
  }

  /// 文字分析提示词
  static String _getTextPrompt(String text) {
    return '''
你是课表抽取助手。请从以下“自然语言文字描述”中抽取课程数据，并仅输出符合严格模式的 JSON（不要输出任何说明/Markdown/多余文本）：

原始描述：
$text

输出 JSON 严格结构：
{
  "name": "不超过6个字的课表名",
  "isDefault": false,
  "courses": [
    {
      "name": "课程名称",
      "location": "上课地点",
      "teacher": "教师姓名",
      "schedules": [
        {
          "day": 1,
          "periods": [1,2],
          "weekPattern": [1,2,3,4,5,6],
          "reminder": ""
        }
      ]
    }
  ]
}

规范要求：
- 仅输出 JSON；不要输出任何多余文字。
- 将“1-16周/单周/双周”等文字规则转换为具体 weekPattern 数组。
- day 1..7；periods 1..16；整数。
- 合并同名课程，不同上课时间放入同一课程对象的 schedules；去重重复时间。
''';
  }
}
