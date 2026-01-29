import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../shared/widgets/stats_card.dart';
import '../../shared/widgets/glass_container.dart';
import 'provider/products_provider.dart';
import 'model/product_model.dart';

/// Products Screen
/// Inventory management view matching the React ProductsScreen
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductsProvider(),
      child: const _ProductsScreenContent(),
    );
  }
}

class _ProductsScreenContent extends StatelessWidget {
  const _ProductsScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();

    return Stack(
      children: [
        // Main Content
        SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: provider.selectedProduct != null
              ? _ProductDetailView(provider: provider)
              : _ProductListView(provider: provider),
        ),

        // Product Entry Modal
        if (provider.isModalOpen) _ProductModal(provider: provider),

        // Stock Movement Modal
        if (provider.isMovementModalOpen) _MovementModal(provider: provider),
      ],
    );
  }
}

/// Product List View
class _ProductListView extends StatelessWidget {
  final ProductsProvider provider;

  const _ProductListView({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.boxes,
                      size: 40,
                      color: AppColors.primaryPurple,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'مستودع المفارش الذكي',
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
                  'إدارة شاملة للمخزون، تتبع الحركات والتحكم في تسعير المنتجات',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => provider.openModal(),
                  icon: const Icon(LucideIcons.plus, size: 24),
                  label: const Text('إضافة مفرش جديد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // PLACEHOLDER: Settings button - Coming Soon
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.glassDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        title: const Text(
                          'إعدادات المخزون',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SwitchListTile(
                              title: const Text(
                                'تنبيهات انخفاض المخزون',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              value: true,
                              onChanged: (val) {},
                              activeThumbColor: AppColors.primaryPurple,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: '10',
                              decoration: const InputDecoration(
                                labelText: 'حد انخفاض المخزون الافتراضي',
                                suffixText: 'وحدة',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
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
                                  content: Text('تم حفظ الإعدادات'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                            ),
                            child: const Text('حفظ'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(LucideIcons.settings2, color: AppColors.textMuted),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.glassBackground,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Stats
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 260,
              child: StatsCard(
                label: 'إجمالي المواد',
                value: '${provider.totalProducts}',
                icon: LucideIcons.boxes,
                color: StatsCardColor.purple,
              ),
            ),
            SizedBox(
              width: 260,
              child: StatsCard(
                label: 'نقص المخزون',
                value: '${provider.lowStockCount}',
                icon: LucideIcons.alertTriangle,
                color: StatsCardColor.red,
              ),
            ),
            SizedBox(
              width: 260,
              child: StatsCard(
                label: 'قيمة المخزون',
                value:
                    '${(provider.totalInventoryValue / 1000).toStringAsFixed(1)}K د.م',
                icon: LucideIcons.barChart3,
                color: StatsCardColor.green,
              ),
            ),
            SizedBox(
              width: 260,
              child: StatsCard(
                label: 'نفدت الكمية',
                value: '${provider.outOfStockCount}',
                icon: LucideIcons.trash2,
                color: StatsCardColor.red,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Toolbar & Table
        GlassContainer(
          borderRadius: 48,
          child: Column(
            children: [
              // Toolbar
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  children: [
                    // Search
                    Expanded(
                      child: TextField(
                        onChanged: provider.setSearchQuery,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText:
                              'ابحث بالمرجع، البيان، أو العلامة التجارية...',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                          prefixIcon: Icon(
                            LucideIcons.search,
                            color: AppColors.textMuted,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: AppColors.glassBorder,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.glassBackground,
                        ),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Category Filter
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.glassDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: provider.categories.map((cat) {
                          final isActive = provider.activeCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => provider.setActiveCategory(cat),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primaryPurple
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  cat == 'ALL' ? 'كل الأصناف' : cat,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textMuted,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.glassBackground,
                  ),
                  columns: const [
                    DataColumn(label: Text('المرجع')),
                    DataColumn(label: Text('اسم المنتج / البيان')),
                    DataColumn(label: Text('المقاسات')),
                    DataColumn(label: Text('سعر الوحدة')),
                    DataColumn(label: Text('المخزون')),
                    DataColumn(label: Text('الإجراءات')),
                  ],
                  rows: provider.filteredProducts.map((p) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            p.refArticle,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.glassBackground,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  LucideIcons.package,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    p.designation,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${p.brand} • ${p.category}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.glassBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Text(
                              '${p.dimensions} CM',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${p.priceTTC.toStringAsFixed(0)} د.م',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'HT: ${p.priceHT.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(_StockBadge(product: p)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => provider.openModal(p),
                                icon: Icon(LucideIcons.edit, size: 18),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue
                                      .withValues(alpha: 0.1),
                                ),
                                color: AppColors.primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => provider.deleteProduct(p.id),
                                icon: Icon(LucideIcons.trash2, size: 18),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.red.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                color: AppColors.red,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => provider.selectProduct(p),
                                icon: Icon(LucideIcons.chevronLeft, size: 18),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.glassBackground,
                                ),
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              if (provider.filteredProducts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(64),
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.search,
                        size: 80,
                        color: AppColors.primaryPurple.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'لم يتم العثور على أي مفارش مطابقة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => provider.resetFilters(),
                        child: Text(
                          'إعادة ضبط البحث',
                          style: TextStyle(color: AppColors.primaryPurple),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Product Detail View
class _ProductDetailView extends StatelessWidget {
  final ProductsProvider provider;

  const _ProductDetailView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final product = provider.selectedProduct!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        GlassContainer(
          borderRadius: 48,
          padding: const EdgeInsets.all(32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => provider.clearSelection(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 24),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleToIndigo,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: AppColors.coloredShadow(
                        AppColors.primaryPurple,
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.package,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.designation,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: [
                          _Tag(
                            text: product.refArticle,
                            color: AppColors.primaryPurple,
                          ),
                          _Tag(
                            text: product.brand,
                            color: AppColors.textSecondary,
                          ),
                          _Tag(
                            text: product.category,
                            color: AppColors.emerald,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => provider.openModal(product),
                    icon: const Icon(LucideIcons.edit, size: 18),
                    label: const Text('تعديل'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => provider.openMovementModal(),
                    icon: const Icon(LucideIcons.layers, size: 18),
                    label: const Text('حركة المخزون'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Detail Cards Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price & Stock Stats
            SizedBox(
              width: 380,
              child: GlassContainer(
                borderRadius: 40,
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'القيمة السوقية للقطعة',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.priceTTC.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'د.م',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.emerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.glassDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.calculator,
                            size: 14,
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'HT: ${product.priceHT.toStringAsFixed(0)} + TVA 20%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(height: 1, color: AppColors.glassBorder),
                    const SizedBox(height: 32),
                    Text(
                      'وضعية المستودع الحالية',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.glassDark,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${product.stock}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'قطعة متوفرة',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          _StockBadge(product: product, isLarge: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.red.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.alertTriangle,
                            size: 14,
                            color: AppColors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'التنبيه عند: ${product.minStock} قطع',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 24),

            // Movement History
            Expanded(
              child: GlassContainer(
                borderRadius: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.glassBackground,
                        border: Border(
                          bottom: BorderSide(color: AppColors.glassBorder),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.history,
                                size: 24,
                                color: AppColors.primaryPurple,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'سجل حركات المخزون',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.glassDark,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Text(
                              '${product.movements.length} عمليات',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (product.movements.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(64),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.history,
                                size: 64,
                                color: AppColors.textMuted.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد حركات مسجلة لهذا المنتج',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.glassBackground,
                        ),
                        columns: const [
                          DataColumn(label: Text('نوع العملية')),
                          DataColumn(label: Text('الكمية')),
                          DataColumn(label: Text('التاريخ')),
                          DataColumn(label: Text('السبب / البيان')),
                        ],
                        rows: product.movements.map((mv) {
                          final isIn = mv.type == MovementType.stockIn;
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    Icon(
                                      isIn
                                          ? LucideIcons.arrowUpCircle
                                          : LucideIcons.arrowDownCircle,
                                      size: 16,
                                      color: isIn
                                          ? AppColors.emerald
                                          : AppColors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isIn ? 'دخول / توريد' : 'خروج / صرف',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: isIn
                                            ? AppColors.emerald
                                            : AppColors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${mv.quantity}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${mv.date.day}/${mv.date.month}/${mv.date.year}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  mv.reason.isEmpty ? 'بدون بيان' : mv.reason,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Stock Badge Widget
class _StockBadge extends StatelessWidget {
  final Product product;
  final bool isLarge;

  const _StockBadge({required this.product, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    if (product.isOutOfStock) {
      color = AppColors.red;
      bgColor = AppColors.red.withValues(alpha: 0.1);
    } else if (product.isLowStock) {
      color = AppColors.amber;
      bgColor = AppColors.amber.withValues(alpha: 0.1);
    } else {
      color = AppColors.emerald;
      bgColor = AppColors.emerald.withValues(alpha: 0.1);
    }

    return Container(
      padding: EdgeInsets.all(isLarge ? 16 : 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Icon(LucideIcons.boxes, size: isLarge ? 32 : 20, color: color),
    );
  }
}

/// Tag Widget
class _Tag extends StatelessWidget {
  final String text;
  final Color color;

  const _Tag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Product Entry/Edit Modal
class _ProductModal extends StatelessWidget {
  final ProductsProvider provider;

  const _ProductModal({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: GlassContainer(
          isDark: true,
          borderRadius: 40,
          padding: const EdgeInsets.all(32),
          child: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          provider.editingProduct?.id != null
                              ? LucideIcons.edit
                              : LucideIcons.plus,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          provider.editingProduct?.id != null
                              ? 'تعديل بيانات المنتج'
                              : 'إضافة منتج جديد للمخزون',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => provider.closeModal(),
                      icon: Icon(LucideIcons.x, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'نموذج إضافة/تعديل المنتج - سيتم تطويره لاحقاً',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => provider.closeModal(),
                        icon: const Icon(LucideIcons.save),
                        label: const Text('حفظ البيانات'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => provider.closeModal(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: const Text('إلغاء'),
                      ),
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
}

/// Stock Movement Modal
class _MovementModal extends StatelessWidget {
  final ProductsProvider provider;

  const _MovementModal({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isIn = provider.movementType == MovementType.stockIn;

    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: GlassContainer(
          isDark: true,
          borderRadius: 40,
          padding: const EdgeInsets.all(32),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: (isIn ? AppColors.emerald : AppColors.red)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    isIn
                        ? LucideIcons.arrowUpCircle
                        : LucideIcons.arrowDownCircle,
                    size: 32,
                    color: isIn ? AppColors.emerald : AppColors.red,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'تعديل حركة المخزون',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  provider.selectedProduct?.designation ?? '',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                // Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.glassDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              provider.setMovementType(MovementType.stockIn),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isIn
                                  ? AppColors.emerald
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'توريد (دخول)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: isIn
                                      ? Colors.white
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              provider.setMovementType(MovementType.stockOut),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isIn ? AppColors.red : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'صرف (خروج)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: !isIn
                                      ? Colors.white
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      provider.setMovementQuantity(int.tryParse(v) ?? 0),
                  decoration: const InputDecoration(labelText: 'الكمية'),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (v) => provider.setMovementReason(v),
                  decoration: const InputDecoration(
                    labelText: 'السبب / الملاحظة',
                    hintText: 'مثال: توريد من مصنع لوتس',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => provider.executeStockMovement(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isIn ? AppColors.emerald : AppColors.red,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text('تأكيد العملية'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
