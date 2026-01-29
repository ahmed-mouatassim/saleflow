import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/app_colors.dart';
import '../model/supplier_model.dart';

/// Supplier Card Widget
/// Displays supplier information in a card format
class SupplierCardWidget extends StatefulWidget {
  final Supplier supplier;
  final int animationDelay;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const SupplierCardWidget({
    super.key,
    required this.supplier,
    this.animationDelay = 0,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
  });

  @override
  State<SupplierCardWidget> createState() => _SupplierCardWidgetState();
}

class _SupplierCardWidgetState extends State<SupplierCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.animationDelay * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.glassBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.supplier.isActive
                    ? AppColors.glassBorder
                    : AppColors.red.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.amber,
                                    AppColors.amber.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  widget.supplier.name.isNotEmpty
                                      ? widget.supplier.name[0]
                                      : 'م',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Name and Category
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.supplier.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.amber.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.supplier.category,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.amber,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // More button
                      // FIXED: Connected all menu actions to provider methods
                      PopupMenuButton<String>(
                        icon: Icon(
                          LucideIcons.moreVertical,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'view':
                              widget.onTap();
                              break;
                            case 'edit':
                              // IMPLEMENTED: Edit functionality
                              if (widget.onEdit != null) {
                                widget.onEdit!();
                              }
                              break;
                            case 'toggle':
                              // IMPLEMENTED: Toggle status
                              if (widget.onToggleStatus != null) {
                                widget.onToggleStatus!();
                              }
                              break;
                            case 'delete':
                              // IMPLEMENTED: Delete functionality
                              if (widget.onDelete != null) {
                                widget.onDelete!();
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(LucideIcons.eye, size: 18),
                                SizedBox(width: 8),
                                Text('عرض التفاصيل'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(LucideIcons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('تعديل البيانات'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  widget.supplier.isActive
                                      ? LucideIcons.userX
                                      : LucideIcons.userCheck,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.supplier.isActive
                                      ? 'تعطيل المورد'
                                      : 'تفعيل المورد',
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.trash2,
                                  size: 18,
                                  color: Color(0xFFEF4444),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'حذف المورد',
                                  style: TextStyle(color: Color(0xFFEF4444)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Contact Info
                  Row(
                    children: [
                      Icon(
                        LucideIcons.phone,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.supplier.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        LucideIcons.mapPin,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.supplier.city,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Financial Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.glassDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          'إجمالي المشتريات',
                          _formatNumber(widget.supplier.totalPurchases),
                          AppColors.primaryBlue,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.glassBorder,
                        ),
                        _buildStat(
                          'المدفوع',
                          _formatNumber(widget.supplier.totalPaid),
                          AppColors.emerald,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.glassBorder,
                        ),
                        _buildStat(
                          'المستحق',
                          _formatNumber(widget.supplier.amountOwed),
                          widget.supplier.amountOwed > 0
                              ? AppColors.red
                              : AppColors.emerald,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(
          '$value د.م',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
