import 'package:flutter/material.dart';
import '../data/data_constants.dart';
import '../data/timetable.dart';
import 'timetable_state.dart';

/// ViewState
/// 
/// - 管理 UI 视图状态：selectedView / showWeekend / selectedDay
/// - 与 TimetableSettings.showWeekend 联动（可加载与写回）
class ViewState extends ChangeNotifier {
  String _selectedView = DataConstants.defaultSelectedView;
  bool _showWeekend = DataConstants.defaultShowWeekend;
  int? _selectedDay;

  /// 当前选中的视图名称（如：week/day/list）
  String get selectedView => _selectedView;

  /// 是否显示周末
  bool get showWeekend => _showWeekend;

  /// 当前选中的星期（1-7），可为空
  int? get selectedDay => _selectedDay;

  /// 从默认值重置
  void reset() {
    _selectedView = DataConstants.defaultSelectedView;
    _showWeekend = DataConstants.defaultShowWeekend;
    _selectedDay = null;
    notifyListeners();
  }

  /// 从课表加载视图偏好（只读取 showWeekend）
  Future<void> loadFromTimetable(Timetable? timetable) async {
    if (timetable == null) return;
    _showWeekend = timetable.settings.showWeekend;
    notifyListeners();
  }

  /// 切换视图（仅内存）
  void changeView(String view) {
    if (_selectedView == view) return;
    _selectedView = view;
    notifyListeners();
  }

  /// 切换周末显示，并持久化到指定课表（通过 TimetableState.put 写回）
  Future<void> toggleWeekend(bool show, {Timetable? timetable, TimetableState? timetableState}) async {
    if (_showWeekend == show) return;
    _showWeekend = show;

    if (timetable != null && timetableState != null) {
      // 更新课表设置并写回数据库
      timetable.settings.showWeekend = show;
      await timetableState.put(timetable);
    }

    notifyListeners();
  }

  /// 选择/清除选中日（仅内存）
  void selectDay(int? day) {
    _selectedDay = day;
    notifyListeners();
  }
}

