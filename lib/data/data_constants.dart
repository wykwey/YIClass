/// 数据模型默认常量
/// 
/// 包含课表等数据模型相关的默认配置
class DataConstants {
  // 课表默认配置
  static const String defaultTimetableName = '默认课表';
  static const int defaultTotalWeeks = 20;
  static const int defaultMaxPeriods = 16;
  
  // 课表范围配置
  static const int minTotalWeeks = 1;
  static const int maxTotalWeeks = 20;
  static const int minMaxPeriods = 1;
  static const int maxMaxPeriods = 16;
  
  // 视图和显示默认配置
  static const int defaultCurrentWeek = 1;
  static const String defaultSelectedView = '周视图';
  static const bool defaultShowWeekend = true;
  
  // 默认节次时间配置
  static const Map<String, String> defaultPeriodTimes = {
    '1': '08:00-08:45',
    '2': '08:50-09:35',
    '3': '09:40-10:25',
    '4': '10:30-11:15',
    '5': '11:20-12:05',
    '6': '13:30-14:15',
    '7': '14:20-15:05',
    '8': '15:10-15:55',
    '9': '16:00-16:45',
    '10': '16:50-17:35',
    '11': '18:30-19:15',
    '12': '19:20-20:05',
    '13': '20:10-20:55',
    '14': '21:00-21:45',
    '15': '21:50-22:35',
    '16': '22:40-23:25'
  };
}
