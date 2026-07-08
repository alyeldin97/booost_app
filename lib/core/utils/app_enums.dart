import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../styling/app_colors.dart';

// Kanban/task status is a fully dynamic, user-managed list backed by the
// `board_columns` table (see BoardColumnsRepository) rather than a fixed
// enum, so columns can be renamed, created, and deleted at runtime.

enum TaskPriority { low, medium, high, urgent }

extension TaskPriorityX on TaskPriority {
  static TaskPriority fromDb(String value) => TaskPriority.values.firstWhere(
        (e) => e.dbValue == value,
        orElse: () => TaskPriority.medium,
      );

  String get dbValue => name;

  String get label => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
        TaskPriority.urgent => 'Urgent',
      };

  Color get color => switch (this) {
        TaskPriority.low => AppColors.priorityLow,
        TaskPriority.medium => AppColors.priorityMedium,
        TaskPriority.high => AppColors.priorityHigh,
        TaskPriority.urgent => AppColors.priorityUrgent,
      };
}

// Task types and platforms are also fully dynamic, user-managed lookup
// lists (see TaskTypesRepository / PlatformsRepository) rather than fixed
// enums, so they can be renamed, created, and deleted at runtime. Since
// user-created platforms have no matching brand glyph, every platform
// renders with this one generic icon.
const IconData genericPlatformIcon = LucideIcons.share2;

/// The seeded platform vocabulary (Facebook/Instagram/TikTok) gets a
/// recognizable icon + brand-ish color; anything else falls back to the
/// generic platform look.
(IconData, Color) platformStyle(String platformKey) => switch (platformKey) {
      'instagram' => (LucideIcons.camera, const Color(0xFFDB2777)),
      'facebook' => (LucideIcons.thumbsUp, const Color(0xFF1877F2)),
      'tiktok' => (LucideIcons.music2, const Color(0xFF0F172A)),
      _ => (genericPlatformIcon, AppColors.textSecondary),
    };

enum ContentType { reel, post, story, carousel, ad, email, blog, landingPage }

extension ContentTypeX on ContentType {
  static ContentType fromDb(String value) => ContentType.values.firstWhere(
        (e) => e.dbValue == value,
        orElse: () => ContentType.post,
      );

  String get dbValue => switch (this) {
        ContentType.landingPage => 'landing_page',
        _ => name,
      };

  String get label => switch (this) {
        ContentType.reel => 'Reel',
        ContentType.post => 'Post',
        ContentType.story => 'Story',
        ContentType.carousel => 'Carousel',
        ContentType.ad => 'Ad',
        ContentType.email => 'Email',
        ContentType.blog => 'Blog',
        ContentType.landingPage => 'Landing Page',
      };
}

enum ApprovalStatus { draft, internalReview, clientReview, approved, published }

extension ApprovalStatusX on ApprovalStatus {
  static ApprovalStatus fromDb(String value) =>
      ApprovalStatus.values.firstWhere(
        (e) => e.dbValue == value,
        orElse: () => ApprovalStatus.draft,
      );

  String get dbValue => switch (this) {
        ApprovalStatus.internalReview => 'internal_review',
        ApprovalStatus.clientReview => 'client_review',
        _ => name,
      };

  String get label => switch (this) {
        ApprovalStatus.draft => 'Draft',
        ApprovalStatus.internalReview => 'Internal Review',
        ApprovalStatus.clientReview => 'Client Review',
        ApprovalStatus.approved => 'Approved',
        ApprovalStatus.published => 'Published',
      };

  Color get color => switch (this) {
        ApprovalStatus.draft => AppColors.approvalDraft,
        ApprovalStatus.internalReview => AppColors.approvalInternalReview,
        ApprovalStatus.clientReview => AppColors.approvalClientReview,
        ApprovalStatus.approved => AppColors.approvalApproved,
        ApprovalStatus.published => AppColors.approvalPublished,
      };
}
