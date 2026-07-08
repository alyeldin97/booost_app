import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_enums.dart';

part 'filters_state.dart';

/// URL is the source of truth for filter state; this cubit is a derived
/// cache with pure parse/serialize methods so the router-sync widget can
/// short-circuit on string equality and avoid update loops.
class FiltersCubit extends Cubit<FiltersState> {
  FiltersCubit() : super(const FiltersState());

  static const _sep = ',';

  void updateFromQuery(Map<String, String> query) {
    emit(FiltersState(
      clientIds: _splitSet(query['clients']),
      assigneeIds: _splitSet(query['assignees']),
      statuses: _splitSet(query['status']),
      priorities:
          _splitSet(query['priority']).map(TaskPriorityX.fromDb).toSet(),
      taskTypes: _splitSet(query['type']),
      platforms: _splitSet(query['platform']),
      dateRange: _parseDateRange(query['from'], query['to']),
      search: query['q'] ?? '',
    ));
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (state.clientIds.isNotEmpty) params['clients'] = state.clientIds.join(_sep);
    if (state.assigneeIds.isNotEmpty) {
      params['assignees'] = state.assigneeIds.join(_sep);
    }
    if (state.statuses.isNotEmpty) {
      params['status'] = state.statuses.join(_sep);
    }
    if (state.priorities.isNotEmpty) {
      params['priority'] = state.priorities.map((p) => p.dbValue).join(_sep);
    }
    if (state.taskTypes.isNotEmpty) params['type'] = state.taskTypes.join(_sep);
    if (state.platforms.isNotEmpty) {
      params['platform'] = state.platforms.join(_sep);
    }
    if (state.dateRange != null) {
      params['from'] = DateFormatIso.iso(state.dateRange!.start);
      params['to'] = DateFormatIso.iso(state.dateRange!.end);
    }
    if (state.search.isNotEmpty) params['q'] = state.search;
    return params;
  }

  void toggleClient(String id) => _toggleInSet(
      state.clientIds, id, (s) => emit(state.copyWith(clientIds: s)));
  void toggleAssignee(String id) => _toggleInSet(
      state.assigneeIds, id, (s) => emit(state.copyWith(assigneeIds: s)));
  void toggleStatus(String s) => _toggleInSet(
      state.statuses, s, (v) => emit(state.copyWith(statuses: v)));
  void togglePriority(TaskPriority p) => _toggleInSet(
      state.priorities, p, (v) => emit(state.copyWith(priorities: v)));
  void toggleTaskType(String t) => _toggleInSet(
      state.taskTypes, t, (v) => emit(state.copyWith(taskTypes: v)));
  void togglePlatform(String p) => _toggleInSet(
      state.platforms, p, (v) => emit(state.copyWith(platforms: v)));

  void setDateRange(DateTimeRange? range) {
    emit(state.copyWith(dateRange: range, clearDateRange: range == null));
  }

  void setSearch(String value) => emit(state.copyWith(search: value));

  void clearAll() => emit(const FiltersState());

  void _toggleInSet<T>(Set<T> current, T value, void Function(Set<T>) apply) {
    final next = Set<T>.from(current);
    if (!next.remove(value)) next.add(value);
    apply(next);
  }

  Set<String> _splitSet(String? raw) =>
      (raw == null || raw.isEmpty) ? {} : raw.split(_sep).toSet();

  DateTimeRange? _parseDateRange(String? from, String? to) {
    if (from == null || to == null) return null;
    try {
      return DateTimeRange(start: DateTime.parse(from), end: DateTime.parse(to));
    } catch (_) {
      return null;
    }
  }
}

class DateFormatIso {
  static String iso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
