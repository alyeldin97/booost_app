import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/app_enums.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../tasks/data/model/activity_log_model.dart';
import '../../../tasks/data/model/task_model.dart';
import '../../../tasks/data/model/task_sub_models.dart';
import '../../../tasks/data/repo/activity_log_repository.dart';
import '../../../tasks/data/repo/tasks_repository.dart';

part 'task_drawer_state.dart';

/// Opened from Kanban/Calendar/Content Calendar/linked-content clicks.
/// Mutations go straight through TasksRepository; the drawer refetches its
/// own view directly for a snappy result, while the realtime pulse (via
/// WorkspaceCubit) is what propagates the change back into the other
/// views' shared task list — so there's only ever one direction of truth.
class TaskDrawerCubit extends Cubit<TaskDrawerCubitState> {
  TaskDrawerCubit(
    this._tasksRepository,
    this._activityLogRepository,
    this._storageService,
  ) : super(const TaskDrawerCubitState());

  final TasksRepository _tasksRepository;
  final ActivityLogRepository _activityLogRepository;
  final StorageService _storageService;

  Future<void> open(String taskId) async {
    emit(state.copyWith(isOpen: true, isLoading: true, errorMessage: null));
    await _refetch(taskId);
  }

  Future<void> _refetch(String taskId) async {
    try {
      final results = await Future.wait([
        _tasksRepository.getTask(taskId),
        _activityLogRepository.getActivityForTask(taskId),
      ]);
      emit(state.copyWith(
        isLoading: false,
        task: results[0] as TaskModel,
        activity: results[1] as List<ActivityLogModel>,
      ));
    } catch (e, st) {
      AppLogger.error('TaskDrawerCubit._refetch failed', e, st);
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void closeDrawer() => emit(const TaskDrawerCubitState());

  Future<void> _mutate(Future<void> Function() action) async {
    final id = state.task?.id;
    if (id == null) return;
    try {
      await action();
      await _refetch(id);
      await _activityLogRepository.logAction(taskId: id, action: 'updated');
      emit(state.copyWith(saveTick: state.saveTick + 1));
    } catch (e, st) {
      AppLogger.error('TaskDrawerCubit mutation failed', e, st);
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> updateTitle(String title) =>
      _mutate(() => _tasksRepository.updateTask(state.task!.id, {'title': title}));

  Future<void> updateDescription(String? description) => _mutate(
      () => _tasksRepository.updateTask(state.task!.id, {'description': description}));

  Future<void> updateStatus(String status) => _mutate(
      () => _tasksRepository.updateTaskStatus(state.task!.id, status));

  Future<void> updatePriority(TaskPriority priority) => _mutate(() =>
      _tasksRepository.updateTask(state.task!.id, {'priority': priority.dbValue}));

  Future<void> updateTaskType(String type) => _mutate(
      () => _tasksRepository.updateTask(state.task!.id, {'task_type': type}));

  Future<void> updateDueDate(DateTime? dueDate) => _mutate(() => _tasksRepository
      .updateTask(state.task!.id, {'due_date': dueDate?.toIso8601String()}));

  Future<void> updateClient(String clientId) => _mutate(
      () => _tasksRepository.updateTask(state.task!.id, {'client_id': clientId}));

  Future<void> toggleAssignee(String profileId) {
    final isAssigned = state.task!.assignees.any((a) => a.id == profileId);
    return _mutate(() => isAssigned
        ? _tasksRepository.removeAssignee(state.task!.id, profileId)
        : _tasksRepository.addAssignee(state.task!.id, profileId));
  }

  Future<void> togglePlatform(String platform) {
    final current = state.task!.platforms.toSet();
    if (!current.remove(platform)) current.add(platform);
    return _mutate(() => _tasksRepository.setPlatforms(state.task!.id, current.toList()));
  }

  Future<void> addLabel(String label) =>
      _mutate(() => _tasksRepository.addLabel(state.task!.id, label));

  Future<void> addChecklistItem(String title) => _mutate(() => _tasksRepository
      .addChecklistItem(state.task!.id, title, state.task!.checklistItems.length));

  Future<void> toggleChecklistItem(String itemId, bool isCompleted) =>
      _mutate(() => _tasksRepository.toggleChecklistItem(itemId, isCompleted));

  Future<void> deleteChecklistItem(String itemId) =>
      _mutate(() => _tasksRepository.deleteChecklistItem(itemId));

  Future<void> addAttachment(PlatformFile file) => _mutate(() async {
        final path = await _storageService.uploadTaskAttachment(
          taskId: state.task!.id,
          file: file,
        );
        await _tasksRepository.addAttachmentRecord(
          taskId: state.task!.id,
          fileName: file.name,
          fileUrl: path,
          fileType: file.extension,
        );
      });

  Future<void> deleteAttachment(TaskAttachmentModel attachment) => _mutate(() async {
        await _storageService.deleteAttachment(attachment.fileUrl);
        await _tasksRepository.deleteAttachmentRecord(attachment.id);
      });

  Future<String> signedAttachmentUrl(String path) =>
      _storageService.signedUrl(path);

  Future<void> addComment(String content) =>
      _mutate(() => _tasksRepository.addComment(state.task!.id, content));

  Future<void> deleteTask() async {
    final id = state.task?.id;
    if (id == null) return;
    await _tasksRepository.deleteTask(id);
    closeDrawer();
  }
}
