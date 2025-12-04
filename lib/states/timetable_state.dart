import 'package:flutter/foundation.dart';
import 'package:isar_plus/isar_plus.dart';
import '../data/timetable.dart';
import '../services/timetable/timetable_service.dart';
import '../services/settings_service.dart';
import '../services/timetable/factory_service.dart';
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

  /// 重新加载所有课表并定位当前课表
  /// 如果数据库中没有课表，自动创建默认课表并设置为当前课表
  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    
    // 1. 获取所有课表
    _timetables = await _service.getAll();
    
    // 2. 如果没有课表，自动创建默认课表并设置为当前课表
    if (_timetables.isEmpty) {
      final defaultTimetable = FactoryService.createTimetable(
        name: DataConstants.defaultTimetableName,
      );
      await _service.put(defaultTimetable);
      _timetables = await _service.getAll();
      
      // 设置为当前课表
      if (_timetables.isNotEmpty) {
        _current = _timetables.first;
        await SettingsService.instance.setCurrentTimetableId(_current!.id.toString());
      }
    } else {
      // 3. 从全局设置获取当前课表ID
      final currentIdStr = await SettingsService.instance.getCurrentTimetableId();
      if (currentIdStr.isNotEmpty) {
        final currentId = int.tryParse(currentIdStr);
        if (currentId != null) {
          final timetable = await _service.getById(currentId);
          if (timetable != null) {
            _current = timetable;
          }
        }
      }
      
      // 4. 如果当前课表不存在或无效，使用第一个课表并更新全局设置
      if (_current == null && _timetables.isNotEmpty) {
        _current = _timetables.first;
        await SettingsService.instance.setCurrentTimetableId(_current!.id.toString());
      }
    }
    
    _loading = false;
    notifyListeners();
  }

  /// 设置当前课表（仅内存态）
  void setCurrent(Timetable? timetable) {
    _current = timetable;
    notifyListeners();
  }

  /// 根据 ID 设置当前课表，并刷新内存态
  Future<bool> setCurrentById(int id) async {
    // 更新全局设置
    final ok = await SettingsService.instance.setCurrentTimetableId(id.toString());
    if (ok) {
      // 从数据库获取课表并更新内存态
      final timetable = await _service.getById(id);
      if (timetable != null) {
        _current = timetable;
        notifyListeners();
      } else {
        // 如果ID无效，重新加载
        await reload();
      }
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
  /// 当前课表不会被删除，此方法仅用于删除非当前课表
  Future<bool> delete(int id) async {
    final ok = await _service.delete(id);
    if (ok) {
      await reload();
    }
    return ok;
  }

  /// 清空所有课表
  Future<int> clearAll() async {
    final count = await _service.deleteAll();
    await reload();
    return count;
  }
}
