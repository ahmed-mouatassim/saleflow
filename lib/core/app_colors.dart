import 'package:flutter/material.dart';

/// App Color Palette - SaleFlow Pro
/// Carefully curated colors from the React design
class AppColors {
  AppColors._();

  // Primary Background
  static const Color background = Color(0xFF0F172A);
  static const Color backgroundLight = Color(0xFF1E293B);

  // Glass Effect Colors
  static const Color glassBackground = Color(0x0DFFFFFF); // 5% white
  static const Color glassBorder = Color(0x1AFFFFFF); // 10% white
  static const Color glassDark = Color(0x4D000000); // 30% black

  // Primary Colors
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryIndigo = Color(0xFF6366F1);

  // Accent Colors
  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color pink = Color(0xFFEC4899);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradient Presets
  static const LinearGradient blueToPurple = LinearGradient(
    colors: [primaryBlue, primaryIndigo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleToIndigo = LinearGradient(
    colors: [primaryPurple, primaryIndigo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Shadows with Color
  static List<BoxShadow> coloredShadow(Color color, {double opacity = 0.2}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ];
  }
}
