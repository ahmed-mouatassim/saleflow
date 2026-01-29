import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/responsive.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/stats_card.dart';
import '../model/client_model.dart';
import '../provider/clients_provider.dart';
import '../../transactions/model/transaction_model.dart';
import '../../orders/model/order_model.dart';
import 'edit_client_modal.dart';

/// Client Detail Widget
/// Displays detailed client information and history
/// Fully responsive with adaptive layouts
class ClientDetailWidget extends StatelessWidget {
  final Client client;
  final List<Transaction> transactions;
  final List<Order> orders;
  final VoidCallback onBack;

  const ClientDetailWidget({
    super.key,
    required this.client,
    required this.transactions,
    required this.orders,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return SingleChildScrollView(
      // Important: Allow scrolling to prevent overflow on any screen size
      physics: const AlwaysScrollableScrollPhysics(),
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Detail Header - Responsive
          _buildHeaderCard(context, isMobile),

          SizedBox(height: isMobile ? 16 : 24),

          // Client Stats Summary - Responsive grid
          _buildStatsGrid(context),

          SizedBox(height: isMobile ? 16 : 24),

          // Orders and Transactions - Stacked on mobile/tablet, side-by-side on desktop
          if (isMobile || isTablet)
            Column(
              children: [
                _buildOrdersCard(context, isMobile),
                const SizedBox(height: 24),
                _buildTransactionsCard(context, isMobile),
              ],
            )
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 350,
                    child: _buildOrdersCard(context, isMobile),
                  ),
                  const SizedBox(width: 24),
                  Expanded(child: _buildTransactionsCard(context, isMobile)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isMobile) {
    if (isMobile) {
      // Mobile: Stacked layout
      return GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button and Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      LucideIcons.arrowRight,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        EditClientModal.show(context, client).then((
                          updatedClient,
                        ) {
                          if (updatedClient != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم تحديث بيانات العميل بنجاح'),
                                backgroundColor: Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        });
                      },
                      icon: const Icon(LucideIcons.edit, size: 20),
                      color: AppColors.primaryBlue,
                    ),
                    // FIXED: More options popup menu
                    PopupMenuButton<String>(
                      icon: const Icon(LucideIcons.moreVertical),
                      color: AppColors.textMuted,
                      onSelected: (value) {
                        switch (value) {
                          case 'delete':
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.glassDark,
                                title: const Text(
                                  'تأكيد الحذف',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                content: Text(
                                  'هل أنت متأكد من حذف العميل ${client.name}؟',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('إلغاء'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context
                                          .read<ClientsProvider>()
                                          .deleteClient(client.id, context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.red,
                                    ),
                                    child: const Text('حذف'),
                                  ),
                                ],
                              ),
                            );
                            break;
                          case 'export':
                            context.read<ClientsProvider>().exportClientData(
                              client,
                              context,
                            );
                            break;
                        }
                      },
                      itemBuilder: (context) => [
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
                                'حذف العميل',
                                style: TextStyle(color: Color(0xFFEF4444)),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'export',
                          child: Row(
                            children: [
                              Icon(LucideIcons.download, size: 18),
                              SizedBox(width: 8),
                              Text('تصدير البيانات'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Client Info
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.blueToPurple,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppColors.coloredShadow(AppColors.primaryBlue),
                  ),
                  child: Center(
                    child: Text(
                      client.name.isNotEmpty ? client.name[0] : '?',
                      style: const TextStyle(
                        fontSize: 24,
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
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
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
                              color: client.isActive
                                  ? AppColors.emerald
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            client.isActive ? 'نشط' : 'غير نشط',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Contact Info Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(icon: LucideIcons.phone, text: client.phone),
                _InfoChip(icon: LucideIcons.mapPin, text: client.address),
              ],
            ),
          ],
        ),
      );
    }

    // Desktop/Tablet: Row layout
    return GlassContainer(
      borderRadius: 40,
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // Back Button
                InkWell(
                  onTap: onBack,
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

                // Client Info
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.blueToPurple,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppColors.coloredShadow(
                            AppColors.primaryBlue,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            client.name.isNotEmpty ? client.name[0] : '?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _InfoChip(
                                  icon: LucideIcons.phone,
                                  text: client.phone,
                                ),
                                _InfoChip(
                                  icon: LucideIcons.mapPin,
                                  text: client.address,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  EditClientModal.show(context, client).then((updatedClient) {
                    if (updatedClient != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تحديث بيانات العميل بنجاح'),
                          backgroundColor: Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('تعديل الملف'),
              ),
              const SizedBox(width: 8),
              // FIXED: More options popup menu
              PopupMenuButton<String>(
                icon: const Icon(LucideIcons.moreVertical),
                color: AppColors.textPrimary,
                onSelected: (value) {
                  switch (value) {
                    case 'toggle':
                      context.read<ClientsProvider>().toggleClientStatus(
                        client,
                        context,
                      );
                      break;
                    case 'delete':
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.glassDark,
                          title: const Text(
                            'تأكيد الحذف',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          content: Text(
                            'هل أنت متأكد من حذف العميل ${client.name}؟',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('إلغاء'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.read<ClientsProvider>().deleteClient(
                                  client.id,
                                  context,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.red,
                              ),
                              child: const Text('حذف'),
                            ),
                          ],
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        const Icon(LucideIcons.userX, size: 18),
                        const SizedBox(width: 8),
                        Text(client.isActive ? 'تعطيل العميل' : 'تفعيل العميل'),
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
                          'حذف العميل',
                          style: TextStyle(color: Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        late double cardWidth;

        if (availableWidth < 400) {
          cardWidth = availableWidth;
        } else if (availableWidth < 600) {
          cardWidth = (availableWidth - 16) / 2;
        } else if (availableWidth < 900) {
          cardWidth = (availableWidth - 32) / 3;
        } else {
          cardWidth = (availableWidth - 48) / 4;
        }

        final cards = [
          StatsCard(
            label: 'إجمالي المسحوبات',
            value: '${_formatNumber(client.totalAmount)} د.م',
            icon: LucideIcons.dollarSign,
            color: StatsCardColor.blue,
          ),
          StatsCard(
            label: 'إجمالي المدفوع',
            value: '${_formatNumber(client.amountPaid)} د.م',
            icon: LucideIcons.dollarSign,
            color: StatsCardColor.green,
          ),
          StatsCard(
            label: 'الرصيد المتبقي',
            value: '${_formatNumber(client.amountRemaining)} د.م',
            icon: LucideIcons.dollarSign,
            color: StatsCardColor.red,
          ),
          StatsCard(
            label: 'حد الائتمان',
            value: '${_formatNumber(client.limitPrice)} د.م',
            icon: LucideIcons.user,
            color: StatsCardColor.purple,
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards.map((card) {
            return SizedBox(width: cardWidth.clamp(200, 300), child: card);
          }).toList(),
        );
      },
    );
  }

  Widget _buildOrdersCard(BuildContext context, bool isMobile) {
    return GlassContainer(
      borderRadius: isMobile ? 24 : 32,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.package,
                size: 20,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(width: 12),
              const Text(
                'آخر الطلبات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'لا توجد طلبات سابقة',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ...orders.take(5).map((order) => _OrderCard(order: order)),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard(BuildContext context, bool isMobile) {
    return GlassContainer(
      borderRadius: isMobile ? 24 : 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.clock, size: 20, color: AppColors.emerald),
                    const SizedBox(width: 12),
                    const Text(
                      'السجل المالي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.glassDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        title: Row(
                          children: [
                            Icon(
                              LucideIcons.download,
                              color: AppColors.emerald,
                            ),
                            const SizedBox(width: 12),
                            const Text('تحميل كشف الحساب'),
                          ],
                        ),
                        content: Text(
                          'هل تريد تحميل كشف حساب العميل ${client.name}؟\n\nسيتم إنشاء ملف PDF يحتوي على جميع المعاملات المالية.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'جاري إعداد كشف الحساب للتحميل...',
                                  ),
                                  backgroundColor: Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(LucideIcons.download, size: 18),
                            label: const Text('تحميل'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'تحميل كشف حساب',
                    style: TextStyle(fontSize: 12, color: AppColors.emerald),
                  ),
                ),
              ],
            ),
          ),

          // Transactions Table or List
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'لا توجد معاملات مالية',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else if (isMobile)
            // Mobile: Use a list instead of table
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: transactions
                    .take(10)
                    .map((tx) => _TransactionListItem(transaction: tx))
                    .toList(),
              ),
            )
          else
            // Desktop: Use table
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.glassBackground,
                  ),
                  columnSpacing: 48,
                  columns: const [
                    DataColumn(label: Text('المرجع')),
                    DataColumn(label: Text('المبلغ')),
                    DataColumn(label: Text('المدفوع')),
                    DataColumn(label: Text('المتبقي')),
                    DataColumn(label: Text('التاريخ')),
                  ],
                  rows: transactions.map((tx) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            tx.reference,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                              color: AppColors.emerald,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatNumber(tx.amount),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatNumber(tx.amountPaid),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.emerald,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatNumber(tx.amountRemaining),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.red.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
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
          Icon(icon, size: 14, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  Color get _stageColor {
    switch (order.stage) {
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  order.reference,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _stageColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  order.stage.value,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: _stageColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.totalAmount.toStringAsFixed(0)} د.م',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Transaction List Item for mobile view
class _TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const _TransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.reference,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  color: AppColors.emerald,
                ),
              ),
              Text(
                '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المبلغ',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                  Text(
                    '${_formatNumber(transaction.amount)} د.م',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'المدفوع',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                  Text(
                    '${_formatNumber(transaction.amountPaid)} د.م',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'المتبقي',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                  Text(
                    '${_formatNumber(transaction.amountRemaining)} د.م',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.red.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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
