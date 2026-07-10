import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/styling/breakpoints.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../data/model/content_creation_item_model.dart';

class ContentCreationCard extends StatelessWidget {
  const ContentCreationCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDuplicate,
    this.onDelete,
  });

  final ContentCreationItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final clientColor = item.clientColor != null
        ? _colorFromHex(item.clientColor!)
        : (item.clientId != null ? AppColors.clientColorFor(item.clientId!) : AppColors.border);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: Breakpoints.isMobile(context)
              ? MediaQuery.sizeOf(context).width - 64
              : 260,
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
                color: clientColor.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.clientName != null || onDuplicate != null || onDelete != null) ...[
                Row(
                  children: [
                    if (item.clientName != null)
                      Expanded(
                        child: Text(item.clientName!,
                            style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
                      )
                    else
                      const Spacer(),
                    if (onDuplicate != null)
                      IconButton(
                        tooltip: 'Duplicate',
                        icon: const Icon(LucideIcons.copy, size: 15),
                        visualDensity: VisualDensity.compact,
                        onPressed: onDuplicate,
                      ),
                    if (onDelete != null)
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(LucideIcons.trash2, size: 15, color: AppColors.danger),
                        visualDensity: VisualDensity.compact,
                        onPressed: onDelete,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Text(
                item.name,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.description != null && item.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.description!,
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  if (item.shouldBePublishedOn != null) ...[
                    const Icon(LucideIcons.calendar, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatters.dueDate(item.shouldBePublishedOn!),
                      style: AppTextStyles.caption,
                    ),
                  ],
                  const Spacer(),
                  if (item.assignee != null)
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        item.assignee!.initials,
                        style: AppTextStyles.label
                            .copyWith(fontSize: 9, color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ],
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
