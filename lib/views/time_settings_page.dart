import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../states/timetable_state.dart';
import '../data/data_constants.dart';
import '../data/class_time.dart';
import '../components/start_date_picker.dart';
import '../components/time_picker_bottom_sheet.dart';
import '../utils/feedback_utils.dart';

class TimeSettingsPage extends StatefulWidget {
  const TimeSettingsPage({super.key});

  @override
  State<TimeSettingsPage> createState() => _TimeSettingsPageState();
}

class _TimeSettingsPageState extends State<TimeSettingsPage> {
  late Map<int, ClassTime> _classTimes; // 使用节次作为key
  DateTime? _selectedDate;
  int _localMaxPeriods = DataConstants.defaultMaxPeriods;
  bool _isSameDuration = false;
  String _sameDurationValue = '';

  @override
  void initState() {
    super.initState();
    final timetableState = Provider.of<TimetableState>(context, listen: false);
    final timetable = timetableState.current;
    
    // 初始化 ClassTime Map
    _classTimes = {};
    if (timetable != null && timetable.settings.classTimes.isNotEmpty) {
      for (final ct in timetable.settings.classTimes) {
        _classTimes[ct.period] = ClassTime()
          ..period = ct.period
          ..startTime = ct.startTime
          ..endTime = ct.endTime
          ..reminderMinutes = ct.reminderMinutes;
      }
    } else {
      // 使用默认值
      DataConstants.defaultPeriodTimes.forEach((key, value) {
        final period = int.tryParse(key) ?? 0;
        if (period > 0) {
          final parts = value.split('-');
          _classTimes[period] = ClassTime()
            ..period = period
            ..startTime = parts.isNotEmpty ? parts.first : '08:00'
            ..endTime = parts.length > 1 ? parts.last : '08:45'
            ..reminderMinutes = 0;
        }
      });
    }
    
    _localMaxPeriods = (timetable?.settings.maxPeriods ?? 0) > 0
        ? timetable!.settings.maxPeriods
        : DataConstants.defaultMaxPeriods;
    _selectedDate = timetable?.settings.startDate;
    
    // 确保所有节次都有时间设置
    for (int i = 1; i <= _localMaxPeriods; i++) {
      _classTimes.putIfAbsent(i, () {
        final defaultTime = DataConstants.defaultPeriodTimes[i.toString()] ?? '08:00-08:45';
        final parts = defaultTime.split('-');
        return ClassTime()
          ..period = i
          ..startTime = parts.isNotEmpty ? parts.first : '08:00'
          ..endTime = parts.length > 1 ? parts.last : '08:45'
          ..reminderMinutes = 0;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }



  void _saveSettings() async {
    try {
      final timetableState = Provider.of<TimetableState>(context, listen: false);
      final timetable = timetableState.current;
      if (timetable == null) return;
      
      // 更新 ClassTime 列表（只保留有效的节次）
      final classTimesList = <ClassTime>[];
      for (int i = 1; i <= _localMaxPeriods; i++) {
        if (_classTimes.containsKey(i)) {
          classTimesList.add(_classTimes[i]!);
        }
      }
      
      // 更新设置
      timetable.settings.classTimes = classTimesList;
      timetable.settings.maxPeriods = _localMaxPeriods;
      if (_selectedDate != null) {
        timetable.settings.startDate = _selectedDate!;
      }
      
      // 保存到数据库
      await timetableState.put(timetable);
      
      // 直接关闭页面，无成功提示
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        FeedbackUtils.show(context, '保存失败：${e.toString()}');
      }
    }
  }

  void _updateMaxPeriods(int value) {
    setState(() {
      _localMaxPeriods = value;
      // 实时更新UI，但不立即保存到数据库
      for (int i = 1; i <= _localMaxPeriods; i++) {
        _classTimes.putIfAbsent(i, () {
          final defaultTime = DataConstants.defaultPeriodTimes[i.toString()] ?? '08:00-08:45';
          final parts = defaultTime.split('-');
          return ClassTime()
            ..period = i
            ..startTime = parts.isNotEmpty ? parts.first : '08:00'
            ..endTime = parts.length > 1 ? parts.last : '08:45'
            ..reminderMinutes = 0;
        });
      }
      _classTimes.removeWhere((key, _) => key > _localMaxPeriods);
    });
  }

  void _applySameDurationDuration() {
    // 以 08:00 为起点，依次推算每节课时间
    int duration = int.tryParse(_sameDurationValue) ?? 45;
    DateTime start = DateTime(2000, 1, 1, 8, 0);
    for (int i = 1; i <= _localMaxPeriods; i++) {
      final end = start.add(Duration(minutes: duration));
      final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
      final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
      
      _classTimes[i] = ClassTime()
        ..period = i
        ..startTime = startStr
        ..endTime = endStr
        ..reminderMinutes = 0;
      
      start = end;
    }
    setState(() {});
  }

  List<int> _morningPeriods() => [1, 2, 3, 4].where((i) => i <= _localMaxPeriods).toList();
  List<int> _afternoonPeriods() => [5, 6, 7, 8, 9].where((i) => i <= _localMaxPeriods).toList();
  List<int> _eveningPeriods() => [10, 11, 12, 13, 14, 15, 16].where((i) => i <= _localMaxPeriods).toList();

  // 将数字转换为汉字
  String _getChineseNumber(int number) {
    const chineseNumbers = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十', '十一', '十二', '十三', '十四', '十五', '十六'];
    if (number >= 1 && number <= 16) {
      return chineseNumbers[number - 1];
    }
    return number.toString();
  }

  Widget _buildTimeList(String title, List<int> periods) {
    if (periods.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(title, style: const TextStyle(color: Colors.grey)),
        ),
        ...periods.map((period) => InkWell(
          onTap: _isSameDuration ? null : () => _showTimePickerBottomSheet(period),
          child: ListTile(
            title: Text(
              '第${_getChineseNumber(period)}节',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _classTimes[period] != null 
                      ? '${_classTimes[period]!.startTime}-${_classTimes[period]!.endTime}'
                      : "未设置",
                  style: TextStyle(
                    color: _isSameDuration ? Colors.grey : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: _isSameDuration ? Colors.grey : Colors.black54,
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  void _showTimePickerBottomSheet(int period) {
    final classTime = _classTimes[period];
    final initialTime = classTime != null 
        ? '${classTime.startTime}-${classTime.endTime}'
        : '08:00-08:45';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TimePickerBottomSheet(
          initialTimeRange: initialTime,
          periodNumber: period,
          onTimeSelected: (timeRange) {
            setState(() {
              final parts = timeRange.split('-');
              _classTimes[period] = ClassTime()
                ..period = period
                ..startTime = parts.isNotEmpty ? parts.first : '08:00'
                ..endTime = parts.length > 1 ? parts.last : '08:45'
                ..reminderMinutes = classTime?.reminderMinutes ?? 0;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程时间设置'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSettings,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          ListTile(
            splashColor: Colors.transparent,
            title: const Text('学期开始日期', style: TextStyle(color: Colors.black)),
            subtitle: Text(
              _selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                  : '未设置',
            ),
            trailing: const Icon(Icons.edit_calendar),
            onTap: () async {
              final currentDate = _selectedDate ?? DateTime.now();
              await showDialog(
                context: context,
                builder: (_) => SimpleDatePicker(
                  initialDate: currentDate,
                  onDateSelected: (picked) async {
                    // 使用局部状态，不立即保存到数据库
                    setState(() {
                      _selectedDate = picked;
                    });
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('最大节数:', style: TextStyle(color: Colors.black)),
                Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue.shade400,
                    inactiveTrackColor: Colors.blue.shade100,
                    thumbColor: Colors.blue.shade400,
                    overlayColor: Colors.blue.shade100.withOpacity(0.2),
                    valueIndicatorColor: Colors.blue.shade400,
                  ),
                  child: Slider(
                    value: _localMaxPeriods.toDouble(),
                    min: DataConstants.minMaxPeriods.toDouble(),
                    max: DataConstants.maxMaxPeriods.toDouble(),
                    divisions: DataConstants.maxMaxPeriods - DataConstants.minMaxPeriods,
                    label: '$_localMaxPeriods',
                    onChanged: (value) {
                      // ✅ 使用局部状态，立即更新UI，避免全局广播冲突
                      _updateMaxPeriods(value.round());
                    },
                  ),
                ),
                ),
                Text('$_localMaxPeriods 节'),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('每节课时长相同', style: TextStyle(color: Colors.black)),
            subtitle: const Text('如45分钟，自动推算每节时间'),
            value: _isSameDuration,
            onChanged: (val) {
              setState(() {
                _isSameDuration = val;
                if (val && _sameDurationValue.isNotEmpty) {
                  _applySameDurationDuration();
                }
              });
            },
          ),
          if (_isSameDuration)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('统一时长(分钟):'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        _sameDurationValue = val;
                        if (_isSameDuration && val.isNotEmpty) {
                          _applySameDurationDuration();
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: '45',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      if (_sameDurationValue.isNotEmpty) {
                        _applySameDurationDuration();
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('应用'),
                  ),
                ],
              ),
            ),
          const Divider(),
          _buildTimeList('上午', _morningPeriods()),
          _buildTimeList('下午', _afternoonPeriods()),
          _buildTimeList('晚上', _eveningPeriods()),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
} 