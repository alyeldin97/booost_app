import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../styling/app_colors.dart';
import '../styling/app_text_styles.dart';
import 'fancy_dialog.dart';

/// Colorful confirm/cancel dialog, defaulting to a "danger" accent since
/// it's most commonly used for delete confirmations.
Future<bool> showFancyConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  IconData icon = LucideIcons.triangleAlert,
  Color color = AppColors.danger,
  bool useRootNavigator = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (dialogContext) => FancyDialog(
      title: title,
      icon: icon,
      color: color,
      width: 400,
      child: Text(message, style: AppTextStyles.body),
      actions: [
        FancyTextButton(
          label: 'Cancel',
          onPressed: () => Navigator.pop(dialogContext, false),
        ),
        FancyFilledButton(
          label: confirmLabel,
          color: color,
          onPressed: () => Navigator.pop(dialogContext, true),
        ),
      ],
    ),
  );
  return result ?? false;
}
