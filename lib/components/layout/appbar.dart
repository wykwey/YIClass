import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../states/timetable_state.dart';
import '../../states/view_state.dart';
import '../../states/week_state.dart';
import '../feedback/timetable_management_dialog.dart';
import '../inputs/components.dart';

// ================== 通用 AppBar ==================
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

  static const double _defaultHeight = 44;

  @override
  Size get preferredSize => Size.fromHeight(_defaultHeight);

  Widget _buildTitle() {
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
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bgColor = backgroundColor ?? Colors.white;

    return Container(
      height: statusBarHeight + preferredSize.height,
      padding: EdgeInsets.fromLTRB(16, statusBarHeight, 16, 0),
      color: bgColor,
      child: Row(
        children: [
          if (showBackButton) ...[
            GestureDetector(
              onTap: onBackPressed ?? () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: centerTitle ? Center(child: _buildTitle()) : _buildTitle(),
          ),
          if (actions != null && actions!.isNotEmpty)
            ...actions!.map((action) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: action,
            )),
        ],
      ),
    );
  }
}

// ================== AppBar 操作按钮 ==================
class YicoreAppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;

  const YicoreAppBarAction({
    required this.icon,
    this.onPressed,
    this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return YicoreIconButton(
      icon: icon,
      onPressed: onPressed,
      iconColor: iconColor,
      size: 36,
      showBorder: false,
    );
  }
}

// ================== 课表专用 AppBar (带周次导航) ==================
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

  Widget _buildBackButton(BuildContext context) {
    return YicoreIconButton(
      icon: Icons.arrow_back,
      showBorder: false,
      onPressed: () {
        final viewState = Provider.of<ViewState>(context, listen: false);
        viewState.changeView('周视图');
      },
    );
  }

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
        YicoreIconButton(
          icon: Icons.chevron_left,
          showBorder: false,
          onPressed: weekState.week > 1
              ? () => weekState.setWeek(weekState.week - 1)
              : null,
        ),
        Text(
          '第${weekState.week}周',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
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

  Widget _buildTimetableManagementButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: YicoreIconButton(
          icon: Icons.swap_horiz,
          showBorder: false,
          onPressed: () => TimetableManagementDialog.show(context),
        ),
      ),
    );
  }
}
