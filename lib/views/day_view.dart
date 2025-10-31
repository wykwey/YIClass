import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/course.dart';
import '../services/query_service.dart';
import '../states/timetable_state.dart';
import '../states/week_state.dart';
import '../states/view_state.dart';
import '../components/add_course_fab.dart';
import '../components/course_card.dart';
import 'course_edit_page.dart';
import '../data/timetable.dart';

/// 日视图组件（V2）
///
/// 显示单日的课程安排，包括日期选择器和课程列表
class DayView extends StatefulWidget {
  const DayView({super.key});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  // ================= 业务逻辑 =================
  Future<void> _handleEditCourse(Course course) async {
    if (!mounted) return;
    
    final timetableId = Provider.of<TimetableState>(context, listen: false).current?.id ?? 0;
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => CourseEditPage(course: course, timetableId: timetableId)), 
    );
    
    if (result != null && mounted) {
      final timetableState = context.read<TimetableState>();
      await timetableState.reload();
      setState(() {});
    }
  }

  // ================= UI构建 =================
  @override
  Widget build(BuildContext context) {
    final timetableState = context.watch<TimetableState>();
    final weekState = context.watch<WeekState>();
    final viewState = context.watch<ViewState>();
    final timetable = timetableState.current;
    
    if (timetable == null) return const SizedBox();
    
    return DayViewUI(
      timetable: timetable,
      currentWeek: weekState.week,
      showWeekend: timetable.settings.showWeekend,
      selectedDay: viewState.selectedDay,
      onDaySelected: (day) => viewState.selectDay(day),
      onEditCourse: _handleEditCourse,
    );
  }
}

/// 日视图UI组件（V2）
class DayViewUI extends StatelessWidget {
  final Timetable timetable;
  final int currentWeek;
  final bool showWeekend;
  final int? selectedDay;
  final ValueChanged<int> onDaySelected;
  final Future<void> Function(Course) onEditCourse;

  const DayViewUI({
    super.key,
    required this.timetable,
    required this.currentWeek,
    required this.showWeekend,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onEditCourse,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              DaySelector(
                currentWeek: currentWeek,
                showWeekend: showWeekend,
                selectedDay: selectedDay,
                onDaySelected: onDaySelected,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: CourseList(
                  timetable: timetable,
                  currentWeek: currentWeek,
                  selectedDay: selectedDay,
                  onEditCourse: onEditCourse,
                ),
              ),
            ],
          ),
          const AddCourseFab(viewIdentifier: 'day'),
        ],
      ),
    );
  }
}

/// 日期选择器组件（V2）
class DaySelector extends StatelessWidget {
  final int currentWeek;
  final bool showWeekend;
  final int? selectedDay;
  final ValueChanged<int> onDaySelected;

  const DaySelector({
    super.key,
    required this.currentWeek,
    required this.showWeekend,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) => _buildDayGrid(constraints),
      ),
    );
  }

  Widget _buildDayGrid(BoxConstraints constraints) {
    final dayCount = showWeekend ? 7 : 5;
    final spacing = 8.0;
    final itemWidth = (constraints.maxWidth - spacing * (dayCount - 1)) / dayCount;
    final itemAspectRatio = itemWidth / 50.0;

    return Builder(
      builder: (context) => GridView.count(
        crossAxisCount: dayCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: itemAspectRatio,
        children: List.generate(dayCount, (i) => _buildDayButton(context, i + 1)),
      ),
    );
  }

  Widget _buildDayButton(BuildContext context, int day) {
    final timetableState = Provider.of<TimetableState>(context, listen: false);
    final timetable = timetableState.current;
    final isSelected = selectedDay == day;
    
    return InkWell(
      onTap: () => onDaySelected(day),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(child: _buildDayContent(day, isSelected, timetable)),
      ),
    );
  }

  Widget _buildDayContent(int day, bool isSelected, Timetable? timetable) {
    final textColor = isSelected ? Colors.white : Colors.grey[800];
    const weekDays = ['周一','周二','周三','周四','周五','周六','周日'];
    final dayName = weekDays[day - 1];
    
    if (timetable == null) {
      return Text(
        dayName,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      );
    }
    
    final startDate = timetable.settings.startDate;
    final courseDate = startDate.add(Duration(days: 7 * (currentWeek - 1) + (day - 1)));
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayName,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          DateFormat('MM/dd').format(courseDate),
          style: TextStyle(
            fontSize: 11,
            color: textColor?.withOpacity(0.85),
          ),
        ),
      ],
    );
  }
}

/// 课程列表组件（V2）
class CourseList extends StatelessWidget {
  final Timetable timetable;
  final int currentWeek;
  final int? selectedDay;
  final Future<void> Function(Course) onEditCourse;

  const CourseList({
    super.key,
    required this.timetable,
    required this.currentWeek,
    required this.selectedDay,
    required this.onEditCourse,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDay == null) {
      return _buildEmptyState("请选择日期");
    }

    final dayCourses = _getDayCourses();
    
    if (dayCourses.isEmpty) {
      return _buildEmptyState("今日无课程");
    }

    return _buildCourseListView(dayCourses);
  }

  List<Course> _getDayCourses() {
    return QueryService.dayCourses(timetable, currentWeek, selectedDay!);
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildCourseListView(List<Course> courses) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: courses.length,
      itemBuilder: (context, index) => CourseCard(
        course: courses[index],
        mode: CourseCardMode.dayView,
        selectedDay: selectedDay!,
        onEdit: () => onEditCourse(courses[index]),
      ),
    );
  }
}

