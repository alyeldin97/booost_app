import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/breakpoints.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/async_state_switcher.dart';
import '../../../../core/widgets/fancy_prompt_dialog.dart';
import '../../../workspace/presentation/cubits/filters_cubit.dart';
import '../../../workspace/presentation/cubits/workspace_cubit.dart';
import '../../data/repo/clients_repository.dart';
import '../../logic/client_stats.dart';
import '../cubits/clients_view_cubit.dart';
import '../widgets/client_card.dart';
import '../widgets/client_profile_dialog.dart';
import '../widgets/clients_table.dart';

class ClientsViewScreen extends StatelessWidget {
  const ClientsViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientsViewCubit(),
      child: const _ClientsViewBody(),
    );
  }
}

class _ClientsViewBody extends StatelessWidget {
  const _ClientsViewBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceCubit, WorkspaceCubitState>(
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
              workspace.clients.isEmpty,
          emptyIcon: LucideIcons.building2,
          emptyTitle: 'No clients yet',
          errorMessage: workspace.errorMessage,
          onRetry: () => context.read<WorkspaceCubit>().load(),
          builder: (data) => (context) {
            final stats = data.clients
                .map((c) => ClientStats.fromTasks(
                      client: c,
                      allTasks: data.tasks,
                      allContentItems: data.contentItems,
                      doneStatus: data.doneStatus,
                    ))
                .toList();

            return Column(
              children: [
                _Toolbar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BlocBuilder<ClientsViewCubit, ClientsViewMode>(
                      builder: (context, mode) {
                        if (mode == ClientsViewMode.table) {
                          return ClientsTable(
                            stats: stats,
                            onRowTap: (s) =>
                                showClientProfileDialog(context, client: s.client),
                            onProfileTap: (s) => _applyClientFilter(context, s),
                          );
                        }
                        final columns = Breakpoints.isDesktop(context)
                            ? 3
                            : Breakpoints.isTablet(context)
                                ? 2
                                : 1;
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: stats.length,
                          itemBuilder: (context, i) => ClientCard(
                            stats: stats[i],
                            onTap: () =>
                                showClientProfileDialog(context, client: stats[i].client),
                            onProfileTap: () => _applyClientFilter(context, stats[i]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applyClientFilter(BuildContext context, ClientStats stats) {
    final filters = context.read<FiltersCubit>();
    filters.toggleClient(stats.client.id);
    final params = filters.toQueryParams();
    final path = GoRouterState.of(context).matchedLocation;
    final uri = Uri(path: path, queryParameters: params.isEmpty ? null : params);
    context.replace(uri.toString());
  }
}

class _Toolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ClientsViewCubit>().state;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          FilledButton.icon(
            onPressed: () => _createClient(context),
            icon: const Icon(LucideIcons.plus, size: 15),
            label: const Text('New client'),
          ),
          const Spacer(),
          SegmentedButton<ClientsViewMode>(
            segments: const [
              ButtonSegment(
                  value: ClientsViewMode.grid,
                  icon: Icon(LucideIcons.layoutGrid, size: 16),
                  label: Text('Grid')),
              ButtonSegment(
                  value: ClientsViewMode.table,
                  icon: Icon(LucideIcons.list, size: 16),
                  label: Text('Table')),
            ],
            selected: {mode},
            onSelectionChanged: (s) =>
                context.read<ClientsViewCubit>().setMode(s.first),
          ),
        ],
      ),
    );
  }

  Future<void> _createClient(BuildContext context) async {
    final name = await showFancyPromptDialog(
      context,
      title: 'New client',
      label: 'Client name',
      confirmLabel: 'Create',
      icon: LucideIcons.building2,
      color: AppColors.success,
    );
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    try {
      await context.read<ClientsRepository>().createClient(name: name.trim());
      if (context.mounted) {
        await context.read<WorkspaceCubit>().load();
        if (context.mounted) AppToast.success(context, 'Client "$name" created');
      }
    } catch (e) {
      if (context.mounted) AppToast.error(context, 'Could not create client: $e');
    }
  }
}
