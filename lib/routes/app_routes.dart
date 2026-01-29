import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/transactions/transactions_screen.dart';

/// App Route Names
class Routes {
  Routes._();

  static const String home = '/';
  static const String clients = '/clients';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String transactions = '/transactions';
}

/// App Route Generator
class AppRoutes {
  AppRoutes._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return _fadeRoute(const HomeScreen());
      case Routes.clients:
        return _slideRoute(const ClientsScreen());
      case Routes.products:
        return _slideRoute(const ProductsScreen());
      case Routes.orders:
        return _slideRoute(const OrdersScreen());
      case Routes.transactions:
        return _slideRoute(const TransactionsScreen());
      default:
        return _fadeRoute(const HomeScreen());
    }
  }

  // Fade transition route
  static PageRouteBuilder<dynamic> _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Slide transition route (RTL aware)
  static PageRouteBuilder<dynamic> _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // For RTL, slide from left; for LTR, slide from right
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final begin = Offset(isRtl ? -1.0 : 1.0, 0.0);
        final tween = Tween(
          begin: begin,
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
