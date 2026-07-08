import 'package:equatable/equatable.dart';

class BoardColumnModel extends Equatable {
  const BoardColumnModel({
    required this.status,
    required this.title,
    required this.position,
  });

  final String status;
  final String title;
  final int position;

  factory BoardColumnModel.fromJson(Map<String, dynamic> json) => BoardColumnModel(
        status: json['status'] as String,
        title: json['title'] as String,
        position: json['position'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [status, title, position];
}
