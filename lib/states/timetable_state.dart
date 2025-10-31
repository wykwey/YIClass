import 'package:flutter/foundation.dart';
import 'package:isar_plus/isar_plus.dart';
import '../data/timetable.dart';
import '../services/timetable_service.dart';
import '../services/factory_service.dart';
import '../data/data_constants.dart';

/// TimetableState
/// 
/// - 负责管理 Timetable 列表与当前选中课表
/// - 封装加载/刷新/设置默认/增删改等操作，并在完成后通知监听者
class TimetableState extends ChangeNotifier {
  final TimetableService _service = TimetableService.instance;

  bool _initialized = false;
  bool _loading = false;
  List<Timetable> _timetables = <Timetable>[];
  Timetable? _current;

  /// 是否已初始化
  bool get initialized => _initialized;

  /// 是否处于加载中
  bool get loading => _loading;

  /// 所有课表
  List<Timetable> get timetables => _timetables;

  /// 当前课表
  Timetable? get current => _current;

  /// 初始化：注入 Isar 实例并加载数据
  Future<void> init(Isar isar) async {
    if (_initialized) return;
    await _service.init(isar);
    await reload();
    _initialized = true;
    notifyListeners();
  }

  /// 重新加载所有课表并定位当前默认课表
  /// 如果数据库中没有课表，自动创建默认课表
  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    _timetables = await _service.getAll();
    
    // 如果没有课表，自动创建默认课表
    if (_timetables.isEmpty) {
      final defaultTimetable = FactoryService.createTimetable(
        name: DataConstants.defaultTimetableName,
        isDefault: true,
      );
      await _service.put(defaultTimetable);
      _timetables = await _service.getAll();
    }
    
    _current = await _service.getDefault() ?? (_timetables.isNotEmpty ? _timetables.first : null);
    _loading = false;
    notifyListeners();
  }

  /// 设置当前课表（仅内存态）
  void setCurrent(Timetable? timetable) {
    _current = timetable;
    notifyListeners();
  }

  /// 根据 ID 设置默认课表，并刷新内存态
  Future<bool> setDefaultById(int id) async {
    final ok = await _service.setDefault(id);
    if (ok) {
      await reload();
    }
    return ok;
  }

  /// 新增或更新课表
  Future<bool> put(Timetable timetable) async {
    final ok = await _service.put(timetable);
    if (ok) await reload();
    return ok;
  }

  /// 批量新增或更新课表
  Future<bool> putAll(List<Timetable> list) async {
    final ok = await _service.putAll(list);
    if (ok) await reload();
    return ok;
  }

  /// 删除课表（按 ID）
  Future<bool> delete(int id) async {
    final ok = await _service.delete(id);
    if (ok) await reload();
    return ok;
  }

  /// 清空所有课表
  Future<int> clearAll() async {
    final count = await _service.deleteAll();
    await reload();
    return count;
  }
}

