import 'package:flutter/material.dart';
import 'components.dart';
import 'dialogs.dart';

// ================== 课表数据模型 ==================
class Schedule {
  String id;
  String name;
  DateTime createdAt;

  Schedule({
    required this.id,
    required this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

// ================== 课表管理器 ==================
class YicoreScheduleManager {
  static Future<void> show(
    BuildContext context, {
    required List<Schedule> schedules,
    required Function(List<Schedule>) onSchedulesChanged,
    String? currentScheduleId,
    Function(String)? onCurrentScheduleChanged,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ScheduleManagerDialog(
        schedules: schedules,
        onSchedulesChanged: onSchedulesChanged,
        currentScheduleId: currentScheduleId,
        onCurrentScheduleChanged: onCurrentScheduleChanged,
      ),
    );
  }
}

class _ScheduleManagerDialog extends StatefulWidget {
  final List<Schedule> schedules;
  final Function(List<Schedule>) onSchedulesChanged;
  final String? currentScheduleId;
  final Function(String)? onCurrentScheduleChanged;

  const _ScheduleManagerDialog({
    required this.schedules,
    required this.onSchedulesChanged,
    this.currentScheduleId,
    this.onCurrentScheduleChanged,
  });

  @override
  State<_ScheduleManagerDialog> createState() => _ScheduleManagerDialogState();
}

class _ScheduleManagerDialogState extends State<_ScheduleManagerDialog> {
  late List<Schedule> _schedules;
  final TextEditingController _newScheduleController = TextEditingController();
  String? _editingScheduleId;
  String? _currentScheduleId; // 本地追踪当前选中的课表ID
  final Map<String, TextEditingController> _editControllers = {};

  @override
  void initState() {
    super.initState();
    _schedules = List.from(widget.schedules);
    _currentScheduleId = widget.currentScheduleId; // 初始化当前课表ID
    
    // 为每个课表创建编辑控制器
    for (var schedule in _schedules) {
      _editControllers[schedule.id] = TextEditingController(text: schedule.name);
    }
  }

  @override
  void dispose() {
    _newScheduleController.dispose();
    for (var controller in _editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSchedule() {
    if (_newScheduleController.text.trim().isEmpty) return;

    final newSchedule = Schedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _newScheduleController.text.trim(),
    );

    setState(() {
      _schedules.add(newSchedule);
      _editControllers[newSchedule.id] = TextEditingController(text: newSchedule.name);
      _newScheduleController.clear();
    });

    widget.onSchedulesChanged(_schedules);
  }

  void _deleteSchedule(String id) {
    setState(() {
      _schedules.removeWhere((s) => s.id == id);
      _editControllers[id]?.dispose();
      _editControllers.remove(id);
      if (_editingScheduleId == id) {
        _editingScheduleId = null;
      }
    });

    widget.onSchedulesChanged(_schedules);
  }

  void _startEditing(String id) {
    setState(() {
      _editingScheduleId = id;
    });
  }

  void _finishEditing(String id) {
    final controller = _editControllers[id];
    if (controller == null || controller.text.trim().isEmpty) {
      // 如果为空，恢复原名称
      final schedule = _schedules.firstWhere((s) => s.id == id);
      controller?.text = schedule.name;
      setState(() {
        _editingScheduleId = null;
      });
    } else {
      // 更新名称
      final schedule = _schedules.firstWhere((s) => s.id == id);
      setState(() {
        schedule.name = controller.text.trim();
        _editingScheduleId = null;
      });
      widget.onSchedulesChanged(_schedules);
    }
  }

  void _cancelEditing() {
    if (_editingScheduleId != null) {
      final schedule = _schedules.firstWhere((s) => s.id == _editingScheduleId);
      _editControllers[_editingScheduleId]?.text = schedule.name;
      setState(() {
        _editingScheduleId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: _buildScheduleList(),
            ),
            _buildNewScheduleInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '课表管理',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          YicoreIconButton(
            icon: Icons.close,
            size: 36,
            showBorder: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNewScheduleInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newScheduleController,
              decoration: InputDecoration(
                hintText: '输入新课表名称',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
              onSubmitted: (_) => _addSchedule(),
            ),
          ),
          const SizedBox(width: 12),
          YicoreButton(
            text: '新建',
            onPressed: _addSchedule,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    if (_schedules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                '暂无课表',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '点击上方新建按钮创建第一个课表',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _schedules.length,
      itemBuilder: (context, index) {
        final schedule = _schedules[index];
        final isEditing = _editingScheduleId == schedule.id;
        final isCurrent = schedule.id == _currentScheduleId; // 使用本地状态

        return _buildScheduleItem(schedule, isEditing, isCurrent);
      },
    );
  }

  Widget _buildScheduleItem(Schedule schedule, bool isEditing, bool isCurrent) {
    final controller = _editControllers[schedule.id]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.black.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? Colors.black : Colors.grey[200]!,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isEditing ? null : () {
          if (!isCurrent) {
            // 更新本地状态以立即刷新UI
            setState(() {
              _currentScheduleId = schedule.id;
            });
            // 调用回调通知外部
            if (widget.onCurrentScheduleChanged != null) {
              widget.onCurrentScheduleChanged!(schedule.id);
            }
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
          children: [
            // 图标
            Icon(
              isCurrent ? Icons.check_circle : Icons.calendar_today_outlined,
              color: isCurrent ? Colors.black : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            // 名称或输入框
            Expanded(
              child: isEditing
                  ? TextField(
                      controller: controller,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                      onSubmitted: (_) => _finishEditing(schedule.id),
                    )
                  : Text(
                      schedule.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // 操作按钮
            if (isEditing) ...[
              // 确认按钮
              IconButton(
                onPressed: () => _finishEditing(schedule.id),
                icon: const Icon(Icons.check, color: Colors.green),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 4),
              // 取消按钮
              IconButton(
                onPressed: _cancelEditing,
                icon: Icon(Icons.close, color: Colors.grey[600]),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ] else ...[
              // 编辑按钮（所有课表都显示）
              IconButton(
                onPressed: () => _startEditing(schedule.id),
                icon: Icon(Icons.edit_outlined, color: Colors.grey[600]),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: '重命名',
              ),
              // 删除按钮（仅非当前课表显示）
              if (!isCurrent) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => _showDeleteConfirm(schedule),
                  icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: '删除',
                ),
              ],
            ],
          ],
        ),
      ),
      ),
    );
  }

  void _showDeleteConfirm(Schedule schedule) {
    YicoreConfirm.show(
      context,
      title: '确认删除',
      message: '确定要删除课表"${schedule.name}"吗？此操作无法撤销。',
      onConfirm: () {
        _deleteSchedule(schedule.id);
      },
    );
  }
}

