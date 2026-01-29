import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../../shared/widgets/stats_card.dart';
import '../../shared/widgets/glass_container.dart';
import 'provider/home_provider.dart';
import 'model/home_model.dart';
import 'package:provider/provider.dart';

/// Home Screen
/// Dashboard view matching the React HomeScreen component
/// Now fully responsive with loading states and error handling
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    // Show loading state
    if (provider.isLoading) {
      return const _LoadingView();
    }

    // Show error state with retry option
    if (provider.hasError) {
      return _ErrorView(
        message: provider.errorMessage ?? 'حدث خطأ غير متوقع',
        onRetry: () => provider.refreshData(),
      );
    }

    final stats = provider.stats;
    final salesDist = provider.salesDistribution;

    // Main scrollable content - prevents RenderFlex overflow
    return RefreshIndicator(
      onRefresh: provider.refreshData,
      color: AppColors.primaryBlue,
      child: SingleChildScrollView(
        // Changed from Column to ListView for better scroll handling
        physics: const AlwaysScrollableScrollPhysics(),
        padding: Responsive.padding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section - Responsive layout
            _buildHeader(context, provider, isMobile),

            SizedBox(height: isMobile ? 24 : 32),

            // Primary KPIs - Responsive grid
            _buildStatsGrid(context, stats, isMobile),

            SizedBox(height: isMobile ? 24 : 32),

            // Two-column layout or stacked on mobile
            if (isMobile || isTablet)
              // Mobile/Tablet: Stacked layout
              Column(
                children: [
                  _SalesDistributionCard(salesDist: salesDist),
                  const SizedBox(height: 24),
                  _RecentOperationsCard(operations: provider.recentOperations),
                ],
              )
            else
              // Desktop: Side-by-side layout
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sales Distribution - Fixed width on desktop
                    SizedBox(
                      width: 350,
                      child: _SalesDistributionCard(salesDist: salesDist),
                    ),
                    const SizedBox(width: 24),
                    // Recent Operations - Flexible width
                    Expanded(
                      child: _RecentOperationsCard(
                        operations: provider.recentOperations,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    HomeProvider provider,
    bool isMobile,
  ) {
    if (isMobile) {
      // Mobile: Stacked header
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نظرة عامة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'متابعة الأداء المالي وحالة المبيعات اليومية',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          // System Time (compact on mobile)
          _buildTimeCard(provider, compact: true),
        ],
      );
    }

    // Desktop/Tablet: Row layout
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نظرة عامة',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'متابعة الأداء المالي وحالة المبيعات اليومية',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // System Time
        _buildTimeCard(provider, compact: false),
      ],
    );
  }

  Widget _buildTimeCard(HomeProvider provider, {required bool compact}) {
    return GlassContainer(
      borderRadius: 20,
      padding: EdgeInsets.all(compact ? 10 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'توقيت النظام',
            style: TextStyle(
              fontSize: compact ? 8 : 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${provider.currentTime} - ${provider.currentDate}',
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              fontFamily: 'monospace',
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, HomeStats stats, bool isMobile) {
    // Use LayoutBuilder for responsive card width calculation
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // Calculate card width based on available space
        late double cardWidth;

        if (availableWidth < 400) {
          // 1 column
          cardWidth = availableWidth;
        } else if (availableWidth < 600) {
          // 2 columns
          cardWidth = (availableWidth - 16) / 2;
        } else if (availableWidth < 900) {
          // 3 columns
          cardWidth = (availableWidth - 32) / 3;
        } else {
          // 4 columns
          cardWidth = (availableWidth - 48) / 4;
        }

        final cards = [
          StatsCard(
            label: 'إجمالي مبيعات الشهر',
            value: '${_formatNumber(stats.monthlySales)} د.م',
            icon: LucideIcons.trendingUp,
            color: StatsCardColor.blue,
          ),
          StatsCard(
            label: 'الطلبات الجديدة',
            value: '${stats.newOrders}',
            icon: LucideIcons.package,
            color: StatsCardColor.purple,
          ),
          StatsCard(
            label: 'تحصيل اليوم',
            value: '+ ${_formatNumber(stats.todayCollection)} د.م',
            icon: LucideIcons.dollarSign,
            color: StatsCardColor.green,
          ),
          StatsCard(
            label: 'تجاوز الائتمان',
            value: '${stats.creditExceededClients} عملاء',
            icon: LucideIcons.alertCircle,
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

  String _formatNumber(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

/// Sales Distribution Card
class _SalesDistributionCard extends StatelessWidget {
  final SalesDistribution salesDist;

  const _SalesDistributionCard({required this.salesDist});

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
              Icon(
                LucideIcons.trendingUp,
                size: 20,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 12),
              Text(
                'توزيع المبيعات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Devis Progress
          _SalesProgressBar(
            label: 'Devis (عروض أثمان)',
            amount: salesDist.devisAmount,
            percentage: salesDist.devisPercentage,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 16),

          // Orders Progress
          _SalesProgressBar(
            label: 'Orders (أوامر شراء)',
            amount: salesDist.ordersAmount,
            percentage: salesDist.ordersPercentage,
            color: AppColors.amber,
          ),
          const SizedBox(height: 16),

          // Delivered Progress
          _SalesProgressBar(
            label: 'Delivered (توصيل)',
            amount: salesDist.deliveredAmount,
            percentage: salesDist.deliveredPercentage,
            color: AppColors.emerald,
          ),

          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.glassBorder)),
            ),
            child: Center(
              child: Text(
                'مجموع السيولة في المسار: ${_formatNumber(salesDist.total)} د.م',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                ),
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

/// Recent Operations Card
class _RecentOperationsCard extends StatelessWidget {
  final List<RecentOperation> operations;

  const _RecentOperationsCard({required this.operations});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 32,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.checkCircle,
                    size: 20,
                    color: AppColors.emerald,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'العمليات الأخيرة',
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
                  // Show dialog to navigate to transactions
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
                            LucideIcons.creditCard,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          const Text('سجل المعاملات'),
                        ],
                      ),
                      content: const Text(
                        'هل تريد الانتقال إلى صفحة المعاملات المالية لعرض السجل الكامل؟',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إلغاء'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigate to transactions by showing snackbar with instructions
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'اختر "المعاملات المالية" من القائمة الجانبية',
                                ),
                                backgroundColor: Color(0xFF2563EB),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                          ),
                          child: const Text('الانتقال'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'سجل كامل',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (operations.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'لا توجد عمليات حديثة',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...operations.map((op) => _OperationItem(operation: op)),
        ],
      ),
    );
  }
}

class _SalesProgressBar extends StatelessWidget {
  final String label;
  final double amount;
  final double percentage;
  final Color color;

  const _SalesProgressBar({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} د.م',
              style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: (percentage / 100).clamp(0.0, 1.0),
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OperationItem extends StatelessWidget {
  final RecentOperation operation;

  const _OperationItem({required this.operation});

  Color get _color {
    switch (operation.color) {
      case OperationColor.emerald:
        return AppColors.emerald;
      case OperationColor.blue:
        return AppColors.primaryBlue;
      case OperationColor.red:
        return AppColors.red;
    }
  }

  bool get _isPositive => operation.amount.contains('+');

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 36 : 40,
            height: isMobile ? 36 : 40,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isPositive
                  ? LucideIcons.arrowUpRight
                  : LucideIcons.arrowDownRight,
              size: isMobile ? 18 : 20,
              color: _color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operation.client,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${operation.type} • ${operation.time}',
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${operation.amount} د.م',
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              color: _isPositive ? AppColors.emerald : AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading View Widget
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: AppColors.primaryBlue,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل البيانات...',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Error View Widget
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}
