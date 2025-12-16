import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/inputs/fab.dart';
import '../../components/layout/course_selector.dart';
import '../../components/layout/period_label.dart';
import '../../components/layout/week_course_card.dart';
import '../../components/layout/week_header.dart';
import '../../data/class_time.dart';
import '../../data/course.dart';
import '../../data/data_constants.dart';
import '../../data/timetable.dart';
import '../../routes/route_utils.dart';
import '../../services/timetable/factory_service.dart';
import '../../services/timetable/query_service.dart';
import '../../states/timetable_state.dart';
import '../../states/week_state.dart';
import '../../utils/get_weekday.dart';

/// 显示当前周的课程表，支持左右滑动切换周次。
class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  PageController? _pageController;  // 周次滑动翻页控制器
  bool _isPageAnimating = false;    // 防止动画重复触发
  bool _initialWeekSynced = false;  // 仅首次进入时同步当前周

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final timetable = context.read<TimetableState>().current;
    final weekState = context.read<WeekState>();
    int targetWeek = weekState.week;

    // 首次进入，根据学期开始日计算当前周，避免默认回到第1周
    if (!_initialWeekSynced && timetable != null) {
      final info = getWeekInfo(DateTime.now(), timetable.settings.startDate, timetable.settings.totalWeeks);
      targetWeek = (info?['weekIndex'] ?? targetWeek).clamp(1, timetable.settings.totalWeeks);
      if (targetWeek != weekState.week) {
        WidgetsBinding.instance.addPostFrameCallback((_) => weekState.setWeek(targetWeek));
      }
      _initialWeekSynced = true;
    }

    _pageController ??= PageController(initialPage: targetWeek - 1);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  /// 显示课程编辑对话框
  Future<void> _showCourseEditDialog(Course? course, int weekday, int period, int week) async {
    final timetable = context.read<TimetableState>().current;
    if (timetable == null) return;

    Course? courseToEdit;

    if (course == null) {
      // 空课程：创建新课程
      courseToEdit = FactoryService.createCourse(
        name: '',
        schedules: [FactoryService.createSchedule(weekday: weekday, periods: [period], weekPattern: [week])],
      );
    } else {
      // 非空课程：检查冲突
      final coursesAtTime = QueryService.periodCourses(timetable, week, weekday, period);
      if (coursesAtTime.length > 1) {
        final selectedIndex = await YicoreCourseSelector.show(
          context,
          courses: coursesAtTime.asMap().entries.map((e) => CourseItem(id: e.key.toString(), name: e.value.name)).toList(),
          currentCourseId: coursesAtTime.indexOf(course).toString(),
          title: '选择要编辑的课程',
        );
        if (selectedIndex == null || !mounted) return;
        courseToEdit = coursesAtTime[int.tryParse(selectedIndex) ?? 0];
      } else {
        courseToEdit = course;
      }
    }

    final result = await RouteUtils.pushCourseEdit(
      context,
      course: courseToEdit,
      timetableId: context.read<TimetableState>().current?.id ?? 0,
    );

    if (result != null && mounted) {
      await context.read<TimetableState>().reload();
      setState(() {});
    }
  }

  /// 跳转时间设置页
  Future<void> _handleTimeSettingsTap() async {
    await RouteUtils.pushTimeSettings(context);
    if (mounted) setState(() {});
  }

  /// 同步 WeekState 到 PageController
  void _syncPageController(WeekState weekState) {
    if (_pageController == null || !_pageController!.hasClients || _isPageAnimating) return;
    if (_pageController!.page?.round() != weekState.week - 1) {
      _pageController!.animateToPage(
        weekState.week - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final timetableState = context.watch<TimetableState>();
    final weekState = context.watch<WeekState>();
    final timetable = timetableState.current;
    if (timetable == null) return const SizedBox();

    final totalWeeks = timetable.settings.totalWeeks;
    final showWeekend = timetable.settings.showWeekend;
    final classTimes = timetable.settings.classTimes;
    final maxPeriods = timetable.settings.maxPeriods > 0 ? timetable.settings.maxPeriods : DataConstants.defaultMaxPeriods;

    // AppBar 箭头点击时同步 PageController
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPageController(weekState));

    return PageView.builder(
      controller: _pageController,
      itemCount: totalWeeks,
      onPageChanged: (index) {
        _isPageAnimating = false;
        if (weekState.week != index + 1) weekState.setWeek(index + 1);
      },
      itemBuilder: (_, index) {
        final week = index + 1;
        return WeekViewUI(
          timetable: timetable,
          currentWeek: week,
          showWeekend: showWeekend,
          maxPeriods: maxPeriods,
          classTimes: classTimes,
          onCourseEdit: (course, weekday, period) => _showCourseEditDialog(course, weekday, period, week),
          onTimeSettingsTap: _handleTimeSettingsTap,
        );
      },
    );
  }
}

