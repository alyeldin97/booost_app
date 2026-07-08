import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../styling/app_colors.dart';
import 'fancy_dialog.dart';

/// Single-text-field colorful prompt, used for "New column", "Rename",
/// "New client" and similar quick-name inputs across the app.
Future<String?> showFancyPromptDialog(
  BuildContext context, {
  required String title,
  required String label,
  String? initialValue,
  String confirmLabel = 'Save',
  IconData icon = LucideIcons.pencilLine,
  Color color = AppColors.primary,
  bool useRootNavigator = true,
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (dialogContext) => FancyDialog(
      title: title,
      icon: icon,
      color: color,
      width: 400,
      child: TextField(
        controller: controller,
        autofocus: true,
        decoration: fancyFieldDecoration(label, color: color),
        onSubmitted: (v) => Navigator.pop(dialogContext, v),
      ),
      actions: [
        FancyTextButton(label: 'Cancel', onPressed: () => Navigator.pop(dialogContext)),
        FancyFilledButton(
          label: confirmLabel,
          color: color,
          onPressed: () => Navigator.pop(dialogContext, controller.text),
        ),
      ],
    ),
  );
}
