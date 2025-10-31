import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/course.dart';
import '../services/query_service.dart';
import '../services/factory_service.dart';
import '../data/data_constants.dart';
import 'course_edit_page.dart';
import '../components/week_view_components/week_header.dart';
import '../components/week_view_components/period_label.dart';
import '../components/week_view_components/course_card.dart';
import '../states/timetable_state.dart';
import '../states/week_state.dart';
import '../components/add_course_fab.dart';
import '../views/time_settings_page.dart';
import '../data/timetable.dart';
import '../data/class_time.dart';

class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  // ================= 业务逻辑 =================
  Future<void> _showCourseEditDialog(Course? course, int day, int period, int week) async {
    // 如果是空课程，创建一个默认的课程对象，并设置日期和节次信息
    Course courseToEdit;
    if (course == null) {
      final schedule = FactoryService.createSchedule(
        day: day,
        periods: [period],
        weekPattern: [week],
      );
      courseToEdit = FactoryService.createCourse(
        name: '', // 新建课程名称为空
        schedules: [schedule], // 颜色使用工厂默认色
      );
    } else {
      courseToEdit = course;
    }

    
    final timetableId = context.read<TimetableState>().current?.id ?? 0;
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => CourseEditPage(course: courseToEdit, timetableId: timetableId), 
      ),
    );

    if (result != null && mounted) {
      if (result == 'deleted') {
        // 课程被删除，刷新页面
        final timetableState = context.read<TimetableState>();
        await timetableState.reload();
        setState(() {});
      } else if (result is Course) {
        // 课程被编辑，刷新页面
        final timetableState = context.read<TimetableState>();
        await timetableState.reload();
        setState(() {});
      }
    }
  }

  Future<void> _handleTimeSettingsTap() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TimeSettingsPage(),
      ),
    );
    if (mounted) setState(() {});
  }

  // ================= UI构建 =================
  @override
  Widget build(BuildContext context) {
    final timetableState = context.watch<TimetableState>();
    final weekState = context.watch<WeekState>();
    final timetable = timetableState.current;
    if (timetable == null) return const SizedBox();

    final currentWeek = weekState.week;
    final showWeekend = timetable.settings.showWeekend;
    final classTimes = timetable.settings.classTimes;
    final maxPeriods = (timetable.settings.maxPeriods) > 0
        ? timetable.settings.maxPeriods
        : DataConstants.defaultMaxPeriods;
    
    return WeekViewUI(
      timetable: timetable,
      currentWeek: currentWeek,
      showWeekend: showWeekend,
      maxPeriods: maxPeriods,
      classTimes: classTimes,
      onCourseEdit: (course, day, period) => _showCourseEditDialog(course, day, period, currentWeek),
      onTimeSettingsTap: _handleTimeSettingsTap,
    );
  }
}

/// 周视图UI组件（V2）
class WeekViewUI extends StatelessWidget {
  final Timetable timetable;
  final int currentWeek;
  final bool showWeekend;
  final int maxPeriods;
  final List<ClassTime> classTimes;
  final Future<void> Function(Course?, int, int) onCourseEdit;
  final Future<void> Function() onTimeSettingsTap;

