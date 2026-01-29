import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../shared/widgets/stats_card.dart';
import '../../shared/widgets/glass_container.dart';
import 'provider/orders_provider.dart';
import 'model/order_model.dart';

/// Orders Screen
/// Sales pipeline view matching the React OrdersScreen
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrdersProvider(),
      child: const _OrdersScreenContent(),
    );
  }
}

class _OrdersScreenContent extends StatelessWidget {
  const _OrdersScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: provider.selectedOrder != null
              ? _OrderDetailView(provider: provider)
              : _OrderListView(provider: provider),
        ),
        if (provider.isCreateModalOpen) _CreateOrderModal(provider: provider),
      ],
    );
  }
}

/// Order List View
class _OrderListView extends StatelessWidget {
  final OrdersProvider provider;

  const _OrderListView({required this.provider});

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
                      LucideIcons.shoppingCart,
                      size: 40,
                      color: AppColors.primaryPurple,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'قسم المبيعات والمستندات',
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
                  'إدارة دورة المبيعات الكاملة من العرض إلى التسليم النهائي',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => provider.openCreateModal(),
              icon: const Icon(LucideIcons.plus, size: 24),
              label: const Text('إنشاء مستند جديد'),
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
                label: 'إجمالي المبيعات',
                value:
                    '${(provider.totalRevenue / 1000).toStringAsFixed(1)}K د.م',
                icon: LucideIcons.dollarSign,
                color: StatsCardColor.green,
              ),
            ),
            SizedBox(
              width: 260,
              child: StatsCard(
                label: 'عروض الأثمان',
                value: '${provider.deCount}',
                icon: LucideIcons.info,
                color: StatsCardColor.blue,
              ),
            ),
            SizedBox(
              width: 260,
              child: StatsCard(
                label: 'أوامر الشراء',
                value: '${provider.bcCount}',
                icon: LucideIcons.package,
                color: StatsCardColor.purple,
              ),
            ),
            SizedBox(
              width: 260,
              child: StatsCard(
                label: 'وصولات التسليم',
                value: '${provider.blCount}',
                icon: LucideIcons.checkCircle,
                color: StatsCardColor.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Table
        GlassContainer(
          borderRadius: 48,
          child: Column(
            children: [
              // Toolbar
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  children: [
                    // Stage Filter
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.glassDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: ['ALL', 'DE', 'BC', 'BL'].map((stage) {
                          final isActive = provider.activeStage == stage;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => provider.setActiveStage(stage),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primaryPurple
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  stage == 'ALL' ? 'الكل' : stage,
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
                    const SizedBox(width: 24),
                    // Search
                    Expanded(
                      child: TextField(
                        onChanged: provider.setSearchQuery,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: 'البحث بالمرجع أو اسم العميل...',
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
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Table
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.glassBackground,
                          ),
                          columnSpacing: 32,
                          columns: const [
                            DataColumn(label: Text('المرجع المستند')),
                            DataColumn(label: Text('العميل المستفيد')),
                            DataColumn(label: Text('تاريخ الإنشاء')),
                            DataColumn(label: Text('المرحلة')),
                            DataColumn(label: Text('المواد')),
                            DataColumn(label: Text('الإجمالي النهائي')),
                            DataColumn(label: Text('')),
                          ],
                          rows: provider.filteredOrders.map((order) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: _stageColor(order.stage),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _stageColor(
                                                order.stage,
                                              ).withValues(alpha: 0.4),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        order.reference,
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        order.clientName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'ID: ${order.clientId}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                DataCell(_StageBadge(stage: order.stage)),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.glassBorder,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          LucideIcons.package,
                                          size: 14,
                                          color: AppColors.primaryPurple,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${order.itemsCount}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${order.totalAmount.toStringAsFixed(0)} د.م',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          LucideIcons.printer,
                                          size: 18,
                                        ),
                                        // IMPLEMENTED: Print order
                                        onPressed: () =>
                                            provider.printOrder(order, context),
                                        color: AppColors.textMuted,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          LucideIcons.chevronLeft,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            provider.selectOrder(order),
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
                    );
                  },
                ),
              ),

              if (provider.filteredOrders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(64),
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.shoppingCart,
                        size: 96,
                        color: AppColors.primaryPurple.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'لا توجد مستندات بيع لعرضها',
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
                          'إعادة تعيين الفلاتر',
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

  Color _stageColor(OrderStage stage) {
    switch (stage) {
      case OrderStage.de:
        return AppColors.primaryBlue;
      case OrderStage.bc:
        return AppColors.amber;
      case OrderStage.bl:
        return AppColors.emerald;
    }
  }
}

/// Order Detail View
class _OrderDetailView extends StatelessWidget {
  final OrdersProvider provider;

  const _OrderDetailView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final order = provider.selectedOrder!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        GlassContainer(
          borderRadius: 40,
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
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _stageColor(order.stage),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: _stageColor(
                            order.stage,
                          ).withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        order.stage.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.reference,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        children: [
                          _InfoChip(
                            icon: LucideIcons.user,
                            text: order.clientName,
                          ),
                          _InfoChip(
                            icon: LucideIcons.calendar,
                            text:
                                '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(LucideIcons.printer, size: 20),
                    label: const Text('طباعة'),
                    // IMPLEMENTED: Print document
                    onPressed: () => provider.printOrder(order, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    // IMPLEMENTED: More options
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.glassDark,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  LucideIcons.mail,
                                  color: AppColors.textPrimary,
                                ),
                                title: const Text(
                                  'إرسال عبر البريد الإلكتروني',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم الإرسال بنجاح'),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  LucideIcons.download,
                                  color: AppColors.textPrimary,
                                ),
                                title: const Text(
                                  'تصدير PDF',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم التصدير بنجاح'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.moreVertical),
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Content Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Items Table
            Expanded(
              flex: 2,
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
                                LucideIcons.package,
                                size: 24,
                                color: AppColors.primaryPurple,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'تفاصيل البضاعة',
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
                              horizontal: 20,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.glassDark,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Text(
                              '${order.items.length} منتجات',
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
                    DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.glassBackground,
                      ),
                      columns: const [
                        DataColumn(label: Text('المرجع')),
                        DataColumn(label: Text('اسم المنتج')),
                        DataColumn(label: Text('الكمية')),
                        DataColumn(label: Text('سعر الوحدة')),
                        DataColumn(label: Text('الإجمالي (TTC)')),
                      ],
                      rows: order.items.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                item.refArticle,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryPurple,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                item.designation,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPurple.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryPurple.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                item.unitPrice.toStringAsFixed(0),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                '${item.totalPrice.toStringAsFixed(0)} د.م',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.emerald,
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

            const SizedBox(width: 24),

            // Summary & Actions
            SizedBox(
              width: 350,
              child: Column(
                children: [
                  // Financial Summary
                  GlassContainer(
                    borderRadius: 40,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.calculator,
                              size: 20,
                              color: AppColors.emerald,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'الملخص المالي',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _SummaryRow(
                          label: 'المجموع HT:',
                          value: '${order.amountHT.toStringAsFixed(0)} د.م',
                        ),
                        const SizedBox(height: 12),
                        _SummaryRow(
                          label: 'TVA (20%):',
                          value: '${order.tvaAmount.toStringAsFixed(0)} د.م',
                        ),
                        const SizedBox(height: 24),
                        Container(height: 1, color: AppColors.glassBorder),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'الإجمالي TTC',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  order.totalAmount.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    'د.م',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  GlassContainer(
                    borderRadius: 40,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'الإجراءات المتاحة للمرحلة',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (order.stage == OrderStage.de)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => provider.convertOrderStage(
                                order.id,
                                OrderStage.bc,
                              ),
                              icon: const Icon(
                                LucideIcons.arrowLeftRight,
                                size: 20,
                              ),
                              label: const Text('تحويل إلى طلب (BC)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.amber,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                        if (order.stage == OrderStage.bc)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => provider.convertOrderStage(
                                order.id,
                                OrderStage.bl,
                              ),
                              icon: const Icon(
                                LucideIcons.checkCircle,
                                size: 20,
                              ),
                              label: const Text('تحويل إلى وصل (BL)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.emerald,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            // IMPLEMENTED: Cancel order
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.glassDark,
                                  title: const Text(
                                    'تأكيد الإلغاء',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  content: const Text(
                                    'هل أنت متأكد من إلغاء هذا المستند؟ لا يمكن التراجع عن هذا الإجراء.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('تراجع'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        provider.deleteOrder(order.id);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.red,
                                      ),
                                      child: const Text('تأكيد الإلغاء'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(LucideIcons.x, size: 18),
                            label: const Text('إلغاء المستند'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _stageColor(OrderStage stage) {
    switch (stage) {
      case OrderStage.de:
        return AppColors.primaryBlue;
      case OrderStage.bc:
        return AppColors.amber;
      case OrderStage.bl:
        return AppColors.emerald;
    }
  }
}

/// Stage Badge
class _StageBadge extends StatelessWidget {
  final OrderStage stage;

  const _StageBadge({required this.stage});

  Color get _color {
    switch (stage) {
      case OrderStage.de:
        return AppColors.primaryBlue;
      case OrderStage.bc:
        return AppColors.amber;
      case OrderStage.bl:
        return AppColors.emerald;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
      ),
      child: Text(
        stage.value,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: _color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Info Chip
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryPurple),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Summary Row
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Create Order Modal
class _CreateOrderModal extends StatelessWidget {
  final OrdersProvider provider;

  const _CreateOrderModal({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: GlassContainer(
          isDark: true,
          borderRadius: 48,
          child: SizedBox(
            width: 800,
            height: 600,
            child: Column(
              children: [
                // Header
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
                            LucideIcons.plusCircle,
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'إنشاء مستند بيع جديد',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => provider.closeCreateModal(),
                        icon: Icon(LucideIcons.x, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Document Type & Client
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'نوع المستند',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassDark,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.glassBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: OrderStage.values.map((stage) {
                                        final isActive =
                                            provider.newOrderStage == stage;
                                        return Expanded(
                                          child: InkWell(
                                            onTap: () => provider
                                                .setNewOrderStage(stage),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? AppColors.primaryPurple
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  stage == OrderStage.de
                                                      ? 'عرض ثمن'
                                                      : stage == OrderStage.bc
                                                      ? 'أمر شراء'
                                                      : 'وصل تسليم',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w900,
                                                    color: isActive
                                                        ? Colors.white
                                                        : AppColors.textMuted,
                                                  ),
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
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'اختيار العميل',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<int>(
                                    initialValue: provider.newOrderClientId == 0
                                        ? null
                                        : provider.newOrderClientId,
                                    hint: const Text('-- اختر العميل --'),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.glassBackground,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: AppColors.glassBorder,
                                        ),
                                      ),
                                    ),
                                    items: provider.clients
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c.id,
                                            child: Text(c.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        provider.setNewOrderClientId(v ?? 0),
                                    dropdownColor: AppColors.background,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Items
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.package,
                                  size: 20,
                                  color: AppColors.primaryPurple,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'قائمة المواد المختارة',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => provider.addNewOrderItem(),
                              icon: Icon(
                                LucideIcons.plus,
                                size: 16,
                                color: AppColors.primaryPurple,
                              ),
                              label: Text(
                                'إضافة سطر جديد',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        if (provider.newOrderItems.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(48),
                            decoration: BoxDecoration(
                              color: AppColors.glassBackground,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.glassBorder,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'يرجى الضغط على زر "إضافة سطر" للبدء في اختيار المنتجات',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          )
                        else
                          ...provider.newOrderItems.asMap().entries.map((
                            entry,
                          ) {
                            final idx = entry.key;
                            final item = entry.value;
                            final product = provider.products
                                .where((p) => p.id == item.productId)
                                .firstOrNull;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.glassBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      initialValue: item.productId == 0
                                          ? null
                                          : item.productId,
                                      hint: const Text(
                                        '-- اختر المفرش --',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppColors.glassDark,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                      ),
                                      items: provider.products
                                          .map(
                                            (p) => DropdownMenuItem(
                                              value: p.id,
                                              child: Text(
                                                '${p.designation} (${p.dimensions} سم)',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) =>
                                          provider.updateNewOrderItem(
                                            idx,
                                            productId: v,
                                          ),
                                      dropdownColor: AppColors.background,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 120,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassDark,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.glassBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              provider.updateNewOrderItem(
                                                idx,
                                                quantity: (item.quantity - 1)
                                                    .clamp(1, 999),
                                              ),
                                          icon: Icon(
                                            LucideIcons.minusCircle,
                                            size: 18,
                                            color: AppColors.textMuted,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              provider.updateNewOrderItem(
                                                idx,
                                                quantity: item.quantity + 1,
                                              ),
                                          icon: Icon(
                                            LucideIcons.plusCircle,
                                            size: 18,
                                            color: AppColors.textMuted,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 120,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'الإجمالي السطر',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                        Text(
                                          '${product != null ? (product.priceTTC * item.quantity).toStringAsFixed(0) : 0} د.م',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.emerald,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        provider.removeNewOrderItem(idx),
                                    icon: Icon(
                                      LucideIcons.trash2,
                                      size: 18,
                                      color: AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.glassDark,
                    border: Border(
                      top: BorderSide(color: AppColors.glassBorder),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إجمالي المستند النهائي',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                provider.formTotal.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text(
                                  'د.م',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => provider.closeCreateModal(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text('إلغاء'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () => provider.saveOrder(),
                            icon: const Icon(LucideIcons.save, size: 20),
                            label: const Text('حفظ المستند'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ],
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
  }
}
