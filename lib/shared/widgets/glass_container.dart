import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/app_colors.dart';

/// Glass Container Widget
/// Creates a glassmorphism effect container matching the React design
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isDark;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 32,
    this.padding,
    this.margin,
    this.isDark = false,
    this.borderColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isDark ? 16 : 12,
            sigmaY: isDark ? 16 : 12,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: isDark ? AppColors.glassDark : AppColors.glassBackground,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color:
                    borderColor ??
                    (isDark
                        ? AppColors.glassBorder.withValues(alpha: 0.5)
                        : AppColors.glassBorder),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glass Card - Simple preset for cards
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 32,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: GlassContainer(
          borderRadius: borderRadius,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
