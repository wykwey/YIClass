import 'package:flutter/material.dart';
import 'components.dart';

// ================== 自定义 AppBar ==================
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
    Key? key,
  }) : super(key: key);

  static const double _defaultHeight = 44;

  @override
  Size get preferredSize => Size.fromHeight(_defaultHeight);

  Widget _buildTitle() {
    if (titleWidget != null) {
      return titleWidget!;
    }
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
          // 返回按钮
          if (showBackButton) ...[
            GestureDetector(
              onTap: onBackPressed ?? () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 12),
          ],
          // 标题
          Expanded(
            child: centerTitle ? Center(child: _buildTitle()) : _buildTitle(),
          ),
          // 右侧操作按钮
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
    Key? key,
  }) : super(key: key);

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
