import 'package:flutter/material.dart';
import 'components.dart';

// ================== 常量定义 ==================
class _NotificationConstants {
  static const double defaultSpacing = 72.0;
  static const double defaultSonnerSpacing = 80.0;
  static const double bottomOffset = 60.0;
  static const double horizontalPadding = 20.0;
  static const Duration defaultDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double minCardWidth = 360.0;
  static const double maxCardWidth = 560.0;
  static const double cardBorderRadius = 12.0;
  static const double closeIconSize = 18.0;
  static const double closeButtonPadding = 4.0;
}

// ================== 通知卡片装饰 ==================
BoxDecoration _defaultNotificationDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(_NotificationConstants.cardBorderRadius),
    border: Border.all(
      color: Colors.grey[300]!,
      width: 1,
    ),
  );
}

// ================== 通知条目 ==================
class _NotificationEntry {
  final String id;
  final Widget card;
  
  _NotificationEntry({
    required this.id,
    required this.card,
  });
}

// ================== 通知管理器 ==================
class _NotificationsManager {
  static OverlayEntry? _entry;
  static OverlayState? _overlay;
  static bool _visible = false;
  static final List<_NotificationEntry> _entries = [];
  static double _spacing = _NotificationConstants.defaultSpacing;

  static bool _ensureOverlay(BuildContext context) {
    if (!context.mounted) return false;
    try {
      _overlay = Overlay.of(context);
    } catch (_) {
      return false;
    }
    return _overlay != null;
  }

  static NotificationHandle add(
    BuildContext context,
    _NotificationEntry entry, {
    double spacing = _NotificationConstants.defaultSpacing,
  }) {
    if (!_ensureOverlay(context)) {
      return NotificationHandle('');
    }
    
    _spacing = spacing;
    _entries.add(entry);
    
    if (!_visible) {
      _visible = true;
      _rebuild();
    } else {
      _rebuild();
    }
    
    return NotificationHandle(entry.id);
  }

  static void remove(String id) {
    _entries.removeWhere((e) => e.id == id);
    
    if (_entries.isEmpty) {
      _visible = false;
      try {
        _entry?.remove();
      } catch (_) {
        // 忽略移除错误
      }
      _entry = null;
      _overlay = null;
    } else {
      _rebuild();
    }
  }

  static void _rebuild() {
    if (_overlay == null) return;
    
    try {
      _entry?.remove();
      _entry = OverlayEntry(
        builder: (context) {
          return Stack(
            children: _entries.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final offset = _NotificationConstants.bottomOffset + 
                           index * _spacing;
              
              return Positioned(
                bottom: offset,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _NotificationConstants.horizontalPadding,
                    ),
                    child: item.card,
                  ),
                ),
              );
            }).toList(),
          );
        },
      );
      _overlay!.insert(_entry!);
    } catch (_) {
      _entry = null;
      _overlay = null;
      _visible = false;
      _entries.clear();
    }
  }
}

// ================== 通知句柄 ==================
class NotificationHandle {
  final String id;
  
  NotificationHandle(this.id);
  
  void dismiss() {
    _NotificationsManager.remove(id);
  }
}

// ================== 通知卡片 ==================
class _NotificationCard extends StatefulWidget {
  final String id;
  final String? title;
  final String? message;
  final Duration duration;
  final VoidCallback onClose;
  final String? actionText;
  final VoidCallback? onAction;

  const _NotificationCard({
    required this.id,
    this.title,
    this.message,
    required this.duration,
    required this.onClose,
    this.actionText,
    this.onAction,
    Key? key,
  }) : super(key: key);

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _NotificationConstants.animationDuration,
    );
    _slide = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    
    if (mounted) {
      _controller.forward();
      Future.delayed(widget.duration, () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    
    try {
      await _controller.reverse();
    } catch (e) {
      // 忽略动画错误
    }
    
    if (mounted) {
      widget.onClose();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _NotificationConstants.horizontalPadding,
                vertical: 16,
              ),
              constraints: BoxConstraints(
                minWidth: _NotificationConstants.minCardWidth,
                maxWidth: _NotificationConstants.maxCardWidth,
              ),
              decoration: _defaultNotificationDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildContent(),
                  ),
                  if (widget.actionText != null && widget.onAction != null) ...[
                    SizedBox(width: 16),
                    _buildActionButton(),
                  ],
                  SizedBox(width: 12),
                  _buildCloseButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null && widget.title!.isNotEmpty)
          Text(
            widget.title!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              height: 1.3,
              letterSpacing: 0.2,
            ),
          ),
        if (widget.title != null &&
            widget.title!.isNotEmpty &&
            widget.message != null &&
            widget.message!.isNotEmpty)
          SizedBox(height: 6),
        if (widget.message != null && widget.message!.isNotEmpty)
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700]!,
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton() {
    return YicoreButton(
      text: widget.actionText!,
      isOutlined: true,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      onPressed: widget.onAction,
    );
  }

  Widget _buildCloseButton() {
    return InkWell(
      onTap: _dismiss,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: EdgeInsets.all(_NotificationConstants.closeButtonPadding),
        child: Icon(
          Icons.close,
          size: _NotificationConstants.closeIconSize,
          color: Colors.grey[600] ?? Colors.grey,
        ),
      ),
    );
  }
}

// ================== 对外 API ==================
class Notifications {
  /// 显示一个 Sonner 风格的通知
  /// 
  /// [title] 通知标题（可选）
  /// [message] 通知消息（可选，但至少需要 title 或 message 之一）
  /// [duration] 通知显示时长，默认 3 秒
  /// [actionText] 操作按钮文本（可选）
  /// [onAction] 操作按钮回调（可选）
  /// [spacing] 多个通知之间的间距，默认 80.0
  /// 
  /// 返回 [NotificationHandle] 可用于手动关闭通知
  static NotificationHandle sonner(
    BuildContext context, {
    String? title,
    String? message,
    Duration duration = _NotificationConstants.defaultDuration,
    String? actionText,
    VoidCallback? onAction,
    double spacing = _NotificationConstants.defaultSonnerSpacing,
  }) {
    // 验证至少需要标题或消息之一
    if ((title == null || title.isEmpty) &&
        (message == null || message.isEmpty)) {
      return NotificationHandle('');
    }
    
    final id = 'sonner_${DateTime.now().microsecondsSinceEpoch}';
    final notificationId = id;
    
    final card = _NotificationCard(
      key: ValueKey(notificationId),
      id: notificationId,
      title: title,
      message: message,
      duration: duration,
      onClose: () {
        _NotificationsManager.remove(notificationId);
      },
      actionText: actionText,
      onAction: onAction,
    );
    
    return _NotificationsManager.add(
      context,
      _NotificationEntry(
        id: id,
        card: card,
      ),
      spacing: spacing,
    );
  }
}
