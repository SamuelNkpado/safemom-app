import 'package:flutter/material.dart';

/// SafeMom colour palette. See DESIGN_SYSTEM.md.
///
/// Hard rule: never hardcode a colour in a widget file. Always reference
/// [AppColors]. Never use Flutter's Colors.red — use [AppColors.emergencyRed]
/// and only for actual emergencies.
class AppColors {
  AppColors._();

  // Primary palette (60-30-10)
  static const Color cream = Color(0xFFFAF7F2); // 60% app background
  static const Color teal = Color(0xFF2E7D7D); // 30% brand, primary actions
  static const Color coral = Color(0xFFE76F51); // 10% non-emergency CTAs

  // Semantic
  static const Color emergencyRed = Color(0xFFC0392B);
  static const Color successGreen = Color(0xFF27AE60);
  static const Color warningAmber = Color(0xFFF39C12);
  static const Color infoBlue = Color(0xFF185FA5);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5F5E5A);
  static const Color textTertiary = Color(0xFF888780);
  static const Color textOnColor = Color(0xFFFFFFFF);

  // Surfaces
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color softTeal = Color(0xFFE1F0F0);
  static const Color softCoral = Color(0xFFFCE5DD);
  static const Color borderDefault = Color(0xFFE1E0DA);
}
