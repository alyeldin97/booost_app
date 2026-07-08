import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle _base = TextStyle(color: AppColors.textPrimary);

  static TextStyle get h1 =>
      _base.copyWith(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2);
  static TextStyle get h2 =>
      _base.copyWith(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25);
  static TextStyle get h3 =>
      _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3);
  static TextStyle get subtitle =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3);
  static TextStyle get body => _base.copyWith(fontSize: 14, height: 1.4);
  static TextStyle get bodyMedium =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);
  static TextStyle get caption => _base.copyWith(
      fontSize: 12, color: AppColors.textSecondary, height: 1.3);
  static TextStyle get label => _base.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      letterSpacing: 0.4);
  static TextStyle get button =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600);
}
