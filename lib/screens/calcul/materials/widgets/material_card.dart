import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../calculator/constants/calc_constants.dart';
import '../models/material_item.dart';

/// ===== Material Card Widget =====
/// بطاقة عرض مادة واحدة مع أزرار التعديل والحذف
class MaterialCard extends StatelessWidget {
  final MaterialItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isSaving;

  const MaterialCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onEdit();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getTypeColor(item.type).withValues(alpha: 0.2),
                        _getTypeColor(item.type).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(item.type),
                    color: _getTypeColor(item.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Name & Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(
                                item.type,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.typeLabel,
                              style: TextStyle(
                                color: _getTypeColor(item.type),
                                fontFamily: 'Tajawal',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (item.editedBy != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.person_outline_rounded,
                              size: 12,
                              color: Colors.white38,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item.editedBy!,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontFamily: 'Tajawal',
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Price Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [CalcTheme.primaryStart, CalcTheme.primaryEnd],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: CalcTheme.primaryStart.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _formatPrice(item.price),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit Button
                    _ActionButton(
                      icon: Icons.edit_rounded,
                      color: CalcTheme.warning,
                      onTap: isSaving ? null : onEdit,
                      tooltip: 'تعديل',
                    ),
                    const SizedBox(width: 4),
                    // Delete Button
                    _ActionButton(
                      icon: Icons.delete_rounded,
                      color: CalcTheme.error,
                      onTap: isSaving ? null : onDelete,
                      tooltip: 'حذف',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return '${price.toInt()} درهم';
    }
    return '${price.toStringAsFixed(2)} درهم';
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'spongeTypes':
        return Icons.layers_rounded;
      case 'dressTypes':
        return Icons.texture_rounded;
      case 'footerTypes':
        return Icons.grid_view_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'spongeTypes':
        return CalcTheme.primaryStart;
      case 'dressTypes':
        return CalcTheme.warning;
      case 'footerTypes':
        return CalcTheme.success;
      default:
        return Colors.white70;
    }
  }
}

/// Action button for edit/delete
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: onTap != null ? color : Colors.white30,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
