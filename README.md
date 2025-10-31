# 📅 YIClass - 智能课表管理应用

一个功能完善的跨平台课表应用，支持多种视图模式、AI智能导入、文件导入导出，界面美观，操作流畅。

**当前版本**: v2.1

## ✨ 核心功能

### 视图模式
- **周视图**：直观展示整周课程安排，支持多课程并排显示
- **日视图**：专注单日详细课程，彩色边框清晰标识
- **列表视图**：按周次分组查看所有课程，卡片式展示

### 课程管理
- 添加/编辑/删除课程
- 自定义课程颜色（预设颜色自动分配）
- 多课表支持（可创建和管理多个课表）
- 课程时间冲突检测
- 连续节次自动识别

### 智能导入
- **AI图片识别**：上传课程表图片，自动识别课程信息
- **AI表格解析**：解析CSV/Excel格式的课程表
- **AI文字识别**：从自然语言描述中提取课程数据
- **多AI服务支持**：OpenAI、Claude、Gemini、DeepSeek
- **文件导入/导出**：支持JSON格式导入导出课表数据

### 其他功能
- 显示/隐藏周末课程
- 按周筛选课程
- 自定义上课时间设置
- 节假日和补课日管理
- 数据本地持久化（Isar数据库）

## 🖼️ 应用截图

TODO: 添加应用截图

## 🚀 快速开始

### 运行要求
- Flutter 3.5.0+
- Dart 3.5.0+
- Android SDK 21+ (Android)
- iOS 12+ (iOS)
- Windows 10+ / macOS 10.14+ / Linux (桌面端)

### 安装步骤
```bash
git clone https://github.com/wykwey/YIClass
cd YIClass
flutter pub get
flutter run
```

### AI功能配置（可选）
1. 打开应用设置 → 高级功能 → AI导入配置
2. 选择或配置AI服务提供商（OpenAI/Claude/Gemini/DeepSeek）
3. 输入API Key和Endpoint
4. 选择使用的模型（视觉模型/文本模型）
5. 保存配置后即可使用AI导入功能

## 📚 数据结构说明

### 课程模型
```dart
class Course {
  String name;              // 课程名称
  String location;          // 上课地点
  String teacher;           // 教师姓名
  int color;               // 课程颜色（ARGB格式）
  List<CourseSchedule> schedules; // 上课时间安排
}

class CourseSchedule {
  int day;                 // 星期几 (1=周一, ..., 7=周日)
  List<int> periods;       // 节次列表 (如[1,2]表示1-2节)
  List<int> weekPattern;   // 上课周次数组 (如[1,2,3,4,5,6])
  String reminder;         // 提醒设置
}
```

### 时间安排格式
- `day`: 星期几 (1=周一, 2=周二...7=周日)
- `periods`: 节次列表，范围 1-20 (如[1,2]表示1-2节)
- `weekPattern`: 周次数组，具体数字列表 (如[1,2,3,4,5,6]表示第1-6周)

### 课表设置
```dart
class TimetableSettings {
  DateTime startDate;      // 学期开始日期
  int totalWeeks;          // 总周数 (1-20)
  bool showWeekend;        // 是否显示周末
  int maxPeriods;          // 最大节数 (1-16)
  List<ClassTime> classTimes; // 每节课的时间设置
  List<DateTime> holidays; // 节假日
  List<DateTime> extraClassDays; // 补课日
}
```

### JSON导入导出格式
```json
{
  "name": "课表名称",
  "isDefault": false,
  "courses": [
    {
      "name": "课程名称",
      "location": "上课地点",
      "teacher": "教师姓名",
      "color": 4280391411,
      "schedules": [
        {
          "day": 1,
          "periods": [1, 2],
          "weekPattern": [1, 2, 3, 4, 5, 6],
          "reminder": ""
        }
      ]
    }
  ]
}
```

## 🛠️ 技术架构

### 核心组件
- **状态管理**: Provider (ChangeNotifier)
- **数据持久化**: Isar Plus (NoSQL数据库)
- **UI框架**: Flutter Material Design 3
- **文件操作**: file_selector (跨平台文件选择)
- **AI服务**: HTTP API (支持OpenAI/Claude/Gemini/DeepSeek等)

