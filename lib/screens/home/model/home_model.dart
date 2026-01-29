/// Home Model
/// Data class for home screen statistics
class HomeStats {
  final double monthlySales;
  final int newOrders;
  final double todayCollection;
  final int creditExceededClients;

  const HomeStats({
    required this.monthlySales,
    required this.newOrders,
    required this.todayCollection,
    required this.creditExceededClients,
  });

  factory HomeStats.empty() {
    return const HomeStats(
      monthlySales: 0,
      newOrders: 0,
      todayCollection: 0,
      creditExceededClients: 0,
    );
  }
}

/// Recent Operation Model
/// Represents a recent transaction for the home feed
class RecentOperation {
  final String client;
  final String amount;
  final String time;
  final String type;
  final OperationColor color;

  const RecentOperation({
    required this.client,
    required this.amount,
    required this.time,
    required this.type,
    required this.color,
  });
}

enum OperationColor { emerald, blue, red }

/// Sales Distribution Model
class SalesDistribution {
  final double devisAmount;
  final double ordersAmount;
  final double deliveredAmount;

  const SalesDistribution({
    required this.devisAmount,
    required this.ordersAmount,
    required this.deliveredAmount,
  });

  double get total => devisAmount + ordersAmount + deliveredAmount;

  double get devisPercentage => total > 0 ? (devisAmount / total) * 100 : 0;
  double get ordersPercentage => total > 0 ? (ordersAmount / total) * 100 : 0;
  double get deliveredPercentage =>
      total > 0 ? (deliveredAmount / total) * 100 : 0;
}
