import 'package:flutter/material.dart';
import '../../data/school_index.dart';

/// 脚本选择页
class ScriptSelectPage extends StatelessWidget {
  final SchoolEntry school;

  const ScriptSelectPage({
    super.key,
    required this.school,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(school.school),
      ),
      body: school.scripts.isEmpty
          ? const Center(
              child: Text('该学校暂无可用脚本'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: school.scripts.length,
              itemBuilder: (context, index) {
                final script = school.scripts[index];
                return _buildScriptCard(context, script);
              },
            ),
    );
  }

  Widget _buildScriptCard(BuildContext context, ScriptEntry script) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: 导航到课表导入页
          Navigator.pop(context, script);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 名称
              Text(
                script.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // 说明
              if (script.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  script.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // 贡献者
              if (script.author.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '贡献者: ${script.author}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

