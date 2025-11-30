import 'package:flutter/material.dart';

// ================== 分段控制器项 ==================
class SegmentedItem {
  final String label;
  final String value;

  const SegmentedItem({
    required this.label,
    required this.value,
  });
}

// ================== 自定义分段控制器 ==================
// ================== 分段控制器尺寸 ==================
enum SegmentedControlSize {
  small,
  medium,
  large,
}

class YicoreSegmentedControl extends StatelessWidget {
  final List<SegmentedItem> items;
  final String selectedValue;
  final ValueChanged<String> onChanged;
  final SegmentedControlSize size;
  final bool showBorder;

  const YicoreSegmentedControl({
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.size = SegmentedControlSize.medium,
    this.showBorder = false,
    Key? key,
  }) : super(key: key);

  Map<String, double> _getSizeConfig() {
    switch (size) {
      case SegmentedControlSize.small:
        return {
          'height': 36.0,
          'fontSize': 12.0,
          'vPadding': 6.0,
          'hPadding': 8.0,
          'maxWidth': 200.0,
        };
      case SegmentedControlSize.large:
        return {
          'height': 44.0,
          'fontSize': 15.0,
          'vPadding': 8.0,
          'hPadding': 20.0,
          'maxWidth': 400.0,
        };
      case SegmentedControlSize.medium:
        return {
          'height': 40.0,
          'fontSize': 14.0,
          'vPadding': 8.0,
          'hPadding': 16.0,
          'maxWidth': 340.0,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = items.indexWhere((item) => item.value == selectedValue);
    
    final config = _getSizeConfig();
    final height = config['height']!;
    final fontSize = config['fontSize']!;
    final vPadding = config['vPadding']!;
    final hPadding = config['hPadding']!;
    final maxWidth = config['maxWidth']!;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          decoration: BoxDecoration(
            color: showBorder ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: showBorder ? Border.all(color: Colors.grey[300]!, width: 1) : null,
          ),
          child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / (items.isEmpty ? 1 : items.length);
          final alignmentX = (items.length > 1)
              ? -1.0 + (2.0 * selectedIndex / (items.length - 1))
              : 0.0;
          
          return SizedBox(
            height: height,
            child: Stack(
              children: [
                // 滑动背景块
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment(alignmentX, 0),
                  child: Container(
                    width: itemWidth,
                    height: height,
                    decoration: BoxDecoration(
                      color: showBorder ? Colors.grey[200] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                // 文字按钮层
                Row(
                  children: items.map((item) {
                    final isSelected = item.value == selectedValue;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onChanged(item.value),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOutCubic,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? Colors.black : Colors.grey[600],
                              ),
                              child: Text(item.label),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
          ),
        ),
      ),
    );
  }
}

