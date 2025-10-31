import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/timetable_state.dart';
import '../services/file_service.dart';
import '../utils/feedback_utils.dart';

class AddCourseFab extends StatefulWidget {
  final String? viewIdentifier;
  
  const AddCourseFab({super.key, this.viewIdentifier});

  @override
  State<AddCourseFab> createState() => _AddCourseFabState();
}

class _AddCourseFabState extends State<AddCourseFab> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  Offset _position = const Offset(16, 16); // 初始位置

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Future<void> _importFromFile() async {
    _toggleMenu();
    final ok = await FileService.importAndSave();
    if (!mounted) return;
    if (ok) {
      await Provider.of<TimetableState>(context, listen: false).reload();
      FeedbackUtils.show(context, '导入成功');
    } else {
      FeedbackUtils.show(context, '已取消或导入失败');
    }
  }

  Future<void> _exportToFile() async {
    _toggleMenu();
    final timetableState = Provider.of<TimetableState>(context, listen: false);
    final current = timetableState.current;
    if (current == null) {
      FeedbackUtils.show(context, '请先选择一个课表');
      return;
    }
    final result = await FileService.exportTimetable(current);
    if (!mounted) return;
    if (result != null) {
      FeedbackUtils.show(context, '导出成功: $result');
    } else {
      FeedbackUtils.show(context, '已取消或当前平台不支持');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        Positioned(
          right: _position.dx,
          bottom: _position.dy,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isExpanded) ...[
                _buildCircularButton(
                  icon: Icons.download,
                  onTap: _importFromFile,
                  showScale: true,
                ),
                const SizedBox(height: 16),
                _buildCircularButton(
                  icon: Icons.upload_file,
                  onTap: _exportToFile,
                  showScale: true,
                ),
                const SizedBox(height: 16),
              ],
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    final newX = _position.dx - details.delta.dx;
                    final newY = _position.dy - details.delta.dy;
                    
                    // 获取屏幕尺寸
                    final screenSize = MediaQuery.of(context).size;
                    final fabSize = 56.0; // FloatingActionButton 的默认大小
                    
                    // 统一使用展开状态下的总高度
                    final expandedHeight = fabSize * 3 + 16 * 2; // 3个按钮 + 2个间距
                    
                    // 限制在屏幕边界内
                    final minX = 0.0;
                    final maxX = screenSize.width - fabSize;
                    final minY = 0.0;
                    final maxY = screenSize.height - expandedHeight;
                    
                    _position = Offset(
                      newX.clamp(minX, maxX),
                      newY.clamp(minY, maxY),
                    );
                  });
                },
                child: _buildCircularButton(
                  icon: Icons.add,
                  onTap: _toggleMenu,
                  showScale: false,
                  child: RotationTransition(
                    turns: _rotateAnimation,
                    child: Icon(
                      Icons.add,
                      color: Colors.blue[700],
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool showScale,
    Widget? child,
    bool disabled = false,
  }) {
    // 创建唯一的 heroTag 避免冲突
    final heroTag = '${widget.viewIdentifier ?? 'default'}_fab_${icon.codePoint}';
    
    Widget button = FloatingActionButton(
      heroTag: heroTag,
      onPressed: disabled ? null : onTap,
      backgroundColor: disabled ? Colors.grey.shade300 : Colors.white,
      elevation: disabled ? 1 : 4,
      child: child ?? Icon(
        icon,
        color: disabled ? Colors.grey.shade500 : Colors.blue.shade400,
        size: 28,
      ),
    );

    if (showScale) {
      button = ScaleTransition(
        scale: _scaleAnimation,
        child: button,
      );
    }

    return button;
  }
}