import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/timetable_state.dart';
import '../states/view_state.dart';
import '../states/week_state.dart';
import 'timetable_management_dialog.dart';

/// 自定义应用栏组件（V2）
/// 
/// 主要功能：
/// - 返回按钮：切换回周视图
/// - 周次导航：显示当前周数，支持前后切换
/// - 课表管理：打开课表管理对话框
/// 
/// 状态依赖：
/// - TimetableStateV2: 获取课表信息和总周数
/// - ViewStateV2: 管理视图切换
/// - WeekStateV2: 管理当前周次
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
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: weekState.week > 1
                ? Colors.black87
                : Colors.black26,
          ),
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
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: weekState.week < totalWeeks
                ? Colors.black87
                : Colors.black26,
          ),
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
        child: IconButton(
          icon: const Icon(Icons.swap_horiz, color: Colors.black54),
          onPressed: () => _showTimetableManagementDialog(context),
        ),
      ),
    );
  }

  /// 显示课表管理对话框
  void _showTimetableManagementDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const TimetableManagementDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return _buildDialogTransition(animation, secondaryAnimation, child);
      },
    );
  }

  /// 构建对话框动画效果
  Widget _buildDialogTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 弹出动画：从中心缩放 + 淡入
    final scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.elasticOut,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ));

    // 回收动画：反向缩放和淡出
    final reverseScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInBack,
    ));

    final reverseFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInOut,
    ));

    return FadeTransition(
      opacity: animation.status == AnimationStatus.reverse
          ? reverseFadeAnimation
          : fadeAnimation,
      child: ScaleTransition(
        scale: animation.status == AnimationStatus.reverse
            ? reverseScaleAnimation
            : scaleAnimation,
        child: child,
      ),
    );
  }
}
