import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/config/env.dart';
import 'core/config/supabase_config.dart';
import 'core/router/app_router.dart';
import 'core/services/realtime_service.dart';
import 'core/services/storage_service.dart';
import 'core/styling/app_colors.dart';
import 'features/auth/data/remote/auth_remote_data_source.dart';
import 'features/auth/data/repo/auth_repository.dart';
import 'features/auth/data/repo/profiles_repository.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/clients/data/repo/clients_repository.dart';
import 'features/content_calendar/data/repo/content_items_repository.dart';
import 'features/content_creation/data/repo/content_creation_columns_repository.dart';
import 'features/content_creation/data/repo/content_creation_items_repository.dart';
import 'features/kanban/data/repo/board_columns_repository.dart';
import 'features/notes/data/repo/notes_repository.dart';
import 'features/tasks/data/repo/activity_log_repository.dart';
import 'features/tasks/data/repo/platforms_repository.dart';
import 'features/tasks/data/repo/task_types_repository.dart';
import 'features/tasks/data/repo/tasks_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  await SupabaseConfig.initialize();
  runApp(const BooostApp());
}

class BooostApp extends StatefulWidget {
  const BooostApp({super.key});

  @override
  State<BooostApp> createState() => _BooostAppState();
}

class _BooostAppState extends State<BooostApp> {
  late final AuthRepository _authRepository;
  late final AuthCubit _authCubit;
  late final RealtimeService _realtimeService;
  late final StorageService _storageService;
  late final TasksRepository _tasksRepository;
  late final ClientsRepository _clientsRepository;
  late final ContentItemsRepository _contentItemsRepository;
  late final ActivityLogRepository _activityLogRepository;
  late final ProfilesRepository _profilesRepository;
  late final BoardColumnsRepository _boardColumnsRepository;
  late final NotesRepository _notesRepository;
  late final TaskTypesRepository _taskTypesRepository;
  late final PlatformsRepository _platformsRepository;
  late final ContentCreationColumnsRepository _contentCreationColumnsRepository;
  late final ContentCreationItemsRepository _contentCreationItemsRepository;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Constructed exactly once here (not inside build()) — building a
    // GoRouter on every rebuild spins up a new GoRouterRefreshStream each
    // time, which causes an infinite rebuild loop on Flutter Web.
    final client = SupabaseConfig.client;
    _authRepository = AuthRepository(SupabaseAuthDataSource(client));
    _authCubit = AuthCubit(_authRepository);
    _realtimeService = RealtimeService(client);
    _storageService = StorageService(client);
    _tasksRepository = TasksRepository(client, _realtimeService);
    _clientsRepository = ClientsRepository(client, _realtimeService);
    _contentItemsRepository = ContentItemsRepository(client, _realtimeService);
    _activityLogRepository = ActivityLogRepository(client);
    _profilesRepository = ProfilesRepository(client);
    _boardColumnsRepository = BoardColumnsRepository(client, _realtimeService);
    _notesRepository = NotesRepository(client, _realtimeService);
    _taskTypesRepository = TaskTypesRepository(client, _realtimeService);
    _platformsRepository = PlatformsRepository(client, _realtimeService);
    _contentCreationColumnsRepository =
        ContentCreationColumnsRepository(client, _realtimeService);
    _contentCreationItemsRepository =
        ContentCreationItemsRepository(client, _realtimeService);
    _router = AppRouter(_authCubit).router;
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<RealtimeService>.value(value: _realtimeService),
        RepositoryProvider<StorageService>.value(value: _storageService),
        RepositoryProvider<TasksRepository>.value(value: _tasksRepository),
        RepositoryProvider<ClientsRepository>.value(value: _clientsRepository),
        RepositoryProvider<ContentItemsRepository>.value(
            value: _contentItemsRepository),
        RepositoryProvider<ActivityLogRepository>.value(
            value: _activityLogRepository),
        RepositoryProvider<ProfilesRepository>.value(value: _profilesRepository),
        RepositoryProvider<BoardColumnsRepository>.value(
            value: _boardColumnsRepository),
        RepositoryProvider<NotesRepository>.value(value: _notesRepository),
        RepositoryProvider<TaskTypesRepository>.value(value: _taskTypesRepository),
        RepositoryProvider<PlatformsRepository>.value(value: _platformsRepository),
        RepositoryProvider<ContentCreationColumnsRepository>.value(
            value: _contentCreationColumnsRepository),
        RepositoryProvider<ContentCreationItemsRepository>.value(
            value: _contentCreationItemsRepository),
      ],
      child: BlocProvider<AuthCubit>.value(
        value: _authCubit,
        child: MaterialApp.router(
          title: 'Booost',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(),
          routerConfig: _router,
        ),
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
    );
    return base.copyWith(
      focusColor: AppColors.primary,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.highlightPink,
        selectionColor: AppColors.highlightPinkLight,
        selectionHandleColor: AppColors.highlightPink,
      ),
    );
  }
}
