import 'package:flutter/material.dart';

class AppColors {
  // Primary — Sea Green (warmer, less muddy than the old dark green)
  static const Color primary = Color(0xFF2E8B57);
  static const Color primaryLight = Color(0xFF3AA868);
  static const Color primaryDark = Color(0xFF1A6B3C);

  // Accent — Amber (unchanged, works great)
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);

  // === LIGHT THEME (white body, as you requested) ===
  static const Color backgroundLight = Color(0xFFFFFFFF); // pure white body
  static const Color surfaceLight = Color(0xFFF9FAFB); // cards / input fill
  static const Color cardLight = Color(0xFFFFFFFF);

  // === DARK THEME (deep navy-gray, not black-green) ===
  static const Color backgroundDark = Color(0xFF111827); // Tailwind gray-900
  static const Color surface = Color(0xFF1F2937); // gray-800
  static const Color cardDark = Color(0xFF1F2937);

  // Semantic — price comparison
  static const Color cheapestGreen = Color(0xFF4CAF50); // light theme
  static const Color cheapestGreenDark =
      Color(0xFF4ADE80); // dark theme (brighter)
  static const Color cheapestBg = Color(0xFFE8F5EE); // light chip bg
  static const Color expensiveRed = Color(0xFFEF4444);

  // Text
  static const Color textPrimary = Color(0xFFF9FAFB); // dark theme body text
  static const Color textSecondary = Color(0xFF9CA3AF); // dark theme muted
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textPrimaryLight =
      Color(0xFF111827); // light theme body text
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // Dividers
  static const Color dividerDark = Color(0xFF374151);
  static const Color dividerLight = Color(0xFFE5E7EB);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