### 主要依赖
```yaml
provider: ^6.1.5          # 状态管理
isar_plus: ^1.1.1         # 本地数据库
file_selector: ^1.0.3     # 文件选择器
http: ^1.1.0              # HTTP请求
image_picker: ^1.0.4      # 图片选择
shared_preferences: ^2.2.2 # 简单配置存储
```

### 项目结构
```
lib/
├── components/           # 可复用UI组件
│   ├── week_view_components/  # 周视图专用组件
│   ├── course_card.dart       # 课程卡片
│   ├── bottom_nav_bar.dart    # 底部导航
│   └── ...
├── data/                # 数据模型
│   ├── course.dart           # 课程模型
│   ├── timetable.dart       # 课表模型
│   └── ...
├── services/            # 业务逻辑服务
│   ├── ai/                  # AI服务
│   │   ├── ai_service.dart      # AI调用逻辑
│   │   └── ai_config_service.dart # AI配置管理
│   ├── file_service.dart    # 文件导入导出
│   ├── timetable_service.dart # 课表CRUD
│   └── ...
├── states/             # 状态管理
│   ├── timetable_state.dart  # 课表状态
│   ├── view_state.dart       # 视图状态
│   └── week_state.dart       # 周次状态
├── utils/              # 工具类
│   ├── color_utils.dart      # 颜色工具
│   └── ...
└── views/             # 页面视图
    ├── week_view.dart        # 周视图
    ├── day_view.dart         # 日视图
    ├── list_view.dart        # 列表视图
    ├── ai_import_page.dart   # AI导入页面
    └── ...
```

## 🤝 贡献指南

欢迎提交Pull Request或Issue。提交前请确保：
1. 代码通过静态分析
2. 添加适当的单元测试
3. 更新相关文档

## ❓ 常见问题

**Q: 如何添加新课表?**
A: 进入设置页面 → 课表管理 → 点击"添加课表"按钮

**Q: 如何导入课程表?**
A: 支持三种导入方式：
1. **AI图片识别**：在AI导入页面选择图片，AI会自动识别课程信息
2. **AI表格解析**：粘贴CSV/Excel格式的课程表文本
3. **AI文字识别**：输入自然语言描述的课程安排
4. **文件导入**：在设置页面或悬浮按钮选择"导入"，选择JSON格式的课表文件

**Q: 如何导出课程表?**
A: 在设置页面或悬浮按钮选择"导出"，选择保存位置即可导出为JSON文件

**Q: AI导入功能如何使用?**
A: 
1. 先在设置中启用"高级功能"
2. 进入"AI导入配置"，配置API Key和Endpoint
3. 支持OpenAI、Claude、Gemini、DeepSeek等AI服务
4. 配置完成后在AI导入页面使用

**Q: 课程时间冲突如何处理?**
A: 系统会自动检测同一时段的多个课程，并允许同时显示（可手动调整）

**Q: 如何自定义课程颜色?**
A: 编辑课程时可以手动选择颜色，未设置颜色的课程会从预设颜色中自动分配

**Q: 数据存储在哪里?**
A: 使用Isar数据库本地存储，所有数据保存在设备本地，不会上传到服务器

## 📄 开源协议

本项目采用 **Apache License 2.0** 开源协议。

### 许可证信息
- **许可证名称**: Apache License 2.0
- **许可证链接**: [LICENSE](LICENSE)
- **版权年份**: 2024
- **版权所有者**: YIClass

### 第三方依赖协议
本应用使用的第三方库及其协议：
- Flutter - Google (BSD-3-Clause)
- Provider - Remi Rousselet (MIT)
- Isar Plus - Isar Team (Apache-2.0)
- file_selector - Flutter Team (BSD-3-Clause)
- intl - Dart Team (BSD-3-Clause)
- http - Dart Team (BSD-3-Clause)
- image_picker - Flutter Team (BSD-3-Clause)
- shared_preferences - Flutter Team (BSD-3-Clause)




