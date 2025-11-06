import 'package:flutter/material.dart';
import 'components.dart';

// ================== 日期选择器 ==================
class YicoreDatePicker {
  // 私有构造函数，防止实例化
  YicoreDatePicker._();

  // 静态方法：显示日期选择对话框
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    if (!context.mounted) return null;

    return await showDialog<DateTime>(
      context: context,
      builder: (_) => _DatePickerDialog(
        initialDate: initialDate ?? DateTime.now(),
        firstDate: firstDate ?? DateTime(1900, 1, 1),
        lastDate: lastDate ?? DateTime(2100, 12, 31),
      ),
    );
  }
}

// ================== 日期选择对话框 ==================
class _DatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _DatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _changeMonth(int delta) {
    final newMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
    final minMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    final maxMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    
    if (newMonth.isBefore(minMonth) || newMonth.isAfter(maxMonth)) return;
    
    setState(() => _currentMonth = newMonth);
  }

  bool _isDateInRange(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final minDate = DateTime(widget.firstDate.year, widget.firstDate.month, widget.firstDate.day);
    final maxDate = DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day);
    return !dateOnly.isBefore(minDate) && !dateOnly.isAfter(maxDate);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 400;
    
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isCompact ? screenWidth - 32 : 380,
        ),
        padding: EdgeInsets.all(isCompact ? 12 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isCompact),
            const SizedBox(height: 16),
            _buildCalendar(isCompact),
            const SizedBox(height: 16),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isCompact) {
    final monthYear = '${_currentMonth.year}年${_currentMonth.month}月';
    
    return Row(
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left),
          iconSize: isCompact ? 20 : 24,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: isCompact ? 32 : 40,
            minHeight: isCompact ? 32 : 40,
          ),
        ),
        Expanded(
          child: Text(
            monthYear,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        IconButton(
          onPressed: () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right),
          iconSize: isCompact ? 20 : 24,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: isCompact ? 32 : 40,
            minHeight: isCompact ? 32 : 40,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(bool isCompact) {
    const weekDays = ['一', '二', '三', '四', '五', '六', '日'];
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final weekdayOffset = (firstDayOfMonth.weekday - 1) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final cellHeight = isCompact ? 40.0 : 44.0;

    return Column(
      children: [
        // 星期标题
        Row(
          children: weekDays.map((day) {
            return Expanded(
              child: Container(
                height: cellHeight * 0.6,
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: isCompact ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        // 日期网格
        ...List.generate(6, (weekIndex) {
          final weekCells = <Widget>[];
          for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
            final cellIndex = weekIndex * 7 + dayIndex;
            if (cellIndex < weekdayOffset || cellIndex >= weekdayOffset + daysInMonth) {
              weekCells.add(Expanded(child: SizedBox(height: cellHeight)));
            } else {
              final day = cellIndex - weekdayOffset + 1;
              final date = DateTime(_currentMonth.year, _currentMonth.month, day);
              weekCells.add(Expanded(child: _buildDateCell(date, cellHeight, isCompact)));
            }
          }
          return Row(
            children: weekCells,
          );
        }),
      ],
    );
  }

  Widget _buildDateCell(DateTime date, double height, bool isCompact) {
    final isSelected = _isSameDay(date, _selectedDate);
    final isInRange = _isDateInRange(date);
    final isToday = _isSameDay(date, DateTime.now());

    return GestureDetector(
      onTap: isInRange ? () => setState(() => _selectedDate = date) : null,
      child: Container(
        height: height,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : null,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: Colors.black.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontSize: isCompact ? 14 : 16,
            color: !isInRange
                ? Colors.grey[300]
                : isSelected
                    ? Colors.white
                    : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        YicoreButton(
          text: '取消',
          isOutlined: true,
          onPressed: () => Navigator.pop(context),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        const SizedBox(width: 12),
        YicoreButton(
          text: '确定',
          onPressed: () => Navigator.pop(context, _selectedDate),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ],
    );
  }
}
