import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/utils/app_enums.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../content_calendar/data/model/content_item_model.dart';
import '../../../tasks/data/model/task_model.dart';
import '../../data/model/board_column_model.dart';

class KanbanCard extends StatelessWidget {
  const KanbanCard({
    super.key,
    required this.task,
    required this.linkedContentItem,
    required this.allColumns,
    this.isDragging = false,
    this.onTap,
    this.onMoveTo,
  });

  final TaskModel task;
  final ContentItemModel? linkedContentItem;
  final List<BoardColumnModel> allColumns;
  final bool isDragging;
  final VoidCallback? onTap;
  final void Function(String)? onMoveTo;

  @override
  Widget build(BuildContext context) {
    final overdue = DateFormatters.isOverdue(task.dueDate);
    final clientColor = task.clientColor != null
        ? _colorFromHex(task.clientColor!)
        : AppColors.clientColorFor(task.clientId);

    return Semantics(
      button: true,
      label: 'Task ${task.title}',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border(
                left: BorderSide(color: clientColor, width: 4),
                top: BorderSide(color: clientColor.withValues(alpha: 0.28)),
                right: BorderSide(color: clientColor.withValues(alpha: 0.28)),
                bottom: BorderSide(color: clientColor.withValues(alpha: 0.28)),
              ),
              boxShadow: [
                BoxShadow(
                  color: clientColor.withValues(alpha: 0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: clientColor.withValues(alpha: 0.15),
                      child: Text(
                        (task.clientName ?? '?').trim().isNotEmpty
                            ? task.clientName![0].toUpperCase()
                            : '?',
                        style: AppTextStyles.label.copyWith(color: clientColor),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        task.clientName ?? '',
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onMoveTo != null)
                      PopupMenuButton<String>(
                        tooltip: 'Move to...',
                        icon: const Icon(LucideIcons.moreHorizontal, size: 16),
                        onSelected: onMoveTo,
                        itemBuilder: (context) => allColumns
                            .where((c) => c.status != task.status)
                            .map((c) => PopupMenuItem(
                                  value: c.status,
                                  child: Text('Move to ${c.title}'),
                                ))
                            .toList(),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  task.title,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Chip(label: task.taskType),
                    _PriorityChip(priority: task.priority),
                    if (linkedContentItem != null)
                      _Chip(
                        label: linkedContentItem!.approvalStatus.label,
                        color: linkedContentItem!.approvalStatus.color,
                      ),
                  ],
                ),
                if (task.platforms.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: task.platforms.take(4).map((p) {
                      final (icon, color) = platformStyle(p);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(icon, size: 11, color: color),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (task.dueDate != null) ...[
                      Icon(LucideIcons.calendar,
                          size: 12,
                          color: overdue ? AppColors.danger : AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatters.dueDate(task.dueDate!),
                        style: AppTextStyles.caption.copyWith(
                          color: overdue ? AppColors.danger : AppColors.textSecondary,
                          fontWeight: overdue ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (task.assignees.isNotEmpty)
                      SizedBox(
                        height: 20,
                        child: Stack(
                          children: [
                            for (var i = 0; i < task.assignees.take(3).length; i++)
                              Positioned(
                                left: i * 14.0,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: AppColors.primaryLight,
                                  child: Text(
                                    task.assignees[i].initials,
                                    style: AppTextStyles.label
                                        .copyWith(fontSize: 9, color: AppColors.primary),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _colorFromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse('FF$cleaned', radix: 16);
    return value != null ? Color(value) : AppColors.primary;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.color});
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppTextStyles.label.copyWith(color: c)),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.flag, size: 10, color: priority.color),
          const SizedBox(width: 3),
          Text(priority.label, style: AppTextStyles.label.copyWith(color: priority.color)),
        ],
      ),
    );
  }
}
