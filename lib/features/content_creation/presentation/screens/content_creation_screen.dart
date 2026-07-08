import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/exceptions/lookup_delete_restricted_exception.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/async_state_switcher.dart';
import '../../../../core/widgets/fancy_confirm_dialog.dart';
import '../../../../core/widgets/fancy_prompt_dialog.dart';
import '../../../kanban/data/model/board_column_model.dart';
import '../../../workspace/presentation/cubits/workspace_cubit.dart';
import '../../data/model/content_creation_item_model.dart';
import '../../data/repo/content_creation_columns_repository.dart';
import '../../data/repo/content_creation_items_repository.dart';
import '../cubits/content_creation_cubit.dart';
import '../widgets/content_creation_column.dart';
import '../widgets/content_creation_item_dialog.dart';

class ContentCreationScreen extends StatelessWidget {
  const ContentCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContentCreationCubit(
        context.read<ContentCreationItemsRepository>(),
        context.read<WorkspaceCubit>(),
      ),
      child: const _ContentCreationBoard(),
    );
  }
}

class _ContentCreationBoard extends StatelessWidget {
  const _ContentCreationBoard();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContentCreationCubit, ContentCreationUiState>(
      listenWhen: (prev, curr) => prev.errorTick != curr.errorTick,
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppToast.error(context, state.errorMessage!);
        }
      },
      child: BlocBuilder<WorkspaceCubit, WorkspaceCubitState>(
        builder: (context, workspace) {
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
            emptyIcon: LucideIcons.clapperboard,
            emptyTitle: 'No content in the pipeline yet',
            emptyMessage: 'Cards created here will show up on the read-only Content Calendar.',
            errorMessage: workspace.errorMessage,
            onRetry: () => context.read<WorkspaceCubit>().load(),
            builder: (data) => (context) {
              final columns = data.contentCreationColumns;
              final grouped = <String, List<ContentCreationItemModel>>{
                for (final c in columns)
                  c.status:
                      data.contentCreationItems.where((i) => i.status == c.status).toList(),
              };

              return Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < columns.length; i++)
                        ContentCreationColumn(
                          status: columns[i].status,
                          title: columns[i].title,
                          color: AppColors.columnColorFor(i),
                          allColumns: columns,
                          items: grouped[columns[i].status] ?? const [],
                          onCardTap: (item) => showContentCreationItemDialog(
                            context,
                            item: item,
                            defaultStatus: columns[i].status,
                            clients: data.clients,
                            profiles: data.profiles,
                            columns: columns,
                          ),
                          onDropItem: (item, newStatus) =>
                              context.read<ContentCreationCubit>().moveItem(item, newStatus),
                          onRenameColumn: (title) async {
                            context.read<WorkspaceCubit>().patchContentCreationColumnTitleLocally(
                                columns[i].status, title);
                            try {
                              await context
                                  .read<ContentCreationColumnsRepository>()
                                  .renameColumn(columns[i].status, title);
                            } catch (e) {
                              if (context.mounted) {
                                AppToast.error(context, 'Could not rename column: $e');
                              }
                            }
                          },
                          onAddItem: () => showContentCreationItemDialog(
                            context,
                            defaultStatus: columns[i].status,
                            clients: data.clients,
                            profiles: data.profiles,
                            columns: columns,
                          ),
                          onDeleteColumn: () => _deleteColumn(context, columns[i], grouped),
                        ),
                      _AddColumnButton(nextPosition: columns.length),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteColumn(BuildContext context, BoardColumnModel column,
      Map<String, List<ContentCreationItemModel>> grouped) async {
    if ((grouped[column.status] ?? const []).isNotEmpty) {
      AppToast.error(context,
          'Move or delete the cards in "${column.title}" before deleting the column.');
      return;
    }
    final confirmed = await showFancyConfirmDialog(
      context,
      title: 'Delete "${column.title}"?',
      message: 'This cannot be undone.',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await context.read<ContentCreationColumnsRepository>().deleteColumn(column.status);
      if (context.mounted) await context.read<WorkspaceCubit>().load();
    } on LookupDeleteRestrictedException {
      if (context.mounted) {
        AppToast.error(context, 'That column still has cards in it.');
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
      icon: LucideIcons.clapperboard,
      color: AppColors.highlightPink,
    );
    if (title == null || title.trim().isEmpty || !context.mounted) return;
    try {
      await context
          .read<ContentCreationColumnsRepository>()
          .createColumn(title.trim(), nextPosition);
      if (context.mounted) await context.read<WorkspaceCubit>().load();
    } catch (e) {
      if (context.mounted) AppToast.error(context, 'Could not create column: $e');
    }
  }
}
