import 'package:flutter/material.dart';
import 'components.dart';
import 'segmented_control.dart';

// ================== 设置项块 ==================
class SettingsItem extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool inBlock;
  final bool showArrow;
  final String? value;
  final bool isLastInBlock;
  final bool enabled;

  const SettingsItem({
    required this.title,
    this.description,
    this.trailing,
    this.onTap,
    this.inBlock = false,
    this.showArrow = false,
    this.value,
    this.isLastInBlock = false,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  // 便捷构造：开关类型
  factory SettingsItem.switch_({
    required String title,
    String? description,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool inBlock = false,
    bool enabled = true,
  }) {
    return SettingsItem(
      title: title,
      description: description,
      inBlock: inBlock,
      enabled: enabled,
      trailing: YicoreSwitch(
        value: value,
        onChanged: enabled ? onChanged : (_) {},
      ),
    );
  }

  // 便捷构造：文本值类型
  factory SettingsItem.value({
    required String title,
    String? description,
    required String value,
    VoidCallback? onTap,
    bool inBlock = false,
    bool showArrow = true,
    bool enabled = true,
  }) {
    return SettingsItem(
      title: title,
      description: description,
      value: value,
      onTap: enabled ? onTap : null,
      inBlock: inBlock,
      showArrow: showArrow,
      enabled: enabled,
    );
  }

  // 便捷构造：纯文本类型
  factory SettingsItem.text({
    required String title,
    String? description,
    VoidCallback? onTap,
    bool inBlock = false,
    bool showArrow = false,
    bool enabled = true,
  }) {
    return SettingsItem(
      title: title,
      description: description,
      onTap: enabled ? onTap : null,
      inBlock: inBlock,
      showArrow: showArrow,
      enabled: enabled,
    );
  }

  // 便捷构造：滑块类型
  factory SettingsItem.slider({
    required String title,
    String? description,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    bool inBlock = false,
    bool enabled = true,
  }) {
    return SettingsItem(
      title: title,
      description: description,
      inBlock: inBlock,
      enabled: enabled,
      trailing: YicoreSlider(
        value: value,
        min: min,
        max: max,
        onChanged: enabled ? onChanged : (_) {},
      ),
    );
  }

  // 便捷构造：分段控制器类型
  factory SettingsItem.segmented({
    required String title,
    String? description,
    required List<SegmentedItem> items,
    required String selectedValue,
    required ValueChanged<String> onChanged,
    bool inBlock = false,
    bool showBorder = true,
    bool enabled = true,
  }) {
    return SettingsItem(
      title: title,
      description: description,
      inBlock: inBlock,
      enabled: enabled,
      trailing: SizedBox(
        width: 220,
        child: YicoreSegmentedControl(
          size: SegmentedControlSize.small,
          showBorder: showBorder,
          items: items,
          selectedValue: selectedValue,
          onChanged: enabled ? onChanged : (_) {},
        ),
      ),
    );
  }

  // ================== 私有辅助 ==================
  BorderRadius? _radius() {
    if (!inBlock) return BorderRadius.circular(12);
    if (isLastInBlock) {
      return BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    }
    return null;
  }

  Widget? _buildTrailing() {
    final arrowColor = enabled ? Colors.grey[400]! : Colors.grey[300]!;
    final valueColor = enabled ? Colors.grey[600]! : Colors.grey[400]!;
    final arrow = showArrow ? Icon(Icons.chevron_right, size: 20, color: arrowColor) : null;

    if (value != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value!, style: TextStyle(fontSize: 14, color: valueColor)),
          if (arrow != null) ...[SizedBox(width: 8), arrow],
        ],
      );
    }

    if (trailing != null && arrow != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [trailing!, SizedBox(width: 8), arrow],
      );
    }

    return trailing ?? arrow;
  }

  Color? _overlayColor(Set<WidgetState> states) =>
      (enabled && onTap != null && states.contains(WidgetState.pressed))
          ? Color(0xFFE2E2E2)
          : Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final radius = _radius();
    final trailingWidget = _buildTrailing();
    
    // 禁用时的颜色和透明度
    final titleColor = enabled 
        ? Colors.black.withValues(alpha: 0.85)
        : Colors.grey[400]!;
    final descriptionColor = enabled 
        ? Colors.grey[600]
        : Colors.grey[400]!;
    final opacity = enabled ? 1.0 : 0.5;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: inBlock ? Colors.transparent : Colors.white,
        shape: radius == null ? null : RoundedRectangleBorder(borderRadius: radius),
        child: ClipRRect(
          borderRadius: radius ?? BorderRadius.zero,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: radius,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.resolveWith(_overlayColor),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: titleColor,
                            height: 1.2,
                          ),
                        ),
                        if (description != null) ...[
                          SizedBox(height: 4),
                          Text(
                            description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: descriptionColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailingWidget != null) ...[
                    SizedBox(width: 16),
                    trailingWidget,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================== 设置区块 ==================
class SettingsBlock extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SettingsBlock({
    this.title,
    required this.children,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          ...children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            final isLast = index == children.length - 1;
            
            // 如果是 SettingsItem 且是最后一项，添加 isLastInBlock 属性
            if (child is SettingsItem) {
              return SettingsItem(
                key: child.key,
                title: child.title,
                description: child.description,
                trailing: child.trailing,
                onTap: child.onTap,
                inBlock: true,
                showArrow: child.showArrow,
                value: child.value,
                isLastInBlock: isLast,
                enabled: child.enabled,
              );
            }
            return child;
          }).toList(),
        ],
      ),
    );
  }
}
