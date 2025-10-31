import 'package:isar_plus/isar_plus.dart';
import '../data/timetable.dart';
import '../data/course.dart';

/// 课程服务：对指定课表下的课程进行增删改查
/// 所有操作均以课表 ID 为作用域，修改后会回写 Timetable
class CourseService {
  static CourseService? _instance;
  Isar? _isar;

  CourseService._();

  /// 获取单例实例
  static CourseService get instance {
    _instance ??= CourseService._();
    return _instance!;
  }

  /// 注入 Isar 实例
  Future<void> init(Isar isarInstance) async {
    _isar = isarInstance;
  }

  /// 获取内部持有的 Isar 实例
  Isar get isar {
    if (_isar == null) throw Exception('CourseService 未初始化');
    return _isar!;
  }

  /// 获取课表下所有课程
  /// - timetableId: 课表 ID
  Future<List<Course>> getCourses(int timetableId) async {
    final t = await isar.timetables.get(timetableId);
    return t?.courses ?? <Course>[];
    
  }

  /// 在课表下添加单个课程
  /// - timetableId: 课表 ID
  /// - course: 要添加的课程
  /// 成功返回 true
  Future<bool> addCourse(int timetableId, Course course) async {
    try {
      final t = await isar.timetables.get(timetableId);
      if (t == null) throw Exception('课表不存在');
      final list = List<Course>.from(t.courses)..add(course);
      t.courses = list;
      await isar.write((isar) async {
        isar.timetables.put(t);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 批量添加课程
  /// - timetableId: 课表 ID
  /// - courses: 课程列表
  Future<bool> addCourses(int timetableId, List<Course> courses) async {
    try {
      final t = await isar.timetables.get(timetableId);
      if (t == null) throw Exception('课表不存在');
      final list = List<Course>.from(t.courses)..addAll(courses);
      t.courses = list;
      await isar.write((isar) async {
        isar.timetables.put(t);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 更新课程（按索引替换）
  /// - timetableId: 课表 ID
  /// - index: 课程在列表中的索引
  /// - course: 新的课程数据
  Future<bool> updateCourseAt(int timetableId, int index, Course course) async {
    try {
      final t = await isar.timetables.get(timetableId);
      if (t == null) throw Exception('课表不存在');
      if (index < 0 || index >= t.courses.length) throw Exception('索引越界');
      final list = List<Course>.from(t.courses);
      list[index] = course;
      t.courses = list;
      await isar.write((isar) async {
        isar.timetables.put(t);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 删除课程（按索引）
  /// - timetableId: 课表 ID
  /// - index: 课程索引
  Future<bool> deleteCourseAt(int timetableId, int index) async {
    try {
      final t = await isar.timetables.get(timetableId);
      if (t == null) throw Exception('课表不存在');
      if (index < 0 || index >= t.courses.length) throw Exception('索引越界');
      final list = List<Course>.from(t.courses)..removeAt(index);
      t.courses = list;
      await isar.write((isar) async {
        isar.timetables.put(t);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 清空课表下所有课程
  /// - timetableId: 课表 ID
  Future<bool> clearCourses(int timetableId) async {
    try {
      await isar.write((isar) async {
        final t = await isar.timetables.get(timetableId);
        if (t == null) throw Exception('课表不存在');
        t.courses = <Course>[];
        isar.timetables.put(t);
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}

