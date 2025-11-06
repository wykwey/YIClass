import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/view_state.dart';
import '../views/settings_view.dart';
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
          if (index == 2) {
            // 导航到设置页
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ),
            );
          } else {
            // 切换周视图/日视图
            final views = ['周视图', '日视图'];
            viewState.changeView(views[index]);
          }
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
      default:
        return 0;
    }
  }
}
