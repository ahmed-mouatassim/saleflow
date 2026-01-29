import 'package:flutter/material.dart';
import '../constants/calc_constants.dart';

/// ===== Section Title Widget =====
/// A premium styled section header with gradient accent and glow effects
class SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool showDivider;
  final Color? accentColor;

  const SectionTitle({
    super.key,
    required this.title,
    this.icon,
    this.showDivider = true,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveAccent = accentColor ?? CalcTheme.primaryStart;

    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Animated gradient accent line with glow
              Container(
                width: 5,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [effectiveAccent, CalcTheme.primaryEnd],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: effectiveAccent.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        effectiveAccent.withValues(alpha: 0.15),
                        CalcTheme.primaryEnd.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: effectiveAccent.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(icon, color: effectiveAccent, size: 22),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      isDark
                          ? CalcTheme.textPrimaryDark
                          : CalcTheme.textPrimaryLight,
                      effectiveAccent,
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ).createShader(bounds),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Tajawal',
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 14),
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    effectiveAccent.withValues(alpha: 0.5),
                    effectiveAccent.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ===== Glass Card Widget =====
/// A container with Glassmorphism effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassCard({super.key, required this.child, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: CalcTheme.glassEffect(isDark),
      child: child,
    );
  }
}
