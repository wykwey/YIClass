import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/course.dart';
import '../constants/app_constants.dart';
import '../utils/color_utils.dart';
import '../components/course_edit_dialog.dart';
import '../states/timetable_state.dart';
import '../components/add_course_fab.dart';

/// 列表视图组件
///
/// 显示所有课程的列表视图
/// 包含:
/// - 课程按时间排序
/// - 可折叠的周次显示
/// - 快速跳转到指定课程
class CourseListView extends StatelessWidget {
  final List<Course> courses;

  const CourseListView({
    super.key,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    final groupedCourses = _groupCoursesByWeek(courses);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: groupedCourses.length,
            itemBuilder: (context, weekIndex) {
              final week = groupedCourses.keys.elementAt(weekIndex);
              final weekCourses = groupedCourses[week]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      '第$week周',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const itemMinWidth = 160.0;
                      const itemMaxWidth = 200.0;
                      final availableWidth = constraints.maxWidth - 16;
                      final crossAxisCount = (availableWidth / itemMinWidth).floor().clamp(1, (availableWidth / itemMinWidth).floor());
                      final itemWidth = (availableWidth / crossAxisCount).clamp(itemMinWidth, itemMaxWidth);

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: weekCourses.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 1.2,
                          mainAxisExtent: itemWidth / 1.2,
                        ),
                        itemBuilder: (context, index) {
                          return CourseCard(course: weekCourses[index]);
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const AddCourseFab(),
        ],
      ),
    );
  }

  Map<int, List<Course>> _groupCoursesByWeek(List<Course> courses) {
    final map = <int, List<Course>>{};
    for (final course in courses) {
      for (final schedule in course.schedules) {
        if (schedule['weekPattern'] == 'all') {
          for (int week = 1; week <= 20; week++) {
            map.putIfAbsent(week, () => []).add(course);
          }
        } else {
          for (var part in schedule['weekPattern'].split(',')) {
            part = part.trim();
            if (part.contains('-')) {
              final range = part.split('-');
              final start = int.parse(range[0].trim());
              final end = int.parse(range[1].trim());
              for (int week = start; week <= end; week++) {
                map.putIfAbsent(week, () => []).add(course);
              }
            } else {
              final weekNum = int.tryParse(part) ?? 0;
              if (weekNum > 0) {
                map.putIfAbsent(weekNum, () => []).add(course);
              }
            }
          }
        }
      }
    }
    return map;
  }
}

class CourseCard extends StatefulWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  Future<void> _handleEditCourse() async {
    if (!mounted) return;
    
            final editedCourse = await showDialog<Course>(
              context: context,
              builder: (context) => CourseEditDialog(
                course: widget.course,
                onSave: (editedCourse) async {
                  if (!mounted) return false;
                  final timetableState = Provider.of<TimetableState>(context, listen: false);
                  await timetableState.updateCourse(editedCourse);
                  return true;
                },
                onCancel: () {
                  if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
                },
              ),
            ).then((saved) {
              if (saved == true && mounted) {
                setState(() {});
              }
              return saved;
            });
    
    if (editedCourse != null && mounted) {
      final timetableState = Provider.of<TimetableState>(context, listen: false);
      await timetableState.updateCourse(editedCourse);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorBar = widget.course.color != 0 
        ? Color(widget.course.color) 
        : ColorUtils.getCourseColor(widget.course.name);
    final bgColor = ColorUtils.getWeekColor(widget.course.schedules.first['weekPattern']);
    final timetableState = Provider.of<TimetableState>(context);
    final timetable = timetableState.currentTimetable;
    final schedulesText = widget.course.schedules.map((s) {
      final dayText = AppConstants.weekDays[s['day'] - 1];
      if (timetable?.settings['startDate'] == null) {
        return '$dayText 第${s['periods'].join(',')}节';
      }
      final startDate = DateTime.parse(timetable!.settings['startDate'].toString());
      final week = int.tryParse(widget.course.schedules.first['weekPattern'].split(',').first) ?? 1;
      final courseDate = startDate.add(Duration(days: 7 * (week - 1) + ((s['day'] as int) - 1)));
      return '$dayText(${DateFormat('MM/dd').format(courseDate)}) 第${s['periods'].join(',')}节';
    }).join('\n');

    return GestureDetector(
      onTap: _handleEditCourse,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: colorBar,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor.withAlpha((0.07 * 255).round()),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  schedulesText,
                  style: const TextStyle(fontSize: 13, color: Colors.deepPurple),
                ),
                const SizedBox(height: 6),
                Text(
                  '教师: ${widget.course.teacher}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                Text(
                  '地点: ${widget.course.location}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