  const WeekViewUI({
    super.key,
    required this.timetable,
    required this.currentWeek,
    required this.showWeekend,
    required this.maxPeriods,
    required this.classTimes,
    required this.onCourseEdit,
    required this.onTimeSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _buildHeaderRow(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: _buildCourseGrid(),
              ),
            ),
          ],
        ),
        const AddCourseFab(viewIdentifier: 'week'),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return WeekHeader(
      showWeekend: showWeekend,
      currentWeek: currentWeek,
      startDate: timetable.settings.startDate,
    );
  }

  Widget _buildCourseGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final preferredCellHeight = (constraints.maxWidth / 8).clamp(80.0, 120.0);
      final totalHeight = preferredCellHeight * maxPeriods;
      final cellHeight = totalHeight < constraints.maxHeight
          ? constraints.maxHeight / maxPeriods
          : preferredCellHeight;

      return SingleChildScrollView(
        child: SizedBox(
          height: cellHeight * maxPeriods,  // 设置总高度
          child: Stack(  // 使用Stack作为主容器
            children: [
              // 绘制网格背景
              Column(
                children: List.generate(maxPeriods, (periodIndex) {
                  return Container(
                    height: cellHeight,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: periodIndex < maxPeriods - 1 ? BorderSide(color: Colors.grey[200]!, width: 1.0) : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildPeriodLabel(periodIndex + 1, cellHeight),
                        Expanded(child: Container()),
                      ],
                    ),
                  );
                }),
              ),
              // 纵向分割线（列）
              Positioned(
                left: 40,
                right: 0,
                top: 0,
                bottom: 0,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final columns = (showWeekend ? 7 : 5);
                    return CustomPaint(
                      painter: _VerticalGridPainter(
                        columns: columns,
                        color: Colors.grey[200]!,
                        strokeWidth: 1.0,
                      ),
                      size: Size(c.maxWidth, c.maxHeight),
                    );
                  },
                ),
              ),

              // 绘制课程卡片
              Positioned(
                left: 40,  // 匹配调整后的PeriodLabel宽度
                right: 0,
                top: 0,
                bottom: 0,
                child: Stack(
                  children: [
                    for (int periodIndex = 0; periodIndex < maxPeriods; periodIndex++)
                      for (int dayIndex = 0; dayIndex < (showWeekend ? 7 : 5); dayIndex++)
                        Builder(builder: (context) {
                          final day = dayIndex + 1;
                          final period = periodIndex + 1;

                          final cellWidth = (constraints.maxWidth - 40) / (showWeekend ? 7 : 5);

                          // 判断当前节次是否有课程
                          final course = QueryService.periodCourse(timetable, currentWeek, day, period);
                          
                          if (course == null) {
                            // 空白格：不渲染空课程卡片，保留可点击添加
                            return Positioned(
                              left: dayIndex * cellWidth,
                              top: periodIndex * cellHeight,
                              width: cellWidth,
                              height: cellHeight,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => onCourseEdit(null, day, period),
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                ),
                              ),
                            );
                          }

                          // 判断是否是连续区块的第一节：如果前一个节次没有课程或不在同一课程中，则是第一节
                          final isFirstOfBlock = period == 1 || 
                              QueryService.periodCourse(timetable, currentWeek, day, period - 1) != course;

                          if (!isFirstOfBlock) {
                            // 不是第一节，不渲染（由第一节的卡片覆盖）
                            return const SizedBox.shrink();
                          }

                          final consecutiveCount = QueryService.consecutivePeriods(
                            timetable,
                            currentWeek,
                            day,
                            period,
                          );

                          return Positioned(
                            left: dayIndex * cellWidth,
                            top: periodIndex * cellHeight,
                            width: cellWidth,
                            height: cellHeight * (consecutiveCount > 0 ? consecutiveCount : 1),
                            child: _buildCourseCell(
                              course,
                              day,
                              period,
                              course,
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // 已移除空课程占位渲染

  Widget _buildPeriodLabel(int period, double cellHeight) {
    final classTime = classTimes.firstWhere(
      (ct) => ct.period == period,
      orElse: () => ClassTime()
        ..period = period
        ..startTime = DataConstants.defaultPeriodTimes[period.toString()]?.split('-').first ?? '00:00'
        ..endTime = DataConstants.defaultPeriodTimes[period.toString()]?.split('-').last ?? '00:00',
    );
    final timeText = '${classTime.startTime}-${classTime.endTime}';
    
    return PeriodLabel(
      period: period,
      timeText: timeText,
      onTap: onTimeSettingsTap,
      height: cellHeight,
    );
  }

  Widget _buildCourseCell(Course course, int day, int period, Course? originalCourse) {
    final isEmpty = course.name.isEmpty;
    return CourseCard(
      course: course,
      showWeekend: showWeekend,
      onTap: () => onCourseEdit(isEmpty ? null : (originalCourse ?? course), day, period),
    );
  }
}

class _VerticalGridPainter extends CustomPainter {
  final int columns;
  final Color color;
  final double strokeWidth;

  _VerticalGridPainter({
    required this.columns,
    required this.color,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (columns <= 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    final colWidth = size.width / columns;
    for (int i = 1; i < columns; i++) {
      final x = i * colWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalGridPainter oldDelegate) {
    return oldDelegate.columns != columns ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
