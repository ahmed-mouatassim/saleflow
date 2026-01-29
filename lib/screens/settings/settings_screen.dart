import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../../shared/widgets/glass_container.dart';
import 'provider/settings_provider.dart';
import 'model/settings_model.dart';

/// Settings Screen
/// Application settings and configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends StatelessWidget {
  const _SettingsScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final isMobile = Responsive.isMobile(context);
    final settings = provider.settings;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(isMobile),

          SizedBox(height: isMobile ? 24 : 32),

          // Settings Sections - Responsive Layout
          if (isMobile)
            Column(
              children: [
                _buildAppearanceSection(context, provider, settings),
                const SizedBox(height: 24),
                _buildNotificationsSection(context, provider, settings),
                const SizedBox(height: 24),
                _buildRegionalSection(context, provider, settings),
                const SizedBox(height: 24),
                _buildBackupSection(context, provider, settings),
                const SizedBox(height: 24),
                _buildAboutSection(context),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    children: [
                      _buildAppearanceSection(context, provider, settings),
                      const SizedBox(height: 24),
                      _buildRegionalSection(context, provider, settings),
                      const SizedBox(height: 24),
                      _buildAboutSection(context),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column
                Expanded(
                  child: Column(
                    children: [
                      _buildNotificationsSection(context, provider, settings),
                      const SizedBox(height: 24),
                      _buildBackupSection(context, provider, settings),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.settings,
              size: isMobile ? 28 : 32,
              color: AppColors.primaryPurple,
            ),
            const SizedBox(width: 16),
            Text(
              'الإعدادات',
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'إدارة إعدادات النظام والتفضيلات',
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    SettingsProvider provider,
    AppSettings settings,
  ) {
    return _SettingsSection(
      title: 'المظهر',
      icon: LucideIcons.palette,
      children: [
        _SettingsToggle(
          title: 'الوضع الداكن',
          subtitle: 'تفعيل المظهر الداكن للتطبيق',
          icon: LucideIcons.moon,
          value: settings.darkMode,
          onChanged: (_) => provider.toggleDarkMode(),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(
    BuildContext context,
    SettingsProvider provider,
    AppSettings settings,
  ) {
    return _SettingsSection(
      title: 'الإشعارات',
      icon: LucideIcons.bell,
      children: [
        _SettingsToggle(
          title: 'الإشعارات',
          subtitle: 'استلام إشعارات عند وجود تحديثات',
          icon: LucideIcons.bellRing,
          value: settings.notifications,
          onChanged: (_) => provider.toggleNotifications(),
        ),
        const SizedBox(height: 16),
        _SettingsToggle(
          title: 'الصوت',
          subtitle: 'تشغيل صوت عند استلام إشعار',
          icon: LucideIcons.volume2,
          value: settings.soundEnabled,
          onChanged: (_) => provider.toggleSound(),
        ),
      ],
    );
  }

  Widget _buildRegionalSection(
    BuildContext context,
    SettingsProvider provider,
    AppSettings settings,
  ) {
    return _SettingsSection(
      title: 'الإعدادات الإقليمية',
      icon: LucideIcons.globe,
      children: [
        _SettingsDropdown(
          title: 'اللغة',
          subtitle: 'لغة واجهة التطبيق',
          icon: LucideIcons.languages,
          value: settings.language,
          items: const [
            DropdownMenuItem(value: 'ar', child: Text('العربية')),
            DropdownMenuItem(value: 'fr', child: Text('Français')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (value) {
            if (value != null) provider.setLanguage(value);
          },
        ),
        const SizedBox(height: 16),
        _SettingsDropdown(
          title: 'العملة',
          subtitle: 'العملة المستخدمة في المعاملات',
          icon: LucideIcons.dollarSign,
          value: settings.currency,
          items: const [
            DropdownMenuItem(value: 'MAD', child: Text('درهم مغربي (MAD)')),
            DropdownMenuItem(value: 'USD', child: Text('دولار أمريكي (USD)')),
            DropdownMenuItem(value: 'EUR', child: Text('يورو (EUR)')),
          ],
          onChanged: (value) {
            if (value != null) provider.setCurrency(value);
          },
        ),
      ],
    );
  }

  Widget _buildBackupSection(
    BuildContext context,
    SettingsProvider provider,
    AppSettings settings,
  ) {
    return _SettingsSection(
      title: 'النسخ الاحتياطي',
      icon: LucideIcons.hardDrive,
      children: [
        _SettingsToggle(
          title: 'النسخ الاحتياطي التلقائي',
          subtitle: 'حفظ نسخة احتياطية تلقائياً',
          icon: LucideIcons.cloud,
          value: settings.autoBackup,
          onChanged: (_) => provider.toggleAutoBackup(),
        ),
        const SizedBox(height: 16),
        _SettingsButton(
          title: 'نسخ احتياطي الآن',
          subtitle: 'إنشاء نسخة احتياطية يدوياً',
          icon: LucideIcons.download,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('جاري إنشاء نسخة احتياطية...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _SettingsButton(
          title: 'استعادة البيانات',
          subtitle: 'استعادة من نسخة احتياطية سابقة',
          icon: LucideIcons.upload,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.glassDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Row(
                  children: [
                    Icon(LucideIcons.upload, color: AppColors.amber),
                    const SizedBox(width: 12),
                    const Text('استعادة البيانات'),
                  ],
                ),
                content: const Text(
                  'هل أنت متأكد من استعادة البيانات من النسخة الاحتياطية؟\n\nسيتم استبدال جميع البيانات الحالية.',
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
                          content: Text('جاري استعادة البيانات...'),
                          backgroundColor: Color(0xFF2563EB),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber,
                    ),
                    child: const Text('استعادة'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _SettingsSection(
      title: 'حول التطبيق',
      icon: LucideIcons.info,
      children: [
        _SettingsInfo(
          title: 'الإصدار',
          value: 'v2.5.0 Pro',
          icon: LucideIcons.tag,
        ),
        const SizedBox(height: 16),
        _SettingsInfo(
          title: 'المطور',
          value: 'SaleFlow Technologies',
          icon: LucideIcons.code2,
        ),
        const SizedBox(height: 16),
        _SettingsButton(
          title: 'سياسة الخصوصية',
          subtitle: 'اقرأ سياسة الخصوصية',
          icon: LucideIcons.shield,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.glassDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Row(
                  children: [
                    Icon(LucideIcons.shield, color: AppColors.primaryBlue),
                    const SizedBox(width: 12),
                    const Text('سياسة الخصوصية'),
                  ],
                ),
                content: const SingleChildScrollView(
                  child: Text(
                    'سياسة الخصوصية\n\nنحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية.\n\n1. جمع البيانات: نجمع فقط البيانات الضرورية لتقديم الخدمة.\n\n2. حماية البيانات: نستخدم تشفير عالي المستوى لحماية بياناتك.\n\n3. المشاركة: لا نشارك بياناتك مع أطراف ثالثة.',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق'),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _SettingsButton(
          title: 'شروط الاستخدام',
          subtitle: 'اقرأ شروط الاستخدام',
          icon: LucideIcons.fileText,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.glassDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Row(
                  children: [
                    Icon(LucideIcons.fileText, color: AppColors.primaryPurple),
                    const SizedBox(width: 12),
                    const Text('شروط الاستخدام'),
                  ],
                ),
                content: const SingleChildScrollView(
                  child: Text(
                    'شروط الاستخدام\n\nباستخدامك لهذا التطبيق، فإنك توافق على:\n\n1. الاستخدام القانوني فقط.\n\n2. عدم مشاركة بيانات الدخول.\n\n3. الالتزام بالقوانين المحلية.\n\n4. التحديثات الدورية للتطبيق.',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Settings Section Container
class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 32,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryPurple),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

/// Settings Toggle Switch
class _SettingsToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.glassDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primaryPurple;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }
}

/// Settings Dropdown
class _SettingsDropdown extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _SettingsDropdown({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.glassDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            dropdownColor: AppColors.glassDark,
            borderRadius: BorderRadius.circular(16),
            underline: const SizedBox(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings Button
class _SettingsButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.glassDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.primaryPurple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronLeft, size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Settings Info Display
class _SettingsInfo extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SettingsInfo({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.glassDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }
}
