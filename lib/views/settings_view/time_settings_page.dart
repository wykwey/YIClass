import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../states/timetable_state.dart';
import '../../data/data_constants.dart';
import '../../data/class_time.dart';
import '../../components/inputs/timepicker.dart';
import '../../components/inputs/datepicker.dart';
import '../../components/feedback/notifications.dart';
import '../../components/layout/appbar.dart';
import '../../components/layout/settingscard.dart';
import '../../components/inputs/components.dart';
import '../../components/layout/cards.dart';

/// 课程时间设置页面
/// 
/// 功能：
/// - 设置学期开始日期
/// - 设置最大节数
/// - 设置每节课的时间
/// - 支持统一时长快捷设置
class TimeSettingsPage extends StatefulWidget {
  const TimeSettingsPage({super.key});

  @override
  State<TimeSettingsPage> createState() => _TimeSettingsPageState();
}

class _TimeSettingsPageState extends State<TimeSettingsPage> {
  // ==================== 状态变量 ====================
  late Map<int, ClassTime> _classTimes;
  DateTime? _selectedDate;
  int _maxPeriods = DataConstants.defaultMaxPeriods;
  bool _useSameDuration = false;
  final TextEditingController _durationController = TextEditingController();

  // ==================== 生命周期 ====================
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  // ==================== 数据加载 ====================
  
  /// 从课表加载设置
  void _loadSettings() {
    final timetable = context.read<TimetableState>().current;
    if (timetable == null) return;

    _selectedDate = timetable.settings.startDate;
    _maxPeriods = timetable.settings.maxPeriods > 0
        ? timetable.settings.maxPeriods
        : DataConstants.defaultMaxPeriods;

    _loadClassTimes(timetable);
  }

  /// 加载课程时间
  void _loadClassTimes(timetable) {
    _classTimes = {};

    // 从课表加载已有的时间设置
    for (final ct in timetable.settings.classTimes) {
      _classTimes[ct.period] = ClassTime()
        ..period = ct.period
        ..startTime = ct.startTime
        ..endTime = ct.endTime;
    }

    // 确保所有节次都有默认值
    for (int i = 1; i <= _maxPeriods; i++) {
      _classTimes.putIfAbsent(i, () => _createDefaultClassTime(i));
    }
  }

  /// 创建默认的课程时间
  ClassTime _createDefaultClassTime(int period) {
    final defaultTime = DataConstants.defaultPeriodTimes[period.toString()] ?? '08:00-08:45';
    final parts = defaultTime.split('-');
    return ClassTime()
      ..period = period
      ..startTime = parts.isNotEmpty ? parts.first : '08:00'
      ..endTime = parts.length > 1 ? parts.last : '08:45';
  }

  // ==================== 数据保存 ====================
  
