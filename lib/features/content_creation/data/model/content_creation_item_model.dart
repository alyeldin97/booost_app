import 'package:equatable/equatable.dart';
import '../../../auth/data/model/profile_model.dart';

class ContentCreationItemModel extends Equatable {
  const ContentCreationItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.script,
    this.deadline,
    this.copy,
    this.driveUrl,
    this.clientId,
    this.shouldBePublishedOn,
    this.assigneeId,
    required this.createdAt,
    required this.updatedAt,
    this.clientName,
    this.clientColor,
    this.assignee,
  });

  final String id;
  final String name;
  final String? description;
  final String status;
  final String? script;
  final DateTime? deadline;
  final String? copy;
  final String? driveUrl;
  final String? clientId;
  final DateTime? shouldBePublishedOn;
  final String? assigneeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? clientName;
  final String? clientColor;
  final ProfileModel? assignee;

  factory ContentCreationItemModel.fromJson(Map<String, dynamic> json) {
    final client = json['clients'] as Map<String, dynamic>?;
    return ContentCreationItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      script: json['script'] as String?,
      deadline:
          json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      copy: json['copy'] as String?,
      driveUrl: json['drive_url'] as String?,
      clientId: json['client_id'] as String?,
      shouldBePublishedOn: json['should_be_published_on'] != null
          ? DateTime.parse(json['should_be_published_on'] as String)
          : null,
      assigneeId: json['assignee_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      clientName: client?['name'] as String?,
      clientColor: client?['color'] as String?,
      assignee: json['assignee'] != null
          ? ProfileModel.fromJson(json['assignee'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'name': name,
        'description': description,
        'status': status,
        'script': script,
        'deadline': deadline?.toIso8601String(),
        'copy': copy,
        'drive_url': driveUrl,
        'client_id': clientId,
        'should_be_published_on': shouldBePublishedOn?.toIso8601String(),
        'assignee_id': assigneeId,
      };

  ContentCreationItemModel copyWith({
    String? name,
    String? description,
    String? status,
    String? script,
    DateTime? deadline,
    String? copy,
    String? driveUrl,
    String? clientId,
    DateTime? shouldBePublishedOn,
    String? assigneeId,
  }) =>
      ContentCreationItemModel(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        status: status ?? this.status,
        script: script ?? this.script,
        deadline: deadline ?? this.deadline,
        copy: copy ?? this.copy,
        driveUrl: driveUrl ?? this.driveUrl,
        clientId: clientId ?? this.clientId,
        shouldBePublishedOn: shouldBePublishedOn ?? this.shouldBePublishedOn,
        assigneeId: assigneeId ?? this.assigneeId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        clientName: clientName,
        clientColor: clientColor,
        assignee: assignee,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        status,
        script,
        deadline,
        copy,
        driveUrl,
        clientId,
        shouldBePublishedOn,
        assigneeId,
        createdAt,
        updatedAt,
      ];
}
