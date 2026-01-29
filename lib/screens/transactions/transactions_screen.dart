import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../../shared/widgets/stats_card.dart';
import '../../shared/widgets/glass_container.dart';
import 'provider/transactions_provider.dart';
import 'model/transaction_model.dart';
import 'widgets/add_payment_modal.dart';

/// Transactions Screen
/// Financial transactions view matching the React TransactionsScreen
/// Now fully responsive with loading states and error handling
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionsProvider(),
      child: const _TransactionsScreenContent(),
    );
  }
}

class _TransactionsScreenContent extends StatelessWidget {
  const _TransactionsScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionsProvider>();
    final isMobile = Responsive.isMobile(context);

    // Show loading state
    if (provider.isLoading) {
      return _buildLoadingView();
    }

    // Show error state with retry option
    if (provider.hasError) {
      return _buildErrorView(
        message: provider.errorMessage ?? 'حدث خطأ غير متوقع',
        onRetry: () => provider.refreshTransactions(),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: provider.refreshTransactions,
          color: AppColors.emerald,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: Responsive.padding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header - Responsive
                _buildHeader(context, provider, isMobile),

                SizedBox(height: isMobile ? 24 : 32),

                // Financial KPIs - Responsive grid
                _buildStatsGrid(context, provider, isMobile),

                SizedBox(height: isMobile ? 24 : 32),

                // Toolbar
                _buildToolbar(context, provider, isMobile),

                SizedBox(height: isMobile ? 16 : 24),

                // Table or List (based on screen size)
                _buildTransactionsList(context, provider, isMobile),
              ],
            ),
          ),
        ),

        // Transaction Receipt Modal
        if (provider.selectedTransaction != null)
          _TransactionReceiptModal(
            transaction: provider.selectedTransaction!,
            onClose: () => provider.clearSelection(),
          ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    TransactionsProvider provider,
    bool isMobile,
  ) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.creditCard, size: 28, color: AppColors.emerald),
              const SizedBox(width: 12),
              Text(
                'إدارة المعاملات',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'تتبع التدفق النقدي ومستحقات العملاء',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final transaction = await AddPaymentModal.show(context);
                if (transaction != null && context.mounted) {
                  await Provider.of<TransactionsProvider>(
                    context,
                    listen: false,
                  ).addTransaction(transaction, context);
                }
              },
              icon: const Icon(LucideIcons.plus, size: 20),
              label: const Text('تسجيل دفعة جديدة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.creditCard,
                    size: 32,
                    color: AppColors.emerald,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'إدارة المعاملات',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'تتبع التدفق النقدي ومستحقات العملاء',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final transaction = await AddPaymentModal.show(context);
            if (transaction != null && context.mounted) {
              await Provider.of<TransactionsProvider>(
                context,
                listen: false,
              ).addTransaction(transaction, context);
            }
          },
          icon: const Icon(LucideIcons.plus, size: 20),
          label: const Text('تسجيل دفعة جديدة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    TransactionsProvider provider,
    bool isMobile,
  ) {
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
            label: 'إجمالي المبيعات',
            value: '${_formatNumber(provider.totalValue)} د.م',
            icon: LucideIcons.fileText,
            color: StatsCardColor.blue,
          ),
          StatsCard(
            label: 'المحصل نقداً',
            value: '${_formatNumber(provider.collected)} د.م',
            icon: LucideIcons.arrowUpCircle,
            color: StatsCardColor.green,
          ),
          StatsCard(
            label: 'نسبة التحصيل',
            value: '${provider.collectionRate}%',
            icon: LucideIcons.creditCard,
            color: StatsCardColor.purple,
          ),
          StatsCard(
            label: 'باقي التحصيل',
            value: '${_formatNumber(provider.remaining)} د.م',
            icon: LucideIcons.clock,
            color: StatsCardColor.red,
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

  Widget _buildToolbar(
    BuildContext context,
    TransactionsProvider provider,
    bool isMobile,
  ) {
    if (isMobile) {
      // Mobile: Stacked layout
      return Column(
        children: [
          // Search
          GlassContainer(
            borderRadius: 20,
            isDark: true,
            child: TextField(
              onChanged: provider.setSearchQuery,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث بالمرجع أو اسم العميل...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 8),
                  child: Icon(
                    LucideIcons.search,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['ALL', 'Cash', 'Virement', 'Cheque'].map((type) {
                final isActive = provider.filterType == type;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: InkWell(
                    onTap: () => provider.setFilterType(type),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.emerald
                            : AppColors.glassBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? AppColors.emerald
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        type == 'ALL' ? 'الكل' : type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isActive ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    // Desktop: Row layout
    return GlassContainer(
      borderRadius: 32,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Search
          Expanded(
            child: TextField(
              onChanged: provider.setSearchQuery,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث بالمرجع أو اسم العميل...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                filled: true,
                fillColor: AppColors.glassBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          // Filter
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.glassDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: ['ALL', 'Cash', 'Virement', 'Cheque'].map((type) {
                final isActive = provider.filterType == type;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => provider.setFilterType(type),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.emerald
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type == 'ALL' ? 'الكل' : type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isActive ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: AppColors.emerald,
                        onPrimary: Colors.white,
                        surface: AppColors.glassDark,
                        onSurface: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم اختيار الفترة: ${picked.start.day}/${picked.start.month} - ${picked.end.day}/${picked.end.month}',
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: Icon(
              LucideIcons.calendar,
              size: 18,
              color: AppColors.textMuted,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.glassBackground,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    TransactionsProvider provider,
    bool isMobile,
  ) {
    final transactions = provider.filteredTransactions;

    if (transactions.isEmpty) {
      return _buildEmptyState(provider.searchQuery.isNotEmpty);
    }

    if (isMobile) {
      // Mobile: Card list
      return Column(
        children: transactions.map((tx) {
          return _TransactionCard(
            transaction: tx,
            onTap: () => provider.selectTransaction(tx),
          );
        }).toList(),
      );
    }

    // Desktop: Table
    return GlassContainer(
      borderRadius: 32,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.glassBackground,
                  ),
                  columnSpacing: 32,
                  columns: const [
                    DataColumn(label: Text('المرجع')),
                    DataColumn(label: Text('العميل')),
                    DataColumn(label: Text('التاريخ')),
                    DataColumn(label: Text('المبلغ الإجمالي')),
                    DataColumn(label: Text('تم دفعه')),
                    DataColumn(label: Text('طريقة الدفع')),
                    DataColumn(label: Text('')),
                  ],
                  rows: transactions.map((tx) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            tx.reference,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.emerald,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.glassBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  LucideIcons.user,
                                  size: 16,
                                  color: AppColors.emerald,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                tx.clientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'monospace',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatNumber(tx.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatNumber(tx.amountPaid),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.emerald,
                                ),
                              ),
                              Text(
                                'باقي: ${_formatNumber(tx.amountRemaining)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.red.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.emerald.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              tx.paymentMethod,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.emerald,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            onPressed: () => provider.selectTransaction(tx),
                            icon: Icon(
                              LucideIcons.arrowRight,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
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
              isSearchResult ? LucideIcons.search : LucideIcons.creditCard,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              isSearchResult
                  ? 'لم يتم العثور على معاملات مطابقة'
                  : 'لا توجد معاملات بعد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearchResult
                  ? 'جرب تغيير معايير البحث'
                  : 'ابدأ بتسجيل أول معاملة',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: AppColors.emerald,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل المعاملات...',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: AppColors.red.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
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

/// Transaction Card for Mobile
class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const _TransactionCard({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
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
                      fontWeight: FontWeight.w900,
                      color: AppColors.emerald,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      transaction.paymentMethod,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.emerald,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.user,
                      size: 14,
                      color: AppColors.emerald,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      transaction.clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AmountColumn(
                      label: 'المبلغ',
                      value: _formatNumber(transaction.amount),
                      color: AppColors.textPrimary,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppColors.glassBorder,
                    ),
                    _AmountColumn(
                      label: 'المدفوع',
                      value: _formatNumber(transaction.amountPaid),
                      color: AppColors.emerald,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppColors.glassBorder,
                    ),
                    _AmountColumn(
                      label: 'المتبقي',
                      value: _formatNumber(transaction.amountRemaining),
                      color: AppColors.red.withValues(alpha: 0.8),
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

  String _formatNumber(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _AmountColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AmountColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Transaction Receipt Modal
class _TransactionReceiptModal extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onClose;

  const _TransactionReceiptModal({
    required this.transaction,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: GlassContainer(
              isDark: true,
              borderRadius: isMobile ? 32 : 40,
              padding: EdgeInsets.all(isMobile ? 24 : 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 400,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: isMobile ? 48 : 64,
                          height: isMobile ? 48 : 64,
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              isMobile ? 16 : 24,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.receipt,
                            size: isMobile ? 24 : 32,
                            color: AppColors.emerald,
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: Icon(
                            LucideIcons.x,
                            size: 24,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isMobile ? 24 : 32),

                    // Amount
                    Text(
                      'وصل معاملة مالية',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatNumber(transaction.amountPaid),
                          style: TextStyle(
                            fontSize: isMobile ? 28 : 36,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'د.م',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.checkCircle2,
                            size: 12,
                            color: AppColors.emerald,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'مكتملة بنجاح',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.emerald,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isMobile ? 24 : 32),

                    // Details
                    Container(
                      padding: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.glassBorder),
                        ),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            label: 'المرجع',
                            value: transaction.reference,
                            isMono: true,
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            label: 'العميل',
                            value: transaction.clientName,
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            label: 'التاريخ',
                            value:
                                '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            label: 'طريقة الدفع',
                            value: transaction.paymentMethod,
                            valueColor: AppColors.emerald,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isMobile ? 24 : 32),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('جاري إرسال الوصل للطباعة...'),
                                  backgroundColor: Color(0xFF2563EB),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(LucideIcons.printer, size: 18),
                            label: const Text('طباعة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 14 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم نسخ بيانات الوصل للمشاركة'),
                                  backgroundColor: Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 14 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('مشاركة'),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMono;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isMono = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: isMono ? 'monospace' : null,
              color: valueColor ?? AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
