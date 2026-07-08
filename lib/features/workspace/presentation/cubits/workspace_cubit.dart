import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/data/model/profile_model.dart';
import '../../../auth/data/repo/profiles_repository.dart';
import '../../../clients/data/model/client_model.dart';
import '../../../clients/data/repo/clients_repository.dart';
import '../../../content_calendar/data/model/content_item_model.dart';
import '../../../content_calendar/data/repo/content_items_repository.dart';
import '../../../content_creation/data/model/content_creation_item_model.dart';
import '../../../content_creation/data/repo/content_creation_columns_repository.dart';
import '../../../content_creation/data/repo/content_creation_items_repository.dart';
import '../../../kanban/data/model/board_column_model.dart';
import '../../../kanban/data/repo/board_columns_repository.dart';
import '../../../notes/data/model/note_model.dart';
import '../../../notes/data/repo/notes_repository.dart';
import '../../../tasks/data/model/platform_model.dart';
import '../../../tasks/data/model/task_model.dart';
import '../../../tasks/data/model/task_type_model.dart';
import '../../../tasks/data/repo/platforms_repository.dart';
import '../../../tasks/data/repo/task_types_repository.dart';
import '../../../tasks/data/repo/tasks_repository.dart';

part 'workspace_state.dart';

/// The single centralized, realtime-synced source of task/content/client
/// data for the entire Workspace shell. Provided once above the view tabs
/// (Kanban/Calendar/Clients/Content Calendar/Content Creation) so switching
/// tabs never re-fetches — this is what makes "one unified screen,
/// centralized data" real instead of independent per-tab fetches.
class WorkspaceCubit extends Cubit<WorkspaceCubitState> {
  WorkspaceCubit(
    this._tasksRepository,
    this._contentItemsRepository,
    this._clientsRepository,
    this._profilesRepository,
    this._boardColumnsRepository,
    this._notesRepository,
    this._taskTypesRepository,
    this._platformsRepository,
    this._contentCreationColumnsRepository,
    this._contentCreationItemsRepository,
  ) : super(const WorkspaceCubitState()) {
    _tasksSub = _tasksRepository.watchTasks().listen((_) => _loadTasks());
    _contentSub =
        _contentItemsRepository.watchContentItems().listen((_) => _loadContentItems());
    _clientsSub = _clientsRepository.watchClients().listen((_) => _loadClients());
    _columnsSub =
        _boardColumnsRepository.watchColumns().listen((_) => _loadBoardColumns());
    _notesSub = _notesRepository.watchNotes().listen((_) => _loadNotes());
    _taskTypesSub =
        _taskTypesRepository.watchTypes().listen((_) => _loadTaskTypes());
    _platformsSub =
        _platformsRepository.watchPlatforms().listen((_) => _loadPlatforms());
    _contentCreationColumnsSub = _contentCreationColumnsRepository
        .watchColumns()
        .listen((_) => _loadContentCreationColumns());
    _contentCreationItemsSub = _contentCreationItemsRepository
        .watchItems()
        .listen((_) => _loadContentCreationItems());
    load();
  }

  final TasksRepository _tasksRepository;
  final ContentItemsRepository _contentItemsRepository;
  final ClientsRepository _clientsRepository;
  final ProfilesRepository _profilesRepository;
  final BoardColumnsRepository _boardColumnsRepository;
  final NotesRepository _notesRepository;
  final TaskTypesRepository _taskTypesRepository;
  final PlatformsRepository _platformsRepository;
  final ContentCreationColumnsRepository _contentCreationColumnsRepository;
  final ContentCreationItemsRepository _contentCreationItemsRepository;

  StreamSubscription<void>? _tasksSub;
  StreamSubscription<void>? _contentSub;
  StreamSubscription<void>? _clientsSub;
  StreamSubscription<void>? _columnsSub;
  StreamSubscription<void>? _notesSub;
  StreamSubscription<void>? _taskTypesSub;
  StreamSubscription<void>? _platformsSub;
  StreamSubscription<void>? _contentCreationColumnsSub;
  StreamSubscription<void>? _contentCreationItemsSub;

