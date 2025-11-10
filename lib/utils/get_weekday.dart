
Map<String, int>? getWeekInfo(DateTime date, DateTime startMonday, int totalWeeks) {
  final deltaDays = date.difference(startMonday).inDays;

  // 越界检查
  if (deltaDays < 0) return null;                     // 学期未开始
  if (deltaDays >= totalWeeks * 7) return null;      // 学期已结束

  final weekIndex = (deltaDays ~/ 7) + 1;            // 第几周，从1开始
  final weekday = date.weekday;                      // 1=周一, 7=周日

  return {
    'weekIndex': weekIndex,
    'weekday': weekday,
  };
}
