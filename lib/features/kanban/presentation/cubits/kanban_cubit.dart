import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tasks/data/model/task_model.dart';
import '../../../tasks/data/repo/activity_log_repository.dart';
import '../../../tasks/data/repo/tasks_repository.dart';
import '../../../workspace/presentation/cubits/workspace_cubit.dart';

class KanbanUiState extends Equatable {
  const KanbanUiState({this.pendingTaskIds = const {}, this.errorTick = 0, this.errorMessage});

  final Set<String> pendingTaskIds;
  final int errorTick;
  final String? errorMessage;

  KanbanUiState copyWith({
    Set<String>? pendingTaskIds,
    int? errorTick,
    String? errorMessage,
  }) =>
      KanbanUiState(
        pendingTaskIds: pendingTaskIds ?? this.pendingTaskIds,
        errorTick: errorTick ?? this.errorTick,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [pendingTaskIds, errorTick, errorMessage];
}

/// Tab-local: holds only drag-in-flight UI state. Task data itself lives
/// in the shared [WorkspaceCubit]; this cubit just orchestrates the
/// optimistic-update-then-rollback mutation on drag-and-drop.
class KanbanCubit extends Cubit<KanbanUiState> {
  KanbanCubit(this._tasksRepository, this._activityLogRepository, this._workspaceCubit)
      : super(const KanbanUiState());

  final TasksRepository _tasksRepository;
  final ActivityLogRepository _activityLogRepository;
  final WorkspaceCubit _workspaceCubit;

  Future<void> moveTask(TaskModel task, String newStatus) async {
    if (task.status == newStatus) return;
    if (state.pendingTaskIds.contains(task.id)) return;

    final previousStatus = task.status;
    emit(state.copyWith(pendingTaskIds: {...state.pendingTaskIds, task.id}));
    _workspaceCubit.patchTaskLocally(task.id, (t) => t.copyWith(status: newStatus));

    try {
      await _tasksRepository.updateTaskStatus(task.id, newStatus);
      unawaited(_activityLogRepository.logAction(
        taskId: task.id,
        action: 'status_changed',
        metadata: {'from': previousStatus, 'to': newStatus},
      ));
    } catch (e) {
      _workspaceCubit.patchTaskLocally(
          task.id, (t) => t.copyWith(status: previousStatus));
      emit(state.copyWith(
        errorTick: state.errorTick + 1,
        errorMessage: 'Could not move "${task.title}". Please try again.',
      ));
    } finally {
      final next = Set<String>.from(state.pendingTaskIds)..remove(task.id);
      emit(state.copyWith(pendingTaskIds: next));
    }
  }
}
