import 'package:flutter/material.dart';

// ================== 自定义开关 ==================
class YicoreSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const YicoreSwitch({required this.value, required this.onChanged, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 120),
        width: 50,
        height: 28,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value ? Colors.black : Colors.grey[300],
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 120),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ================== 自定义滑块 ==================
class YicoreSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final double? width;

  const YicoreSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.width,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double trackHeight = 8;
    const double ballSize = 20;
    final double totalWidth = width ?? 250;

    double normalized = ((value - min) / (max - min)).clamp(0.0, 1.0);
    // 圆球中心位置
    double ballCenterX = normalized * (totalWidth - ballSize) + ballSize / 2;
    // 进度条宽度到圆球中心
    double progressWidth = ballCenterX;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // 使用 localPosition 避免每次拖动都进行全局坐标转换和 RenderObject 查询
        double localX = details.localPosition.dx;
        // 限制 localX 在有效范围内，防止小球拖出进度条
        localX = localX.clamp(ballSize / 2, totalWidth - ballSize / 2);
        double newValue =
            ((localX - ballSize / 2) / (totalWidth - ballSize)) * (max - min) +
                min;
        onChanged(newValue.clamp(min, max));
      },
      child: SizedBox(
        width: totalWidth,
        height: ballSize,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // 背景轨道
            Container(
              height: trackHeight,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(trackHeight / 2),
              ),
            ),
            // 黑色进度条
            Container(
              width: progressWidth,
              height: trackHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(trackHeight / 2),
              ),
            ),
            // 滑块小球
            Positioned(
              left: normalized * (totalWidth - ballSize),
              child: Container(
                width: ballSize,
                height: ballSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== 自定义按钮 ==================
class YicoreButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isSecondary;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final double? width;

  const YicoreButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isSecondary = false,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.width,
    Key? key,
  }) : super(key: key);

  @override
  _YicoreButtonState createState() => _YicoreButtonState();
}

class _YicoreButtonState extends State<YicoreButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 变体配色：优先加载态，其次 outlined/secondary，再到 primary
    Color defaultPrimary = Colors.black.withValues(alpha: 0.85);
    Color defaultSecondaryBg = Colors.grey[200]!;
    Color defaultSecondaryText = Colors.black.withValues(alpha: 0.85);

    final bool outlined = widget.isOutlined;
    final bool secondary = widget.isSecondary;

    Color effectiveBgColor;
    Color effectiveTextColor;
    Color borderColor = Colors.transparent;

    if (widget.isLoading) {
      effectiveBgColor = Colors.grey[300]!;
      effectiveTextColor = Colors.grey[600]!;
      borderColor = Colors.transparent;
    } else if (outlined) {
      effectiveBgColor = Colors.transparent;
      effectiveTextColor = widget.textColor ?? Colors.black.withValues(alpha: 0.85);
      borderColor = Colors.black.withValues(alpha: 0.4);
    } else if (secondary) {
      effectiveBgColor = widget.backgroundColor ?? defaultSecondaryBg;
      effectiveTextColor = widget.textColor ?? defaultSecondaryText;
      borderColor = Colors.transparent;
    } else {
      // primary
      effectiveBgColor = widget.backgroundColor ?? defaultPrimary;
      effectiveTextColor = widget.textColor ?? Colors.white;
      borderColor = Colors.transparent;
    }

    return SizedBox(
      width: widget.width,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                padding: widget.padding ??
                    EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: effectiveBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor,
                    width: outlined ? 1 : 1,
                  ),
                  boxShadow: [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isLoading) ...[
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(effectiveTextColor),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.onPressed == null || widget.isLoading
                            ? effectiveTextColor.withValues(alpha: 0.6)
                            : effectiveTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ================== 自定义输入框 ==================
class YicoreTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final bool enabled;
  final String? errorText;
  final TextInputType? keyboardType;

  const YicoreTextField({
    this.hintText,
    this.labelText,
    this.controller,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.errorText,
    this.keyboardType,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 16,
            color: enabled ? Colors.black : Colors.grey[400],
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.black,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            errorText: errorText,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ================== 自定义图标按钮 ==================
class YicoreIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;
  final bool showBorder;

  const YicoreIconButton({
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.iconColor,
    this.showBorder = true,
    Key? key,
  }) : super(key: key);

  @override
  _YicoreIconButtonState createState() => _YicoreIconButtonState();
}

class _YicoreIconButtonState extends State<YicoreIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: widget.showBorder
                    ? Border.all(
                        color: widget.onPressed == null
                            ? (widget.iconColor ?? Colors.black).withValues(alpha: 0.2)
                            : (widget.iconColor ?? Colors.black).withValues(alpha: 0.4),
                        width: 1,
                      )
                    : null,
              ),
              child: Icon(
                widget.icon,
                size: widget.size * 0.5,
                color: widget.onPressed == null
                    ? (widget.iconColor ?? Colors.black).withValues(alpha: 0.3)
                    : (widget.iconColor ?? Colors.black).withValues(alpha: 0.85),
              ),
            ),
          );
        },
      ),
    );
  }
}
