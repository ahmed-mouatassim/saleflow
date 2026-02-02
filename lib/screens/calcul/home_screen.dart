import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'calculator/calc_screen.dart';
import 'calculator/constants/calc_constants.dart';
import 'calculator/provider/calc_data_provider.dart';
import 'calculator/provider/calculator_provider.dart';
import 'cost/costs_screen.dart';
import 'cost/provider/costs_provider.dart';
import 'mattress_prices/mattress_prices_screen.dart';
import 'mattress_prices/constants/mattress_prices_theme.dart';
import 'materials/materials_management_screen.dart';

/// Home Screen - Main Tabbed Navigation
/// Provides tabbed navigation between Calculator, Prices Table, and Costs
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ألوان التبويبات
  static const List<List<Color>> _tabGradients = [
    [CalcTheme.primaryStart, CalcTheme.primaryEnd], // حاسبة الأسعار
    [
      MattressPricesTheme.primaryStart,
      MattressPricesTheme.primaryEnd,
    ], // جدول الأسعار
    [Color(0xFF6366F1), Color(0xFF8B5CF6)], // التكاليف
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      HapticFeedback.selectionClick();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentGradient = _tabGradients[_tabController.index];

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalcDataProvider()),
        ChangeNotifierProxyProvider<CalcDataProvider, CalculatorProvider>(
          create: (context) => CalculatorProvider(
            costsProvider: context.read<CostsProvider>(),
            dataProvider: context.read<CalcDataProvider>(),
          ),
          update: (context, dataProvider, previous) =>
              previous ??
              CalculatorProvider(
                costsProvider: context.read<CostsProvider>(),
                dataProvider: dataProvider,
              ),
        ),
      ],
      builder: (context, child) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header with Tab Bar
                  _buildTabBar(currentGradient),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Tab 1: Calculator
                        const _CalcTabContent(),

                        // Tab 2: Mattress Prices
                        _PricesTabContent(
                          onSwitchToCalculator: () =>
                              _tabController.animateTo(0),
                        ),

                        // Tab 3: Costs
                        const _CostsTabContent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar(List<Color> currentGradient) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: Row(
        children: [
          // زر إدارة المواد
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaterialsManagementScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: Colors.white70,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Tab Bar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: LinearGradient(colors: currentGradient),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: currentGradient[0].withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                labelStyle: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
                tabs: [
                  _buildTab(
                    icon: Icons.calculate_rounded,
                    label: 'الحاسبة',
                    isSelected: _tabController.index == 0,
                  ),
                  _buildTab(
                    icon: Icons.table_chart_rounded,
                    label: 'الأسعار',
                    isSelected: _tabController.index == 1,
                  ),
                  _buildTab(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'التكاليف',
                    isSelected: _tabController.index == 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

/// Calculator Tab Content - Embeds the CalcScreen content
class _CalcTabContent extends StatelessWidget {
  const _CalcTabContent();

  @override
  Widget build(BuildContext context) {
    return const CalcScreen(isEmbedded: true);
  }
}

/// Prices Tab Content - Embeds the MattressPricesScreen content
class _PricesTabContent extends StatelessWidget {
  final VoidCallback? onSwitchToCalculator;

  const _PricesTabContent({this.onSwitchToCalculator});

  @override
  Widget build(BuildContext context) {
    return MattressPricesScreen(
      isEmbedded: true,
      onSwitchToCalculator: onSwitchToCalculator,
    );
  }
}

/// Costs Tab Content - Embeds the CostsScreen content
class _CostsTabContent extends StatelessWidget {
  const _CostsTabContent();

  @override
  Widget build(BuildContext context) {
    return const CostsScreen(isEmbedded: true);
  }
}
