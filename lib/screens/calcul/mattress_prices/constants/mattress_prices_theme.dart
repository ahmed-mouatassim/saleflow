import 'package:flutter/material.dart';

/// ثوابت وألوان شاشة أسعار المراتب
class MattressPricesTheme {
  // الألوان الأساسية
  static const Color primaryStart = Color(0xFF6C5CE7);
  static const Color primaryEnd = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFFE94560);

  // ألوان الخلفية
  static const Color backgroundDark = Color(0xFF0F0F23);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);

  // ألوان النص
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB2B2B2);
  static const Color textMuted = Color(0xFF6B7280);

  // ألوان الجدول
  static const Color headerBg = Color(0xFF2D1B69);
  static const Color headerText = Color(0xFFFFFFFF);
  static const Color rowEven = Color(0xFF1A1A2E);
  static const Color rowOdd = Color(0xFF16213E);
  static const Color cellBorder = Color(0xFF374151);
  static const Color cellHover = Color(0xFF3B2F63);
  static const Color cellSelected = Color(0xFF6C5CE7);

  // ألوان الأسعار
  static const Color priceAvailable = Color(0xFF10B981);
  static const Color priceUnavailable = Color(0xFF6B7280);

  // الظلال
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.3),
    blurRadius: 20,
    offset: const Offset(0, 10),
  );

  static BoxShadow get glowShadow => BoxShadow(
    color: primaryStart.withValues(alpha: 0.3),
    blurRadius: 30,
    spreadRadius: 5,
  );

  // التدرجات
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, surfaceDark, cardDark],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2D1B69), Color(0xFF4A3298)],
  );

  // أنماط النص الافتراضية
  static const TextStyle TajawalStyle = TextStyle(fontFamily: 'Tajawal');
}

/// أبعاد الجدول
class MattressTableDimensions {
  static const double nameColumnWidth = 140.0;
  static const double priceColumnWidth =
      70.0; // عرض أصغر لتناسب أكثر على الشاشة
  static const double headerHeight = 50.0;
  static const double rowHeight = 44.0;
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
}
