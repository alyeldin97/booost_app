import '../../content_calendar/data/model/content_item_model.dart';
import '../../content_creation/data/model/content_creation_item_model.dart';
import '../../tasks/data/model/task_model.dart';
import '../presentation/cubits/filters_cubit.dart';

/// Pure filtering so views can derive from [WorkspaceCubit]'s already
/// realtime-synced dataset without a per-filter-change network round trip.
List<TaskModel> filterTasks(List<TaskModel> tasks, FiltersState f) {
  return tasks.where((t) {
    if (f.clientIds.isNotEmpty && !f.clientIds.contains(t.clientId)) return false;
    if (f.assigneeIds.isNotEmpty &&
        !t.assignees.any((a) => f.assigneeIds.contains(a.id))) {
      return false;
    }
    if (f.statuses.isNotEmpty && !f.statuses.contains(t.status)) return false;
    if (f.priorities.isNotEmpty && !f.priorities.contains(t.priority)) {
      return false;
    }
    if (f.taskTypes.isNotEmpty && !f.taskTypes.contains(t.taskType)) return false;
    if (f.platforms.isNotEmpty &&
        !t.platforms.any((p) => f.platforms.contains(p))) {
      return false;
    }
    if (f.dateRange != null) {
      if (t.dueDate == null) return false;
      if (t.dueDate!.isBefore(f.dateRange!.start) ||
          t.dueDate!.isAfter(f.dateRange!.end)) {
        return false;
      }
    }
    if (f.search.isNotEmpty &&
        !t.title.toLowerCase().contains(f.search.toLowerCase())) {
      return false;
    }
    return true;
  }).toList();
}

List<ContentItemModel> filterContentItems(
    List<ContentItemModel> items, FiltersState f) {
  return items.where((c) {
    if (f.clientIds.isNotEmpty && !f.clientIds.contains(c.clientId)) return false;
    if (f.assigneeIds.isNotEmpty) {
      final assignedIds = {c.copywriterId, c.designerId, c.accountManagerId}
          .whereType<String>();
      if (!assignedIds.any(f.assigneeIds.contains)) return false;
    }
    if (f.platforms.isNotEmpty && !f.platforms.contains(c.platform)) return false;
    if (f.dateRange != null) {
      if (c.publishAt.isBefore(f.dateRange!.start) ||
          c.publishAt.isAfter(f.dateRange!.end)) {
        return false;
      }
    }
    if (f.search.isNotEmpty &&
        !c.title.toLowerCase().contains(f.search.toLowerCase())) {
      return false;
    }
    return true;
  }).toList();
}

/// Content Creation cards have no priority/type/platform fields and their
/// `status` means a pipeline column (Idea/Script/...), not a task status —
/// so only client, assignee, "should be published on" date, and search
/// apply here, unlike [filterTasks].
List<ContentCreationItemModel> filterContentCreationItems(
    List<ContentCreationItemModel> items, FiltersState f) {
  return items.where((c) {
    if (f.clientIds.isNotEmpty &&
        (c.clientId == null || !f.clientIds.contains(c.clientId))) {
      return false;
    }
    if (f.assigneeIds.isNotEmpty &&
        (c.assigneeId == null || !f.assigneeIds.contains(c.assigneeId))) {
      return false;
    }
    if (f.dateRange != null) {
      if (c.shouldBePublishedOn == null) return false;
      if (c.shouldBePublishedOn!.isBefore(f.dateRange!.start) ||
          c.shouldBePublishedOn!.isAfter(f.dateRange!.end)) {
        return false;
      }
    }
    if (f.search.isNotEmpty &&
        !c.name.toLowerCase().contains(f.search.toLowerCase())) {
      return false;
    }
    return true;
  }).toList();
}
