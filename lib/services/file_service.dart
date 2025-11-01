import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../data/timetable.dart';
import '../data/timetable_settings.dart';
import '../data/class_time.dart';
import '../data/course.dart';
import '../data/course_schedule.dart';
import 'timetable_service.dart';
import '../data/data_constants.dart';
import '../utils/color_utils.dart';

/// 文件服务：导入/导出 Timetable
/// 仅负责结构转换（Timetable <-> Map/JSON）与持久化入口封装
class FileService {
  // ===== 导出为可序列化 Map =====

  /// 将 Timetable 导出为可序列化的 Map 结构
  /// - t: 待导出的课表对象
  /// 返回：包含课表、设置、课程与时间安排的 Map
  static Map<String, dynamic> toMap(Timetable t) {
    return {
      'id': t.id,
      'name': t.name,
      'isDefault': t.isDefault,
      'settings': _settingsToMap(t.settings),
      'courses': t.courses.map(_courseToMap).toList(),
      'version': '2.0',
        'exportTime': DateTime.now().toIso8601String(),
    };
  }

  /// 将 TimetableSettings 导出为 Map（包含 showWeekend）
  static Map<String, dynamic> _settingsToMap(TimetableSettings s) {
    return {
      'startDate': s.startDate.toIso8601String(),
      'totalWeeks': s.totalWeeks,
      'showWeekend': s.showWeekend,
      'maxPeriods': s.maxPeriods,
      'holidays': s.holidays.map((d) => d.toIso8601String()).toList(),
      'reminderMinutes': s.reminderMinutes,
    };
  }

  // 不再导出/解析单个 ClassTime

  /// 将 Course 导出为 Map
  static Map<String, dynamic> _courseToMap(Course c) {
    return {
      'name': c.name,
      'location': c.location,
      'teacher': c.teacher,
      'color': c.color,
      'schedules': c.schedules.map(_scheduleToMap).toList(),
    };
  }

  /// 将 CourseSchedule 导出为 Map
  static Map<String, dynamic> _scheduleToMap(CourseSchedule s) {
    return {
      'day': s.day,
      'periods': s.periods,
      'weekPattern': s.weekPattern,
      'reminder': s.reminder,
    };
  }

  // ===== 从 Map 构建 Timetable =====

  /// 从 Map 构建 Timetable（包含 showWeekend）
  /// - m: 包含课表、设置、课程与时间安排的 Map
  /// 返回：Timetable 实例
  static Timetable fromMap(Map<String, dynamic> m) {
    final Map<String, dynamic> settingsMap = Map<String, dynamic>.from(m['settings'] as Map? ?? {});

    // startDate（默认当前时间）
    final String? startDateStr = settingsMap['startDate'] as String?;
    DateTime startDate;
    if (startDateStr != null) {
      try {
        startDate = DateTime.parse(startDateStr);
      } catch (_) {
        startDate = DateTime.now();
      }
    } else {
      startDate = DateTime.now();
    }

    // totalWeeks / showWeekend（使用 DataConstants 默认值）
    final int totalWeeks = settingsMap['totalWeeks'] as int? ?? DataConstants.defaultTotalWeeks;
    final bool showWeekend = settingsMap['showWeekend'] as bool? ?? DataConstants.defaultShowWeekend;

    // maxPeriods：缺失用默认值
    final int maxPeriods = settingsMap['maxPeriods'] as int? ?? DataConstants.defaultMaxPeriods;

    // classTimes：不解析输入，按 maxPeriods 直接生成默认时段
    final List<ClassTime> classTimes = List<ClassTime>.generate(maxPeriods, (index) {
      final int period = index + 1;
      final String def = DataConstants.defaultPeriodTimes[period.toString()] ?? '08:00-08:45';
      final List<String> parts = def.split('-');
      return ClassTime()
        ..period = period
        ..startTime = parts.isNotEmpty ? parts.first : '08:00'
        ..endTime = parts.length > 1 ? parts.last : '08:45';
    });

    // holidays（默认空数组）
    List<DateTime> holidays = <DateTime>[];
    if (settingsMap['holidays'] is List) {
      holidays = (settingsMap['holidays'] as List)
          .map((e) => DateTime.tryParse(e.toString()))
          .whereType<DateTime>()
          .toList();
    }

    // reminderMinutes（默认30分钟）
    final int reminderMinutes = settingsMap['reminderMinutes'] as int? ?? 30;

    final s = TimetableSettings()
      ..startDate = startDate
      ..totalWeeks = totalWeeks
      ..showWeekend = showWeekend
      ..classTimes = classTimes
      ..holidays = holidays
      ..reminderMinutes = reminderMinutes;

    // 以 maxPeriods 为准
    s.maxPeriods = maxPeriods;

    final t = Timetable()
      ..id = (m['id'] as int? ?? 0)
      ..name = m['name']?.toString() ?? ''
      ..isDefault = (m['isDefault'] as bool? ?? false)
      ..settings = s
      ..courses = (m['courses'] as List)
          .map((e) => _courseFromMap(Map<String, dynamic>.from(e)))
          .toList();

    return t;
  }

