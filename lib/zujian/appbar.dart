import 'package:flutter/material.dart';

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
    // 获取状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      // 总高度 = 状态栏高度 + AppBar 内容高度
      height: statusBarHeight + preferredSize.height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: [],
      ),
      child: Column(
        children: [
          // 状态栏占位
          SizedBox(height: statusBarHeight),
          // AppBar 内容区域
          Container(
            height: preferredSize.height,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // 返回按钮
                if (showBackButton) ...[
                  GestureDetector(
                    onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 12),
                ],
                // 标题
                Expanded(
                  child: centerTitle ? Center(child: _buildTitle()) : _buildTitle(),
                ),
                // 右侧操作按钮
                if (actions != null && actions!.isNotEmpty) ...[
                  SizedBox(width: 8),
                  ...actions!.map((action) => Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: action,
                  )),
                ],
              ],
            ),
          ),
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
  final Color? backgroundColor;

  const YicoreAppBarAction({
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Icon(
        icon,
        size: 20,
        color: iconColor ?? Colors.black,
      ),
    );
  }
}

