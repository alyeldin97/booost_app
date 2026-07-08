import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../logic/client_stats.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({
    super.key,
    required this.stats,
    required this.onTap,
    required this.onProfileTap,
  });

  final ClientStats stats;
  final VoidCallback onTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.clientColorFor(stats.client.id);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Text(stats.client.initials,
                        style: AppTextStyles.subtitle.copyWith(color: color)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(stats.client.name,
                        style: AppTextStyles.h3, overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    tooltip: 'Filter tasks by this client',
                    icon: const Icon(LucideIcons.filter, size: 16),
                    visualDensity: VisualDensity.compact,
                    onPressed: onProfileTap,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Stat(label: 'Open', value: '${stats.openCount}'),
                  _Stat(
                    label: 'Overdue',
                    value: '${stats.overdueCount}',
                    color: stats.overdueCount > 0 ? AppColors.danger : null,
                  ),
                  _Stat(label: 'Due this week', value: '${stats.dueThisWeekCount}'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Completion', style: AppTextStyles.caption),
                  const Spacer(),
                  Text('${(stats.completionPercent * 100).round()}%',
                      style: AppTextStyles.bodyMedium),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: stats.completionPercent,
                  minHeight: 6,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation(AppColors.success),
                ),
              ),
              const SizedBox(height: 12),
              if (stats.nextContentItem != null)
                Row(
                  children: [
                    const Icon(LucideIcons.megaphone,
                        size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${stats.nextContentItem!.title} · ${DateFormatters.dueDate(stats.nextContentItem!.publishAt)}',
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              else
                Text('No upcoming content', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: AppTextStyles.h3.copyWith(color: color ?? AppColors.textPrimary)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
