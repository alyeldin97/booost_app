import 'package:flutter/material.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/utils/date_formatters.dart';
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
    builder: (_) => AlertDialog(
      title: Text(item.name),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.clientName != null) _Row('Client', item.clientName!),
              if (item.description != null && item.description!.trim().isNotEmpty)
                _Row('Description', item.description!),
              if (item.script != null && item.script!.trim().isNotEmpty)
                _Row('Script', item.script!),
              if (item.copy != null && item.copy!.trim().isNotEmpty)
                _Row('Copy', item.copy!),
              if (item.driveUrl != null && item.driveUrl!.trim().isNotEmpty)
                _Row('Drive URL', item.driveUrl!),
              if (item.deadline != null)
                _Row('Deadline', DateFormatters.dateTime(item.deadline!)),
              if (item.shouldBePublishedOn != null)
                _Row('Should be published on',
                    DateFormatters.dateTime(item.shouldBePublishedOn!)),
              if (item.assignee != null) _Row('Assignee', item.assignee!.displayName),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
