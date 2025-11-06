import 'package:flutter/material.dart';
import 'components.dart';

// 统一样式
const _kDialogTitleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);
final _kDialogContentStyle = TextStyle(
  fontSize: 14,
  color: Colors.grey[700],
  height: 1.5,
);
final _kDividerColor = Colors.grey[200]!;

Future<T?> _showBasicDialog<T>(
  BuildContext context, {
  required String title,
  required String message,
  required List<Widget> Function(BuildContext dialogContext) actionsBuilder,
  bool barrierDismissible = true,
}) {
  if (!context.mounted) return Future.value(null);
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: true,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(title, style: _kDialogTitleStyle),
        content: Text(message, style: _kDialogContentStyle),
        actions: actionsBuilder(dialogContext),
      );
    },
  );
}

Dialog _modalDialog(
  BuildContext dialogContext, {
  String? title,
  required Widget child,
  Widget? footer,
  EdgeInsets? padding,
  double? width,
  double? height,
}) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    clipBehavior: Clip.antiAlias,
    child: Container(
      color: Colors.white,
      width: width ?? 400,
      height: height,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(dialogContext).size.width * 0.9,
        maxHeight: MediaQuery.of(dialogContext).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: _kDividerColor, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: _kDialogTitleStyle,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(dialogContext, rootNavigator: true).pop(),
                    child: Icon(
                      Icons.close,
                      size: 24,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
          Flexible(
            child: SingleChildScrollView(
              padding: padding ?? EdgeInsets.all(20),
              child: child,
            ),
          ),
          if (footer != null) ...[
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: _kDividerColor, width: 1),
                ),
              ),
              child: footer,
            ),
          ],
        ],
      ),
    ),
  );
}

// ================== Alert 对话框 ==================
class YicoreAlert {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) async {
    await _showBasicDialog<void>(
      context,
      title: title,
      message: message,
      barrierDismissible: barrierDismissible,
      actionsBuilder: (dialogContext) => [
        Padding(
          padding: EdgeInsets.only(right: 8, bottom: 8),
          child: YicoreButton(
            text: confirmText ?? '确定',
            onPressed: () {
              Navigator.of(dialogContext, rootNavigator: true).pop();
              if (context.mounted) onConfirm?.call();
            },
          ),
        ),
      ],
    );
  }
}

// ================== Confirm 确认对话框 ==================
class YicoreConfirm {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) async {
    final result = await _showBasicDialog<bool>(
      context,
      title: title,
      message: message,
      barrierDismissible: barrierDismissible,
      actionsBuilder: (dialogContext) => [
        Padding(
          padding: EdgeInsets.only(right: 8, bottom: 8),
          child: YicoreButton(
            text: cancelText ?? '取消',
            isOutlined: true,
            onPressed: () {
              Navigator.of(dialogContext, rootNavigator: true).pop(false);
              if (context.mounted) onCancel?.call();
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 8, bottom: 8),
          child: YicoreButton(
            text: confirmText ?? '确定',
            onPressed: () {
              Navigator.of(dialogContext, rootNavigator: true).pop(true);
              if (context.mounted) onConfirm?.call();
            },
          ),
        ),
      ],
    );
    return result ?? false;
  }
}

// ================== Modal 模态对话框 ==================
class YicoreModal {
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    Widget? footer,
    bool barrierDismissible = true,
    EdgeInsets? padding,
    double? width,
    double? height,
  }) async {
    if (!context.mounted) return null;
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        return _modalDialog(
          dialogContext,
          title: title,
          child: child,
          footer: footer,
          padding: padding,
          width: width,
          height: height,
        );
      },
    );
  }
}

// ================== 公告对话框 ==================
class YicoreAnnouncement {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String primaryText = '我知道了',
    String secondaryText = '稍后',
    VoidCallback? onPrimary,
    VoidCallback? onSecondary,
    bool barrierDismissible = true,
  }) async {
    await _showBasicDialog<void>(
      context,
      title: title,
      message: message,
      barrierDismissible: barrierDismissible,
      actionsBuilder: (dialogContext) => [
        Padding(
          padding: EdgeInsets.only(right: 8, bottom: 8),
          child: YicoreButton(
            text: secondaryText,
            isOutlined: true,
            onPressed: () {
              Navigator.of(dialogContext, rootNavigator: true).pop();
              if (context.mounted) onSecondary?.call();
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 8, bottom: 8),
          child: YicoreButton(
            text: primaryText,
            onPressed: () {
              Navigator.of(dialogContext, rootNavigator: true).pop();
              if (context.mounted) onPrimary?.call();
            },
          ),
        ),
      ],
    );
  }
}

// ================== Dialog 类型枚举 ==================
enum DialogType {
  alert,
  confirm,
  modal,
}
