import 'package:flutter/material.dart';

/// ===== Costs Constants =====
/// Default values for cost calculations

class CostsConstants {
  // ===== Default Values =====
  static const double defaultSpringValue = 0.0;
  static const double defaultRibbon36mm = 0.0;
  static const double defaultRibbon18mm = 0.0;
  static const double defaultRibbon3D = 0.0;
  static const double defaultChainPrice = 0.0;
  static const double defaultElasticPrice = 0.0;

  // Packaging Defaults
  static const double defaultCorners = 0.0;
  static const double defaultTickets = 0.0;
  static const double defaultPlastic = 0.0;

  // Cost Defaults
  static const double defaultRent = 0.0;
  static const double defaultEmployees = 0.0;
  static const double defaultDiesel = 0.0;
  static const double defaultElectricity = 0.0;
  static const int defaultProduction = 0;

  // New Monthly Defaults
  static const double defaultWater = 0.0;
  static const double defaultInternet = 0.0;
  static const double defaultMaintenance = 0.0;
  static const double defaultTransport = 0.0;
  static const double defaultMarketing = 0.0;
  static const double defaultOtherMonthly = 0.0;

  // New Packaging Defaults
  static const double defaultScotch = 0.0;
  static const double defaultOtherPackaging = 0.0;

  // New Sfifa Defaults
  static const double defaultThread = 0.0;

  // Spring Defaults
  static const double defaultSpringSachet = 0.0;
}

/// ===== Costs Theme =====
/// UI Theme for Costs Screen
class CostsTheme {
  // ===== Primary Colors =====
  static const Color primaryStart = Color(0xFF6366F1); // Indigo
  static const Color primaryEnd = Color(0xFF8B5CF6); // Purple

  // ===== Background Colors =====
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color cardDark = Color(0xFF0F3460);

  // ===== Text Colors =====
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFA78BFA);
  static const Color textMuted = Color(0xFF64748B);

  // ===== Gradients =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
  );

  static const TextStyle labelStyle = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14,
    color: textSecondary,
  );

  static const TextStyle valueStyle = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
  );
}
