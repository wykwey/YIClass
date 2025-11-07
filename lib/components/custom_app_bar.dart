import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/timetable_state.dart';
import '../states/view_state.dart';
import '../states/week_state.dart';
import 'timetable_management_dialog.dart';
import '../zujian/components.dart';

/// 自定义应用栏组件（V2）
/// 
/// 主要功能：
/// - 返回按钮：切换回周视图
/// - 周次导航：显示当前周数，支持前后切换
/// - 课表管理：打开课表管理对话框
/// 
/// 状态依赖：
/// - TimetableState: 获取课表信息和总周数
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final timetableState = context.watch<TimetableState>();
    final weekState = context.watch<WeekState>();

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: _buildBackButton(context),
      centerTitle: true,
      title: _buildWeekNavigation(context, timetableState, weekState),
      actions: [_buildTimetableManagementButton(context)],
    );
  }

  /// 构建返回按钮
  Widget _buildBackButton(BuildContext context) {
    return YicoreIconButton(
      icon: Icons.arrow_back,
      showBorder: false,
      onPressed: () {
        final viewState = Provider.of<ViewState>(context, listen: false);
        viewState.changeView('周视图');
        // 不再退出应用
      },
    );
  }

  /// 构建周次导航
  Widget _buildWeekNavigation(
    BuildContext context,
    TimetableState timetableState,
    WeekState weekState,
  ) {
    final totalWeeks = timetableState.current?.settings.totalWeeks ?? 20;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 上一周按钮
        YicoreIconButton(
          icon: Icons.chevron_left,
          showBorder: false,
          onPressed: weekState.week > 1
              ? () => weekState.setWeek(weekState.week - 1)
              : null,
        ),
        // 当前周数显示
        Text(
          '第${weekState.week}周',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        // 下一周按钮
        YicoreIconButton(
          icon: Icons.chevron_right,
          showBorder: false,
          onPressed: weekState.week < totalWeeks
              ? () => weekState.setWeek(weekState.week + 1)
              : null,
        ),
      ],
    );
  }

  /// 构建课表管理按钮
  Widget _buildTimetableManagementButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: YicoreIconButton(
          icon: Icons.swap_horiz,
          showBorder: false,
          onPressed: () => _showTimetableManagementDialog(context),
        ),
      ),
    );
  }

  /// 显示课表管理对话框
  void _showTimetableManagementDialog(BuildContext context) {
    TimetableManagementDialog.show(context);
  }
}
