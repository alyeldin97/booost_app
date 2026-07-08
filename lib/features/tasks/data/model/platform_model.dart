import 'package:equatable/equatable.dart';

class PlatformModel extends Equatable {
  const PlatformModel({
    required this.platform,
    required this.title,
    required this.position,
  });

  final String platform;
  final String title;
  final int position;

  factory PlatformModel.fromJson(Map<String, dynamic> json) => PlatformModel(
        platform: json['platform'] as String,
        title: json['title'] as String,
        position: json['position'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [platform, title, position];
}
