import 'package:flutter/material.dart';
import '../../data/course.dart';
import '../../utils/color_utils.dart';
import '../../services/settings_service.dart';

class CourseCard extends StatefulWidget {
  final Course course;
  final bool showWeekend;
  final VoidCallback onTap;
  final bool hasConflict;

  const CourseCard({
    super.key,
    required this.course,
    required this.showWeekend,
    required this.onTap,
    this.hasConflict = false,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _disableAdaptiveFontColor = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.instance.loadSettings();
    if (mounted) {
      setState(() {
        _disableAdaptiveFontColor = settings.disableAdaptiveFontColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.course.color != 0
        ? Color(widget.course.color)
        : ColorUtils.getCourseColor(widget.course.name);
    final textColor = ColorUtils.getCourseTextColor(
      baseColor,
      disableAdaptive: _disableAdaptiveFontColor,
    );

    return InkWell(
      onTap: widget.onTap,
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
                margin: const EdgeInsets.all(1),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final small = constraints.maxWidth < (widget.showWeekend ? 80 : 100);

                    final nameStyle = TextStyle(
                      fontSize: small ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    );
                    final subStyle = TextStyle(
                      fontSize: small ? 11 : 13,
                      color: textColor,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.course.name,
                                  style: nameStyle,
                                  textAlign: TextAlign.left,
                                  softWrap: true,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.course.teacher,
                                  style: subStyle,
                                  textAlign: TextAlign.left,
                                  softWrap: true,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.course.location.isNotEmpty ? '@${widget.course.location}' : '',
                                  style: subStyle,
                                  textAlign: TextAlign.left,
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.hasConflict) ...[
                          const SizedBox(height: 4),
                          Text(
                            '冲突',
                            style: TextStyle(
                              fontSize: small ? 10 : 12,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
