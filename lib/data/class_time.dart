import 'package:isar_plus/isar_plus.dart';

part 'class_time.g.dart';

/// 课时时间模型（嵌入式对象）
/// 描述某节课的具体上课与下课时间
@embedded
class ClassTime {
  /// 第几节课
  late int period;

  /// 开始时间（24小时制，如 "08:00"）
  late String startTime;

  /// 结束时间（24小时制，如 "08:45"）
  late String endTime;

  ClassTime();
}
