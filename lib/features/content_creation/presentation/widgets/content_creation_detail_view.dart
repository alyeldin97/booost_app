import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/fancy_dialog.dart';
import '../../data/model/content_creation_item_model.dart';

/// Read-only view used by the Content Calendar tab — the Content Calendar
/// no longer supports creating/editing content directly; that happens on
/// the Content Creation board. This is just for glancing at a card's
/// details from the calendar.
Future<void> showContentCreationDetailView(
  BuildContext context, {
  required ContentCreationItemModel item,
}) {
  return showDialog(
    context: context,
    useRootNavigator: false,
    builder: (_) => FancyDialog(
      title: item.name,
      icon: LucideIcons.clapperboard,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6D28D9), Color(0xFFDB2777)],
      ),
      width: 440,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.clientName != null)
            _Row(LucideIcons.building2, 'Client', item.clientName!),
          if (item.description != null && item.description!.trim().isNotEmpty)
            _Row(LucideIcons.lightbulb, 'Description', item.description!),
          if (item.script != null && item.script!.trim().isNotEmpty)
            _Row(LucideIcons.fileText, 'Script', item.script!),
          if (item.copy != null && item.copy!.trim().isNotEmpty)
            _Row(LucideIcons.penLine, 'Copy', item.copy!),
          if (item.driveUrl != null && item.driveUrl!.trim().isNotEmpty)
            _Row(LucideIcons.link, 'Drive URL', item.driveUrl!),
          if (item.deadline != null)
            _Row(LucideIcons.clock, 'Deadline', DateFormatters.dateTime(item.deadline!)),
          if (item.shouldBePublishedOn != null)
            _Row(LucideIcons.calendarClock, 'Should be published on',
                DateFormatters.dateTime(item.shouldBePublishedOn!)),
          if (item.assignee != null)
            _Row(LucideIcons.userRound, 'Assignee', item.assignee!.displayName),
        ],
      ),
      actions: [
        FancyFilledButton(label: 'Close', onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.label.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
