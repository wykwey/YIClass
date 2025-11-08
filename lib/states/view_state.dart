import 'package:flutter/material.dart';
import '../data/data_constants.dart';

/// ViewState
/// 
/// - 管理 UI 视图状态：selectedView / selectedDay
class ViewState extends ChangeNotifier {
  String _selectedView = DataConstants.defaultSelectedView;
  int? _selectedDay;

  /// 当前选中的视图名称（如：week/day/list）
  String get selectedView => _selectedView;

  /// 当前选中的星期（1-7），可为空
  int? get selectedDay => _selectedDay;

  /// 从默认值重置
  void reset() {
    _selectedView = DataConstants.defaultSelectedView;
    _selectedDay = null;
    notifyListeners();
  }

  /// 切换视图（仅内存）
  void changeView(String view) {
    if (_selectedView == view) return;
    _selectedView = view;
    notifyListeners();
  }

  /// 选择/清除选中日（仅内存）
  void selectDay(int? weekday) {
    _selectedDay = weekday;
    notifyListeners();
  }
}

