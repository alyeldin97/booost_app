import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/styling/breakpoints.dart';
import '../../../../core/utils/app_enums.dart';
import '../cubits/filters_cubit.dart';
import '../cubits/workspace_cubit.dart';
import 'multi_select_dropdown.dart';

class FilterToolbar extends StatelessWidget {
  const FilterToolbar({super.key, required this.onFiltersChanged});

  /// Called whenever a filter mutates, so the owning shell can push the
  /// new state into the URL.
  final VoidCallback onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    final filters = context.watch<FiltersCubit>();
    final workspace = context.watch<WorkspaceCubit>().state;
    final isMobile = Breakpoints.isMobile(context);

    void toggleAndSync(void Function() mutate) {
      mutate();
      onFiltersChanged();
    }

    final children = <Widget>[
      MultiSelectDropdown<String>(
        label: 'Client',
        icon: LucideIcons.building2,
        options: workspace.clients
            .map((c) => MultiSelectOption(c.id, c.name,
                color: AppColors.clientColorFor(c.id)))
            .toList(),
        selected: filters.state.clientIds,
        onToggle: (id) => toggleAndSync(() => filters.toggleClient(id)),
      ),
      MultiSelectDropdown<String>(
        label: 'Assignee',
        icon: LucideIcons.users,
        options: workspace.profiles
            .map((p) => MultiSelectOption(p.id, p.displayName))
            .toList(),
        selected: filters.state.assigneeIds,
        onToggle: (id) => toggleAndSync(() => filters.toggleAssignee(id)),
      ),
      MultiSelectDropdown<String>(
        label: 'Status',
        icon: LucideIcons.circleDot,
        options: [
          for (var i = 0; i < workspace.boardColumns.length; i++)
            MultiSelectOption(
              workspace.boardColumns[i].status,
              workspace.boardColumns[i].title,
              color: AppColors.columnColorFor(i),
            ),
        ],
        selected: filters.state.statuses,
        onToggle: (s) => toggleAndSync(() => filters.toggleStatus(s)),
      ),
      MultiSelectDropdown<TaskPriority>(
        label: 'Priority',
        icon: LucideIcons.flag,
        options: TaskPriority.values
            .map((p) => MultiSelectOption(p, p.label, color: p.color))
            .toList(),
        selected: filters.state.priorities,
        onToggle: (p) => toggleAndSync(() => filters.togglePriority(p)),
      ),
      MultiSelectDropdown<String>(
        label: 'Type',
        icon: LucideIcons.tag,
        options: workspace.taskTypes
            .map((t) => MultiSelectOption(t.taskType, t.title))
            .toList(),
        selected: filters.state.taskTypes,
        onToggle: (t) => toggleAndSync(() => filters.toggleTaskType(t)),
      ),
      MultiSelectDropdown<String>(
        label: 'Platform',
        icon: LucideIcons.share2,
        options: workspace.platforms
            .map((p) => MultiSelectOption(p.platform, p.title))
            .toList(),
        selected: filters.state.platforms,
        onToggle: (p) => toggleAndSync(() => filters.togglePlatform(p)),
      ),
      _DateRangeButton(onFiltersChanged: onFiltersChanged),
      SizedBox(
        width: isMobile ? 160 : 220,
        height: 36,
        child: TextField(
          onChanged: (v) => toggleAndSync(() => filters.setSearch(v)),
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            prefixIcon: const Icon(LucideIcons.search, size: 16),
            isDense: true,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ),
      if (!filters.state.isEmpty)
        TextButton.icon(
          onPressed: () => toggleAndSync(filters.clearAll),
          icon: const Icon(LucideIcons.x, size: 15),
          label: const Text('Clear filters'),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
        ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final child in children) ...[
              child,
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({required this.onFiltersChanged});
  final VoidCallback onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    final filters = context.watch<FiltersCubit>();
    final range = filters.state.dateRange;
    final hasRange = range != null;
    final label = hasRange
        ? '${_fmt(range.start)} - ${_fmt(range.end)}'
        : 'Date range';

    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDateRange: range,
        );
        if (picked != null) {
          filters.setDateRange(picked);
          onFiltersChanged();
        }
      },
      icon: const Icon(LucideIcons.calendarRange, size: 15),
      label: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: hasRange ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: hasRange ? AppColors.primary : AppColors.border),
        backgroundColor: hasRange ? AppColors.primaryLight : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.month}/${d.day}';
}
