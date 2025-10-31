import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/timetable_state.dart';
import '../services/factory_service.dart';
import '../data/timetable.dart';

class TimetableManagementDialog extends StatefulWidget {
  const TimetableManagementDialog({super.key});

  @override
  State<TimetableManagementDialog> createState() => _TimetableManagementDialogState();
}

class _TimetableManagementDialogState extends State<TimetableManagementDialog> {
  String? editingId;
  final Map<String, TextEditingController> _controllers = {};
  late final TextEditingController _newTimetableController;
  bool _hasUnsavedChanges = false; // 跟踪是否有未保存的更改

  @override
  void initState() {
    super.initState();
    _newTimetableController = TextEditingController();
  }

  @override
  void dispose() {
    _newTimetableController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  
  Future<void> _syncAllEdits(TimetableState state) async {
    // 如果有正在编辑的课表且有未保存的更改，才需要处理
    if (editingId != null && _hasUnsavedChanges) {
      final controller = _controllers[editingId!];
      if (controller != null) {
        final newName = controller.text.trim();
        if (newName.isNotEmpty) {
          final timetable = state.timetables.firstWhere(
            (t) => t.id.toString() == editingId!,
          );
          timetable.name = newName;
          await state.put(timetable);
        }
      }
      _hasUnsavedChanges = false; // 标记为已保存
    }
    // 无论是否有未保存的更改，都要退出编辑模式
    if (editingId != null) {
      setState(() => editingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timetableState = context.watch<TimetableState>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('课表管理', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 使用 Consumer 局部刷新列表
                Consumer<TimetableState>(
                  builder: (_, state, __) {
                    return Column(
                      children: state.timetables.map((timetable) {
                        final id = timetable.id.toString();
                        _controllers.putIfAbsent(
                          id,
                          () => TextEditingController(text: timetable.name),
                        );
                        final isCurrent = state.current?.id == timetable.id;
                        final isEditing = editingId == id;

                        return TimetableItem(
                          timetable: timetable,
                          controller: _controllers[id]!,
                          isCurrent: isCurrent,
                          isEditing: isEditing,
                          onEditTap: () {
                            setState(() {
                              editingId = id;
                              _hasUnsavedChanges = true; // 开始编辑，标记为有未保存的更改
                            });
                          },
                          onDelete: () async {
                            await state.delete(timetable.id);
                            if (editingId == id) setState(() => editingId = null);
                          },
                          onSwitch: () {
                            state.setCurrent(timetable);
                            state.setDefaultById(timetable.id);
                          },
                          onExitEdit: () async {
                            // 统一的退出编辑逻辑：保存并退出
                            final controller = _controllers[id];
                            if (controller != null) {
                              final newName = controller.text.trim();
                              if (newName.isNotEmpty) {
                                timetable.name = newName;
                                await state.put(timetable);
                                _hasUnsavedChanges = false; // 标记为已保存
                              }
                            }
                            setState(() => editingId = null);
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const Divider(height: 32),
                TextField(
                  controller: _newTimetableController,
                  decoration: const InputDecoration(
                    labelText: '新课表名称',
                    hintText: '输入名称如：大一上学期',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await _syncAllEdits(timetableState);
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () async {
            final name = _newTimetableController.text.trim();
            if (name.isNotEmpty) {
              final newTimetable = FactoryService.createTimetable(name: name);
              await timetableState.put(newTimetable);
              _newTimetableController.clear();
            }
          },
          child: const Text('添加'),
        ),
      ],
    );
  }
}

class TimetableItem extends StatelessWidget {
  final Timetable timetable;
  final TextEditingController controller;
  final bool isCurrent;
  final bool isEditing;
  final VoidCallback onEditTap;
  final VoidCallback onDelete;
  final VoidCallback onSwitch;
  final VoidCallback onExitEdit;

  const TimetableItem({
    super.key,
    required this.timetable,
    required this.controller,
    required this.isCurrent,
    required this.isEditing,
    required this.onEditTap,
    required this.onDelete,
    required this.onSwitch,
    required this.onExitEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today_outlined, color: Colors.blueAccent),
        title: isEditing
            ? TextField(
                controller: controller,
                style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                autofocus: true,
                onSubmitted: (value) {
                  // 回车键直接退出编辑（使用统一的退出逻辑）
                  onExitEdit();
                },
                onEditingComplete: () {
                  // 完成按钮直接退出编辑（使用统一的退出逻辑）
                  onExitEdit();
                },
                onTapOutside: (event) {
                  // 点击外部区域时退出编辑（使用统一的退出逻辑）
                  onExitEdit();
                },
              )
            : Text(
                timetable.name,
                style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrent) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: '重命名',
                onPressed: onEditTap,
              ),
            ],
            if (!isCurrent)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: onDelete,
              ),
          ],
        ),
        onTap: onSwitch,
      ),
    );
  }
}
