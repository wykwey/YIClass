/// 解析工具类
/// 
/// 提供统一的数字解析功能，支持节次和周次的解析
class ParseUtils {
  
  /// 核心解析方法：解析节次/周次字符串为整数列表
  /// 
  /// 支持格式：
  /// - 单个数字：1
  /// - 范围：2-4
  /// - 单/双标记：6-8[单], 6-8[双]
  /// - 多区间逗号或空格分隔：1,3-5 6-8[双]
  /// - 特殊值：all (返回所有数字)
  /// 
  /// 参数：
  /// - [input]: 输入字符串
  /// - [defaultMax]: 默认最大值，用于'all'和范围检查
  /// 
  /// 返回：解析后的整数列表
  static List<int> parseNumbers(String input, {int defaultMax = 30}) {
    if (input.isEmpty) return [];
    if (input == 'all') return List.generate(defaultMax, (i) => i + 1);

    final numbers = <int>{};
    final parts = input.replaceAll(' ', ',').split(',');

    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;

      // 处理范围格式：2-4, 6-8[单], 6-8[双]
      if (trimmed.contains('-')) {
        final rangeParts = trimmed.split('-');
        if (rangeParts.length == 2) {
          int start = int.parse(rangeParts[0]);
          int end = int.parse(rangeParts[1].replaceAll(RegExp(r'\[.*\]'), ''));
          String? oddEven = trimmed.contains('[单]') ? '单' : 
                            trimmed.contains('[双]') ? '双' : null;
          
          for (int i = start; i <= end; i++) {
            if (oddEven == '单' && i % 2 == 0) continue;
            if (oddEven == '双' && i % 2 != 0) continue;
            numbers.add(i);
          }
        }
      } else {
        // 处理单个数字
        final num = int.tryParse(trimmed);
        if (num != null) numbers.add(num);
      }
    }

    final result = numbers.toList()..sort();
    return result;
  }

  /// 格式化数字列表为字符串
  /// 
  /// 参数：
  /// - [numbers]: 数字列表
  static String formatNumbers(List<int> numbers) {
    if (numbers.isEmpty) return '';
    
    final sorted = numbers.toSet().toList()..sort();
    final result = <String>[];
    int start = sorted[0], end = sorted[0];
    
    for (int i = 1; i <= sorted.length; i++) {
      if (i < sorted.length && sorted[i] == end + 1) {
        end = sorted[i];
      } else {
        result.add(start == end ? '$start' : '$start-$end');
        if (i < sorted.length) start = end = sorted[i];
      }
    }
    
    return result.join(', ');
  }

  /// 判断两个数字模式是否有重叠
  /// 
  /// 参数：
  /// - [a]: 第一个模式字符串
  /// - [b]: 第二个模式字符串
  /// 
  /// 返回：是否有重叠
  static bool hasOverlappingNumbers(String a, String b) {
    final numbersA = parseNumbers(a);
    final numbersB = parseNumbers(b);
    return numbersA.any((n) => numbersB.contains(n));
  }

  /// 判断指定数字是否匹配模式
  /// 
  /// 参数：
  /// - [number]: 要检查的数字
  /// - [pattern]: 模式字符串
  /// 
  /// 返回：是否匹配
  static bool matchesPattern(int number, String pattern) {
    if (pattern.isEmpty) return false;
    if (pattern == 'all') return true;
    
    final numbers = parseNumbers(pattern, defaultMax: 30);
    return numbers.contains(number);
  }

  /// 验证数字模式格式是否正确
  /// 
  /// 参数：
  /// - [pattern]: 要验证的模式字符串
  /// 
  /// 返回：验证结果，null表示正确，字符串表示错误信息
  static String? validatePattern(String pattern) {
    if (pattern.isEmpty) return '模式不能为空';
    
    // 检查基本格式
    if (!RegExp(r'^(\d+(-\d+)?(\[单\]|\[双\])?)(,\s*\d+(-\d+)?(\[单\]|\[双\])?)*$').hasMatch(pattern)) {
      return '格式错误，请使用如"1-16"、"1,3,5"或"1-3,5,7-9"的格式';
    }
    
    return null;
  }
}