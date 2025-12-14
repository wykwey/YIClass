import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../states/timetable_state.dart';
import '../../states/view_state.dart';
import '../../states/week_state.dart';
import '../feedback/timetable_management_dialog.dart';
import '../inputs/components.dart';

// ================== 通用 AppBar ==================

/// 通用应用栏组件
/// 
/// 使用 Stack 布局实现标题真正居中，支持返回按钮和操作按钮。
class YicoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final bool centerTitle;

  const YicoreAppBar({
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.centerTitle = false,
    super.key,
  });

  /// AppBar 高度
  static const double _height = 44;
  
  /// 水平内边距
  static const double _horizontalPadding = 16;
  
  /// 返回按钮宽度
  static const double _backButtonWidth = 36;
  
  /// 操作按钮间距
  static const double _actionSpacing = 8;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  /// 构建标题组件
  Widget _buildTitleWidget() {
    if (titleWidget != null) return titleWidget!;
    if (title != null) {
      return Text(
        title!,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: titleColor ?? Colors.black,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// 构建返回按钮
  Widget _buildBackButton(BuildContext context) {
    return YicoreIconButton(
      icon: Icons.arrow_back_ios_new,
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      showBorder: false,
    );
  }

  /// 构建操作按钮组
  Widget _buildActions() {
    if (actions == null || actions!.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions!.map((action) => Padding(
        padding: const EdgeInsets.only(left: _actionSpacing),
        child: action,
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bgColor = backgroundColor ?? Colors.white;
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Container(
      height: statusBarHeight + preferredSize.height,
      padding: EdgeInsets.only(top: statusBarHeight),
      color: bgColor,
      child: SizedBox(
        height: _height,
        child: Stack(
          children: [
            // 标题：centerTitle=true 时使用 Center，否则使用 Positioned
            if (centerTitle)
              Center(child: _buildTitleWidget())
            else
              Positioned(
                left: showBackButton 
                    ? _horizontalPadding + _backButtonWidth + _actionSpacing 
                    : _horizontalPadding,
                top: 0,
                bottom: 0,
                child: Center(child: _buildTitleWidget()),
              ),
            
            // 返回按钮：固定在左侧
            if (showBackButton)
              Positioned(
                left: _horizontalPadding,
                top: 0,
                bottom: 0,
                child: Center(child: _buildBackButton(context)),
              ),
            
            // 操作按钮：固定在右侧
            if (actions != null && actions!.isNotEmpty)
              Positioned(
                right: _horizontalPadding,
                top: 0,
                bottom: 0,
                child: Center(child: _buildActions()),
              ),
          ],
        ),
      ),
    );
  }
}

// ================== 周次选择器 ==================

/// 周次选择器组件
/// 
/// 显示当前周次，支持左右切换周次。
class WeekSelector extends StatelessWidget {
  const WeekSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final timetableState = context.watch<TimetableState>();
    final weekState = context.watch<WeekState>();
    final totalWeeks = timetableState.current?.settings.totalWeeks ?? 20;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        YicoreIconButton(
          icon: Icons.arrow_back_ios_new,
          showBorder: false,
          onPressed: weekState.week > 1
              ? () => weekState.setWeek(weekState.week - 1)
              : null,
        ),
        Text(
          '第${weekState.week}周',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        YicoreIconButton(
          icon: Icons.arrow_forward_ios,
          showBorder: false,
          onPressed: weekState.week < totalWeeks
              ? () => weekState.setWeek(weekState.week + 1)
              : null,
        ),
      ],
    );
  }
}

// ================== 课表专用 AppBar (带周次导航) ==================

/// 课表专用应用栏
/// 
/// 基于 YicoreAppBar，集成周次选择器和课表管理按钮。
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(YicoreAppBar._height);

  @override
  Widget build(BuildContext context) {
    return YicoreAppBar(
      centerTitle: true,
      onBackPressed: () {
        final viewState = Provider.of<ViewState>(context, listen: false);
        viewState.changeView('周视图');
      },
      titleWidget: const WeekSelector(),
      actions: [
        YicoreIconButton(
          icon: Icons.swap_horiz,
          showBorder: false,
          onPressed: () => TimetableManagementDialog.show(context),
        ),
      ],
    );
  }
}
