import '../model/home_model.dart';

/// Home Screen Data
/// Static data for dashboard display
class HomeData {
  HomeData._();

  static const HomeStats initialStats = HomeStats(
    monthlySales: 124500,
    newOrders: 12,
    todayCollection: 8200,
    creditExceededClients: 3,
  );

  static const SalesDistribution salesDistribution = SalesDistribution(
    devisAmount: 45000,
    ordersAmount: 62300,
    deliveredAmount: 17200,
  );

  static const List<RecentOperation> recentOperations = [
    RecentOperation(
      client: 'أنس تيك',
      amount: '+ 1,500',
      time: '10 دقائق',
      type: 'Cash',
      color: OperationColor.emerald,
    ),
    RecentOperation(
      client: 'متجر محمد',
      amount: '+ 3,200',
      time: '45 دقيقة',
      type: 'Virement',
      color: OperationColor.blue,
    ),
    RecentOperation(
      client: 'شركة الأمل',
      amount: '- 500',
      time: 'ساعة واحدة',
      type: 'Return',
      color: OperationColor.red,
    ),
    RecentOperation(
      client: 'الراجي فون',
      amount: '+ 12,000',
      time: '3 ساعات',
      type: 'Cheque',
      color: OperationColor.emerald,
    ),
  ];
}
