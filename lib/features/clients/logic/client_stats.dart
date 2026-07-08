import '../../../core/utils/date_formatters.dart';
import '../../content_calendar/data/model/content_item_model.dart';
import '../../tasks/data/model/task_model.dart';
import '../data/model/client_model.dart';

class ClientStats {
  const ClientStats({
    required this.client,
    required this.openCount,
    required this.overdueCount,
    required this.dueThisWeekCount,
    required this.completionPercent,
    required this.totalCount,
    this.nextContentItem,
  });

  final ClientModel client;
  final int openCount;
  final int overdueCount;
  final int dueThisWeekCount;
  final double completionPercent;
  final int totalCount;
  final ContentItemModel? nextContentItem;

  /// [doneStatus] is the status key treated as "completed" — the rightmost
  /// Kanban column, since columns are user-managed rather than a fixed enum.
  factory ClientStats.fromTasks({
    required ClientModel client,
    required List<TaskModel> allTasks,
    required List<ContentItemModel> allContentItems,
    String? doneStatus,
  }) {
    final clientTasks = allTasks.where((t) => t.clientId == client.id).toList();
    bool isDone(TaskModel t) => doneStatus != null && t.status == doneStatus;

    final open = clientTasks.where((t) => !isDone(t)).length;
    final overdue = clientTasks
        .where((t) => !isDone(t) && DateFormatters.isOverdue(t.dueDate))
        .length;
    final dueThisWeek = clientTasks
        .where((t) => !isDone(t) && DateFormatters.isDueThisWeek(t.dueDate))
        .length;
    final done = clientTasks.where(isDone).length;
    final completion =
        clientTasks.isEmpty ? 0.0 : done / clientTasks.length;

    final upcoming = allContentItems
        .where((c) => c.clientId == client.id && c.publishAt.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.publishAt.compareTo(b.publishAt));

    return ClientStats(
      client: client,
      openCount: open,
      overdueCount: overdue,
      dueThisWeekCount: dueThisWeek,
      completionPercent: completion,
      totalCount: clientTasks.length,
      nextContentItem: upcoming.isEmpty ? null : upcoming.first,
    );
  }
}
