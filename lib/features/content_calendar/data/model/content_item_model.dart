import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_enums.dart';
import '../../../auth/data/model/profile_model.dart';

class ContentAttachment extends Equatable {
  const ContentAttachment({
    required this.fileName,
    required this.fileUrl,
    this.fileType,
  });

  final String fileName;
  final String fileUrl;
  final String? fileType;

  factory ContentAttachment.fromJson(Map<String, dynamic> json) =>
      ContentAttachment(
        fileName: json['file_name'] as String,
        fileUrl: json['file_url'] as String,
        fileType: json['file_type'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'file_name': fileName,
        'file_url': fileUrl,
        'file_type': fileType,
      };

  @override
  List<Object?> get props => [fileName, fileUrl, fileType];
}

class ContentItemModel extends Equatable {
  const ContentItemModel({
    required this.id,
    this.taskId,
    required this.clientId,
    required this.title,
    required this.platform,
    required this.contentType,
    required this.publishAt,
    this.caption,
    this.brief,
    this.approvalStatus = ApprovalStatus.draft,
    this.attachments = const [],
    this.copywriterId,
    this.designerId,
    this.accountManagerId,
    required this.createdAt,
    required this.updatedAt,
    this.clientName,
    this.clientColor,
    this.copywriter,
    this.designer,
    this.accountManager,
  });

  final String id;
  final String? taskId;
  final String clientId;
  final String title;
  final String platform;
  final ContentType contentType;
  final DateTime publishAt;
  final String? caption;
  final String? brief;
  final ApprovalStatus approvalStatus;
  final List<ContentAttachment> attachments;
  final String? copywriterId;
  final String? designerId;
  final String? accountManagerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? clientName;
  final String? clientColor;
  final ProfileModel? copywriter;
  final ProfileModel? designer;
  final ProfileModel? accountManager;

  factory ContentItemModel.fromJson(Map<String, dynamic> json) {
    final client = json['clients'] as Map<String, dynamic>?;
    final attachmentsJson = json['attachments'] as List<dynamic>? ?? [];
    return ContentItemModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String?,
      clientId: json['client_id'] as String,
      title: json['title'] as String,
      platform: json['platform'] as String,
      contentType: ContentTypeX.fromDb(json['content_type'] as String),
      publishAt: DateTime.parse(json['publish_at'] as String),
      caption: json['caption'] as String?,
      brief: json['brief'] as String?,
      approvalStatus:
          ApprovalStatusX.fromDb(json['approval_status'] as String? ?? 'draft'),
      attachments: attachmentsJson
          .map((a) => ContentAttachment.fromJson(a as Map<String, dynamic>))
          .toList(),
      copywriterId: json['copywriter_id'] as String?,
      designerId: json['designer_id'] as String?,
      accountManagerId: json['account_manager_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      clientName: client?['name'] as String?,
      clientColor: client?['color'] as String?,
      copywriter: json['copywriter'] != null
          ? ProfileModel.fromJson(json['copywriter'] as Map<String, dynamic>)
          : null,
      designer: json['designer'] != null
          ? ProfileModel.fromJson(json['designer'] as Map<String, dynamic>)
          : null,
      accountManager: json['account_manager'] != null
          ? ProfileModel.fromJson(json['account_manager'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'task_id': taskId,
        'client_id': clientId,
        'title': title,
        'platform': platform,
        'content_type': contentType.dbValue,
        'publish_at': publishAt.toIso8601String(),
        'caption': caption,
        'brief': brief,
        'approval_status': approvalStatus.dbValue,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'copywriter_id': copywriterId,
        'designer_id': designerId,
        'account_manager_id': accountManagerId,
      };

  ContentItemModel copyWith({
    DateTime? publishAt,
    ApprovalStatus? approvalStatus,
    String? title,
    String? caption,
    String? brief,
  }) =>
      ContentItemModel(
        id: id,
        taskId: taskId,
        clientId: clientId,
        title: title ?? this.title,
        platform: platform,
        contentType: contentType,
        publishAt: publishAt ?? this.publishAt,
        caption: caption ?? this.caption,
        brief: brief ?? this.brief,
        approvalStatus: approvalStatus ?? this.approvalStatus,
        attachments: attachments,
        copywriterId: copywriterId,
        designerId: designerId,
        accountManagerId: accountManagerId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        clientName: clientName,
        clientColor: clientColor,
        copywriter: copywriter,
        designer: designer,
        accountManager: accountManager,
      );

  @override
  List<Object?> get props => [
        id,
        taskId,
        clientId,
        title,
        platform,
        contentType,
        publishAt,
        caption,
        brief,
        approvalStatus,
        attachments,
        copywriterId,
        designerId,
        accountManagerId,
        createdAt,
        updatedAt,
      ];
}
