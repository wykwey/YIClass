import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../states/view_state.dart';

// ================== 底部导航项 ==================
class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.label,
  });
}

// ================== 通用底部导航栏 ==================
class YicoreBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const YicoreBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6).copyWith(
        bottom: 6 + bottomPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          BottomNavItem item = entry.value;
          bool isSelected = index == currentIndex;

          return Expanded(
            child: _NavItem(
              item: item,
              isSelected: isSelected,
              onTap: () => onTap(index),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ================== 导航项组件 ==================
class _NavItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon,
                size: 19,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 13 : 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: Colors.black,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== 应用专用底部导航栏 ==================
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

  int _getIndex(String view) {
    switch (view) {
      case '周视图': return 0;
      case '日视图': return 1;
      case '列表视图': return 0;
      case '设置': return 2;
      default: return 0;
    }
  }
}
