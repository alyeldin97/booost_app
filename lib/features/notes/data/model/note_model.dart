import 'package:equatable/equatable.dart';

class NoteModel extends Equatable {
  const NoteModel({
    required this.id,
    required this.title,
    this.content,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
  });

  final String id;
  final String title;
  final String? content;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorName;

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final author = json['profiles'] as Map<String, dynamic>?;
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      authorName: author?['full_name'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, content, createdBy, createdAt, updatedAt];
}
