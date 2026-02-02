import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:saleflow/screens/calcul/cost/provider/costs_provider.dart';
import 'package:saleflow/screens/calcul/calculator/provider/calc_data_provider.dart';
import 'core/app_theme.dart';
import 'core/app_colors.dart';
import 'core/responsive.dart';
import 'shared/widgets/floating_circles.dart';
import 'shared/widgets/sidebar.dart';
import 'shared/widgets/custom_app_bar.dart';
import 'screens/home/home_screen.dart';
import 'screens/clients/clients_screen.dart';
import 'screens/suppliers/suppliers_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/profile_screen.dart';
import 'screens/settings/permissions_screen.dart';
import 'screens/calcul/home_screen.dart' as calcul;
// import 'screens/calcul/calculator/costs_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل التكاليف من API
  final costsProvider = CostsProvider();
  await costsProvider.fetchCosts();

  // تحميل بيانات الحاسبة
  final calcDataProvider = CalcDataProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: costsProvider),
        ChangeNotifierProvider.value(value: calcDataProvider),
      ],
      child: const SaleFlowApp(),
    ),
  );
}

/// SaleFlow Pro - Sales Management System
/// نظام إدارة المبيعات - SaleFlow Pro v2.5
class SaleFlowApp extends StatelessWidget {
  const SaleFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaleFlow Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // RTL Support
      locale: const Locale('ar', 'MA'),
      supportedLocales: const [Locale('ar', 'MA'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const MainShell(),
    );
  }
}

/// Main Shell Widget
/// Contains the sidebar navigation and main content area
/// Now supports responsive layouts with drawer for mobile
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  AppScreen _currentScreen = AppScreen.home;
  // GlobalKey for the Scaffold to control drawer from anywhere
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildScreen() {
    switch (_currentScreen) {
      case AppScreen.home:
        return const HomeScreen();
      case AppScreen.clients:
        return const ClientsScreen();
      case AppScreen.suppliers:
        return const SuppliersScreen();
      case AppScreen.products:
        return const ProductsScreen();
      case AppScreen.orders:
        return const OrdersScreen();
      case AppScreen.transactions:
        return const TransactionsScreen();
      case AppScreen.settings:
        return const SettingsScreen();
      case AppScreen.profile:
        return const ProfileScreen();
      case AppScreen.permissions:
        return const PermissionsScreen();
      case AppScreen.calculator:
        return const calcul.HomeScreen();
    }
  }

  void _navigateTo(AppScreen screen) {
    setState(() => _currentScreen = screen);
    // Close drawer on mobile after navigation
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder for responsive layout decisions
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = Responsive.isMobile(context);

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.background,

            // Drawer for mobile navigation - placed on the right for RTL
            endDrawer: isMobile
                ? Sidebar(
                    currentScreen: _currentScreen,
                    onNavigate: _navigateTo,
                    isDrawer: true, // Flag to indicate drawer mode
                  )
                : null,

            body: SafeArea(
              top: false,
              child: Stack(
                children: [
                  // Floating Background Circles
                  const FloatingCircles(),

                  // Main Layout - Responsive Row/Column
                  if (isMobile)
                    // Mobile: Column layout with hamburger menu
                    Column(
                      children: [
                        // Mobile App Bar with menu button
                        CustomAppBar(
                          onMenuTap: () {
                            _scaffoldKey.currentState?.openEndDrawer();
                          },
                          showMenuButton: true,
                        ),
                        // Content View - Expanded to fill remaining space
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0.05, 0),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                  child: child,
                                ),
                              );
                            },
                            child: KeyedSubtree(
                              key: ValueKey(_currentScreen),
                              child: _buildScreen(),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    // Desktop/Tablet: Row layout with persistent sidebar
                    Row(
                      children: [
                        // Sidebar Navigation
                        Sidebar(
                          currentScreen: _currentScreen,
                          onNavigate: _navigateTo,
                        ),

                        // Main Content Area
                        Expanded(
                          child: Column(
                            children: [
                              // Top App Bar
                              const CustomAppBar(),

                              // Content View
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position:
                                              Tween<Offset>(
                                                begin: const Offset(0.05, 0),
                                                end: Offset.zero,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeOutCubic,
                                                ),
                                              ),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: KeyedSubtree(
                                      key: ValueKey(_currentScreen),
                                      child: _buildScreen(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
