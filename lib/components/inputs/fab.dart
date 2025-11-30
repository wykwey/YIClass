import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../states/timetable_state.dart';
import '../../services/file_service.dart';
import '../feedback/notifications.dart' show Notifications;

// ================== 悬浮窗菜单项 ==================
class YicoreFabItem {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const YicoreFabItem({
    required this.icon,
    this.label,
    this.onPressed,
    this.backgroundColor,
  });
}

// ================== 通用悬浮按钮 ==================
class YicoreFab extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final List<YicoreFabItem>? menuItems;
  final double size;

  const YicoreFab({
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.menuItems,
    this.size = 56.0,
    Key? key,
  }) : super(key: key);

  @override
  State<YicoreFab> createState() => _YicoreFabState();
}

class _YicoreFabState extends State<YicoreFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  Offset _position = const Offset(24, 24);
  bool _isExpanded = false;
  bool _isDragging = false;
  Offset _dragStartPosition = Offset.zero;
  
  static const double _dragThreshold = 5.0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_hasMenuItems) {
      setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) {
          _animationController.forward();
          _adjustPosition();
        } else {
          _animationController.reverse();
        }
      });
    } else {
      widget.onPressed?.call();
    }
  }

  void _closeMenu() {
    if (_isExpanded && mounted) {
      setState(() {
        _isExpanded = false;
        _animationController.reverse();
      });
    }
  }

  void _adjustPosition() {
    final screenSize = MediaQuery.of(context).size;
    final expandedHeight = _getExpandedHeight();
    
    setState(() {
      _position = Offset(
        _position.dx.clamp(0.0, screenSize.width - widget.size),
        _position.dy.clamp(0.0, screenSize.height - expandedHeight),
      );
    });
  }

  void _onPanStart(DragStartDetails details) {
    _dragStartPosition = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!mounted) return;
    
    final dragDistance = (details.globalPosition - _dragStartPosition).distance;
    
    if (!_isDragging && dragDistance > _dragThreshold) {
      setState(() => _isDragging = true);
      if (_isExpanded) _closeMenu();
    }
    
    if (_isDragging) {
      final screenSize = MediaQuery.of(context).size;
      final expandedHeight = _getExpandedHeight();
      setState(() {
        _position = Offset(
          (_position.dx - details.delta.dx).clamp(0.0, screenSize.width - widget.size),
          (_position.dy - details.delta.dy).clamp(0.0, screenSize.height - expandedHeight),
        );
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isDragging = false);
    });
  }

  bool get _hasMenuItems => 
      widget.menuItems != null && widget.menuItems!.isNotEmpty;

  double _getExpandedHeight() {
    if (!_hasMenuItems) return widget.size;
    return widget.size * (widget.menuItems!.length + 1) + 
           16.0 * widget.menuItems!.length;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: _position.dx,
          bottom: _position.dy,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isExpanded && _hasMenuItems) ..._buildMenuItems(),
              _buildMainButton(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems() {
    return widget.menuItems!.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: _MenuItemButton(
            size: widget.size,
            icon: item.icon,
            backgroundColor: item.backgroundColor ?? Colors.white,
            onTap: () {
              item.onPressed?.call();
              _closeMenu();
            },
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMainButton() {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: () {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() => _isDragging = false);
        });
      },
      child: _buildCircleButton(
        icon: _isExpanded ? Icons.close : widget.icon,
        backgroundColor: Colors.white,
        onTap: _isDragging ? null : _toggleMenu,
        rotation: _rotationAnimation,
        tooltip: !_isExpanded ? widget.tooltip : null,
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color backgroundColor,
    VoidCallback? onTap,
    Animation<double>? rotation,
    String? tooltip,
  }) {
    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(widget.size / 2),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: rotation != null
              ? RotationTransition(
                  turns: rotation,
                  child: Icon(icon, color: Colors.black.withValues(alpha: 0.85), size: widget.size * 0.5),
                )
              : Icon(icon, color: Colors.black.withValues(alpha: 0.85), size: widget.size * 0.5),
        ),
      ),
    );

    if (tooltip != null && tooltip.isNotEmpty) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }
}

// ================== 菜单项按钮 ==================
class _MenuItemButton extends StatefulWidget {
  final double size;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _MenuItemButton({
    required this.size,
    required this.icon,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  State<_MenuItemButton> createState() => _MenuItemButtonState();
}

class _MenuItemButtonState extends State<_MenuItemButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: Colors.black.withValues(alpha: 0.85),
              size: widget.size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ================== 课程操作悬浮按钮 ==================
class AddCourseFab extends StatelessWidget {
  final String? viewIdentifier;
  
  const AddCourseFab({super.key, this.viewIdentifier});

  Future<void> _importFromFile(BuildContext context) async {
    final ok = await FileService.importAndSave();
    if (!context.mounted) return;
    if (ok) {
      await Provider.of<TimetableState>(context, listen: false).reload();
      Notifications.sonner(context, message: '导入成功');
    } else {
      Notifications.sonner(context, message: '已取消或导入失败');
    }
  }

  Future<void> _exportToFile(BuildContext context) async {
    final timetableState = Provider.of<TimetableState>(context, listen: false);
    final current = timetableState.current;
    if (current == null) {
      Notifications.sonner(context, message: '请先选择一个课表');
      return;
    }
    final result = await FileService.exportTimetable(current);
    if (!context.mounted) return;
    if (result != null) {
      Notifications.sonner(context, message: '导出成功: $result');
    } else {
      Notifications.sonner(context, message: '已取消或当前平台不支持');
    }
  }

  @override
  Widget build(BuildContext context) {
    return YicoreFab(
      icon: Icons.add,
      tooltip: '快速操作',
      menuItems: [
        YicoreFabItem(
          icon: Icons.file_download,
          label: '导入',
          onPressed: () => _importFromFile(context),
        ),
        YicoreFabItem(
          icon: Icons.file_upload,
          label: '导出',
          onPressed: () => _exportToFile(context),
        ),
      ],
    );
  }
}
