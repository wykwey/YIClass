import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../states/timetable_state.dart';
import '../../services/timetable/factory_service.dart';
import '../layout/schedule_manager.dart';
// 注意：此文件被 layout/appbar.dart 引用

/// 课表管理对话框 - 使用 YicoreScheduleManager 组件，只保留数据转换逻辑
class TimetableManagementDialog {
  static Future<void> show(BuildContext context) async {
    final timetableState = Provider.of<TimetableState>(context, listen: false);
    
    // 将 Timetable 对象转换为 Schedule 对象
    final schedules = timetableState.timetables.map((t) => Schedule(
      id: t.id.toString(),
      name: t.name,
      createdAt: DateTime.now(), // Timetable 没有 createdAt 字段，使用当前时间
    )).toList();
    
    // 显示 YicoreScheduleManager
    await YicoreScheduleManager.show(
      context,
      schedules: schedules,
      currentScheduleId: timetableState.current?.id.toString(),
      onSchedulesChanged: (updatedSchedules) async {
        // 处理课表更新
        await _handleScheduleChanges(
          context,
          timetableState,
          updatedSchedules,
        );
      },
      onCurrentScheduleChanged: (scheduleId) {
        // 切换当前课表
        final id = int.tryParse(scheduleId);
        if (id != null) {
          timetableState.setCurrentById(id);
        }
      },
    );
  }

  /// 处理课表变更（新增、更新、删除）
  static Future<void> _handleScheduleChanges(
    BuildContext context,
    TimetableState timetableState,
    List<Schedule> updatedSchedules,
  ) async {
    final currentTimetables = timetableState.timetables;
    final updatedIds = updatedSchedules.map((s) => s.id).toSet();
    final currentIds = currentTimetables.map((t) => t.id.toString()).toSet();

    // 1. 找出被删除的课表
    final deletedIds = currentIds.difference(updatedIds);
    for (final idStr in deletedIds) {
      final id = int.parse(idStr);
      await timetableState.delete(id);
    }

    // 2. 处理新增和更新的课表
    for (final schedule in updatedSchedules) {
      final existingTimetable = currentTimetables.firstWhere(
        (t) => t.id.toString() == schedule.id,
        orElse: () {
          // 新课表：使用 FactoryService 创建
          final newTimetable = FactoryService.createTimetable(name: schedule.name);
          // 使用 schedule.id 作为新 ID（如果可解析为整数）
          try {
            final newId = int.parse(schedule.id);
            newTimetable.id = newId;
          } catch (_) {
            // 如果不能解析，使用 0（Isar 会自动分配新 ID）
            newTimetable.id = 0;
          }
          return newTimetable;
        },
      );

      // 更新名称
      existingTimetable.name = schedule.name;
      
      // 保存到数据库
      await timetableState.put(existingTimetable);
    }

    // 3. 重新加载状态
    await timetableState.reload();
  }
}