  Future<void> load() async {
    emit(state.copyWith(status: WorkspaceStatus.loading));
    try {
      final results = await Future.wait([
        _tasksRepository.getTasks(),
        _contentItemsRepository.getContentItems(),
        _clientsRepository.getClients(),
        _profilesRepository.getProfiles(),
        _boardColumnsRepository.getColumns(),
        _notesRepository.getNotes(),
        _taskTypesRepository.getTypes(),
        _platformsRepository.getPlatforms(),
        _contentCreationColumnsRepository.getColumns(),
        _contentCreationItemsRepository.getItems(),
      ]);
      emit(state.copyWith(
        status: WorkspaceStatus.success,
        tasks: results[0] as List<TaskModel>,
        contentItems: results[1] as List<ContentItemModel>,
        clients: results[2] as List<ClientModel>,
        profiles: results[3] as List<ProfileModel>,
        boardColumns: results[4] as List<BoardColumnModel>,
        notes: results[5] as List<NoteModel>,
        taskTypes: results[6] as List<TaskTypeModel>,
        platforms: results[7] as List<PlatformModel>,
        contentCreationColumns: results[8] as List<BoardColumnModel>,
        contentCreationItems: results[9] as List<ContentCreationItemModel>,
      ));
    } catch (e, st) {
      AppLogger.error('WorkspaceCubit.load failed', e, st);
      emit(state.copyWith(
        status: WorkspaceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _tasksRepository.getTasks();
      emit(state.copyWith(tasks: tasks));
    } catch (e, st) {
      AppLogger.error('WorkspaceCubit._loadTasks failed', e, st);
    }
  }

  Future<void> _loadContentItems() async {
    try {
      final items = await _contentItemsRepository.getContentItems();
      emit(state.copyWith(contentItems: items));
    } catch (e, st) {
      AppLogger.error('WorkspaceCubit._loadContentItems failed', e, st);
    }
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _clientsRepository.getClients();
      emit(state.copyWith(clients: clients));
    } catch (e, st) {
      AppLogger.error('WorkspaceCubit._loadClients failed', e, st);
    }
  }

  Future<void> _loadBoardColumns() async {
    try {
      final columns = await _boardColumnsRepository.getColumns();
      emit(state.copyWith(boardColumns: columns));
    } catch (e, st) {
      AppLogger.error('WorkspaceCubit._loadBoardColumns failed', e, st);
    }
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await _notesRepository.getNotes();
      emit(state.copyWith(notes: notes));
    } catch (e, st) {
      AppLogger.error('WorkspaceCubit._loadNotes failed', e, st);
    }
  }

  Future<void> _loadTaskTypes() async {
    try {
      final types = await _taskTypesRepository.getTypes();
      emit(state.copyWith(taskTypes: types));
    } catch (e, st) {
      AppLogger.error('WorkspaceCubit._loadTaskTypes failed', e, st);
    }
  }

  Future<void> _loadPlatforms() async {
    try {
      final platforms = await _platformsRepository.getPlatforms();
      emit(state.copyWith(platforms: platforms));
    } catch (e, st) {
      AppLogger.error('WorkspaceCubit._loadPlatforms failed', e, st);
    }
  }

  Future<void> _loadContentCreationColumns() async {
    try {
      final columns = await _contentCreationColumnsRepository.getColumns();
      emit(state.copyWith(contentCreationColumns: columns));
    } catch (e, st) {
      AppLogger.error('WorkspaceCubit._loadContentCreationColumns failed', e, st);
    }
  }

  Future<void> _loadContentCreationItems() async {
    try {
      final items = await _contentCreationItemsRepository.getItems();
      emit(state.copyWith(contentCreationItems: items));
    } catch (e, st) {
      AppLogger.error('WorkspaceCubit._loadContentCreationItems failed', e, st);
    }
  }

  /// Optimistically patches a task in-memory (used by Kanban drag and the
  /// content-reschedule due-date sync) without waiting for the realtime
  /// round trip, for perceived responsiveness.
  void patchTaskLocally(String taskId, TaskModel Function(TaskModel) update) {
    final next = state.tasks
        .map((t) => t.id == taskId ? update(t) : t)
        .toList();
    emit(state.copyWith(tasks: next));
  }

  void patchContentItemLocally(
      String id, ContentItemModel Function(ContentItemModel) update) {
    final next =
        state.contentItems.map((c) => c.id == id ? update(c) : c).toList();
    emit(state.copyWith(contentItems: next));
  }

  void patchColumnTitleLocally(String status, String title) {
    final next = state.boardColumns
        .map((c) => c.status == status
            ? BoardColumnModel(status: c.status, title: title, position: c.position)
            : c)
        .toList();
    emit(state.copyWith(boardColumns: next));
  }

  void patchContentCreationColumnTitleLocally(String status, String title) {
    final next = state.contentCreationColumns
        .map((c) => c.status == status
            ? BoardColumnModel(status: c.status, title: title, position: c.position)
            : c)
        .toList();
    emit(state.copyWith(contentCreationColumns: next));
  }

  void patchContentCreationItemLocally(
      String id, ContentCreationItemModel Function(ContentCreationItemModel) update) {
    final next = state.contentCreationItems
        .map((c) => c.id == id ? update(c) : c)
        .toList();
    emit(state.copyWith(contentCreationItems: next));
  }

  @override
  Future<void> close() {
    _tasksSub?.cancel();
    _contentSub?.cancel();
    _clientsSub?.cancel();
    _columnsSub?.cancel();
    _notesSub?.cancel();
    _taskTypesSub?.cancel();
    _platformsSub?.cancel();
    _contentCreationColumnsSub?.cancel();
    _contentCreationItemsSub?.cancel();
    return super.close();
  }
}
