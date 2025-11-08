import 'package:flutter/material.dart';
import 'notifications.dart';
import 'navigation.dart';
import 'fab.dart';
import 'pages/basic_components_page.dart';
import 'pages/advanced_components_page.dart';
import 'pages/premium_components_page.dart';

void main() {
  runApp(MaterialApp(
    home: ComponentDemoPage(),
  ));
}

// ================== 主演示页面 ==================
class ComponentDemoPage extends StatefulWidget {
  @override
  _ComponentDemoPageState createState() => _ComponentDemoPageState();
}

class _ComponentDemoPageState extends State<ComponentDemoPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: Stack(
        children: [
          // 根据当前索引显示不同的页面
          IndexedStack(
            index: _currentIndex,
            children: [
              BasicComponentsPage(),
              AdvancedComponentsPage(),
              PremiumComponentsPage(),
            ],
          ),
          // 悬浮窗按钮演示
          YicoreFab(
            icon: Icons.add,
            menuItems: [
              YicoreFabItem(
                icon: Icons.edit,
                label: '编辑',
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了编辑',
                  );
                },
              ),
              YicoreFabItem(
                icon: Icons.favorite,
                label: '收藏',
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了收藏',
                  );
                },
              ),
              YicoreFabItem(
                icon: Icons.share,
                label: '分享',
                onPressed: () {
                  Notifications.sonner(
                    context,
                    message: '点击了分享',
                  );
                },
              ),
            ],
            onPressed: () {
              Notifications.sonner(
                context,
                message: '点击了主按钮',
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: YicoreBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavItem(
            icon: Icons.widgets,
            label: '基础组件',
          ),
          BottomNavItem(
            icon: Icons.extension,
            label: '进阶组件',
          ),
          BottomNavItem(
            icon: Icons.workspace_premium,
            label: '高级组件',
          ),
        ],
      ),
    );
  }
}
