import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../styling/app_colors.dart';
import '../styling/app_text_styles.dart';

enum ToastVariant { success, error, info }

class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    ToastVariant variant = ToastVariant.info,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final (color, icon) = switch (variant) {
      ToastVariant.success => (AppColors.success, LucideIcons.circleCheck),
      ToastVariant.error => (AppColors.danger, LucideIcons.circleAlert),
      ToastVariant.info => (AppColors.info, LucideIcons.info),
    };

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, variant: ToastVariant.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, variant: ToastVariant.error);

  static void info(BuildContext context, String message) =>
      show(context, message: message, variant: ToastVariant.info);
}
