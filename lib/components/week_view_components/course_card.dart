import 'package:flutter/material.dart';
import '../../data/course.dart';
import '../../utils/color_utils.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool showWeekend;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.showWeekend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 课程总是有内容，不再需要isEmpty检查

    final baseColor = course.color != 0
        ? Color(course.color)
        : ColorUtils.getCourseColor(course.name);
    final textColor = ColorUtils.getContrastColor(baseColor);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey[200]!, width: 0.5),
            bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
        ),
        child: Container(
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final small = constraints.maxWidth < (showWeekend ? 80 : 100);

                    final nameStyle = TextStyle(
                      fontSize: small ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    );
                    final subStyle = TextStyle(
                      fontSize: small ? 11 : 13,
                      color: textColor,
                    );

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: nameStyle,
                            textAlign: TextAlign.left,
                            softWrap: true,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            course.teacher,
                            style: subStyle,
                            textAlign: TextAlign.left,
                            softWrap: true,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            course.location.isNotEmpty ? '@${course.location}' : '',
                            style: subStyle,
                            textAlign: TextAlign.left,
                            softWrap: true,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
