import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/app_colors.dart';
import '../../../core/responsive.dart';
import '../../../shared/widgets/glass_container.dart';
import '../model/client_model.dart';
import 'edit_client_modal.dart';

/// Client Card Widget
/// Displays a single client in the grid
/// Now responsive with adaptive padding and sizing
class ClientCardWidget extends StatefulWidget {
  final Client client;
  final Duration animationDelay;
  final VoidCallback onTap;

  const ClientCardWidget({
    super.key,
    required this.client,
    required this.animationDelay,
    required this.onTap,
  });

  @override
  State<ClientCardWidget> createState() => _ClientCardWidgetState();
}

class _ClientCardWidgetState extends State<ClientCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.diagonal3Values(
            _isHovered ? 1.02 : 1.0,
            _isHovered ? 1.02 : 1.0,
            1.0,
          ),
          child: GlassContainer(
            borderRadius: isMobile ? 28 : 40,
            borderColor: _isHovered
                ? AppColors.primaryBlue.withValues(alpha: 0.3)
                : AppColors.glassBorder,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ]
                : null,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 20 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row
                  Row(
                    children: [
                      // Avatar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()
                          ..rotateZ(_isHovered ? 0.1 : 0),
                        child: Container(
                          width: isMobile ? 48 : 56,
                          height: isMobile ? 48 : 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              isMobile ? 14 : 16,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.client.name.isNotEmpty
                                  ? widget.client.name[0]
                                  : '?',
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.client.name,
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.w900,
                                color: _isHovered
                                    ? AppColors.primaryBlue
                                    : AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.client.isActive
                                        ? AppColors.emerald
                                        : AppColors.textMuted,
                                    boxShadow: widget.client.isActive
                                        ? [
                                            BoxShadow(
                                              color: AppColors.emerald
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.client.isActive ? 'نشط' : 'غير نشط',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textMuted,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          LucideIcons.moreVertical,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: AppColors.glassDark,
                        onSelected: (value) {
                          switch (value) {
                            case 'view':
                              widget.onTap();
                              break;
                            case 'edit':
                              EditClientModal.show(
                                context,
                                widget.client,
                              ).then((updatedClient) {
                                if (updatedClient != null && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'تم تحديث بيانات العميل بنجاح',
                                      ),
                                      backgroundColor: Color(0xFF10B981),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              });
                              break;
                            case 'transaction':
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'إضافة معاملة لـ ${widget.client.name}',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              break;
                            case 'toggle_status':
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    widget.client.isActive
                                        ? 'تم تعطيل العميل'
                                        : 'تم تفعيل العميل',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.eye,
                                  size: 18,
                                  color: AppColors.primaryBlue,
                                ),
                                const SizedBox(width: 12),
                                const Text('عرض التفاصيل'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.edit,
                                  size: 18,
                                  color: AppColors.amber,
                                ),
                                const SizedBox(width: 12),
                                const Text('تعديل البيانات'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'transaction',
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.creditCard,
                                  size: 18,
                                  color: AppColors.emerald,
                                ),
                                const SizedBox(width: 12),
                                const Text('إضافة معاملة'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'toggle_status',
                            child: Row(
                              children: [
                                Icon(
                                  widget.client.isActive
                                      ? LucideIcons.userX
                                      : LucideIcons.userCheck,
                                  size: 18,
                                  color: widget.client.isActive
                                      ? AppColors.red
                                      : AppColors.emerald,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  widget.client.isActive
                                      ? 'تعطيل العميل'
                                      : 'تفعيل العميل',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: isMobile ? 16 : 24),

                  // Financial Stats
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 12 : 16,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatColumn(
                            label: 'إجمالي',
                            value: _formatNumber(widget.client.totalAmount),
                            color: AppColors.textPrimary,
                            isMobile: isMobile,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: isMobile ? 32 : 40,
                          color: AppColors.glassBorder,
                        ),
                        Expanded(
                          child: _StatColumn(
                            label: 'مدفوع',
                            value: _formatNumber(widget.client.amountPaid),
                            color: AppColors.emerald,
                            isMobile: isMobile,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: isMobile ? 32 : 40,
                          color: AppColors.glassBorder,
                        ),
                        Expanded(
                          child: _StatColumn(
                            label: 'متبقي',
                            value: _formatNumber(widget.client.amountRemaining),
                            color: AppColors.red.withValues(alpha: 0.8),
                            isMobile: isMobile,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isMobile ? 12 : 16),

                  // Footer Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.phone,
                              size: 12,
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.client.phone,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlue.withValues(
                                    alpha: 0.6,
                                  ),
                                  letterSpacing: 1,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.translationValues(
                          _isHovered ? -8.0 : 0.0,
                          0.0,
                          0.0,
                        ),
                        child: Icon(
                          LucideIcons.arrowLeft,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isMobile;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 8 : 8,
            fontWeight: FontWeight.w900,
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w900,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
