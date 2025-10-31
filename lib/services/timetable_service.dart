import 'package:isar_plus/isar_plus.dart';
import '../data/timetable.dart';

/// Timetable 服务（CRUD）
/// 提供对 `Timetable` 集合的增删改查与常用操作封装。
class TimetableService {
  static TimetableService? _instance;
  Isar? _isar;

  TimetableService._();

  /// 获取单例实例
  static TimetableService get instance {
    _instance ??= TimetableService._();
    return _instance!;
  }

  /// 注入 Isar 实例
  /// - isarInstance: 通过 Isar.open(...) 创建的实例
  Future<void> init(Isar isarInstance) async {
    _isar = isarInstance;
  }

  /// 生成一个未被占用的自增 ID（简单顺序分配）
  Future<int> _generateNewId() async {
    var id = await isar.timetables.count() + 1;
    // 保证唯一，若存在冲突则递增查找
    while (await isar.timetables.get(id) != null) {
      id++;
    }
    return id;
  }

  /// 获取内部持有的 Isar 实例，未初始化时抛出异常
  Isar get isar {
    if (_isar == null) {
      throw Exception('TimetableService 未初始化');
    }
    return _isar!;
  }

  // ===== Read =====

  /// 获取全部课表
  Future<List<Timetable>> getAll() async {
    return await isar.timetables.where().findAll();
  }

  /// 根据 ID 获取课表
  Future<Timetable?> getById(int id) async {
    return await isar.timetables.get(id);
  }

  /// 获取默认课表（第一个 isDefault = true 的课表），不存在返回 null
  Future<Timetable?> getDefault() async {
    final all = await getAll();
    for (final t in all) {
      if (t.isDefault) return t;
    }
    return null;
  }

  /// 按名称模糊查询课表（在内存中过滤）
  Future<List<Timetable>> searchByName(String name) async {
    final all = await getAll();
    return all.where((t) => t.name.contains(name)).toList();
  }

  /// 获取课表数量
  Future<int> count() async {
    return await isar.timetables.count();
  }

  // ===== Create / Update =====

  /// 新增或更新单个课表（put）。成功返回 true
  Future<bool> put(Timetable t) async {
    try {
      // 若未分配 ID，生成唯一 ID，避免覆盖现有课表
      if (t.id <= 0) {
        t.id = await _generateNewId();
      }
      await isar.write((isar) async {
        isar.timetables.put(t);
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 批量新增或更新课表。成功返回 true
  Future<bool> putAll(List<Timetable> list) async {
    try {
      // 为待插入的课表分配缺失的 ID，避免相互覆盖
      for (final t in list) {
        if (t.id <= 0) {
          t.id = await _generateNewId();
        }
      }
      await isar.write((isar) async {
        for (final t in list) {
          isar.timetables.put(t);
        }
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 将指定 ID 的课表设为默认，其余取消默认。成功返回 true
  Future<bool> setDefault(int id) async {
    try {
      await isar.write((isar) async {
        final all = await isar.timetables.where().findAll();
        for (final t in all) {
          t.isDefault = (t.id == id);
          isar.timetables.put(t);
        }
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ===== Delete =====

  /// 根据 ID 删除课表。返回是否成功
  Future<bool> delete(int id) async {
    try {
      bool ok = false;
      await isar.write((isar) async {
        ok = await isar.timetables.delete(id);
      });
      return ok;
    } catch (_) {
      return false;
    }
  }

  /// 删除所有课表，返回删除数量
  Future<int> deleteAll() async {
    int cnt = 0;
    await isar.write((isar) async {
      final all = await isar.timetables.where().findAll();
      for (final t in all) {
        if (await isar.timetables.delete(t.id)) cnt++;
      }
    });
    return cnt;
  }
}

