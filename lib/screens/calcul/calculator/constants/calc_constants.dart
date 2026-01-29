import 'package:flutter/material.dart';

/// ===== Calculator Constants =====
/// All static data, colors, and configurations for the calculator

class CalcConstants {
  // ===== Sponge Types with Coefficients =====
  static const Map<String, int> spongeTypes = {
    'D22': 2184,
    'D20': 1820,
    'ABS': 2635,
    'D33': 1490,
    'HR D35': 4000,
    'D33+ABS': 1450,
    'D18': 925,
  };

  // ===== Footer Information =====
  static const Map<String, double> footerTypes = {'footer_1m*2': 11.88};

  // ===== Dress Types with Prices =====
  static const Map<String, double> dressTypes = {
    'NEWDORSAL': 58,
    'OCTAVIAa': 58,
    'ABS': 60,
    'HR': 60,
    'ANIR': 50,
    'ANATALYA': 47,
    'MARIBELLE': 47,
    'NAMASTE': 42,
    'FORMIDABLE': 42,
    'VERAFLEX': 58,
    'BAYT EL BADIAA': 50,
  };

  // ===== Default Values =====
  static const double defaultSpringValue = 0.919;
  static const double defaultRibbon36mm = 0.55;
  static const double defaultRibbon18mm = 0.35;
  static const double defaultRibbon3D = 2.50;
  static const double defaultChainPrice = 8.0;
  static const double defaultElasticPrice = 1.5;
  static const int defaultSfifaNum1 = 3;
  static const int defaultSfifaNum2 = 2;
  static const int defaultSfifaNum3 = 1;
  static const int defaultNumChain = 3;
  static const int defaultNumElastic = 0;

  // Packaging Defaults
  static const double defaultCorners = 6.5;
  static const double defaultTickets = 3.20;
  static const double defaultLargeFlyer = 2.20;
  static const double defaultSmallFlyer = 1.40;
  static const double defaultPlastic = 20.0;
  static const double defaultScotch = 3.0;
  static const double defaultGlue = 17.0;
  static const double defaultAdding = 0.0;

  // Cost Defaults
  static const double defaultRent = 8000;
  static const double defaultEmployees = 28575;
  static const double defaultDiesel = 8400;
  static const double defaultCnss = 4200;
  static const double defaultTva = 400;
  static const double defaultElectricity = 1000;
  static const double defaultPhone = 600;
  static const double defaultDesktop = 300;
  static const double defaultMachineFix = 300;
  static const double defaultRepairs = 0;
  static const int defaultProduction = 20;
}

/// ===== Calculator Theme =====
/// Premium Modern UI with Glassmorphism & Neumorphism

class CalcTheme {
  // ===== Primary Colors (Vibrant Gradient) =====
  static const Color primaryStart = Color(0xFF7C3AED); // Violet 600
  static const Color primaryEnd = Color(0xFFDB2777); // Pink 600
  static const Color primaryMid = Color(0xFFA855F7); // Purple 500
  static const Color accent = Color(0xFF06B6D4); // Cyan 500
  static const Color accentSecondary = Color(0xFF14B8A6); // Teal 500
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500

  // ===== Decorative Colors =====
  static const Color glow = Color(0xFF8B5CF6); // Purple glow
  static const Color shimmer = Color(0xFFE879F9); // Fuchsia shimmer
  static const Color headerAccent = Color(0xFF4F46E5); // Indigo

  // ===== Background Colors (Deep & Rich) =====
  static const Color backgroundDark = Color(0xFF0A0F1C); // Deep navy
  static const Color surfaceDark = Color(0xFF131B2E); // Dark slate
  static const Color cardDark = Color(0xFF1E293B); // Slate 800
  static const Color cardDarkHover = Color(0xFF2D3A4F); // Lighter slate

  // ===== Light Mode (Clean & Fresh) =====
  static const Color backgroundLight = Color(0xFFF5F3FF); // Violet 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF3E8FF); // Purple 50
  static const Color cardLightHover = Color(0xFFE9D5FF); // Purple 100

  // ===== Text Colors =====
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFA78BFA); // Violet 400
  static const Color textPrimaryLight = Color(0xFF1E1B4B); // Indigo 950
  static const Color textSecondaryLight = Color(0xFF6B21A8); // Purple 800

  // ===== Premium Gradients =====
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryMid, primaryEnd],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF4F46E5), // Indigo
      Color(0xFF7C3AED), // Violet
      Color(0xFFA855F7), // Purple
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF14B8A6)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  );

  // ===== Premium Glassmorphism Effect =====
  static BoxDecoration glassEffect(bool isDark) => BoxDecoration(
    color: (isDark ? surfaceDark : surfaceLight).withValues(
      alpha: isDark ? 0.6 : 0.8,
    ),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: (isDark ? primaryMid : primaryStart).withValues(alpha: 0.2),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryStart.withValues(alpha: isDark ? 0.15 : 0.08),
        blurRadius: 30,
        spreadRadius: -5,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
        blurRadius: 15,
        spreadRadius: 0,
        offset: const Offset(0, 5),
      ),
    ],
  );

  // ===== Elevated Glass Card =====
  static BoxDecoration elevatedGlass(bool isDark) => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              cardDark.withValues(alpha: 0.8),
              surfaceDark.withValues(alpha: 0.6),
            ]
          : [
              surfaceLight.withValues(alpha: 0.95),
              cardLight.withValues(alpha: 0.7),
            ],
    ),
    borderRadius: BorderRadius.circular(28),
    border: Border.all(
      color: (isDark ? glow : primaryStart).withValues(alpha: 0.25),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: glow.withValues(alpha: isDark ? 0.2 : 0.1),
        blurRadius: 40,
        spreadRadius: -10,
        offset: const Offset(0, 15),
      ),
    ],
  );

  // ===== Input Decoration =====
  static InputDecoration inputDecoration({
    required String label,
    required String hint,
    required bool isDark,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: primaryStart, size: 20)
          : null,
      labelStyle: TextStyle(
        color: isDark ? textSecondaryDark : textSecondaryLight,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: (isDark ? textSecondaryDark : textSecondaryLight).withValues(
          alpha: 0.6,
        ),
      ),
      filled: true,
      fillColor: (isDark ? cardDark : cardLight).withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: (isDark ? Colors.white : primaryStart).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryStart, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: error, width: 1),
      ),
    );
  }

  // ===== Button Styles =====
  static ButtonStyle primaryButton() => ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 0,
  );

  static ButtonStyle dangerButton() => ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: error,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  );

  // ===== Text Styles =====
  static TextStyle headingStyle(bool isDark) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: isDark ? textPrimaryDark : textPrimaryLight,
    fontFamily: 'Tajawal',
  );

  static TextStyle sectionTitleStyle(bool isDark) => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryStart,
    fontFamily: 'Tajawal',
  );

  static TextStyle labelStyle(bool isDark) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: isDark ? textSecondaryDark : textSecondaryLight,
    fontFamily: 'Tajawal',
  );

  static TextStyle valueStyle(bool isDark) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: isDark ? textPrimaryDark : textPrimaryLight,
    fontFamily: 'Tajawal',
  );
}
