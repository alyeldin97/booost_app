import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../task_drawer/presentation/cubits/task_drawer_cubit.dart';
import '../../../task_drawer/presentation/widgets/task_details_drawer.dart';
import '../cubits/filters_cubit.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/filter_toolbar.dart';

class WorkspaceShellScreen extends StatefulWidget {
  const WorkspaceShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<WorkspaceShellScreen> createState() => _WorkspaceShellScreenState();
}

class _WorkspaceShellScreenState extends State<WorkspaceShellScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _tabs = [
    (
      label: 'Kanban Board',
      icon: LucideIcons.columns3,
      path: Routes.workspaceKanban,
    ),
    (
      label: 'Content Creation',
      icon: LucideIcons.clapperboard,
      path: Routes.workspaceContentCreation,
    ),
    (
      label: 'Calendar',
      icon: LucideIcons.calendar,
      path: Routes.workspaceCalendar,
    ),
    (
      label: 'Clients',
      icon: LucideIcons.building2,
      path: Routes.workspaceClients,
    ),
    (
      label: 'Content Calendar',
      icon: LucideIcons.megaphone,
      path: Routes.workspaceContentCalendar,
    ),
    (
      label: 'Shakhabeet',
      icon: LucideIcons.notebookPen,
      path: Routes.workspaceShakhabeet,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // URL is the source of truth: whenever the route's query params differ
    // from the cubit's current serialization (e.g. a fresh deep link, back
    // button, or another tab's edit), pull them into FiltersCubit. The
    // string-equality short-circuit is what prevents this from looping
    // with _pushFiltersToUrl's own context.replace calls.
    final query = GoRouterState.of(context).uri.queryParameters;
    final cubit = context.read<FiltersCubit>();
    if (!_sameParams(query, cubit.toQueryParams())) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) cubit.updateFromQuery(query);
      });
    }
  }

  bool _sameParams(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  void _pushFiltersToUrl() {
    final params = context.read<FiltersCubit>().toQueryParams();
    final path = GoRouterState.of(context).matchedLocation;
    final uri = Uri(
      path: path,
      queryParameters: params.isEmpty ? null : params,
    );
    context.replace(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskDrawerCubit, TaskDrawerCubitState>(
      listenWhen: (prev, curr) => prev.isOpen != curr.isOpen,
      listener: (context, state) {
        final scaffold = _scaffoldKey.currentState;
        if (scaffold == null) return;
        if (state.isOpen && !scaffold.isEndDrawerOpen) {
          scaffold.openEndDrawer();
        } else if (!state.isOpen && scaffold.isEndDrawerOpen) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: const TaskDetailsDrawer(),
        onEndDrawerChanged: (isOpen) {
          if (!isOpen) context.read<TaskDrawerCubit>().closeDrawer();
        },
        body: Row(
          children: [
            const AppSidebar(),
            Expanded(
              child: Column(
                children: [
                  FilterToolbar(onFiltersChanged: _pushFiltersToUrl),
                  Container(
                    width: double.infinity,
                    color: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        for (var i = 0; i < _tabs.length; i++) ...[
                          if (i > 0) const SizedBox(width: 6),
                          _TabButton(
                            label: _tabs[i].label,
                            icon: _tabs[i].icon,
                            selected: widget.navigationShell.currentIndex == i,
                            onTap: () => widget.navigationShell.goBranch(
                              i,
                              initialLocation:
                                  i == widget.navigationShell.currentIndex,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(child: widget.navigationShell),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
