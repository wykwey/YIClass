import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/course.dart';
import '../services/query_service.dart';
import '../components/course_card.dart';
import '../components/add_course_fab.dart';
import '../states/timetable_state.dart';
import '../data/timetable.dart';

/// 按周次分组显示课程的列表视图（V2）
class CourseListView extends StatelessWidget {
  const CourseListView({super.key});

  // ================= 业务逻辑 =================
  /// 将课程按周次分组
  Map<int, List<Course>> _groupCoursesByWeek(Timetable timetable) {
    final grouped = <int, List<Course>>{};
    
    // 获取所有可能的周次（从1到totalWeeks周）
    for (int week = 1; week <= timetable.settings.totalWeeks; week++) {
      final weekCourses = QueryService.weekCourses(timetable, week);
      if (weekCourses.isNotEmpty) {
        grouped[week] = weekCourses;
      }
    }
    
    return grouped;
  }

  // ================= UI构建 =================
  @override
  Widget build(BuildContext context) {
    final timetableState = context.watch<TimetableState>();
    final timetable = timetableState.current;
    
    if (timetable == null) {
      return const Scaffold(
        body: Center(child: Text('请先选择一个课表')),
      );
    }
    
    final groupedCourses = _groupCoursesByWeek(timetable);
    
    return CourseListViewUI(
      timetable: timetable,
      groupedCourses: groupedCourses,
    );
  }
}

/// 列表视图UI组件（V2）
class CourseListViewUI extends StatelessWidget {
  final Timetable timetable;
  final Map<int, List<Course>> groupedCourses;

  const CourseListViewUI({
    super.key,
    required this.timetable,
    required this.groupedCourses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildCourseList(),
          const AddCourseFab(viewIdentifier: 'list'),
        ],
      ),
    );
  }

  /// 构建按周次分组的课程列表
  Widget _buildCourseList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: groupedCourses.length,
      itemBuilder: (context, index) {
        final week = groupedCourses.keys.elementAt(index);
        final weekCourses = groupedCourses[week]!;

        return _WeekSection(week: week, courses: weekCourses);
      },
    );
  }
}

/// 单个“周次区块”（V2）
class _WeekSection extends StatelessWidget {
  final int week;
  final List<Course> courses;

  const _WeekSection({required this.week, required this.courses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWeekHeader(),
        _buildCourseGrid(),
      ],
    );
  }

  Widget _buildWeekHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        '第$week周',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildCourseGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minWidth = 160.0;
        const maxWidth = 200.0;
        final available = constraints.maxWidth - 16;
        final count = (available / minWidth).floor().clamp(1, 4);
        final itemWidth = (available / count).clamp(minWidth, maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            mainAxisExtent: itemWidth / 1.2,
          ),
          itemBuilder: (context, i) => CourseCard(
            course: courses[i],
            mode: CourseCardMode.listView,
            showWeekPattern: true,
          ),
        );
      },
    );
  }
}

