import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/async_state_switcher.dart';
import '../../../../core/widgets/timeline/timeline_view.dart';
import '../../../calendar_view/logic/calendar_event.dart';
import '../../../content_creation/presentation/widgets/content_creation_detail_view.dart';
import '../../../content_creation/presentation/widgets/content_creation_list_view.dart';
import '../../../workspace/presentation/cubits/workspace_cubit.dart';
import '../cubits/content_calendar_cubit.dart';
import '../widgets/content_month_grid.dart';

/// Read-only: content is created and managed on the Content Creation
/// board. This tab is purely a calendar-shaped view over those cards,
/// keyed by "should be published on".
class ContentCalendarScreen extends StatelessWidget {
  const ContentCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContentCalendarCubit(),
      child: const _ContentCalendarBody(),
    );
  }
}

class _ContentCalendarBody extends StatelessWidget {
  const _ContentCalendarBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceCubit, WorkspaceCubitState>(
      builder: (context, workspace) {
        return BlocBuilder<ContentCalendarCubit, ContentCalendarState>(
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
                  workspace.contentCreationItems.isEmpty,
              emptyIcon: LucideIcons.megaphone,
              emptyTitle: 'No content scheduled',
              emptyMessage: 'Cards with a "Should be published on" date show up here.',
              errorMessage: workspace.errorMessage,
              onRetry: () => context.read<WorkspaceCubit>().load(),
              builder: (data) => (context) {
                final items = data.contentCreationItems
                    .where((i) => i.shouldBePublishedOn != null)
                    .toList();
                final events = items.map(CalendarEvent.fromContentCreationItem).toList();
                final eventsByDay = <DateTime, List<CalendarEvent>>{};
                for (final e in events) {
                  eventsByDay.putIfAbsent(dateOnly(e.date), () => []).add(e);
                }

                void onEventTap(CalendarEvent e) {
                  if (e.contentCreationItem != null) {
                    showContentCreationDetailView(context, item: e.contentCreationItem!);
                  }
                }

                return Column(
                  children: [
                    const _Toolbar(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: switch (calState.mode) {
                          ContentDisplayMode.month => ContentMonthGrid(
                              focusedDay: calState.focusedDay,
                              eventsByDay: eventsByDay,
                              onEventTap: onEventTap,
                              readOnly: true,
                            ),
                          ContentDisplayMode.week => TimelineView(
                              days: _weekDays(calState.focusedDay),
                              eventsByDay: eventsByDay,
                              onEventTap: onEventTap,
                            ),
                          ContentDisplayMode.list => ContentCreationListView(
                              items: items,
                              onItemTap: (item) =>
                                  showContentCreationDetailView(context, item: item),
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
  }

  List<DateTime> _weekDays(DateTime focusedDay) {
    final start = focusedDay.subtract(Duration(days: focusedDay.weekday - 1));
    return List.generate(7, (i) => DateTime(start.year, start.month, start.day + i));
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ContentCalendarCubit>();
    final state = context.watch<ContentCalendarCubit>().state;

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
          SegmentedButton<ContentDisplayMode>(
            segments: const [
              ButtonSegment(value: ContentDisplayMode.month, label: Text('Month')),
              ButtonSegment(value: ContentDisplayMode.week, label: Text('Week')),
              ButtonSegment(value: ContentDisplayMode.list, label: Text('List')),
            ],
            selected: {state.mode},
            onSelectionChanged: (s) => cubit.setMode(s.first),
          ),
        ],
      ),
    );
  }
}
