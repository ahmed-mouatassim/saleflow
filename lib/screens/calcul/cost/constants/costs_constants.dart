import 'package:flutter/material.dart';

/// ===== Costs Constants =====
/// Default values for cost calculations

class CostsConstants {
  // ===== Default Values =====
  static const double defaultSpringValue = 0.919;
  static const double defaultSpringSachetValue = 1.20;
  static const double defaultRibbon36mm = 0.55;
  static const double defaultRibbon18mm = 0.35;
  static const double defaultRibbon3D = 2.50;
  static const double defaultChainPrice = 8.0;
  static const double defaultElasticPrice = 1.5;

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
