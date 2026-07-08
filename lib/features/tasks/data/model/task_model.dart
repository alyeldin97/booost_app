import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_enums.dart';
import '../../../auth/data/model/profile_model.dart';
import 'task_sub_models.dart';

class TaskModel extends Equatable {
  const TaskModel({
    required this.id,
    required this.clientId,
    required this.title,
    this.description,
    this.status = 'todo',
    this.priority = TaskPriority.medium,
    this.taskType = 'Internal',
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.assignees = const [],
    this.platforms = const [],
    this.labels = const [],
    this.checklistItems = const [],
    this.attachments = const [],
    this.comments = const [],
    this.linkedContentItemId,
    this.clientName,
    this.clientColor,
  });

  final String id;
  final String clientId;
  final String title;
  final String? description;
  final String status;
  final TaskPriority priority;
  final String taskType;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final List<ProfileModel> assignees;
  final List<String> platforms;
  final List<String> labels;
  final List<TaskChecklistItemModel> checklistItems;
  final List<TaskAttachmentModel> attachments;
  final List<TaskCommentModel> comments;
  final String? linkedContentItemId;

  // Denormalized convenience fields populated by joined selects, so cards
  // don't need a separate client lookup.
  final String? clientName;
  final String? clientColor;

  int get checklistCompletedCount =>
      checklistItems.where((c) => c.isCompleted).length;

  double get checklistProgress => checklistItems.isEmpty
      ? 0
      : checklistCompletedCount / checklistItems.length;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final client = json['clients'] as Map<String, dynamic>?;
    final assigneesJson = json['task_assignees'] as List<dynamic>? ?? [];
    final platformsJson = json['task_platforms'] as List<dynamic>? ?? [];
    final labelsJson = json['task_labels'] as List<dynamic>? ?? [];
    final checklistJson =
        json['task_checklist_items'] as List<dynamic>? ?? [];
    final attachmentsJson = json['task_attachments'] as List<dynamic>? ?? [];
    final commentsJson = json['task_comments'] as List<dynamic>? ?? [];
    final contentItems = json['content_items'] as List<dynamic>? ?? [];

    return TaskModel(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'todo',
      priority:
          TaskPriorityX.fromDb(json['priority'] as String? ?? 'medium'),
      taskType: json['task_type'] as String? ?? 'Internal',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      assignees: assigneesJson
          .map((a) => a['profiles'] as Map<String, dynamic>?)
          .whereType<Map<String, dynamic>>()
          .map(ProfileModel.fromJson)
          .toList(),
      platforms: platformsJson
          .map((p) => p['platform'] as String)
          .toList(),
      labels: labelsJson.map((l) => l['label'] as String).toList(),
      checklistItems: checklistJson
          .map((c) => TaskChecklistItemModel.fromJson(c as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position)),
      attachments: attachmentsJson
          .map((a) => TaskAttachmentModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      comments: commentsJson
          .map((c) => TaskCommentModel.fromJson(c as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      linkedContentItemId:
          contentItems.isNotEmpty ? contentItems.first['id'] as String? : null,
      clientName: client?['name'] as String?,
      clientColor: client?['color'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'client_id': clientId,
        'title': title,
        'description': description,
        'status': status,
        'priority': priority.dbValue,
        'task_type': taskType,
        'due_date': dueDate?.toIso8601String(),
      };

  TaskModel copyWith({
    String? title,
    String? description,
    String? status,
    TaskPriority? priority,
    String? taskType,
    DateTime? dueDate,
    bool clearDueDate = false,
    List<ProfileModel>? assignees,
    List<String>? platforms,
    List<String>? labels,
    List<TaskChecklistItemModel>? checklistItems,
    List<TaskAttachmentModel>? attachments,
    List<TaskCommentModel>? comments,
  }) =>
      TaskModel(
        id: id,
        clientId: clientId,
        title: title ?? this.title,
        description: description ?? this.description,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        taskType: taskType ?? this.taskType,
        dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
        createdAt: createdAt,
        updatedAt: updatedAt,
        createdBy: createdBy,
        assignees: assignees ?? this.assignees,
        platforms: platforms ?? this.platforms,
        labels: labels ?? this.labels,
        checklistItems: checklistItems ?? this.checklistItems,
        attachments: attachments ?? this.attachments,
        comments: comments ?? this.comments,
        linkedContentItemId: linkedContentItemId,
        clientName: clientName,
        clientColor: clientColor,
      );

  @override
  List<Object?> get props => [
        id,
        clientId,
        title,
        description,
        status,
        priority,
        taskType,
        dueDate,
        createdAt,
        updatedAt,
        createdBy,
        assignees,
        platforms,
        labels,
        checklistItems,
        attachments,
        comments,
        linkedContentItemId,
      ];
}
