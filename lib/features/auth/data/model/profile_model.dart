import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  const ProfileModel({
    required this.id,
    this.fullName,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;

  String get displayName =>
      (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : 'Unnamed';

  String get initials {
    final name = displayName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        fullName: json['full_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        role: json['role'] as String? ?? 'member',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'role': role,
      };

  ProfileModel copyWith({String? fullName, String? avatarUrl, String? role}) =>
      ProfileModel(
        id: id,
        fullName: fullName ?? this.fullName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        role: role ?? this.role,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, fullName, avatarUrl, role, createdAt];
}