  // 不再从 JSON 解析单个 ClassTime

  /// 从 Map 构建 Course
  static Course _courseFromMap(Map<String, dynamic> m) {
    final c = Course()
      ..name = m['name']?.toString() ?? ''
      ..location = m['location']?.toString() ?? ''
      ..teacher = m['teacher']?.toString() ?? ''
      ..color = (() {
        final dynamic colorAny = m['color'];
        if (colorAny is int && colorAny > 0) return colorAny;
        // 无颜色字段或非法值：从预设颜色中随机选择
        return ColorUtils.getRandomColor().value;
      })()
      ..schedules = (m['schedules'] as List)
          .map((e) => _scheduleFromMap(Map<String, dynamic>.from(e)))
          .toList();
    return c;
  }

  /// 从 Map 构建 CourseSchedule
  static CourseSchedule _scheduleFromMap(Map<String, dynamic> m) {
    final s = CourseSchedule()
      ..day = m['day'] as int
      ..periods = (m['periods'] as List).cast<int>().toList()
      ..weekPattern = (m['weekPattern'] as List).cast<int>().toList()
      ..reminder = m['reminder']?.toString() ?? '';
    return s;
  }

  // ===== JSON 便捷方法 =====

  /// 导出为 JSON 字符串（带缩进）
  static String toJson(Timetable t) => const JsonEncoder.withIndent('  ').convert(toMap(t));

  /// 从 JSON 字符串导入 Timetable
  static Timetable fromJson(String json) => fromMap(jsonDecode(json) as Map<String, dynamic>);

  // ===== 持久化便捷方法 =====

  /// 保存 Timetable（委托给 TimetableService）
  static Future<bool> save(Timetable t) async {
    return await TimetableService.instance.put(t);
  }

  // ===== 基于 file_selector 的导入/导出 =====

  /// 选择保存位置并导出课表为 JSON 文件。
  /// - suggestedName: 建议文件名（默认带 .json 后缀）
  /// - 返回：成功时返回保存路径；用户取消或不支持平台返回 null
  static Future<String?> exportTimetable(Timetable t, {String? suggestedName}) async {
    final String fileName = (suggestedName == null || suggestedName.trim().isEmpty)
        ? 'YIClass_${t.name.isNotEmpty ? t.name : 'Timetable'}.json'
        : (suggestedName.endsWith('.json') ? suggestedName : '${suggestedName}.json');

    final String jsonText = toJson(t);

    // Web：使用浏览器下载（file_selector 的 saveTo 会触发下载）
    if (kIsWeb) {
      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonText));
      final XFile xfile = XFile.fromData(
        bytes,
        mimeType: 'application/json',
        name: fileName,
      );
      await xfile.saveTo(fileName);
      return fileName; // Web 返回文件名作为下载参考
    }

    // Android：支持选择目录后保存
    if (Platform.isAndroid) {
      final String? directoryPath = await getDirectoryPath();
      if (directoryPath == null) return null; // 用户取消
      final String path = '$directoryPath/$fileName';
      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonText));
      final XFile xfile = XFile.fromData(
        bytes,
        mimeType: 'application/json',
        name: fileName,
      );
      await xfile.saveTo(path);
      return path;
    }

    // iOS：暂不支持
    if (Platform.isIOS) {
      return null;
    }

    // 桌面端（Windows/macOS/Linux）：使用原生保存对话框
    final FileSaveLocation? location = await getSaveLocation(suggestedName: fileName);
    if (location == null) return null; // 用户取消

    final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonText));
    final XFile xfile = XFile.fromData(
      bytes,
      mimeType: 'application/json',
      name: fileName,
    );
    await xfile.saveTo(location.path);
    return location.path;
  }

  /// 通过文件选择器导入课表 JSON。
  /// - 返回：成功时返回 Timetable；用户取消或解析失败返回 null
  static Future<Timetable?> importTimetable() async {
    const XTypeGroup jsonGroup = XTypeGroup(
      label: 'JSON',
      extensions: <String>['json'],
      mimeTypes: <String>['application/json'],
      uniformTypeIdentifiers: <String>['public.json'],
    );

    final XFile? picked = await openFile(acceptedTypeGroups: <XTypeGroup>[jsonGroup]);
    if (picked == null) return null; // 用户取消

    try {
      final String content = await picked.readAsString();
      final Timetable t = fromJson(content);
      return t;
    } catch (_) {
      return null;
    }
  }

  /// 通过文件选择器导入并保存到本地数据库。
  /// - 返回：保存成功返回 true；取消/失败返回 false
  static Future<bool> importAndSave() async {
    final Timetable? t = await importTimetable();
    if (t == null) return false;
    return await save(t);
  }
}

