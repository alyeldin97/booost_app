import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF6D28D9);
  static const primaryLight = Color(0xFFF1EBFE);
  static const primaryDark = Color(0xFF4C1D95);
  static const accent = Color(0xFF06B6D4);
  static const accentLight = Color(0xFFECFEFF);

  static const background = Color(0xFFF7F7FC);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE7E5F5);

  static const textPrimary = Color(0xFF1E1B2E);
  static const textSecondary = Color(0xFF6B6483);
  static const textMuted = Color(0xFFA39FBC);

  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFE11D48);
  static const info = Color(0xFF0EA5E9);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D28D9), Color(0xFFDB2777)],
  );

  static const sidebarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF241B3E), Color(0xFF150F27)],
  );

  // Priority
  static const priorityLow = Color(0xFF64748B);
  static const priorityMedium = Color(0xFF0EA5E9);
  static const priorityHigh = Color(0xFFF59E0B);
  static const priorityUrgent = Color(0xFFE11D48);

  // Content approval status
  static const approvalDraft = Color(0xFF94A3B8);
  static const approvalInternalReview = Color(0xFF0EA5E9);
  static const approvalClientReview = Color(0xFFF59E0B);
  static const approvalApproved = Color(0xFF16A34A);
  static const approvalPublished = Color(0xFF9333EA);

  /// Deterministic fallback palette for clients without an explicit
  /// `color` value, keyed by a stable hash of the client id.
  static const clientPalette = <Color>[
    Color(0xFF6D28D9),
    Color(0xFF0EA5E9),
    Color(0xFF16A34A),
    Color(0xFFF59E0B),
    Color(0xFFDB2777),
    Color(0xFF9333EA),
    Color(0xFF0D9488),
    Color(0xFFE11D48),
  ];

  static Color clientColorFor(String clientId) {
    final hash = clientId.codeUnits.fold<int>(0, (acc, c) => acc + c);
    return clientPalette[hash % clientPalette.length];
  }

  /// Vivid, distinct palette for dynamically-created Kanban/status columns,
  /// cycled by column position so colors stay stable as columns are
  /// renamed but shift if columns are reordered/deleted.
  static const columnPalette = <Color>[
    Color(0xFF64748B),
    Color(0xFF2563EB),
    Color(0xFFF59E0B),
    Color(0xFF9333EA),
    Color(0xFF16A34A),
    Color(0xFFE11D48),
    Color(0xFF0D9488),
    Color(0xFFDB2777),
  ];

  static Color columnColorFor(int position) =>
      columnPalette[position % columnPalette.length];
}
