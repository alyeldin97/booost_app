part of 'task_drawer_cubit.dart';

class TaskDrawerCubitState extends Equatable {
  const TaskDrawerCubitState({
    this.isOpen = false,
    this.isLoading = false,
    this.task,
    this.activity = const [],
    this.errorMessage,
    this.saveTick = 0,
  });

  final bool isOpen;
  final bool isLoading;
  final TaskModel? task;
  final List<ActivityLogModel> activity;
  final String? errorMessage;
  final int saveTick;

  TaskDrawerCubitState copyWith({
    bool? isOpen,
    bool? isLoading,
    TaskModel? task,
    bool clearTask = false,
    List<ActivityLogModel>? activity,
    String? errorMessage,
    int? saveTick,
  }) =>
      TaskDrawerCubitState(
        isOpen: isOpen ?? this.isOpen,
        isLoading: isLoading ?? this.isLoading,
        task: clearTask ? null : (task ?? this.task),
        activity: activity ?? this.activity,
        errorMessage: errorMessage,
        saveTick: saveTick ?? this.saveTick,
      );

  @override
  List<Object?> get props =>
      [isOpen, isLoading, task, activity, errorMessage, saveTick];
}
