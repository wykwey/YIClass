import 'package:flutter/material.dart';
import 'components.dart';

// ================== 时间范围选择（底部弹窗） ==================
class TimeRange {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const TimeRange({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  /// 格式化为完整时间范围字符串 "08:00-08:45"
  String format() =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}'
      '-${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  
  /// 格式化开始时间 "08:00"
  String formatStart() =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  
  /// 格式化结束时间 "08:45"
  String formatEnd() =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
}

class YicoreTimeRangePicker {
  static Future<TimeRange?> show({
    required BuildContext context,
    TimeRange? initial,
  }) async {
    if (!context.mounted) return null;

    final result = await showModalBottomSheet<TimeRange>(
      context: context,
      isScrollControlled: true,
      enableDrag: true, // ✅ 保持可手势拖拽
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (sheetContext) {
        return _TimeRangeSheet(initial: initial);
      },
    );
    return result;
  }
}

class _TimeRangeSheet extends StatefulWidget {
  final TimeRange? initial;
  const _TimeRangeSheet({this.initial});

  @override
  State<_TimeRangeSheet> createState() => _TimeRangeSheetState();
}

class _TimeRangeSheetState extends State<_TimeRangeSheet> {
  static const double _itemExtent = 56; // 每项高度
  static const double _visibleCount = 3; // 可见项数

  late FixedExtentScrollController _sh;
  late FixedExtentScrollController _sm;
  late FixedExtentScrollController _eh;
  late FixedExtentScrollController _em;

  int _startHour = 9;
  int _startMinute = 0;
  int _endHour = 10;
  int _endMinute = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _startHour = widget.initial!.startHour;
      _startMinute = widget.initial!.startMinute;
      _endHour = widget.initial!.endHour;
      _endMinute = widget.initial!.endMinute;
    }
    _sh = FixedExtentScrollController(initialItem: _startHour);
    _sm = FixedExtentScrollController(initialItem: _startMinute);
    _eh = FixedExtentScrollController(initialItem: _endHour);
    _em = FixedExtentScrollController(initialItem: _endMinute);
  }

  @override
  void dispose() {
    _sh.dispose();
    _sm.dispose();
    _eh.dispose();
    _em.dispose();
    super.dispose();
  }

  Widget _wheel({
    required int count,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onSelected,
  }) {
    return SizedBox(
      height: _itemExtent * _visibleCount,
      width: 68, // 缩小一点防止超宽
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerSignal: (_) {}, // 修复手势事件冲突
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: _itemExtent,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onSelected,
          perspective: 0.002,
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index < 0 || index >= count) return null;
              return Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              );
            },
            childCount: count,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '选择时间范围',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            // ===== 滚轮区域 =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _wheel(
                    count: 24,
                    controller: _sh,
                    onSelected: (i) => _startHour = i),
                const SizedBox(width: 4),
                const Text(':',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                _wheel(
                    count: 60,
                    controller: _sm,
                    onSelected: (i) => _startMinute = i),
                const SizedBox(width: 10),
                const Text('-',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                _wheel(
                    count: 24,
                    controller: _eh,
                    onSelected: (i) => _endHour = i),
                const SizedBox(width: 4),
                const Text(':',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                _wheel(
                    count: 60,
                    controller: _em,
                    onSelected: (i) => _endMinute = i),
              ],
            ),
            const SizedBox(height: 28),
            // ===== 底部按钮 =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                YicoreButton(
                  text: '取消',
                  isOutlined: true,
                  onPressed: () => Navigator.pop(context),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                YicoreButton(
                  text: '确定',
                  onPressed: () {
                    final startTotal = _startHour * 60 + _startMinute;
                    final endTotal = _endHour * 60 + _endMinute;
                    int eh = _endHour;
                    int em = _endMinute;
                    if (endTotal < startTotal) {
                      eh = _startHour;
                      em = _startMinute;
                    }
                    Navigator.pop(
                      context,
                      TimeRange(
                        startHour: _startHour,
                        startMinute: _startMinute,
                        endHour: eh,
                        endMinute: em,
                      ),
                    );
                  },
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
