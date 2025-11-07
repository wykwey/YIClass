import 'package:flutter/material.dart';
import 'components.dart';

// ================== 课程项数据模型 ==================
class CourseItem {
  String id;
  String name;

  CourseItem({
    required this.id,
    required this.name,
  });
}

// ================== 课程选择器 ==================
class YicoreCourseSelector {
  /// 显示课程选择底部弹窗
  /// 返回选中的课程 ID，如果取消则返回 null
  static Future<String?> show(
    BuildContext context, {
    required List<CourseItem> courses,
    String? currentCourseId,
    String title = '选择课程',
  }) {
    if (!context.mounted) return Future.value(null);

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => _CourseSelectorSheet(
        courses: courses,
        currentCourseId: currentCourseId,
        title: title,
      ),
    );
  }
}

// ================== 课程选择器弹窗 ==================
class _CourseSelectorSheet extends StatelessWidget {
  final List<CourseItem> courses;
  final String? currentCourseId;
  final String title;

  const _CourseSelectorSheet({
    required this.courses,
    this.currentCourseId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(child: _buildCourseList(context)),
          ],
        ),
      ),
    );
  }

  // 构建标题栏
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          YicoreIconButton(
            icon: Icons.close,
            size: 36,
            showBorder: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // 构建课程列表
  Widget _buildCourseList(BuildContext context) {
    if (courses.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final isSelected = course.id == currentCourseId;
        return _buildCourseItem(context, course, isSelected);
      },
    );
  }

  // 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无课程',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建课程项
  Widget _buildCourseItem(
    BuildContext context,
    CourseItem course,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.black.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 课程名称（仅显示）
            Expanded(
              child: Text(
                course.name,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 编辑按钮
            YicoreButton(
              text: '编辑',
              isOutlined: true,
              onPressed: () {
                Navigator.pop(context, course.id);
              },
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ],
        ),
      ),
    );
  }
}