  /// 保存设置
  Future<void> _saveSettings() async {
    try {
      final timetableState = context.read<TimetableState>();
      final timetable = timetableState.current;
      if (timetable == null) return;

      // 构建课程时间列表
      final classTimesList = <ClassTime>[];
      for (int i = 1; i <= _maxPeriods; i++) {
        if (_classTimes.containsKey(i)) {
          classTimesList.add(_classTimes[i]!);
        }
      }

      // 更新设置
      timetable.settings.classTimes = classTimesList;
      timetable.settings.maxPeriods = _maxPeriods;
      if (_selectedDate != null) {
        timetable.settings.startDate = _selectedDate!;
      }

      // 保存到数据库
      await timetableState.put(timetable);

      // 关闭页面
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Notifications.sonner(context, message: '保存失败：${e.toString()}');
      }
    }
  }

  // ==================== 事件处理 ====================
  
  /// 更新最大节数
  void _updateMaxPeriods(int value) {
    setState(() {
      _maxPeriods = value;
      
      // 添加新增的节次
      for (int i = 1; i <= _maxPeriods; i++) {
        _classTimes.putIfAbsent(i, () => _createDefaultClassTime(i));
      }
      
      // 删除超出的节次
      _classTimes.removeWhere((key, _) => key > _maxPeriods);
    });
  }

  /// 选择开始日期
  Future<void> _pickStartDate() async {
    final currentDate = _selectedDate ?? DateTime.now();
    final picked = await YicoreDatePicker.show(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2099, 12, 31),
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  /// 选择课程时间
  Future<void> _pickClassTime(int period) async {
    final classTime = _classTimes[period];
    if (classTime == null) return;

    // 解析当前时间
    final startParts = classTime.startTime.split(':');
    final endParts = classTime.endTime.split(':');
    final initial = TimeRange(
      startHour: int.tryParse(startParts[0]) ?? 8,
      startMinute: int.tryParse(startParts[1]) ?? 0,
      endHour: int.tryParse(endParts[0]) ?? 8,
      endMinute: int.tryParse(endParts[1]) ?? 45,
    );

    // 显示时间选择器
    final result = await YicoreTimeRangePicker.show(
      context: context,
      initial: initial,
    );

    if (result != null && mounted) {
      setState(() {
        _classTimes[period] = ClassTime()
          ..period = period
          ..startTime = result.formatStart()
          ..endTime = result.formatEnd();
      });
    }
  }

  /// 应用统一时长
  void _applySameDuration() {
    final duration = int.tryParse(_durationController.text);
    if (duration == null || duration <= 0) {
      Notifications.sonner(context, message: '请输入有效的时长（分钟）');
      return;
    }

    setState(() {
      DateTime start = DateTime(2000, 1, 1, 8, 0);
      for (int i = 1; i <= _maxPeriods; i++) {
        final end = start.add(Duration(minutes: duration));
        _classTimes[i] = ClassTime()
          ..period = i
          ..startTime = _formatTime(start)
          ..endTime = _formatTime(end);
        start = end;
      }
    });

    Notifications.sonner(context, message: '已应用统一时长');
  }

  // ==================== 辅助方法 ====================
  
  /// 格式化时间
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 获取中文数字
  String _getChineseNumber(int number) {
    const numbers = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十', 
                     '十一', '十二', '十三', '十四', '十五', '十六'];
    return (number >= 1 && number <= 16) ? numbers[number - 1] : number.toString();
  }

  /// 获取时间段的节次列表
  List<int> _getPeriodsForTimeSlot(String slot) {
    final ranges = {
      '上午': [1, 2, 3, 4],
      '下午': [5, 6, 7, 8, 9],
      '晚上': [10, 11, 12, 13, 14, 15, 16],
    };
    return ranges[slot]!.where((i) => i <= _maxPeriods).toList();
  }

  // ==================== UI 构建 ====================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YicoreAppBar(
        title: '课程时间设置',
        centerTitle: true,
        onBackPressed: () => Navigator.pop(context),
        actions: [
          YicoreAppBarAction(
            icon: Icons.check,
            onPressed: _saveSettings,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBasicSettings(),
          const SizedBox(height: 16),
          _buildQuickSettings(),
          if (_useSameDuration) ...[
            const SizedBox(height: 16),
            _buildDurationInput(),
          ],
          const SizedBox(height: 16),
          _buildTimeSlots(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 构建基础设置
  Widget _buildBasicSettings() {
    return SettingsBlock(
      title: '基础设置',
      children: [
        SettingsItem.value(
          title: '学期开始日期',
          value: _selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
              : '未设置',
          showArrow: true,
          onTap: _pickStartDate,
          inBlock: true,
        ),
        SettingsItem.slider(
          title: '最大节数',
          description: '共$_maxPeriods节',
          value: _maxPeriods.toDouble(),
          min: DataConstants.minMaxPeriods.toDouble(),
          max: DataConstants.maxMaxPeriods.toDouble(),
          onChanged: (value) => _updateMaxPeriods(value.round()),
          inBlock: true,
        ),
      ],
    );
  }

  /// 构建快捷设置
  Widget _buildQuickSettings() {
    return SettingsBlock(
      title: '快捷设置',
      children: [
        SettingsItem.switch_(
          title: '每节课时长相同',
          description: '自动推算每节课的开始和结束时间',
          value: _useSameDuration,
          onChanged: (value) => setState(() => _useSameDuration = value),
          inBlock: true,
        ),
      ],
    );
  }

  /// 构建统一时长输入
  Widget _buildDurationInput() {
    return YicoreCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '统一时长设置',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: YicoreTextField(
                  labelText: '统一时长（分钟）',
                  hintText: '45',
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              YicoreButton(
                text: '应用',
                onPressed: _applySameDuration,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建时间段设置
  Widget _buildTimeSlots() {
    return SettingsBlock(
      title: '时间段设置',
      children: [
        ..._buildTimeSlotSection('上午'),
        ..._buildTimeSlotSection('下午'),
        ..._buildTimeSlotSection('晚上'),
      ],
    );
  }

  /// 构建时间段区块
  List<Widget> _buildTimeSlotSection(String slot) {
    final periods = _getPeriodsForTimeSlot(slot);
    if (periods.isEmpty) return [];

    final items = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Text(
          slot,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ),
    ];

    for (int i = 0; i < periods.length; i++) {
      final period = periods[i];
      final classTime = _classTimes[period];
      final timeStr = classTime != null
          ? '${classTime.startTime}-${classTime.endTime}'
          : '未设置';
      final isLast = (i == periods.length - 1 && slot == '晚上');

      items.add(
        SettingsItem(
          title: '第${_getChineseNumber(period)}节',
          value: timeStr,
          showArrow: true,
          enabled: !_useSameDuration,
          onTap: _useSameDuration ? null : () => _pickClassTime(period),
          inBlock: true,
          isLastInBlock: isLast,
        ),
      );
    }

    return items;
  }
}
