import 'package:flutter/material.dart';
import '../data/course.dart';
import '../data/course_schedule.dart';
import '../utils/color_utils.dart';
import '../views/course_edit_page.dart';
import 'package:provider/provider.dart';
import '../states/timetable_state.dart';
/// 
/// 支持多种显示模式：日视图模式、列表视图模式
class CourseCard extends StatelessWidget {
  final Course course;
  final CourseCardMode mode;
  final int? selectedDay; // 日视图模式时使用
  final VoidCallback? onEdit; // 自定义编辑回调
  final bool showWeekPattern; // 是否显示周次模式

  const CourseCard({
    super.key,
    required this.course,
    this.mode = CourseCardMode.dayView,
    this.selectedDay,
    this.onEdit,
    this.showWeekPattern = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLarge = constraints.maxWidth > 600;
        return _buildCard(context, isLarge);
      },
    );
  }

  Widget _buildCard(BuildContext context, bool isLarge) {
    final color = _getCourseColor();
    final timeText = _getTimeText();
    
    return GestureDetector(
      onTap: () => _handleEdit(context),
      child: Container(
        margin: _getMargin(),
        padding: _getPadding(isLarge),
        decoration: _getDecoration(color, isLarge),
        child: _buildContent(isLarge, timeText),
      ),
    );
  }

  Widget _buildContent(bool isLarge, String timeText) {
    double titleSize;
    double detailSize;
    if (mode == CourseCardMode.listView) {
      titleSize = isLarge ? 22.0 : 18.0;
      detailSize = isLarge ? 17.0 : 14.0;
    } else {
      titleSize = isLarge ? 18.0 : 15.0;
      detailSize = isLarge ? 14.0 : 12.0;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.name,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isLarge ? 8 : 6),
        Text(
          timeText,
          style: TextStyle(
            fontSize: detailSize,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          '教师: ${course.teacher}',
          style: TextStyle(
            fontSize: detailSize,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '地点: ${course.location}',
          style: TextStyle(
            fontSize: detailSize,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Color _getCourseColor() {
    return course.color != 0
        ? Color(course.color)
        : ColorUtils.getCourseColor(course.name);
  }

  String _getTimeText() {
    switch (mode) {
      case CourseCardMode.dayView:
        return _getDayViewTimeText();
      case CourseCardMode.listView:
        return _getListViewTimeText();
    }
  }

  String _getDayViewTimeText() {
    if (selectedDay == null) return '';
    
    final schedule = course.schedules.firstWhere(
      (s) => s.day == selectedDay,
      orElse: () => course.schedules.isNotEmpty ? course.schedules.first : CourseSchedule()
        ..day = selectedDay ?? 1
        ..periods = <int>[],
    );
    
    const weekDays = ['周一','周二','周三','周四','周五','周六','周日'];
    final periods = schedule.periods.join(',');
    return '${weekDays[schedule.day - 1]} 第$periods节';
  }

  String _getListViewTimeText() {
    return course.schedules.map((s) {
      const weekDays = ['周一','周二','周三','周四','周五','周六','周日'];
      final dayText = weekDays[s.day - 1];
      final periods = s.periods.join(',');
      return '$dayText 第$periods节';
    }).join('\n');
  }

  EdgeInsets _getMargin() {
    switch (mode) {
      case CourseCardMode.dayView:
        return const EdgeInsets.symmetric(vertical: 6);
      case CourseCardMode.listView:
        return EdgeInsets.zero;
    }
  }

  EdgeInsets _getPadding(bool isLarge) {
    switch (mode) {
      case CourseCardMode.dayView:
        return EdgeInsets.all(isLarge ? 16.0 : 12.0);
      case CourseCardMode.listView:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    }
  }

  BoxDecoration _getDecoration(Color color, bool isLarge) {
    switch (mode) {
      case CourseCardMode.dayView:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: color,
              width: isLarge ? 5.0 : 4.0,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        );
      case CourseCardMode.listView:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            top: BorderSide(
              color: color,
              width: isLarge ? 5.0 : 4.0,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        );
    }
  }

  // 不再用于列表视图着色

  Future<void> _handleEdit(BuildContext context) async {
    if (onEdit != null) {
      onEdit!();
      return;
    }

  
    final timetableId = Provider.of<TimetableState>(context, listen: false).current?.id ?? 0;
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => CourseEditPage(course: course, timetableId: timetableId)), 
    );

    if (result != null && context.mounted) {
      // 可以在这里添加刷新逻辑
    }
  }
}

/// 课程卡片显示模式
enum CourseCardMode {
  /// 日视图模式：左侧彩色边框，显示单日课程
  dayView,
  /// 列表视图模式：顶部彩色条带，显示所有课程时间
  listView,
}
