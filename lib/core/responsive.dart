import 'package:flutter/material.dart';

/// Responsive Helper Utility
/// Provides breakpoints and responsive utilities for adaptive layouts
class Responsive {
  Responsive._();

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Check if screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get responsive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? desktop;
    return desktop;
  }

  /// Get responsive padding
  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.all(
      value(context, mobile: 16.0, tablet: 24.0, desktop: 32.0),
    );
  }

  /// Get sidebar width (0 for mobile - drawer instead)
  static double sidebarWidth(BuildContext context) {
    if (isMobile(context)) return 0;
    if (isTablet(context)) return 240;
    return 280;
  }

  /// Get card width for stats cards
  static double statsCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return width - 32; // Full width minus padding
    if (width < 600) return (width - 48) / 2; // 2 columns
    if (width < 900) return (width - 64) / 3; // 3 columns
    return 260; // Fixed width on desktop
  }

  /// Get number of columns for grid layouts
  static int gridColumns(BuildContext context) {
    return value(context, mobile: 1, tablet: 2, desktop: 4);
  }
}

/// Responsive Builder Widget
/// Allows building different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  )
  builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(
          context,
          Responsive.isMobile(context),
          Responsive.isTablet(context),
          Responsive.isDesktop(context),
        );
      },
    );
  }
}
