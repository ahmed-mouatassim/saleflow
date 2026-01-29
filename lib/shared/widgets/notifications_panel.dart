import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/app_colors.dart';
import 'glass_container.dart';
import '../../screens/settings/model/settings_model.dart';
import '../../screens/settings/data/settings_data.dart';

/// Notifications Panel
/// Overlay panel showing all notifications
class NotificationsPanel extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onViewAll;

  const NotificationsPanel({super.key, required this.onClose, this.onViewAll});

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();

  /// Show as overlay
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => NotificationsPanel(
        onClose: () => Navigator.pop(context),
        onViewAll: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'اختر "الإعدادات" من القائمة الجانبية للوصول لجميع الإشعارات',
              ),
              backgroundColor: Color(0xFF7C3AED),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(SettingsData.sampleNotifications);
  }

  void _markAsRead(int id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });
  }

  void _deleteNotification(int id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Align(
      alignment: isMobile ? Alignment.center : Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(
          top: isMobile ? 0 : 80,
          left: isMobile ? 16 : 24,
          right: isMobile ? 16 : 0,
        ),
        child: Material(
          color: Colors.transparent,
          child: GlassContainer(
            isDark: true,
            borderRadius: isMobile ? 28 : 32,
            child: SizedBox(
              width: isMobile ? double.infinity : 400,
              height: isMobile ? MediaQuery.of(context).size.height * 0.7 : 500,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.glassBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  Icon(
                                    LucideIcons.bell,
                                    size: 20,
                                    color: AppColors.primaryBlue,
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: AppColors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'الإشعارات',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Text(
                                    '$unreadCount إشعارات غير مقروءة',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (unreadCount > 0)
                              IconButton(
                                onPressed: _markAllAsRead,
                                icon: const Icon(
                                  LucideIcons.checkCheck,
                                  size: 18,
                                ),
                                tooltip: 'قراءة الكل',
                                color: AppColors.emerald,
                              ),
                            IconButton(
                              onPressed: widget.onClose,
                              icon: const Icon(LucideIcons.x, size: 20),
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Notifications List
                  Expanded(
                    child: _notifications.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return _NotificationItem(
                                notification: notification,
                                onTap: () => _markAsRead(notification.id),
                                onDismiss: () =>
                                    _deleteNotification(notification.id),
                              );
                            },
                          ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.glassBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _notifications.isEmpty
                                ? null
                                : _clearAll,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('مسح الكل'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onViewAll,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('عرض الكل'),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.bellOff,
            size: 48,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا الإشعارات الجديدة',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Notification Item Widget
class _NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.info:
        return LucideIcons.info;
      case NotificationType.warning:
        return LucideIcons.alertTriangle;
      case NotificationType.success:
        return LucideIcons.checkCircle;
      case NotificationType.error:
        return LucideIcons.xCircle;
    }
  }

  Color get _color {
    switch (notification.type) {
      case NotificationType.info:
        return AppColors.primaryBlue;
      case NotificationType.warning:
        return AppColors.amber;
      case NotificationType.success:
        return AppColors.emerald;
      case NotificationType.error:
        return AppColors.red;
    }
  }

  String get _timeAgo {
    final now = DateTime.now();
    final diff = now.difference(notification.createdAt);

    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return 'منذ ${diff.inDays} يوم';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(LucideIcons.trash2, color: AppColors.red),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.glassBackground
                : _color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.glassBorder
                  : _color.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, size: 18, color: _color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _timeAgo,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
