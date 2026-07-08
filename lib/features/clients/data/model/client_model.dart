import 'package:equatable/equatable.dart';

class ClientModel extends Equatable {
  const ClientModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.color,
    this.isActive = true,
    required this.createdAt,
    this.createdBy,
    this.notes,
    this.persona,
    this.feedback,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final String? color;
  final bool isActive;
  final DateTime createdAt;
  final String? createdBy;
  final String? notes;
  final String? persona;
  final String? feedback;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
        id: json['id'] as String,
        name: json['name'] as String,
        logoUrl: json['logo_url'] as String?,
        color: json['color'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        createdBy: json['created_by'] as String?,
        notes: json['notes'] as String?,
        persona: json['persona'] as String?,
        feedback: json['feedback'] as String?,
      );

  Map<String, dynamic> toInsertJson() => {
        'name': name,
        'logo_url': logoUrl,
        'color': color,
        'is_active': isActive,
        'notes': notes,
        'persona': persona,
        'feedback': feedback,
      };

  ClientModel copyWith({
    String? name,
    String? logoUrl,
    String? color,
    bool? isActive,
    String? notes,
    String? persona,
    String? feedback,
  }) =>
      ClientModel(
        id: id,
        name: name ?? this.name,
        logoUrl: logoUrl ?? this.logoUrl,
        color: color ?? this.color,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        createdBy: createdBy,
        notes: notes ?? this.notes,
        persona: persona ?? this.persona,
        feedback: feedback ?? this.feedback,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        logoUrl,
        color,
        isActive,
        createdAt,
        createdBy,
        notes,
        persona,
        feedback
      ];
}
