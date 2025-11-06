import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/course.dart';
import '../data/course_schedule.dart';
import '../states/timetable_state.dart';
import '../services/course_service.dart';
import '../services/factory_service.dart';
import '../utils/color_utils.dart';
import '../utils/parse_utils.dart';
import '../zujian/dropdown.dart';
import '../zujian/components.dart';
import '../zujian/cards.dart';
import '../zujian/dialogs.dart';
import '../zujian/notifications.dart';
import '../zujian/appbar.dart';

/// 课程编辑页面
class CourseEditPage extends StatefulWidget {
  final Course course;
  final int timetableId; // 直接传入课表ID，简化依赖

  const CourseEditPage({super.key, required this.course, required this.timetableId});

  @override
  State<CourseEditPage> createState() => _CourseEditPageState();
}

class _CourseEditPageState extends State<CourseEditPage> {
  // ================= 状态管理 =================
  final _formKey = GlobalKey<FormState>();
  late Color _selectedColor;

  // ================= 输入控制器 =================
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _teacherController;
  late List<TextEditingController> _weekPatternControllers;
  late List<TextEditingController> _periodsControllers;
  late List<int> _days; // 每个时间段对应的星期

  // ================= 生命周期 =================
  @override
  void initState() {
    super.initState();
    _selectedColor = widget.course.color != 0
        ? Color(widget.course.color)
        : ColorUtils.getCourseColor(widget.course.name);
    _nameController = TextEditingController(text: widget.course.name);
    _locationController = TextEditingController(text: widget.course.location);
    _teacherController = TextEditingController(text: widget.course.teacher);
    _initScheduleControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _teacherController.dispose();
    for (final c in _weekPatternControllers) c.dispose();
    for (final c in _periodsControllers) c.dispose();
    super.dispose();
  }

  // ================= 时间安排管理 =================
  void _initScheduleControllers() {
    _weekPatternControllers = [];
    _periodsControllers = [];
    _days = [];
    if (widget.course.schedules.isNotEmpty) {
      for (final schedule in widget.course.schedules) {
        _days.add(schedule.weekday);
        _weekPatternControllers.add(TextEditingController(
          text: ParseUtils.formatNumbers(schedule.weekPattern),
        ));
        _periodsControllers.add(TextEditingController(
          text: ParseUtils.formatNumbers(schedule.periods),
        ));
      }
    } else {
      // 默认添加一条：周一 第1节 1-16周
      _days.add(1);
      _weekPatternControllers.add(TextEditingController(text: '1-16'));
      _periodsControllers.add(TextEditingController(text: '1'));
    }
  }

  void _addNewSchedule() {
    setState(() {
      _days.add(1);
      _weekPatternControllers.add(TextEditingController(text: '1-16'));
      _periodsControllers.add(TextEditingController(text: '1'));
    });
  }

  void _removeScheduleAt(int index) {
    if (_days.length <= 1) return;
    setState(() {
      _weekPatternControllers[index].dispose();
      _periodsControllers[index].dispose();
      _days.removeAt(index);
      _weekPatternControllers.removeAt(index);
      _periodsControllers.removeAt(index);
    });
  }

  // ================= 数据转换 =================
  List<CourseSchedule> _buildSchedulesFromInputs() {
    final List<CourseSchedule> list = [];
    for (int i = 0; i < _days.length; i++) {
      final weeks = ParseUtils.parseNumbers(_weekPatternControllers[i].text.trim(), defaultMax: 30);
      final periods = ParseUtils.parseNumbers(_periodsControllers[i].text.trim(), defaultMax: 20);
      list.add(FactoryService.createSchedule(weekday: _days[i], periods: periods, weekPattern: weeks));
    }
    return list;
  }

  // ================= 业务操作 =================
  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final newCourse = FactoryService.createCourse(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        teacher: _teacherController.text.trim(),
        color: _selectedColor.value,
        schedules: _buildSchedulesFromInputs(),
      );
      
      final timetableId = widget.timetableId;
      // 检查是否是新建课程（通过名称和基本信息判断）
      final timetableState = Provider.of<TimetableState>(context, listen: false);
      final timetable = timetableState.current; // 仅用于定位索引（可能为旧快照）
      final existingIndex = timetable?.courses.indexWhere((c) => 
        c.name == widget.course.name &&
        c.location == widget.course.location &&
        c.teacher == widget.course.teacher) ?? -1;
      
      final isNew = widget.course.name.isEmpty || existingIndex == -1;
      
      if (isNew) {
        // 新建课程
        await CourseService.instance.addCourse(timetableId, newCourse);
      } else {
        // 更新现有课程（通过索引）
        await CourseService.instance.updateCourseAt(timetableId, existingIndex, newCourse);
      }
      
