import 'package:flutter/material.dart';

// ================== 下拉选项 ==================
class YicoreDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const YicoreDropdownItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

// ================== 下拉选择器 ==================
class YicoreDropdown<T> extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final T? value;
  final List<YicoreDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final String? errorText;

  const YicoreDropdown({
    this.labelText,
    this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.enabled = true,
    this.errorText,
    Key? key,
  }) : super(key: key);

  @override
  State<YicoreDropdown<T>> createState() => _YicoreDropdownState<T>();
}

class _YicoreDropdownState<T> extends State<YicoreDropdown<T>> {
  final GlobalKey _dropdownKey = GlobalKey();
  bool _isExpanded = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;
    _isExpanded ? _closeDropdown() : _openDropdown();
  }

  void _openDropdown() {
    if (_isExpanded) return;
    final renderBox = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeDropdown,
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: offset.dy + size.height + 4,
                width: size.width,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      constraints: BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 4),
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) => _buildMenuItem(widget.items[index]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isExpanded = true);
  }

  void _closeDropdown() {
    if (!_isExpanded) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isExpanded = false);
  }

  Widget _buildMenuItem(YicoreDropdownItem<T> item) {
    final isSelected = item.value == widget.value;
    return InkWell(
      onTap: () {
        widget.onChanged?.call(item.value);
        _closeDropdown();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 20, color: isSelected ? Colors.black : Colors.grey[700]),
              SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.black : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check, size: 20, color: Colors.black),
          ],
        ),
      ),
    );
  }

  YicoreDropdownItem<T>? get _selectedItem {
    if (widget.value == null) return null;
    try {
      return widget.items.firstWhere((item) => item.value == widget.value);
    } catch (e) {
      return null;
    }
  }

  Color get _borderColor {
    if (widget.errorText != null) return Colors.red[300]!;
    if (_isExpanded) return Colors.black;
    return widget.enabled ? Colors.grey[300]! : Colors.grey[200]!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: widget.enabled ? _toggleDropdown : null,
          child: Container(
            key: _dropdownKey,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.enabled ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor, width: _isExpanded ? 2 : 1),
            ),
            child: Row(
              children: [
                if (_selectedItem?.icon != null) ...[
                  Icon(
                    _selectedItem!.icon!,
                    size: 20,
                    color: widget.enabled ? Colors.black87 : Colors.grey[400],
                  ),
                  SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    _selectedItem?.label ?? widget.hintText ?? '请选择',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedItem != null
                          ? (widget.enabled ? Colors.black : Colors.grey[600])
                          : Colors.grey[400],
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                  color: widget.enabled ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: TextStyle(fontSize: 12, color: Colors.red[600]),
          ),
        ],
      ],
    );
  }
}

