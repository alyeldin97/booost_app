import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/repo/profiles_repository.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/calendar_view/presentation/screens/calendar_view_screen.dart';
import '../../features/clients/data/repo/clients_repository.dart';
import '../../features/clients/presentation/screens/clients_view_screen.dart';
import '../../features/content_calendar/data/repo/content_items_repository.dart';
import '../../features/content_calendar/presentation/screens/content_calendar_screen.dart';
import '../../features/content_creation/data/repo/content_creation_columns_repository.dart';
import '../../features/content_creation/data/repo/content_creation_items_repository.dart';
import '../../features/content_creation/presentation/screens/content_creation_screen.dart';
import '../../features/kanban/data/repo/board_columns_repository.dart';
import '../../features/kanban/presentation/screens/kanban_screen.dart';
import '../../features/notes/data/repo/notes_repository.dart';
import '../../features/notes/presentation/screens/shakhabeet_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/task_drawer/presentation/cubits/task_drawer_cubit.dart';
import '../../features/tasks/data/repo/activity_log_repository.dart';
import '../../features/tasks/data/repo/platforms_repository.dart';
import '../../features/tasks/data/repo/task_types_repository.dart';
import '../../features/tasks/data/repo/tasks_repository.dart';
import '../../features/workspace/presentation/cubits/filters_cubit.dart';
import '../../features/workspace/presentation/cubits/workspace_cubit.dart';
import '../../features/workspace/presentation/screens/workspace_shell_screen.dart';
import '../services/storage_service.dart';
import 'go_router_refresh_stream.dart';
import 'routes.dart';

class AppRouter {
  AppRouter(this._authCubit);

  final AuthCubit _authCubit;

  late final router = GoRouter(
    initialLocation: Routes.workspaceKanban,
    refreshListenable: GoRouterRefreshStream(_authCubit.stream),
    redirect: (context, state) {
      final status = _authCubit.state.status;
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return null;
      }
      final loggedIn = status == AuthStatus.authenticated;
      final onLoginPage = state.matchedLocation == Routes.login;

      if (!loggedIn && !onLoginPage) return Routes.login;
      if (loggedIn && onLoginPage) return Routes.workspaceKanban;
      if (loggedIn && state.matchedLocation == Routes.workspace) {
        return Routes.workspaceKanban;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<WorkspaceCubit>(
                create: (context) => WorkspaceCubit(
                  context.read<TasksRepository>(),
                  context.read<ContentItemsRepository>(),
                  context.read<ClientsRepository>(),
                  context.read<ProfilesRepository>(),
                  context.read<BoardColumnsRepository>(),
                  context.read<NotesRepository>(),
                  context.read<TaskTypesRepository>(),
                  context.read<PlatformsRepository>(),
                  context.read<ContentCreationColumnsRepository>(),
                  context.read<ContentCreationItemsRepository>(),
                ),
              ),
              BlocProvider<FiltersCubit>(create: (_) => FiltersCubit()),
              BlocProvider<TaskDrawerCubit>(
                create: (context) => TaskDrawerCubit(
                  context.read<TasksRepository>(),
                  context.read<ActivityLogRepository>(),
                  context.read<StorageService>(),
                ),
              ),
            ],
            child: WorkspaceShellScreen(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.workspaceKanban,
              builder: (context, state) => const KanbanScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.workspaceContentCreation,
              builder: (context, state) => const ContentCreationScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.workspaceCalendar,
              builder: (context, state) => const CalendarViewScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.workspaceClients,
              builder: (context, state) => const ClientsViewScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.workspaceContentCalendar,
              builder: (context, state) => const ContentCalendarScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.workspaceShakhabeet,
              builder: (context, state) => const ShakhabeetScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
}
