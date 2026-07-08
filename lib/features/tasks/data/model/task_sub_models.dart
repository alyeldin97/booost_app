import 'package:equatable/equatable.dart';

class TaskChecklistItemModel extends Equatable {
  const TaskChecklistItemModel({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.position = 0,
  });

  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final int position;

  factory TaskChecklistItemModel.fromJson(Map<String, dynamic> json) =>
      TaskChecklistItemModel(
        id: json['id'] as String,
        taskId: json['task_id'] as String,
        title: json['title'] as String,
        isCompleted: json['is_completed'] as bool? ?? false,
        position: json['position'] as int? ?? 0,
      );

  TaskChecklistItemModel copyWith({String? title, bool? isCompleted}) =>
      TaskChecklistItemModel(
        id: id,
        taskId: taskId,
        title: title ?? this.title,
        isCompleted: isCompleted ?? this.isCompleted,
        position: position,
      );

  @override
  List<Object?> get props => [id, taskId, title, isCompleted, position];
}

class TaskAttachmentModel extends Equatable {
  const TaskAttachmentModel({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.fileUrl,
    this.fileType,
    this.uploadedBy,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final String fileName;
  final String fileUrl;
  final String? fileType;
  final String? uploadedBy;
  final DateTime createdAt;

  factory TaskAttachmentModel.fromJson(Map<String, dynamic> json) =>
      TaskAttachmentModel(
        id: json['id'] as String,
        taskId: json['task_id'] as String,
        fileName: json['file_name'] as String,
        fileUrl: json['file_url'] as String,
        fileType: json['file_type'] as String?,
        uploadedBy: json['uploaded_by'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  @override
  List<Object?> get props =>
      [id, taskId, fileName, fileUrl, fileType, uploadedBy, createdAt];
}

class TaskCommentModel extends Equatable {
  const TaskCommentModel({
    required this.id,
    required this.taskId,
    this.profileId,
    required this.content,
    required this.createdAt,
    this.authorName,
    this.authorAvatarUrl,
  });

  final String id;
  final String taskId;
  final String? profileId;
  final String content;
  final DateTime createdAt;
  final String? authorName;
  final String? authorAvatarUrl;

  factory TaskCommentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return TaskCommentModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      profileId: json['profile_id'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorName: profile?['full_name'] as String?,
      authorAvatarUrl: profile?['avatar_url'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, taskId, profileId, content, createdAt, authorName, authorAvatarUrl];
}
