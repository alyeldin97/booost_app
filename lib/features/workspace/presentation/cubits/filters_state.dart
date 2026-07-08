part of 'filters_cubit.dart';

class FiltersState extends Equatable {
  const FiltersState({
    this.clientIds = const {},
    this.assigneeIds = const {},
    this.statuses = const {},
    this.priorities = const {},
    this.taskTypes = const {},
    this.platforms = const {},
    this.dateRange,
    this.search = '',
  });

  final Set<String> clientIds;
  final Set<String> assigneeIds;
  final Set<String> statuses;
  final Set<TaskPriority> priorities;
  final Set<String> taskTypes;
  final Set<String> platforms;
  final DateTimeRange? dateRange;
  final String search;

  bool get isEmpty =>
      clientIds.isEmpty &&
      assigneeIds.isEmpty &&
      statuses.isEmpty &&
      priorities.isEmpty &&
      taskTypes.isEmpty &&
      platforms.isEmpty &&
      dateRange == null &&
      search.isEmpty;

  FiltersState copyWith({
    Set<String>? clientIds,
    Set<String>? assigneeIds,
    Set<String>? statuses,
    Set<TaskPriority>? priorities,
    Set<String>? taskTypes,
    Set<String>? platforms,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    String? search,
  }) =>
      FiltersState(
        clientIds: clientIds ?? this.clientIds,
        assigneeIds: assigneeIds ?? this.assigneeIds,
        statuses: statuses ?? this.statuses,
        priorities: priorities ?? this.priorities,
        taskTypes: taskTypes ?? this.taskTypes,
        platforms: platforms ?? this.platforms,
        dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
        search: search ?? this.search,
      );

  @override
  List<Object?> get props => [
        clientIds,
        assigneeIds,
        statuses,
        priorities,
        taskTypes,
        platforms,
        dateRange,
        search,
      ];
}