      if (mounted) {
        Notifications.sonner(context, message: '课程已保存');
        Navigator.pop(context, newCourse);
      }
    } catch (e) {
      if (mounted) {
        Notifications.sonner(context, title: '保存失败', message: e.toString());
      }
    }
  }

  Future<void> _confirmDeleteCourse() async {
    final confirmed = await YicoreConfirm.show(
      context,
      title: '删除课程',
      message: '确定要删除这门课程吗？此操作无法撤销。',
      confirmText: '删除',
      cancelText: '取消',
    );
    
    if (confirmed && mounted) {
      try {
        final timetableId = widget.timetableId;
        // 找到要删除的课程索引
        final timetableState = Provider.of<TimetableState>(context, listen: false);
        final timetable = timetableState.current;
        final deleteIndex = timetable?.courses.indexWhere((c) => 
          c.name == widget.course.name &&
          c.location == widget.course.location &&
          c.teacher == widget.course.teacher) ?? -1;
        
        if (deleteIndex == -1) {
          Notifications.sonner(context, message: '找不到要删除的课程');
          return;
        }
        
        await CourseService.instance.deleteCourseAt(timetableId, deleteIndex);
        
        Notifications.sonner(context, message: '课程已删除');
        Navigator.pop(context, 'deleted');
      } catch (e) {
        Notifications.sonner(context, title: '删除失败', message: e.toString());
      }
    }
  }

  // ================= UI构建 =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: YicoreAppBar(
        title: _nameController.text.trim().isEmpty ? '添加课程' : '编辑课程',
        centerTitle: true,
        actions: [
          if (widget.course.name.isNotEmpty && _nameController.text.trim().isNotEmpty)
            YicoreAppBarAction(
              icon: Icons.delete_outline,
              iconColor: Colors.red,
              onPressed: _confirmDeleteCourse,
            ),
          YicoreAppBarAction(
            icon: Icons.save,
            onPressed: _saveCourse,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            return SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? 24 : 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 1000 : double.infinity),
                  child: isWide ? _buildWideLayout() : _buildMobileLayout(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() => Column(
        children: [
          _buildBasicInfoCard(),
          const SizedBox(height: 20),
          _buildScheduleSection(),
          const SizedBox(height: 20),
          _buildColorSection(),
          const SizedBox(height: 32),
        ],
      );

  Widget _buildWideLayout() => Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildBasicInfoCard()),
              const SizedBox(width: 24),
              Expanded(child: _buildColorSection()),
            ],
          ),
          const SizedBox(height: 24),
          _buildScheduleSection(),
        ],
      );

  Widget _buildSectionCard(String title, List<Widget> children) {
    return YicoreCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() => _buildSectionCard('基本信息', [
        _buildTextField('课程名称', _nameController, validator: (v) => v!.isEmpty ? '请输入课程名称' : null),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('上课地点', _locationController)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('授课教师', _teacherController)),
          ],
        ),
      ]);

  Widget _buildColorSection() => _buildSectionCard('显示设置', [
        const Text('选择课程颜色', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ColorUtils.courseColors.map((color) {
            final selected = _selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: selected ? Border.all(color: Colors.white, width: 3) : null,
                  boxShadow: selected
                      ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)]
                      : null,
                ),
                child: selected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
              ),
            );
          }).toList(),
        ),
      ]);

  Widget _buildScheduleSection() => _buildSectionCard('时间安排', [
        ...List.generate(_days.length, (index) {
          return _buildScheduleCard(index);
        }),
        const SizedBox(height: 12),
        Center(
          child: YicoreButton(
            text: '添加时间段',
            isOutlined: true,
            onPressed: _addNewSchedule,
          ),
        ),
      ]);

  Widget _buildScheduleCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('时间段 ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (_days.length > 1)
              GestureDetector(
                onTap: () => _removeScheduleAt(index),
                child: Text('删除', style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.w600)),
              ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('星期', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  YicoreDropdown<int>(
                    value: _days[index],
                    hintText: '选择星期',
                    items: List.generate(7, (i) => i + 1)
                        .map((d) => YicoreDropdownItem(
                          value: d,
                          label: '周${['一','二','三','四','五','六','日'][d - 1]}',
                        ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _days[index] = v);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildTextField('周次', _weekPatternControllers[index],
                  hint: '如: 1-16, 1,3,5', validator: (v) => v!.isEmpty ? '请输入周次' : null),
            ),
          ]),
          const SizedBox(height: 16),
          _buildTextField('节次', _periodsControllers[index], hint: '如: 1-2, 3, 5-6', validator: (v) => v!.isEmpty ? '请输入节次' : null),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? hint, String? Function(String?)? validator}) {
    return YicoreTextField(
      labelText: label,
      hintText: hint,
      controller: controller,
      validator: validator,
    );
  }
}

