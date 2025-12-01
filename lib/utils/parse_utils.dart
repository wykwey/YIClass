/// 解析工具类 - 提供节次/周次的解析与格式化功能
class ParseUtils {
  ParseUtils._();

  // ==================== 字符映射表 ====================

  static const _fullWidthDigits = {
    '０': '0', '１': '1', '２': '2', '３': '3', '４': '4',
    '５': '5', '６': '6', '７': '7', '８': '8', '９': '9',
  };

  static const _dashVariants = ['－', '—', '–', '―'];

  // ==================== 核心解析 ====================

  /// 解析节次/周次字符串为整数列表
  ///
  /// 支持格式：`1` | `2-4` | `6-8[单]` | `1,3-5` | `all`
  /// 
  /// 解析失败时抛出 [FormatException]
  static List<int> parseNumbers(String input, {int defaultMax = 30}) {
    if (input.isEmpty) {
      throw const FormatException('输入不能为空');
    }
    if (input == 'all') return List.generate(defaultMax, (i) => i + 1);

    final normalized = _normalize(input);
    final numbers = <int>{};

    for (final part in normalized.replaceAll(' ', ',').split(',')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.contains('-')) {
        _parseRange(trimmed, numbers);
      } else {
        final n = int.tryParse(trimmed);
        if (n == null) {
          throw FormatException('无法解析: "$trimmed"');
        }
        numbers.add(n);
      }
    }

    if (numbers.isEmpty) {
      throw FormatException('无法从 "$input" 解析出有效数字');
    }

    return numbers.toList()..sort();
  }

  /// 格式化数字列表为紧凑字符串（如 `[1,2,3,5]` → `"1-3, 5"`）
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

  // ==================== 匹配与验证 ====================

  /// 判断 [number] 是否在 [pattern] 范围内
  static bool matchesPattern(int number, String pattern) {
    if (pattern.isEmpty) return false;
    if (pattern == 'all') return true;
    return parseNumbers(pattern).contains(number);
  }

  /// 判断两个模式是否有重叠
  static bool hasOverlap(String a, String b) {
    final setA = parseNumbers(a).toSet();
    return parseNumbers(b).any(setA.contains);
  }

  /// 验证模式格式，返回错误信息或 null
  static String? validate(String pattern) {
    if (pattern.isEmpty) return '模式不能为空';
    final normalized = _normalize(pattern);
    final regex = RegExp(r'^(\d+(-\d+)?(\[单]|\[双])?)(,\s*\d+(-\d+)?(\[单]|\[双])?)*$');
    if (!regex.hasMatch(normalized)) {
      return '格式错误，示例：1-16、1,3,5、1-3,5,7-9';
    }
    return null;
  }

  // ==================== 私有方法 ====================

  /// 预处理：全角→半角，统一分隔符
  static String _normalize(String input) {
    var result = input;
    _fullWidthDigits.forEach((k, v) => result = result.replaceAll(k, v));
    for (final dash in _dashVariants) {
      result = result.replaceAll(dash, '-');
    }
    return result
        .replaceAll('，', ',')
        .replaceAll('【', '[')
        .replaceAll('】', ']');
  }

  /// 解析范围格式（如 `2-4`、`6-8[单]`），失败时抛出 [FormatException]
  static void _parseRange(String trimmed, Set<int> numbers) {
    final parts = trimmed.split('-');
    if (parts.length != 2) {
      throw FormatException('范围格式错误: "$trimmed"');
    }

    final start = int.tryParse(parts[0].trim());
    final endStr = parts[1].replaceAll(RegExp(r'\[.*]'), '').trim();
    final end = int.tryParse(endStr);
    
    if (start == null || end == null) {
      throw FormatException('范围格式错误: "$trimmed"');
    }
    if (start > end) {
      throw FormatException('范围起始值不能大于结束值: "$trimmed"');
    }

    final isOdd = trimmed.contains('[单]');
    final isEven = trimmed.contains('[双]');

    for (int i = start; i <= end; i++) {
      if (isOdd && i.isEven) continue;
      if (isEven && i.isOdd) continue;
      numbers.add(i);
    }
  }
}