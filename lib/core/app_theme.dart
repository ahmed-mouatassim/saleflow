import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App Theme Configuration
/// Provides consistent styling across the application
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPurple,
        secondary: AppColors.primaryBlue,
        surface: AppColors.backgroundLight,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.tajawalTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.tajawal(
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Common Border Radius Values
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 32.0;
  static const double radiusXLarge = 40.0;

  // Common Padding Values
  static const EdgeInsets paddingSmall = EdgeInsets.all(8);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24);
  static const EdgeInsets paddingXLarge = EdgeInsets.all(32);

  // Glass Container Decoration
  static BoxDecoration glassDecoration({
    double borderRadius = radiusLarge,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: AppColors.glassBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? AppColors.glassBorder, width: 1),
    );
  }

  // Dark Glass Decoration
  static BoxDecoration glassDarkDecoration({
    double borderRadius = radiusLarge,
  }) {
    return BoxDecoration(
      color: AppColors.glassDark,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.glassBorder.withValues(alpha: 0.5),
        width: 1,
      ),
    );
  }
}
