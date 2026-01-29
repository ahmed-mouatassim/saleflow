import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../../shared/widgets/glass_container.dart';
import 'provider/settings_provider.dart';
import 'model/settings_model.dart';
import 'data/settings_data.dart';

/// Permissions Screen
/// Role and permission management for access control
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const _PermissionsScreenContent(),
    );
  }
}

class _PermissionsScreenContent extends StatelessWidget {
  const _PermissionsScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final isMobile = Responsive.isMobile(context);

    // If role is selected for editing, show editor
    if (provider.selectedRole != null) {
      return _RoleEditor(
        role: provider.selectedRole!,
        onSave: (role) => provider.saveRole(role, context),
        onCancel: () => provider.clearRoleSelection(),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(context, provider, isMobile),

          SizedBox(height: isMobile ? 24 : 32),

          // Stats Cards
          _buildStatsCards(context, provider, isMobile),

          SizedBox(height: isMobile ? 24 : 32),

          // Roles List
          _buildRolesList(context, provider, isMobile),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    SettingsProvider provider,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.shield,
                        size: isMobile ? 28 : 32,
                        color: AppColors.amber,
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Text(
                          'إدارة الصلاحيات',
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'إنشاء وإدارة الأدوار والصلاحيات للمستخدمين',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isMobile)
              ElevatedButton.icon(
                onPressed: () {
                  _showAddRoleDialog(context, provider);
                },
                icon: const Icon(LucideIcons.plus, size: 20),
                label: const Text('إضافة دور جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showAddRoleDialog(context, provider);
              },
              icon: const Icon(LucideIcons.plus, size: 20),
              label: const Text('إضافة دور جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsCards(
    BuildContext context,
    SettingsProvider provider,
    bool isMobile,
  ) {
    final roles = provider.roles;
    final systemRoles = roles.where((r) => r.isSystem).length;
    final permissions = SettingsData.allPermissions.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = isMobile
            ? constraints.maxWidth
            : (constraints.maxWidth - 48) / 3;

        return Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth.clamp(200, 350),
              child: _StatCard(
                label: 'إجمالي الأدوار',
                value: '${roles.length}',
                icon: LucideIcons.users,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(
              width: cardWidth.clamp(200, 350),
              child: _StatCard(
                label: 'أدوار أساسية',
                value: '$systemRoles',
                icon: LucideIcons.shield,
                color: AppColors.amber,
              ),
            ),
            SizedBox(
              width: cardWidth.clamp(200, 350),
              child: _StatCard(
                label: 'صلاحيات متاحة',
                value: '$permissions',
                icon: LucideIcons.key,
                color: AppColors.emerald,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRolesList(
    BuildContext context,
    SettingsProvider provider,
    bool isMobile,
  ) {
    final roles = provider.roles;

    return GlassContainer(
      borderRadius: 32,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.users, size: 20, color: AppColors.amber),
                  const SizedBox(width: 12),
                  const Text(
                    'الأدوار المتاحة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${roles.length} دور',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ...roles.asMap().entries.map((entry) {
            final index = entry.key;
            final role = entry.value;
            return Column(
              children: [
                _RoleCard(
                  role: role,
                  onEdit: () => provider.selectRole(role),
                  onDelete: () => _confirmDeleteRole(context, provider, role),
                ),
                if (index < roles.length - 1) const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showAddRoleDialog(BuildContext context, SettingsProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.glassDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.plus, size: 48, color: AppColors.amber),
              const SizedBox(height: 24),
              const Text(
                'إضافة دور جديد',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'اسم الدور',
                  prefixIcon: const Icon(LucideIcons.tag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'وصف الدور',
                  prefixIcon: const Icon(LucideIcons.fileText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          final newRole = UserRole(
                            id: 0, // Will be assigned by provider
                            name: nameController.text,
                            description: descController.text,
                            permissions: [],
                          );
                          Navigator.pop(context);
                          provider.selectRole(newRole);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('متابعة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteRole(
    BuildContext context,
    SettingsProvider provider,
    UserRole role,
  ) {
    if (role.isSystem) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن حذف الأدوار الأساسية'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: AppColors.red),
            const SizedBox(width: 12),
            const Text('حذف الدور'),
          ],
        ),
        content: Text('هل أنت متأكد من حذف الدور "${role.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteRole(role.id, context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

/// Role Card Widget
class _RoleCard extends StatelessWidget {
  final UserRole role;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoleCard({
    required this.role,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: role.isSystem
                      ? AppColors.amber.withValues(alpha: 0.1)
                      : AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  role.isSystem ? LucideIcons.shieldCheck : LucideIcons.users,
                  size: 24,
                  color: role.isSystem
                      ? AppColors.amber
                      : AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            role.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (role.isSystem) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'أساسي',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.amber,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(LucideIcons.edit, size: 18),
                    color: AppColors.primaryBlue,
                    tooltip: 'تعديل',
                  ),
                  if (!role.isSystem)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(LucideIcons.trash2, size: 18),
                      color: AppColors.red,
                      tooltip: 'حذف',
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Permissions Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.glassDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.key, size: 14, color: AppColors.emerald),
                const SizedBox(width: 8),
                Text(
                  '${role.permissions.length} صلاحية',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Role Editor Widget
class _RoleEditor extends StatefulWidget {
  final UserRole role;
  final Future<bool> Function(UserRole) onSave;
  final VoidCallback onCancel;

  const _RoleEditor({
    required this.role,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_RoleEditor> createState() => _RoleEditorState();
}

class _RoleEditorState extends State<_RoleEditor> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late Set<String> _selectedPermissions;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role.name);
    _descController = TextEditingController(text: widget.role.description);
    _selectedPermissions = Set.from(widget.role.permissions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final permissionsByCategory = SettingsData.allPermissions
        .fold<Map<String, List<Permission>>>({}, (map, p) {
          map.putIfAbsent(p.category, () => []).add(p);
          return map;
        });

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(LucideIcons.arrowRight),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.glassBackground,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.role.id == 0 ? 'إنشاء دور جديد' : 'تعديل الدور',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'تحديد الصلاحيات المتاحة لهذا الدور',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final updatedRole = UserRole(
                    id: widget.role.id,
                    name: _nameController.text,
                    description: _descController.text,
                    permissions: _selectedPermissions.toList(),
                    isSystem: widget.role.isSystem,
                  );
                  await widget.onSave(updatedRole);
                },
                icon: const Icon(LucideIcons.save, size: 18),
                label: const Text('حفظ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 32,
                    vertical: isMobile ? 14 : 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Role Info Section
          GlassContainer(
            borderRadius: 32,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 20,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'معلومات الدور',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم الدور',
                    prefixIcon: const Icon(LucideIcons.tag),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: AppColors.glassBackground,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'وصف الدور',
                    prefixIcon: const Icon(LucideIcons.fileText),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: AppColors.glassBackground,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Permissions Section
          GlassContainer(
            borderRadius: 32,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.key, size: 20, color: AppColors.amber),
                        const SizedBox(width: 12),
                        const Text(
                          'الصلاحيات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_selectedPermissions.length} صلاحية محددة',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.emerald,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Permission Categories
                ...permissionsByCategory.entries.map((entry) {
                  final category = entry.key;
                  final permissions = entry.value;
                  final allSelected = permissions.every(
                    (p) => _selectedPermissions.contains(p.id),
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      children: [
                        // Category Header
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (allSelected) {
                                for (final p in permissions) {
                                  _selectedPermissions.remove(p.id);
                                }
                              } else {
                                for (final p in permissions) {
                                  _selectedPermissions.add(p.id);
                                }
                              }
                            });
                          },
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.glassDark,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: allSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        for (final p in permissions) {
                                          _selectedPermissions.add(p.id);
                                        }
                                      } else {
                                        for (final p in permissions) {
                                          _selectedPermissions.remove(p.id);
                                        }
                                      }
                                    });
                                  },
                                  activeColor: AppColors.amber,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${permissions.where((p) => _selectedPermissions.contains(p.id)).length}/${permissions.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Permissions List
                        ...permissions.map((permission) {
                          final isSelected = _selectedPermissions.contains(
                            permission.id,
                          );
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedPermissions.remove(permission.id);
                                } else {
                                  _selectedPermissions.add(permission.id);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: AppColors.glassBorder),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedPermissions.add(
                                            permission.id,
                                          );
                                        } else {
                                          _selectedPermissions.remove(
                                            permission.id,
                                          );
                                        }
                                      });
                                    },
                                    activeColor: AppColors.emerald,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          permission.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          permission.description,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
