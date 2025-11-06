import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/timetable_state.dart';
import '../services/file_service.dart';
import '../zujian/fab.dart';
import '../zujian/notifications.dart';

class AddCourseFab extends StatelessWidget {
  final String? viewIdentifier;
  
  const AddCourseFab({super.key, this.viewIdentifier});

  Future<void> _importFromFile(BuildContext context) async {
    final ok = await FileService.importAndSave();
    if (!context.mounted) return;
    if (ok) {
      await Provider.of<TimetableState>(context, listen: false).reload();
      Notifications.sonner(context, message: '导入成功');
    } else {
      Notifications.sonner(context, message: '已取消或导入失败');
    }
  }

  Future<void> _exportToFile(BuildContext context) async {
    final timetableState = Provider.of<TimetableState>(context, listen: false);
    final current = timetableState.current;
    if (current == null) {
      Notifications.sonner(context, message: '请先选择一个课表');
      return;
    }
    final result = await FileService.exportTimetable(current);
    if (!context.mounted) return;
    if (result != null) {
      Notifications.sonner(context, message: '导出成功: $result');
    } else {
      Notifications.sonner(context, message: '已取消或当前平台不支持');
    }
  }

  @override
  Widget build(BuildContext context) {
    return YicoreFab(
      icon: Icons.add,
      tooltip: '快速操作',
      menuItems: [
        YicoreFabItem(
          icon: Icons.file_download,
          label: '导入',
          onPressed: () => _importFromFile(context),
        ),
        YicoreFabItem(
          icon: Icons.file_upload,
          label: '导出',
          onPressed: () => _exportToFile(context),
        ),
      ],
    );
  }
}