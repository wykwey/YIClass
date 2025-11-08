import 'package:flutter/material.dart';
import '../navigation.dart';

// ================== 高级组件页面 ==================
class PremiumComponentsPage extends StatefulWidget {
  @override
  _PremiumComponentsPageState createState() => _PremiumComponentsPageState();
}

class _PremiumComponentsPageState extends State<PremiumComponentsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          _buildNavigationDemo(),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  // ================== 导航组件演示 ==================
  Widget _buildNavigationDemo() {
    int demoIndex = 0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: '底部导航栏',
            subtitle: '自定义底部导航样式演示',
          ),
          SizedBox(height: 20),
          StatefulBuilder(
            builder: (context, setDemoState) {
              return YicoreBottomNavigationBar(
                currentIndex: demoIndex,
                onTap: (index) {
                  setDemoState(() {
                    demoIndex = index;
                  });
                },
                items: [
                  BottomNavItem(
                    icon: Icons.home,
                    label: '首页',
                  ),
                  BottomNavItem(
                    icon: Icons.calendar_today,
                    label: '课表',
                  ),
                  BottomNavItem(
                    icon: Icons.settings,
                    label: '设置',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ================== 节标题组件 ==================
class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionTitle({
    required this.title,
    this.subtitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 0.3,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

