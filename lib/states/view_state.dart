import 'package:flutter/material.dart';
import '../data/data_constants.dart';

/// ViewState
/// 
/// - 管理 UI 视图状态：selectedView / selectedDay
class ViewState extends ChangeNotifier {
  String _selectedView = DataConstants.defaultSelectedView;
  int _selectedDay = DateTime.now().weekday;

  /// 当前选中的视图名称
  String get selectedView => _selectedView;

  /// 当前选中的星期（1-7）
  int get selectedDay => _selectedDay;

  /// 从默认值重置
  void reset() {
    _selectedView = DataConstants.defaultSelectedView;
    _selectedDay = DateTime.now().weekday;
    notifyListeners();
  }

  /// 切换视图
  void changeView(String view) {
    if (_selectedView == view) return;
    _selectedView = view;
    
    // 切换到日视图时，自动选中今天
    if (view == '日视图') {
      _selectedDay = DateTime.now().weekday;
    }
    
    notifyListeners();
  }

  /// 选择日期
  void selectDay(int weekday) {
    _selectedDay = weekday;
    notifyListeners();
  }
}

