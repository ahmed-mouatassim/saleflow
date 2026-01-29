import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Screen Enum for Navigation
enum AppScreen {
  home,
  clients,
  suppliers,
  products,
  orders,
  transactions,
  settings,
  profile,
  permissions,
  calculator,
}

/// Sidebar Widget
/// Navigation sidebar matching the React Sidebar component
/// Now supports both persistent sidebar and drawer mode for mobile
class Sidebar extends StatelessWidget {
  final AppScreen currentScreen;
  final ValueChanged<AppScreen> onNavigate;
  final bool isDrawer; // Flag to indicate if in drawer mode

  const Sidebar({
    super.key,
    required this.currentScreen,
    required this.onNavigate,
    this.isDrawer = false,
  });

  /// Check if the current screen is a settings-related screen
  bool _isSettingsScreen(AppScreen screen) {
    return screen == AppScreen.settings ||
        screen == AppScreen.profile ||
        screen == AppScreen.permissions;
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        screen: AppScreen.home,
        title: 'لوحة التحكم',
        icon: LucideIcons.layoutDashboard,
      ),
      _MenuItem(
        screen: AppScreen.clients,
        title: 'إدارة العملاء',
        icon: LucideIcons.users,
      ),
      _MenuItem(
        screen: AppScreen.suppliers,
        title: 'إدارة الموردين',
        icon: LucideIcons.truck,
      ),
      _MenuItem(
        screen: AppScreen.products,
        title: 'إدارة المنتجات',
        icon: LucideIcons.package,
      ),
      _MenuItem(
        screen: AppScreen.orders,
        title: 'المبيعات (DE/BC/BL)',
        icon: LucideIcons.shoppingBag,
      ),
      _MenuItem(
        screen: AppScreen.transactions,
        title: 'المعاملات المالية',
        icon: LucideIcons.creditCard,
      ),
      _MenuItem(
        screen: AppScreen.calculator,
        title: 'حاسبة الاسعار الشاملة',
        icon: LucideIcons.calculator,
      ),
    ];

    // Responsive width - narrower on tablet, full width on drawer
    final sidebarWidth = isDrawer ? 280.0 : Responsive.sidebarWidth(context);

    // If mobile and not drawer, return empty (sidebar hidden)
    if (sidebarWidth == 0 && !isDrawer) {
      return const SizedBox.shrink();
    }

    final content = ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: sidebarWidth,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            border: isDrawer
                ? null // No border in drawer mode as it has its own styling
                : const Border(
                    left: BorderSide(color: AppColors.glassBorder, width: 1),
                  ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Logo Section
                Padding(
                  padding: EdgeInsets.all(isDrawer ? 24 : 32),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF4338CA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'S',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SaleFlow',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              'v2.5 Pro',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation Menu - Scrollable for smaller screens
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: menuItems.map((item) {
                        final isActive = currentScreen == item.screen;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _SidebarButton(
                            title: item.title,
                            icon: item.icon,
                            isActive: isActive,
                            onTap: () => onNavigate(item.screen),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Quick Actions Section
                Padding(
                  padding: EdgeInsets.all(isDrawer ? 16 : 24),
                  child: Column(
                    children: [
                      // Shortcuts Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlue.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.glassBorder.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'اختصارات سريعة',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMuted,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _QuickActionButton(
                                  icon: LucideIcons.plusCircle,
                                  color: AppColors.primaryBlue,
                                  onTap: () {
                                    // Navigate to add order
                                    onNavigate(AppScreen.orders);
                                  },
                                ),
                                const SizedBox(width: 16),
                                _QuickActionButton(
                                  icon: LucideIcons.creditCard,
                                  color: AppColors.emerald,
                                  onTap: () {
                                    // Navigate to transactions
                                    onNavigate(AppScreen.transactions);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Settings Button with Menu
                      PopupMenuButton<AppScreen>(
                        tooltip: 'الإعدادات',
                        offset: const Offset(0, -150),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: AppColors.glassDark,
                        onSelected: (screen) => onNavigate(screen),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: AppScreen.settings,
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.settings,
                                  size: 18,
                                  color: AppColors.primaryPurple,
                                ),
                                const SizedBox(width: 12),
                                const Text('الإعدادات العامة'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: AppScreen.profile,
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
                            value: AppScreen.permissions,
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.shield,
                                  size: 18,
                                  color: AppColors.amber,
                                ),
                                const SizedBox(width: 12),
                                const Text('إدارة الصلاحيات'),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.settings,
                                size: 20,
                                color: _isSettingsScreen(currentScreen)
                                    ? AppColors.primaryPurple
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'الإعدادات',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _isSettingsScreen(currentScreen)
                                      ? AppColors.primaryPurple
                                      : AppColors.textMuted,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                LucideIcons.chevronUp,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // If drawer mode, wrap in Drawer widget
    if (isDrawer) {
      return Drawer(backgroundColor: AppColors.background, child: content);
    }

    return content;
  }
}

class _MenuItem {
  final AppScreen screen;
  final String title;
  final IconData icon;

  const _MenuItem({
    required this.screen,
    required this.title,
    required this.icon,
  });
}

class _SidebarButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<_SidebarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          transform: widget.isActive
              ? Matrix4.diagonal3Values(1.02, 1.02, 1.0)
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primaryBlue
                : (_isHovered ? AppColors.glassBackground : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 20,
                      color: widget.isActive
                          ? Colors.white
                          : (_isHovered
                                ? AppColors.primaryBlue
                                : AppColors.textMuted),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: widget.isActive
                              ? Colors.white
                              : (_isHovered
                                    ? Colors.white
                                    : AppColors.textMuted),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isActive)
                const Icon(LucideIcons.zap, size: 14, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
