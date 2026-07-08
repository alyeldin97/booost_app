import 'package:equatable/equatable.dart';

class ActivityLogModel extends Equatable {
  const ActivityLogModel({
    required this.id,
    this.actorId,
    this.taskId,
    this.contentItemId,
    required this.action,
    this.metadata = const {},
    required this.createdAt,
    this.actorName,
    this.actorAvatarUrl,
  });

  final String id;
  final String? actorId;
  final String? taskId;
  final String? contentItemId;
  final String action;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final String? actorName;
  final String? actorAvatarUrl;

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    final actor = json['profiles'] as Map<String, dynamic>?;
    return ActivityLogModel(
      id: json['id'] as String,
      actorId: json['actor_id'] as String?,
      taskId: json['task_id'] as String?,
      contentItemId: json['content_item_id'] as String?,
      action: json['action'] as String,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
      createdAt: DateTime.parse(json['created_at'] as String),
      actorName: actor?['full_name'] as String?,
      actorAvatarUrl: actor?['avatar_url'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, actorId, taskId, contentItemId, action, metadata, createdAt];
}
