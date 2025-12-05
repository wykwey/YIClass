import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:isar_plus/isar_plus.dart';
import 'states/timetable_state.dart';
import 'states/view_state.dart';
import 'states/week_state.dart';
import 'services/database_service.dart';
import 'services/timetable/timetable_service.dart';
import 'services/timetable/course_service.dart';
import 'services/settings_service.dart';
import 'services/course_reminder_service.dart';
import 'routes/app_routes.dart';
import 'routes/route_names.dart';

/// 应用入口函数
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) await Isar.initialize();

  final timetableState = TimetableState();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: timetableState),
        ChangeNotifierProvider(create: (_) => WeekState()),
        ChangeNotifierProvider(create: (_) => ViewState()),
      ],
      child: const MyApp(),
    ),
  );

  Future.microtask(() => _initializeServices(timetableState));
}

/// 初始化服务
Future<void> _initializeServices(TimetableState timetableState) async {
  final dbService = DatabaseService.instance;
  await dbService.initialize();
  final isar = dbService.isar;

  await Future.wait([
    TimetableService.instance.init(isar),
    CourseService.instance.init(isar),
    SettingsService.instance.init(isar),
  ]);

  await timetableState.init(isar);
  _initializeCourseReminders(timetableState);
}

/// 初始化课程提醒
Future<void> _initializeCourseReminders(TimetableState timetableState) async {
  final settings = await SettingsService.instance.loadSettings();
  if (!settings.courseReminder) return;

  final currentTimetable = timetableState.current;
  if (currentTimetable == null) return;

  await CourseReminderService.instance.scheduleTodayReminders(currentTimetable);
}

/// 应用根组件
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: RouteNames.home,
      theme: ThemeData(useMaterial3: true),
    );
  }
}

