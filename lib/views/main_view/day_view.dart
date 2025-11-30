import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/course.dart';
import '../../services/query_service.dart';
import '../../states/timetable_state.dart';
import '../../states/view_state.dart';
import '../../utils/get_weekday.dart';
import '../../components/inputs/fab.dart';
import '../../components/layout/course_card.dart';
import '../../routes/route_utils.dart';
import '../../data/timetable.dart';
import '../../components/layout/appbar.dart';

/// 日视图组件
///
/// 显示单日的课程安排，包括日期选择器和课程列表
class DayView extends StatefulWidget {
  const DayView({super.key});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// 计算今天所在的周（使用 getWeekInfo 进行越界检查）
  int? _getTodayWeek(Timetable timetable) {
    final info = getWeekInfo(
      DateTime.now(),
      timetable.settings.startDate,
      timetable.settings.totalWeeks,
    );
    return info?['weekIndex'];
  }

  // ================= 业务逻辑 =================
  Future<void> _handleEditCourse(Course course) async {
    if (!mounted) return;

    final timetableId =
        Provider.of<TimetableState>(context, listen: false).current?.id ?? 0;
    final result = await RouteUtils.pushCourseEdit(
      context,
      course: course,
      timetableId: timetableId,
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
    super.build(context); // 必须调用以支持 AutomaticKeepAliveClientMixin

    final timetableState = context.watch<TimetableState>();
    final viewState = context.watch<ViewState>();
    final timetable = timetableState.current;

    if (timetable == null) return const SizedBox();

    // 日视图始终使用今天所在的周，不受周选择器影响
    final todayWeek = _getTodayWeek(timetable);

    // 学期未开始或已结束，显示空白页
    if (todayWeek == null) {
      final now = DateTime.now();
      final startDate = timetable.settings.startDate;
      final isNotStarted = now.isBefore(startDate);
      
      return Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: YicoreAppBar(
          title: '日视图',
          centerTitle: true,
          onBackPressed: () {
            context.read<ViewState>().changeView('周视图');
          },
        ),
        body: Center(
          child: Text(
            isNotStarted ? '学期尚未开始' : '学期已结束',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return DayViewUI(
      timetable: timetable,
      currentWeek: todayWeek,
      showWeekend: timetable.settings.showWeekend,
      selectedDay: viewState.selectedDay,
      onDaySelected: (weekday) => viewState.selectDay(weekday),
      onEditCourse: _handleEditCourse,
    );
  }
}

/// 日视图UI组件（V2）
class DayViewUI extends StatelessWidget {
  final Timetable timetable;
  final int currentWeek;
  final bool showWeekend;
  final int selectedDay;
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
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: YicoreAppBar(
        title: '日视图',
        centerTitle: true,
        onBackPressed: () {
          context.read<ViewState>().changeView('周视图');
        },
      ),
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

/// 日期选择器
class DaySelector extends StatelessWidget {
  final int currentWeek;
  final bool showWeekend;
  final int selectedDay;
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
    const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final timetable = context.read<TimetableState>().current;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: List.generate(showWeekend ? 7 : 5, (i) {
          final day = i + 1;
          final selected = selectedDay == day;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
              child: GestureDetector(
                onTap: () => onDaySelected(day),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: selected
                        ? Border.all(color: Colors.black.withValues(alpha: 0.4))
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(days[day - 1],
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      if (timetable != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MM/dd').format(
                            timetable.settings.startDate.add(Duration(
                                days: 7 * (currentWeek - 1) + day - 1)),
                          ),
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withValues(alpha: 0.6)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 课程列表组件
class CourseList extends StatelessWidget {
  final Timetable timetable;
  final int currentWeek;
  final int selectedDay;
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
    final dayCourses = _getDayCourses();

    if (dayCourses.isEmpty) {
      return _buildEmptyState("今日无课程");
    }

    return _buildCourseListView(dayCourses);
  }

  List<Course> _getDayCourses() {
    return QueryService.dayCourses(timetable, currentWeek, selectedDay);
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
        selectedDay: selectedDay,
        onEdit: () => onEditCourse(courses[index]),
      ),
    );
  }
}
