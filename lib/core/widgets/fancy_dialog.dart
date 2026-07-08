import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../styling/app_colors.dart';
import '../styling/app_text_styles.dart';

/// Shared dialog chrome used across the app for a consistent, colorful
/// look: a gradient header (icon + title + close), a soft body, and a
/// bottom action row. Individual dialogs supply their own form content as
/// [child] and their own [actions].
class FancyDialog extends StatelessWidget {
  const FancyDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.actions = const [],
    this.color,
    this.gradient,
    this.width = 460,
    this.maxHeight = 640,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final List<Widget> actions;
  final Color? color;
  final Gradient? gradient;
  final double width;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight),
        child: Material(
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                decoration: BoxDecoration(
                  gradient: gradient ??
                      LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [accent, accent.withValues(alpha: 0.65)],
                      ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(title,
                          style: AppTextStyles.h3.copyWith(color: Colors.white)),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(child: child),
                ),
              ),
              if (actions.isNotEmpty)
                Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (var i = 0; i < actions.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        actions[i],
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Consistent filled+rounded input decoration used inside FancyDialog forms.
InputDecoration fancyFieldDecoration(
  String label, {
  String? hint,
  Color color = AppColors.primary,
}) =>
    InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: 1.6),
      ),
    );

/// Pill-shaped filled button used for the primary action in FancyDialog
/// footers, tinted to match the dialog's accent color.
class FancyFilledButton extends StatelessWidget {
  const FancyFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    final button = FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      icon: icon != null ? Icon(icon, size: 16) : const SizedBox.shrink(),
      label: Text(label),
    );
    return button;
  }
}

class FancyTextButton extends StatelessWidget {
  const FancyTextButton({super.key, required this.label, required this.onPressed, this.color});
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: color ?? AppColors.textSecondary),
      child: Text(label),
    );
  }
}
