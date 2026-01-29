import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../../shared/widgets/stats_card.dart';
import '../../shared/widgets/glass_container.dart';
import 'provider/suppliers_provider.dart';
import 'model/supplier_model.dart';
import 'data/suppliers_data.dart';
import 'widgets/supplier_card_widget.dart';
import 'widgets/add_supplier_modal.dart';

/// Suppliers Screen
/// Supplier management view for manufacturing material suppliers
class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SuppliersProvider(),
      child: const _SuppliersScreenContent(),
    );
  }
}

class _SuppliersScreenContent extends StatelessWidget {
  const _SuppliersScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuppliersProvider>();
    final isMobile = Responsive.isMobile(context);

    // Show loading state
    if (provider.isLoading) {
      return _buildLoadingView();
    }

    // Show error state
    if (provider.hasError) {
      return _buildErrorView(
        message: provider.errorMessage ?? 'حدث خطأ غير متوقع',
        onRetry: () => provider.refreshSuppliers(),
      );
    }

    // Show supplier detail if selected
    if (provider.selectedSupplier != null) {
      // Helper function to show edit modal
      Future<void> handleEdit(Supplier supplier) async {
        final updatedSupplier = await AddSupplierModal.show(context, supplier);
        if (updatedSupplier != null && context.mounted) {
          await provider.updateSupplier(updatedSupplier, context);
        }
      }

      // Helper function to show delete confirmation
      Future<void> handleDelete(Supplier supplier) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.glassDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'تأكيد الحذف',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'هل أنت متأكد من حذف المورد "${supplier.name}"؟',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          await provider.deleteSupplier(supplier, context);
          provider.clearSelection();
        }
      }

      // Helper function to toggle status
      Future<void> handleToggle(Supplier supplier) async {
        await provider.toggleSupplierStatus(supplier, context);
      }

      return _SupplierDetailView(
        supplier: provider.selectedSupplier!,
        onBack: () => provider.clearSelection(),
        onEdit: () => handleEdit(provider.selectedSupplier!),
        onDelete: () => handleDelete(provider.selectedSupplier!),
        onToggleStatus: () => handleToggle(provider.selectedSupplier!),
      );
    }

    // Main suppliers list view
    return RefreshIndicator(
      onRefresh: provider.refreshSuppliers,
      color: AppColors.amber,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: Responsive.padding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(context, provider, isMobile),

            SizedBox(height: isMobile ? 24 : 32),

            // Stats Grid
            _buildStatsGrid(context, provider, isMobile),

            SizedBox(height: isMobile ? 24 : 32),

            // Search and Filter
            _buildSearchBar(context, provider, isMobile),

            SizedBox(height: isMobile ? 24 : 32),

            // Suppliers List
            _buildSuppliersList(context, provider, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    SuppliersProvider provider,
    bool isMobile,
  ) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.truck, size: 28, color: AppColors.amber),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'إدارة الموردين',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'إدارة موردي المواد الخام والتصنيع',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final supplier = await AddSupplierModal.show(context);
                if (supplier != null && context.mounted) {
                  await provider.addSupplier(supplier, context);
                }
              },
              icon: const Icon(LucideIcons.plus, size: 20),
              label: const Text('إضافة مورد جديد'),
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
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.truck, size: 40, color: AppColors.amber),
                const SizedBox(width: 16),
                const Text(
                  'إدارة الموردين',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'إدارة موردي المواد الخام والتصنيع',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final supplier = await AddSupplierModal.show(context);
            if (supplier != null && context.mounted) {
              await provider.addSupplier(supplier, context);
            }
          },
          icon: const Icon(LucideIcons.plus, size: 24),
          label: const Text('إضافة مورد جديد'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amber,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    SuppliersProvider provider,
    bool isMobile,
  ) {
    final stats = [
      StatsCard(
        label: 'إجمالي الموردين',
        value: '${provider.suppliers.length}',
        icon: LucideIcons.users,
        color: StatsCardColor.blue,
      ),
      StatsCard(
        label: 'الموردين النشطين',
        value: '${provider.activeCount}',
        icon: LucideIcons.userCheck,
        color: StatsCardColor.green,
      ),
      StatsCard(
        label: 'إجمالي المشتريات',
        value: '${_formatNumber(provider.totalPurchases)} د.م',
        icon: LucideIcons.shoppingCart,
        color: StatsCardColor.purple,
      ),
      StatsCard(
        label: 'المستحقات المتبقية',
        value: '${_formatNumber(provider.totalAmountOwed)} د.م',
        icon: LucideIcons.alertCircle,
        color: StatsCardColor.red,
      ),
    ];

    if (isMobile) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: stats.map((stat) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 44) / 2,
            child: stat,
          );
        }).toList(),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: stats.map((stat) {
        return SizedBox(width: 260, child: stat);
      }).toList(),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    SuppliersProvider provider,
    bool isMobile,
  ) {
    final categories = SuppliersData.getCategories();

    if (isMobile) {
      return Column(
        children: [
          // Search Field
          TextField(
            onChanged: provider.setSearchQuery,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'البحث بالاسم أو رقم الهاتف...',
              hintStyle: TextStyle(color: AppColors.textMuted),
              prefixIcon: Icon(LucideIcons.search, color: AppColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              filled: true,
              fillColor: AppColors.glassBackground,
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                final isActive = provider.categoryFilter == category;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isActive,
                    onSelected: (_) => provider.setCategoryFilter(category),
                    selectedColor: AppColors.amber.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: isActive ? AppColors.amber : AppColors.textMuted,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isActive ? AppColors.amber : AppColors.glassBorder,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Category Filter
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.glassDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final isActive = provider.categoryFilter == category;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => provider.setCategoryFilter(category),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.amber
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Search Field
          Expanded(
            child: TextField(
              onChanged: provider.setSearchQuery,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'البحث بالاسم أو رقم الهاتف أو المدينة...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                prefixIcon: Icon(
                  LucideIcons.search,
                  color: AppColors.textMuted,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                filled: true,
                fillColor: AppColors.glassBackground,
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliersList(
    BuildContext context,
    SuppliersProvider provider,
    bool isMobile,
  ) {
    final suppliers = provider.filteredSuppliers;

    if (suppliers.isEmpty) {
      return _buildEmptyState(provider.searchQuery.isNotEmpty);
    }

    // Helper function to show edit modal
    Future<void> handleEdit(Supplier supplier) async {
      final updatedSupplier = await AddSupplierModal.show(context, supplier);
      if (updatedSupplier != null && context.mounted) {
        await provider.updateSupplier(updatedSupplier, context);
      }
    }

    // Helper function to show delete confirmation
    Future<void> handleDelete(Supplier supplier) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.glassDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'تأكيد الحذف',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            'هل أنت متأكد من حذف المورد "${supplier.name}"؟',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
              child: const Text('حذف'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        await provider.deleteSupplier(supplier, context);
      }
    }

    // Helper function to toggle status
    Future<void> handleToggle(Supplier supplier) async {
      await provider.toggleSupplierStatus(supplier, context);
    }

    if (isMobile) {
      return Column(
        children: suppliers.asMap().entries.map((entry) {
          return SupplierCardWidget(
            supplier: entry.value,
            animationDelay: entry.key,
            onTap: () => provider.selectSupplier(entry.value),
            onEdit: () => handleEdit(entry.value),
            onDelete: () => handleDelete(entry.value),
            onToggleStatus: () => handleToggle(entry.value),
          );
        }).toList(),
      );
    }

    // Desktop: Grid layout
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: suppliers.asMap().entries.map((entry) {
        return SizedBox(
          width: 400,
          child: SupplierCardWidget(
            supplier: entry.value,
            animationDelay: entry.key,
            onTap: () => provider.selectSupplier(entry.value),
            onEdit: () => handleEdit(entry.value),
            onDelete: () => handleDelete(entry.value),
            onToggleStatus: () => handleToggle(entry.value),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(bool isSearchResult) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearchResult ? LucideIcons.search : LucideIcons.truck,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              isSearchResult
                  ? 'لم يتم العثور على موردين مطابقين'
                  : 'لا يوجد موردون حالياً',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearchResult
                  ? 'جرب تغيير معايير البحث'
                  : 'ابدأ بإضافة مورد جديد',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.amber),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الموردين...',
            style: TextStyle(fontSize: 16, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertTriangle, size: 64, color: AppColors.red),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

/// Supplier Detail View
class _SupplierDetailView extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _SupplierDetailView({
    required this.supplier,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          GlassContainer(
            borderRadius: 32,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Back button
                InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      LucideIcons.arrowRight,
                      size: 24,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.amber,
                        AppColors.amber.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      supplier.name.isNotEmpty ? supplier.name[0] : 'م',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.name,
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          supplier.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: supplier.isActive
                        ? AppColors.emerald.withValues(alpha: 0.2)
                        : AppColors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    supplier.isActive ? 'نشط' : 'غير نشط',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: supplier.isActive
                          ? AppColors.emerald
                          : AppColors.red,
                    ),
                  ),
                ),
                // FIXED: Added action buttons
                const SizedBox(width: 12),
                // Edit Button - PLACEHOLDER
                // Edit Button
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(LucideIcons.edit, color: AppColors.amber),
                  tooltip: 'تعديل المورد',
                ),
                // More Options Button
                PopupMenuButton<String>(
                  icon: Icon(
                    LucideIcons.moreVertical,
                    color: AppColors.textMuted,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'toggle':
                        onToggleStatus();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            supplier.isActive
                                ? LucideIcons.userX
                                : LucideIcons.userCheck,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            supplier.isActive ? 'تعطيل المورد' : 'تفعيل المورد',
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
          ),

          const SizedBox(height: 24),

          // Contact & Financial Info
          isMobile
              ? Column(
                  children: [
                    _buildContactCard(),
                    const SizedBox(height: 16),
                    _buildFinancialCard(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildContactCard()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildFinancialCard()),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return GlassContainer(
      borderRadius: 32,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.contact, size: 24, color: AppColors.amber),
              const SizedBox(width: 12),
              const Text(
                'معلومات التواصل',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(LucideIcons.phone, 'الهاتف', supplier.phone),
          const SizedBox(height: 16),
          _buildInfoRow(LucideIcons.mail, 'البريد', supplier.email),
          const SizedBox(height: 16),
          _buildInfoRow(LucideIcons.mapPin, 'المدينة', supplier.city),
          const SizedBox(height: 16),
          _buildInfoRow(LucideIcons.home, 'العنوان', supplier.address),
        ],
      ),
    );
  }

  Widget _buildFinancialCard() {
    return GlassContainer(
      borderRadius: 32,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.wallet, size: 24, color: AppColors.amber),
              const SizedBox(width: 12),
              const Text(
                'الملخص المالي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFinancialRow(
            'إجمالي المشتريات',
            '${supplier.totalPurchases.toStringAsFixed(0)} د.م',
            AppColors.primaryBlue,
          ),
          const SizedBox(height: 16),
          _buildFinancialRow(
            'المبلغ المدفوع',
            '${supplier.totalPaid.toStringAsFixed(0)} د.م',
            AppColors.emerald,
          ),
          const SizedBox(height: 16),
          _buildFinancialRow(
            'المبلغ المستحق',
            '${supplier.amountOwed.toStringAsFixed(0)} د.م',
            supplier.amountOwed > 0 ? AppColors.red : AppColors.emerald,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
