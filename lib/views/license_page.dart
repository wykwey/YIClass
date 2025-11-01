import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OpenSourceLicensePage extends StatelessWidget {
  const OpenSourceLicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('开源许可证'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 项目信息
            const Text(
              'YIClass 课表管理应用',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Apache License 2.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 第三方依赖
            const Text(
              '第三方依赖',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Flutter - Google (BSD-3-Clause)'),
            const Text('Provider - Remi Rousselet (MIT)'),
            const Text('Isar Plus - Isar Team (Apache-2.0)'),
            const Text('file_selector - Flutter Team (BSD-3-Clause)'),
            const Text('intl - Dart Team (BSD-3-Clause)'),
            
            const SizedBox(height: 24),
            
            // 许可证文本
            const Text(
              'Apache License 2.0',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: FutureBuilder<String>(
                future: rootBundle.loadString('LICENSE'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(
                      '加载许可证文件失败: ${snapshot.error}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        height: 1.2,
                        color: Colors.red,
                      ),
                    );
                  }
                  return Text(
                    snapshot.data ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      height: 1.2,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 联系信息
            const Text(
              '联系信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text('项目名称: YIClass'),
            const Text('许可证: Apache License 2.0'),
            const Text('版权: © 2025 wykwey'),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}