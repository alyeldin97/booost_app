import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/async_state_switcher.dart';
import '../../../../core/widgets/fancy_confirm_dialog.dart';
import '../../../../core/widgets/fancy_dialog.dart';
import '../../../../core/widgets/fancy_prompt_dialog.dart';
import '../../../clients/data/model/client_model.dart';
import '../../../task_drawer/presentation/cubits/task_drawer_cubit.dart';
import '../../../tasks/data/model/task_model.dart';
import '../../../tasks/data/repo/activity_log_repository.dart';
import '../../../tasks/data/repo/tasks_repository.dart';
import '../../../workspace/logic/task_filtering.dart';
import '../../../workspace/presentation/cubits/filters_cubit.dart';
import '../../../workspace/presentation/cubits/workspace_cubit.dart';
import '../../data/model/board_column_model.dart';
import '../../../../core/exceptions/lookup_delete_restricted_exception.dart';
import '../../data/repo/board_columns_repository.dart';
import '../cubits/kanban_cubit.dart';
import '../widgets/kanban_column.dart';

class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KanbanCubit(
        context.read<TasksRepository>(),
        context.read<ActivityLogRepository>(),
        context.read<WorkspaceCubit>(),
      ),
      child: const _KanbanBoard(),
    );
  }
}

class _KanbanBoard extends StatelessWidget {
  const _KanbanBoard();

