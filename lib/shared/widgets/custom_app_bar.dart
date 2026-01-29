import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'notifications_panel.dart';

/// Custom App Bar Widget
/// Top bar with search and profile matching the React header
/// Now supports responsive layout with optional menu button
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onMenuTap;
  final bool showMenuButton;

  const CustomAppBar({
    super.key,
    this.onProfileTap,
    this.onMenuTap,
    this.showMenuButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 64,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: AppColors.glassDark,
            border: Border(
              bottom: BorderSide(
                color: AppColors.glassBorder.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Mobile Logo (only shown on mobile)
              if (isMobile) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF4338CA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'S',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Search Field
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? double.infinity : 500,
                  ),
                  child: TextField(
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: isMobile
                          ? 'بحث سريع...'
                          : 'بحث سريع عن عميل، طلب، أو مفرش...',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: isMobile ? 12 : 14,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                          right: isMobile ? 8 : 12,
                          left: 8,
                        ),
                        child: const Icon(
                          LucideIcons.search,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.glassBackground,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
              ),

              SizedBox(width: isMobile ? 8 : 16),

              // Notification Bell
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      NotificationsPanel.show(context);
                    },
                    icon: const Icon(
                      LucideIcons.bell,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    hoverColor: AppColors.glassBackground,
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Profile Section (hidden on very small screens)
              if (!isMobile) ...[
                // Divider
                Container(
                  height: 32,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: AppColors.glassBorder,
                ),

                // Profile Section
                PopupMenuButton<String>(
                  tooltip: 'الملف الشخصي',
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: AppColors.glassDark,
                  onSelected: (value) {
                    switch (value) {
                      case 'profile':
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'اختر "الملف الشخصي" من قائمة الإعدادات',
                            ),
                            backgroundColor: Color(0xFF2563EB),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        break;
                      case 'settings':
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'اختر "الإعدادات" من القائمة الجانبية',
                            ),
                            backgroundColor: Color(0xFF7C3AED),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        break;
                      case 'logout':
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.glassDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            title: Row(
                              children: [
                                Icon(LucideIcons.logOut, color: AppColors.red),
                                const SizedBox(width: 12),
                                const Text('تسجيل الخروج'),
                              ],
                            ),
                            content: const Text(
                              'هل أنت متأكد من تسجيل الخروج من النظام؟',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم تسجيل الخروج بنجاح'),
                                      backgroundColor: Color(0xFF10B981),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.red,
                                ),
                                child: const Text('تسجيل الخروج'),
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.user,
                            size: 18,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          const Text('الملف الشخصي'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.settings,
                            size: 18,
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 12),
                          const Text('الإعدادات'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.logOut,
                            size: 18,
                            color: AppColors.red,
                          ),
                          const SizedBox(width: 12),
                          const Text('تسجيل الخروج'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 4,
                      top: 4,
                      bottom: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'أنس الراجي',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'مدير النظام',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.glassBorder,
                              width: 1,
                            ),
                            // Use a placeholder gradient instead of network image
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'أ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Menu Button (for mobile)
              if (showMenuButton)
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(
                    LucideIcons.menu,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.glassBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
