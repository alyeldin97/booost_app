import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../logic/client_stats.dart';

class ClientsTable extends StatelessWidget {
  const ClientsTable({
    super.key,
    required this.stats,
    required this.onRowTap,
    required this.onProfileTap,
  });

  final List<ClientStats> stats;
  final void Function(ClientStats) onRowTap;
  final void Function(ClientStats) onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: AppTextStyles.label,
          dataTextStyle: AppTextStyles.body,
          columns: const [
            DataColumn(label: Text('Client')),
            DataColumn(label: Text('Open')),
            DataColumn(label: Text('Overdue')),
            DataColumn(label: Text('Due this week')),
            DataColumn(label: Text('Completion')),
            DataColumn(label: Text('Next content')),
            DataColumn(label: Text('')),
          ],
          rows: stats
              .map((s) => DataRow(
                    onSelectChanged: (_) => onRowTap(s),
                    cells: [
                      DataCell(Text(s.client.name)),
                      DataCell(Text('${s.openCount}')),
                      DataCell(Text(
                        '${s.overdueCount}',
                        style: TextStyle(
                          color:
                              s.overdueCount > 0 ? AppColors.danger : AppColors.textPrimary,
                        ),
                      )),
                      DataCell(Text('${s.dueThisWeekCount}')),
                      DataCell(Text('${(s.completionPercent * 100).round()}%')),
                      DataCell(Text(
                        s.nextContentItem != null
                            ? '${s.nextContentItem!.title} · ${DateFormatters.dueDate(s.nextContentItem!.publishAt)}'
                            : '—',
                      )),
                      DataCell(IconButton(
                        tooltip: 'Filter tasks by this client',
                        icon: const Icon(LucideIcons.filter, size: 16),
                        onPressed: () => onProfileTap(s),
                      )),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }
}
