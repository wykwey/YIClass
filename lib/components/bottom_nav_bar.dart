import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/view_state.dart';
import '../../views/settings_view.dart';

class AppBottomNavBar extends StatelessWidget {
  final int? currentIndex;
  final ValueChanged<int>? onTabChanged;
  const AppBottomNavBar({super.key, this.currentIndex, this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final viewState = context.watch<ViewState>();
    final idx = currentIndex ?? _getIndex(viewState.selectedView);

    return Theme(
      data: Theme.of(context).copyWith(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue.shade400,
          unselectedItemColor: Colors.grey[600],
          // 禁用点击效果
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        // 禁用Material组件的点击效果
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 防止自动切换效果类型
        currentIndex: idx,
        onTap: (index) {
          if (onTabChanged != null) {
            onTabChanged!(index);
          } else {
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            } else {
              final views = ['周视图', '日视图'];
              viewState.changeView(views[index]);
            }
          }
        },
        items: [
          _buildItem(context, Icons.calendar_view_week, '周视图', idx == 0),
          _buildItem(context, Icons.calendar_today, '日视图', idx == 1),
          _buildItem(context, Icons.settings, '设置', idx == 2),
        ],
      ),
    );
  }

  int _getIndex(String view) {
    switch (view) {
      case '周视图':
        return 0;
      case '日视图':
        return 1;
      case '列表视图':
        return 0; // 列表视图使用周视图的索引，因为底部导航栏没有列表视图选项
      default:
        return 0;
    }
  }

  BottomNavigationBarItem _buildItem(
    BuildContext context,
    IconData icon,
    String label,
    bool selected,
  ) {
    final iconColor = selected ? Colors.blue.shade400 : Colors.grey[600];

    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: iconColor,
      ),
      label: label,
    );
  }
}
