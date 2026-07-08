import 'package:equatable/equatable.dart';

class TaskTypeModel extends Equatable {
  const TaskTypeModel({
    required this.taskType,
    required this.title,
    required this.position,
  });

  final String taskType;
  final String title;
  final int position;

  factory TaskTypeModel.fromJson(Map<String, dynamic> json) => TaskTypeModel(
        taskType: json['task_type'] as String,
        title: json['title'] as String,
        position: json['position'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [taskType, title, position];
}
