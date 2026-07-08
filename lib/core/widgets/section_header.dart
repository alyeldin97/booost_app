import 'package:flutter/material.dart';
import '../styling/app_text_styles.dart';

/// Small icon-badge + title used to head up a form section — shared between
/// the client profile dialog and the task drawer for a consistent look.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.icon, required this.title, required this.color});
  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.subtitle),
      ],
    );
  }
}
