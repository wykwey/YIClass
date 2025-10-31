import 'package:flutter/material.dart';

/// 纯文字提示工具类（透明背景）
class FeedbackUtils {
  static void show(BuildContext context, String message) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent, // 透明背景
        elevation: 0, // 去除阴影
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1000),
        content: Center(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.black, // 文字颜色
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}