part of 'workspace_cubit.dart';

enum WorkspaceStatus { initial, loading, success, failure }

class WorkspaceCubitState extends Equatable {
  const WorkspaceCubitState({
    this.status = WorkspaceStatus.initial,
    this.tasks = const [],
    this.contentItems = const [],
    this.clients = const [],
    this.profiles = const [],
    this.boardColumns = const [],
    this.notes = const [],
    this.taskTypes = const [],
    this.platforms = const [],
    this.contentCreationColumns = const [],
    this.contentCreationItems = const [],
    this.errorMessage,
  });

  final WorkspaceStatus status;
  final List<TaskModel> tasks;
  final List<ContentItemModel> contentItems;
  final List<ClientModel> clients;
  final List<ProfileModel> profiles;
  final List<BoardColumnModel> boardColumns;
  final List<NoteModel> notes;
  final List<TaskTypeModel> taskTypes;
  final List<PlatformModel> platforms;
  final List<BoardColumnModel> contentCreationColumns;
  final List<ContentCreationItemModel> contentCreationItems;
  final String? errorMessage;

  /// The rightmost column is treated as "done" for client-stats purposes,
  /// since columns are user-managed rather than a fixed enum.
  String? get doneStatus => boardColumns.isEmpty ? null : boardColumns.last.status;

  WorkspaceCubitState copyWith({
    WorkspaceStatus? status,
    List<TaskModel>? tasks,
    List<ContentItemModel>? contentItems,
    List<ClientModel>? clients,
    List<ProfileModel>? profiles,
    List<BoardColumnModel>? boardColumns,
    List<NoteModel>? notes,
    List<TaskTypeModel>? taskTypes,
    List<PlatformModel>? platforms,
    List<BoardColumnModel>? contentCreationColumns,
    List<ContentCreationItemModel>? contentCreationItems,
    String? errorMessage,
  }) =>
      WorkspaceCubitState(
        status: status ?? this.status,
        tasks: tasks ?? this.tasks,
        contentItems: contentItems ?? this.contentItems,
        clients: clients ?? this.clients,
        profiles: profiles ?? this.profiles,
        boardColumns: boardColumns ?? this.boardColumns,
        notes: notes ?? this.notes,
        taskTypes: taskTypes ?? this.taskTypes,
        platforms: platforms ?? this.platforms,
        contentCreationColumns: contentCreationColumns ?? this.contentCreationColumns,
        contentCreationItems: contentCreationItems ?? this.contentCreationItems,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        tasks,
        contentItems,
        clients,
        profiles,
        boardColumns,
        notes,
        taskTypes,
        platforms,
        contentCreationColumns,
        contentCreationItems,
        errorMessage
      ];
}
