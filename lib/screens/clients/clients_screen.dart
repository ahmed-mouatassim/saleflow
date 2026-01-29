import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../../shared/widgets/stats_card.dart';
import '../../shared/widgets/glass_container.dart';
import 'provider/clients_provider.dart';
import 'widgets/client_card_widget.dart';
import 'widgets/client_detail_widget.dart';
import 'widgets/add_client_modal.dart';

/// Clients Screen
/// Client management view matching the React ClientsScreen
/// Now fully responsive with loading states and error handling
class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClientsProvider(),
      child: const _ClientsScreenContent(),
    );
  }
}

class _ClientsScreenContent extends StatelessWidget {
  const _ClientsScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientsProvider>();
    final isMobile = Responsive.isMobile(context);

    // Show loading state
    if (provider.isLoading) {
      return _buildLoadingView();
    }

    // Show error state with retry option
    if (provider.hasError) {
      return _buildErrorView(
        message: provider.errorMessage ?? 'حدث خطأ غير متوقع',
        onRetry: () => provider.refreshClients(),
      );
    }

    // If client is selected, show detail view
    if (provider.selectedClient != null) {
      return ClientDetailWidget(
        client: provider.selectedClient!,
        transactions: provider.clientTransactions,
        orders: provider.clientOrders,
        onBack: () => provider.clearSelection(),
      );
    }

    // Main clients list view - Wrapped in RefreshIndicator
    return RefreshIndicator(
      onRefresh: provider.refreshClients,
      color: AppColors.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: Responsive.padding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header - Responsive
            _buildHeader(context, provider, isMobile),

            SizedBox(height: isMobile ? 24 : 32),

            // Stats Grid - Responsive
            _buildStatsGrid(context, provider, isMobile),

            SizedBox(height: isMobile ? 24 : 32),

            // Search Bar
            _buildSearchBar(context, provider, isMobile),

            SizedBox(height: isMobile ? 24 : 32),

            // Clients Grid - Responsive
            _buildClientsGrid(context, provider, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ClientsProvider provider,
    bool isMobile,
  ) {
    if (isMobile) {
      // Mobile: Stacked layout
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.users, size: 28, color: AppColors.primaryBlue),
              const SizedBox(width: 12),
              Text(
                'إدارة العملاء',
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
            'تحليل السلوك الشرائي والملاءة المالية للعملاء',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          // Add button - Full width on mobile
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final client = await AddClientModal.show(context);
                if (client != null && context.mounted) {
                  await Provider.of<ClientsProvider>(
                    context,
                    listen: false,
                  ).addClient(client, context);
                }
              },
              icon: const Icon(LucideIcons.plus, size: 20),
              label: const Text('إضافة عميل جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
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

    // Desktop/Tablet: Row layout
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
                    LucideIcons.users,
                    size: 32,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'إدارة العملاء',
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
                'تحليل السلوك الشرائي والملاءة المالية للعملاء',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final client = await AddClientModal.show(context);
            if (client != null && context.mounted) {
              await Provider.of<ClientsProvider>(
                context,
                listen: false,
              ).addClient(client, context);
            }
          },
          icon: const Icon(LucideIcons.plus, size: 20),
          label: const Text('إضافة عميل جديد'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
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
    ClientsProvider provider,
    bool isMobile,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // Calculate card width based on available space
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
            label: 'إجمالي العملاء',
            value: '${provider.totalClients}',
            icon: LucideIcons.users,
            color: StatsCardColor.blue,
          ),
          StatsCard(
            label: 'عملاء نشطون',
            value: '${provider.activeClients}',
            icon: LucideIcons.users,
            color: StatsCardColor.green,
          ),
          StatsCard(
            label: 'ديون معلقة',
            value: '${_formatNumber(provider.totalDue)} د.م',
            icon: LucideIcons.dollarSign,
            color: StatsCardColor.red,
          ),
          StatsCard(
            label: 'متوسط الائتمان',
            value: '${_formatNumber(provider.avgLimit)} د.م',
            icon: LucideIcons.dollarSign,
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

  Widget _buildSearchBar(
    BuildContext context,
    ClientsProvider provider,
    bool isMobile,
  ) {
    return GlassContainer(
      borderRadius: isMobile ? 20 : 32,
      isDark: true,
      child: TextField(
        onChanged: provider.setSearchQuery,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: isMobile
              ? 'ابحث عن عميل...'
              : 'ابحث بالاسم، الهاتف، أو المدينة...',
          hintStyle: TextStyle(color: AppColors.textMuted),
          prefixIcon: Padding(
            padding: EdgeInsets.only(right: isMobile ? 16 : 24, left: 8),
            child: Icon(
              LucideIcons.search,
              size: 20,
              color: AppColors.textMuted,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 16 : 20,
          ),
        ),
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: isMobile ? 14 : 16,
        ),
      ),
    );
  }

  Widget _buildClientsGrid(
    BuildContext context,
    ClientsProvider provider,
    bool isMobile,
  ) {
    final clients = provider.filteredClients;

    if (clients.isEmpty) {
      return _buildEmptyState(provider.searchQuery.isNotEmpty);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // Calculate card width for clients
        late double cardWidth;

        if (availableWidth < 450) {
          cardWidth = availableWidth;
        } else if (availableWidth < 800) {
          cardWidth = (availableWidth - 24) / 2;
        } else {
          cardWidth = (availableWidth - 48) / 3;
        }

        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: clients.asMap().entries.map((entry) {
            final index = entry.key;
            final client = entry.value;
            return SizedBox(
              width: cardWidth.clamp(320, 420),
              child: ClientCardWidget(
                client: client,
                animationDelay: Duration(milliseconds: index * 100),
                onTap: () => provider.selectClient(client),
              ),
            );
          }).toList(),
        );
      },
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
              isSearchResult ? LucideIcons.search : LucideIcons.users,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              isSearchResult
                  ? 'لم يتم العثور على عملاء مطابقين'
                  : 'لا يوجد عملاء بعد',
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
                  : 'ابدأ بإضافة أول عميل لك',
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
              color: AppColors.primaryBlue,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل العملاء...',
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

  String _formatNumber(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