/// 周视图 UI 组件
class WeekViewUI extends StatelessWidget {
  final Timetable timetable;
  final int currentWeek;
  final bool showWeekend;
  final int maxPeriods;
  final List<ClassTime> classTimes;
  final Future<void> Function(Course?, int, int) onCourseEdit;
  final Future<void> Function() onTimeSettingsTap;

  static const double _periodLabelWidth = 40.0;

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

  int get _columns => showWeekend ? 7 : 5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            WeekHeader(showWeekend: showWeekend, currentWeek: currentWeek, startDate: timetable.settings.startDate),
            Expanded(child: Container(color: Colors.white, child: _buildCourseGrid())),
          ],
        ),
        const AddCourseFab(viewIdentifier: 'week'),
      ],
    );
  }

  Widget _buildCourseGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final preferredCellHeight = (constraints.maxWidth / 8).clamp(80.0, 120.0);
      final totalHeight = preferredCellHeight * maxPeriods;
      final cellHeight = totalHeight < constraints.maxHeight ? constraints.maxHeight / maxPeriods : preferredCellHeight;
      final cellWidth = (constraints.maxWidth - _periodLabelWidth) / _columns;

      return SingleChildScrollView(
        child: SizedBox(
          height: cellHeight * maxPeriods,
          child: Stack(
            children: [
              _buildGridBackground(cellHeight),
              _buildVerticalLines(),
              _buildCourseCards(cellWidth, cellHeight),
            ],
          ),
        ),
      );
    });
  }

  /// 网格背景（横线 + 节次标签）
  Widget _buildGridBackground(double cellHeight) {
    return Column(
      children: List.generate(maxPeriods, (i) {
        return Container(
          height: cellHeight,
          decoration: BoxDecoration(
            border: Border(bottom: i < maxPeriods - 1 ? BorderSide(color: Colors.grey[200]!) : BorderSide.none),
          ),
          child: Row(children: [_buildPeriodLabel(i + 1, cellHeight), const Expanded(child: SizedBox())]),
        );
      }),
    );
  }

  /// 纵向分割线
  Widget _buildVerticalLines() {
    return Positioned(
      left: _periodLabelWidth,
      right: 0,
      top: 0,
      bottom: 0,
      child: CustomPaint(painter: _VerticalGridPainter(columns: _columns, color: Colors.grey[200]!)),
    );
  }

  /// 课程卡片层
  Widget _buildCourseCards(double cellWidth, double cellHeight) {
    return Positioned(
      left: _periodLabelWidth,
      right: 0,
      top: 0,
      bottom: 0,
      child: Stack(
        children: [
          for (int p = 0; p < maxPeriods; p++)
            for (int d = 0; d < _columns; d++) _buildCell(d, p, cellWidth, cellHeight),
        ],
      ),
    );
  }

  Widget _buildCell(int dayIndex, int periodIndex, double cellWidth, double cellHeight) {
    final weekday = dayIndex + 1;
    final period = periodIndex + 1;
    final course = QueryService.periodCourse(timetable, currentWeek, weekday, period);

    // 空白格
    if (course == null) {
      return Positioned(
        left: dayIndex * cellWidth,
        top: periodIndex * cellHeight,
        width: cellWidth,
        height: cellHeight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(onTap: () => onCourseEdit(null, weekday, period), splashColor: Colors.transparent),
        ),
      );
    }

    // 连续课程只渲染第一节
    final isFirst = period == 1 || QueryService.periodCourse(timetable, currentWeek, weekday, period - 1) != course;
    if (!isFirst) return const SizedBox.shrink();

    final span = QueryService.consecutivePeriods(timetable, currentWeek, weekday, period);
    final hasConflict = QueryService.periodCourses(timetable, currentWeek, weekday, period).length > 1;

    return Positioned(
      left: dayIndex * cellWidth,
      top: periodIndex * cellHeight,
      width: cellWidth,
      height: cellHeight * (span > 0 ? span : 1),
      child: CourseCard(
        course: course,
        showWeekend: showWeekend,
        onTap: () => onCourseEdit(course, weekday, period),
        hasConflict: hasConflict,
      ),
    );
  }

  Widget _buildPeriodLabel(int period, double cellHeight) {
    final ct = classTimes.firstWhere(
      (c) => c.period == period,
      orElse: () => ClassTime()
        ..period = period
        ..startTime = DataConstants.defaultPeriodTimes[period.toString()]?.split('-').first ?? '00:00'
        ..endTime = DataConstants.defaultPeriodTimes[period.toString()]?.split('-').last ?? '00:00',
    );
    return PeriodLabel(period: period, timeText: '${ct.startTime}-${ct.endTime}', onTap: onTimeSettingsTap, height: cellHeight);
  }
}

/// 纵向网格线绘制器
class _VerticalGridPainter extends CustomPainter {
  final int columns;
  final Color color;

  _VerticalGridPainter({required this.columns, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (columns <= 0) return;
    final paint = Paint()..color = color;
    final w = size.width / columns;
    for (int i = 1; i < columns; i++) {
      canvas.drawLine(Offset(i * w, 0), Offset(i * w, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalGridPainter old) => old.columns != columns || old.color != color;
}