  @override
  Widget build(BuildContext context) {
    return BlocListener<KanbanCubit, KanbanUiState>(
      listenWhen: (prev, curr) => prev.errorTick != curr.errorTick,
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppToast.error(context, state.errorMessage!);
        }
      },
      child: BlocBuilder<WorkspaceCubit, WorkspaceCubitState>(
        builder: (context, workspace) {
          return BlocBuilder<FiltersCubit, FiltersState>(
            builder: (context, filters) {
              return AsyncStateSwitcher<WorkspaceCubitState>(
                status: switch (workspace.status) {
                  WorkspaceStatus.initial => AsyncStatus.initial,
                  WorkspaceStatus.loading => AsyncStatus.loading,
                  WorkspaceStatus.success => AsyncStatus.success,
                  WorkspaceStatus.failure => AsyncStatus.failure,
                },
                data: workspace,
                isEmpty: workspace.status != WorkspaceStatus.success &&
                    workspace.tasks.isEmpty,
                emptyIcon: LucideIcons.layoutGrid,
                emptyTitle: 'No tasks yet',
                emptyMessage: 'Tasks will show up here once created.',
                errorMessage: workspace.errorMessage,
                onRetry: () => context.read<WorkspaceCubit>().load(),
                builder: (data) => (context) {
                  final filteredTasks = filterTasks(data.tasks, filters);
                  final contentByTaskId = {
                    for (final c in data.contentItems)
                      if (c.taskId != null) c.taskId!: c,
                  };
                  final columns = data.boardColumns;
                  final grouped = <String, List<TaskModel>>{
                    for (final c in columns)
                      c.status: filteredTasks.where((t) => t.status == c.status).toList(),
                  };

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < columns.length; i++)
                            KanbanColumn(
                              status: columns[i].status,
                              title: columns[i].title,
                              color: AppColors.columnColorFor(i),
                              allColumns: columns,
                              tasks: grouped[columns[i].status] ?? const [],
                              contentItemsByTaskId: contentByTaskId,
                              onCardTap: (task) =>
                                  context.read<TaskDrawerCubit>().open(task.id),
                              onDropTask: (task, newStatus) => context
                                  .read<KanbanCubit>()
                                  .moveTask(task, newStatus),
                              onRenameColumn: (title) async {
                                context.read<WorkspaceCubit>().patchColumnTitleLocally(
                                    columns[i].status, title);
                                try {
                                  await context
                                      .read<BoardColumnsRepository>()
                                      .renameColumn(columns[i].status, title);
                                } catch (e) {
                                  if (context.mounted) {
                                    AppToast.error(context, 'Could not rename column: $e');
                                  }
                                }
                              },
                              onAddTask: () =>
                                  _createTask(context, columns[i].status, data.clients),
                              onDeleteColumn: () =>
                                  _deleteColumn(context, columns[i], grouped),
                              onDuplicateTask: (task) => _duplicateTask(context, task),
                            ),
                          _AddColumnButton(nextPosition: columns.length),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _createTask(
      BuildContext context, String status, List<ClientModel> clients) async {
    if (clients.isEmpty) {
      AppToast.error(context, 'Add a client before creating tasks.');
      return;
    }
    final clientId = clients.length == 1
        ? clients.first.id
        : await showDialog<String>(
            context: context,
            builder: (dialogContext) => FancyDialog(
              title: 'New task for which client?',
              icon: LucideIcons.building2,
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final c in clients)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => Navigator.pop(dialogContext, c.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      AppColors.clientColorFor(c.id).withValues(alpha: 0.18),
                                  child: Text(c.initials,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.clientColorFor(c.id))),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(c.name)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
    if (clientId == null || !context.mounted) return;

    try {
      final task = await context.read<TasksRepository>().createTask(
            clientId: clientId,
            title: 'New task',
            status: status,
          );
      if (context.mounted) {
        await context.read<WorkspaceCubit>().load();
        if (context.mounted) context.read<TaskDrawerCubit>().open(task.id);
      }
    } catch (e) {
      if (context.mounted) AppToast.error(context, 'Could not create task: $e');
    }
  }

  Future<void> _duplicateTask(BuildContext context, TaskModel task) async {
    try {
      final duplicate = await context.read<TasksRepository>().duplicateTask(task.id);
      if (context.mounted) {
        await context.read<WorkspaceCubit>().load();
        if (context.mounted) {
          AppToast.success(context, 'Task duplicated');
          context.read<TaskDrawerCubit>().open(duplicate.id);
        }
      }
    } catch (e) {
      if (context.mounted) AppToast.error(context, 'Could not duplicate task: $e');
    }
  }

  Future<void> _deleteColumn(BuildContext context, BoardColumnModel column,
      Map<String, List<TaskModel>> grouped) async {
    if ((grouped[column.status] ?? const []).isNotEmpty) {
      AppToast.error(context,
          'Move or delete the tasks in "${column.title}" before deleting the column.');
      return;
    }
    final confirmed = await showFancyConfirmDialog(
      context,
      title: 'Delete "${column.title}"?',
      message: 'This cannot be undone.',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await context.read<BoardColumnsRepository>().deleteColumn(column.status);
      if (context.mounted) await context.read<WorkspaceCubit>().load();
    } on LookupDeleteRestrictedException {
      if (context.mounted) {
        AppToast.error(context, 'That column still has tasks in it.');
      }
    } catch (e) {
      if (context.mounted) AppToast.error(context, 'Could not delete column: $e');
    }
  }
}

class _AddColumnButton extends StatelessWidget {
  const _AddColumnButton({required this.nextPosition});
  final int nextPosition;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: OutlinedButton.icon(
        onPressed: () => _addColumn(context),
        icon: const Icon(LucideIcons.plus, size: 16),
        label: const Text('Add column'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Future<void> _addColumn(BuildContext context) async {
    final title = await showFancyPromptDialog(
      context,
      title: 'New column',
      label: 'Column name',
      confirmLabel: 'Create',
      icon: LucideIcons.columns3,
    );
    if (title == null || title.trim().isEmpty || !context.mounted) return;
    try {
      await context
          .read<BoardColumnsRepository>()
          .createColumn(title.trim(), nextPosition);
      if (context.mounted) await context.read<WorkspaceCubit>().load();
    } catch (e) {
      if (context.mounted) AppToast.error(context, 'Could not create column: $e');
    }
  }
}
