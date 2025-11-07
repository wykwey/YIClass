import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/view_state.dart';
import '../zujian/navigation.dart';

class AppBottomNavBar extends StatelessWidget {
  final int? currentIndex;
  final ValueChanged<int>? onTabChanged;
  
  const AppBottomNavBar({super.key, this.currentIndex, this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final viewState = context.watch<ViewState>();
    final idx = currentIndex ?? _getIndex(viewState.selectedView);

    return YicoreBottomNavigationBar(
      currentIndex: idx,
      onTap: (index) {
        if (onTabChanged != null) {
          onTabChanged!(index);
        } else {
          // 直接切换视图，不使用 Navigator
          final views = ['周视图', '日视图', '设置'];
          viewState.changeView(views[index]);
        }
      },
      items: const [
        BottomNavItem(icon: Icons.calendar_view_week, label: '周视图'),
        BottomNavItem(icon: Icons.calendar_today, label: '日视图'),
        BottomNavItem(icon: Icons.settings, label: '设置'),
      ],
    );
  }

  /// 根据视图名称获取索引
  int _getIndex(String view) {
    switch (view) {
      case '周视图':
        return 0;
      case '日视图':
        return 1;
      case '列表视图':
        return 0; // 列表视图使用周视图的索引
      case '设置':
        return 2;
      default:
        return 0;
    }
  }
}
