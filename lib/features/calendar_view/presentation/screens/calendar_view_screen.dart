import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/async_state_switcher.dart';
import '../../../../core/widgets/timeline/timeline_view.dart';
import '../../../task_drawer/presentation/cubits/task_drawer_cubit.dart';
import '../../../workspace/logic/task_filtering.dart';
import '../../../workspace/presentation/cubits/filters_cubit.dart';
import '../../../workspace/presentation/cubits/workspace_cubit.dart';
import '../../logic/calendar_event.dart';
import '../cubits/calendar_view_cubit.dart';
import '../widgets/month_grid_view.dart';

class CalendarViewScreen extends StatelessWidget {
  const CalendarViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalendarViewCubit(),
      child: const _CalendarViewBody(),
    );
  }
}

class _CalendarViewBody extends StatelessWidget {
  const _CalendarViewBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceCubit, WorkspaceCubitState>(
      builder: (context, workspace) {
        return BlocBuilder<FiltersCubit, FiltersState>(
          builder: (context, filters) {
            return BlocBuilder<CalendarViewCubit, CalendarViewState>(
              builder: (context, calState) {
                return AsyncStateSwitcher<WorkspaceCubitState>(
                  status: switch (workspace.status) {
                    WorkspaceStatus.initial => AsyncStatus.initial,
                    WorkspaceStatus.loading => AsyncStatus.loading,
                    WorkspaceStatus.success => AsyncStatus.success,
                    WorkspaceStatus.failure => AsyncStatus.failure,
                  },
                  data: workspace,
                  isEmpty: workspace.status != WorkspaceStatus.success &&
                      workspace.tasks.isEmpty &&
                      workspace.contentItems.isEmpty,
                  emptyIcon: LucideIcons.calendar,
                  emptyTitle: 'Nothing scheduled',
                  errorMessage: workspace.errorMessage,
                  onRetry: () => context.read<WorkspaceCubit>().load(),
                  builder: (data) => (context) {
                    final filteredTasks = filterTasks(data.tasks, filters)
                        .where((t) => t.dueDate != null);
                    final filteredContent =
                        filterContentItems(data.contentItems, filters);

                    final events = <CalendarEvent>[
                      if (calState.toggle != ItemToggle.contentOnly)
                        ...filteredTasks.map(CalendarEvent.fromTask),
                      if (calState.toggle != ItemToggle.tasksOnly)
                        ...filteredContent.map(CalendarEvent.fromContentItem),
                    ];

                    final eventsByDay = <DateTime, List<CalendarEvent>>{};
                    for (final e in events) {
                      eventsByDay.putIfAbsent(dateOnly(e.date), () => []).add(e);
                    }

                    return Column(
                      children: [
                        _CalendarToolbar(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: switch (calState.mode) {
                              CalendarDisplayMode.month => SingleChildScrollView(
                                  child: MonthGridView(
                                    focusedDay: calState.focusedDay,
                                    selectedDay: calState.focusedDay,
                                    eventsByDay: eventsByDay,
                                    onDaySelected: (d) =>
                                        context.read<CalendarViewCubit>().setFocusedDay(d),
                                    onEventTap: (e) => _onEventTap(context, e),
                                  ),
                                ),
                              CalendarDisplayMode.week => TimelineView(
                                  days: _weekDays(calState.focusedDay),
                                  eventsByDay: eventsByDay,
                                  onEventTap: (e) => _onEventTap(context, e),
                                ),
                              CalendarDisplayMode.day => TimelineView(
                                  days: [calState.focusedDay],
                                  eventsByDay: eventsByDay,
                                  onEventTap: (e) => _onEventTap(context, e),
                                ),
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  List<DateTime> _weekDays(DateTime focusedDay) {
    final start = focusedDay.subtract(Duration(days: focusedDay.weekday - 1));
    return List.generate(7, (i) => DateTime(start.year, start.month, start.day + i));
  }

  void _onEventTap(BuildContext context, CalendarEvent e) {
    if (e.isTask && e.task != null) {
      context.read<TaskDrawerCubit>().open(e.task!.id);
    } else if (e.contentItem?.taskId != null) {
      context.read<TaskDrawerCubit>().open(e.contentItem!.taskId!);
    } else {
      AppToast.info(context,
          '${e.title} — publishes ${DateFormatters.dateTime(e.date)}');
    }
  }
}

class _CalendarToolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalendarViewCubit>();
    final state = context.watch<CalendarViewCubit>().state;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, size: 18),
            onPressed: cubit.goPrevious,
          ),
          TextButton(onPressed: cubit.goToday, child: const Text('Today')),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight, size: 18),
            onPressed: cubit.goNext,
          ),
          const SizedBox(width: 12),
          Text(DateFormatters.monthYear(state.focusedDay), style: AppTextStyles.subtitle),
          const Spacer(),
          SegmentedButton<CalendarDisplayMode>(
            segments: const [
              ButtonSegment(value: CalendarDisplayMode.month, label: Text('Month')),
              ButtonSegment(value: CalendarDisplayMode.week, label: Text('Week')),
              ButtonSegment(value: CalendarDisplayMode.day, label: Text('Day')),
            ],
            selected: {state.mode},
            onSelectionChanged: (s) => cubit.setMode(s.first),
          ),
          const SizedBox(width: 12),
          SegmentedButton<ItemToggle>(
            segments: const [
              ButtonSegment(value: ItemToggle.all, label: Text('All')),
              ButtonSegment(value: ItemToggle.tasksOnly, label: Text('Tasks')),
              ButtonSegment(value: ItemToggle.contentOnly, label: Text('Content')),
            ],
            selected: {state.toggle},
            onSelectionChanged: (s) => cubit.setToggle(s.first),
          ),
        ],
      ),
    );
  }
}
