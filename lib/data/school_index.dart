import 'package:isar_plus/isar_plus.dart';

part 'school_index.g.dart';

// 顶级学校索引集合
@collection
class SchoolIndex {
  late int id;
  late List<SchoolEntry> schools; // 学校列表
  @index
  late DateTime updatedAt; // 更新时间索引
}

// 学校条目（嵌入对象）
@embedded
class SchoolEntry {
  late String school;        // 学校名称
  late String letterIndex;   // 字母索引 
  late List<ScriptEntry> scripts; // 该校脚本列表
}

// 脚本条目（嵌入对象）
@embedded
class ScriptEntry {
  late String name;          // 项目名称
  late String scriptName;    // 脚本文件名（如 example.js）
  late String url;           // URL
  late String author;        // 作者
  late String description;    // 描述
}

