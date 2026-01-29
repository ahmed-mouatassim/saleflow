import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_theme.dart';

/// Stats Card Widget
/// Displays a KPI metric with icon, label, and value
/// Matches the React StatsCard component exactly
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final StatsCardColor color;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  Color get _iconColor {
    switch (color) {
      case StatsCardColor.blue:
        return AppColors.primaryBlue;
      case StatsCardColor.purple:
        return AppColors.primaryPurple;
      case StatsCardColor.green:
        return AppColors.emerald;
      case StatsCardColor.red:
        return AppColors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassDecoration(borderRadius: 20),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: _iconColor),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum StatsCardColor { blue, purple, green, red }
