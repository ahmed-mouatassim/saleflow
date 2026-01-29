import '../model/home_model.dart';
import '../data/home_data.dart';
import '../../../core/loading_state.dart';

/// Home Service
/// API service for dashboard data
/// Implements realistic mocking for development until backend is ready
class HomeService {
  HomeService._();

  /// Simulated API delay for realistic UX testing
  static const Duration _simulatedDelay = Duration(milliseconds: 800);

  /// Fetch dashboard statistics from API
  /// Returns a Result with HomeStats on success or error message on failure
  static Future<Result<HomeStats>> fetchStats() async {
    try {
      // Simulate network delay
      await Future.delayed(_simulatedDelay);

      // Simulate occasional failures for testing error handling (10% chance)
      // Uncomment below for testing error states:
      // if (DateTime.now().millisecond % 10 == 0) {
      //   throw Exception('خطأ في الاتصال بالخادم');
      // }

      // Return mocked data
      return Result.success(HomeData.initialStats);
    } catch (e) {
      return Result.error('فشل في تحميل الإحصائيات: ${e.toString()}');
    }
  }

  /// Fetch recent operations
  /// Returns a Result with list of RecentOperation on success
  static Future<Result<List<RecentOperation>>> fetchRecentOperations() async {
    try {
      await Future.delayed(_simulatedDelay);

      return Result.success(HomeData.recentOperations);
    } catch (e) {
      return Result.error('فشل في تحميل العمليات الأخيرة: ${e.toString()}');
    }
  }

  /// Fetch sales distribution data
  /// Returns a Result with SalesDistribution on success
  static Future<Result<SalesDistribution>> fetchSalesDistribution() async {
    try {
      await Future.delayed(_simulatedDelay);

      return Result.success(HomeData.salesDistribution);
    } catch (e) {
      return Result.error('فشل في تحميل توزيع المبيعات: ${e.toString()}');
    }
  }

  /// Fetch all dashboard data at once
  /// More efficient than multiple calls for initial load
  static Future<Result<DashboardData>> fetchDashboardData() async {
    try {
      await Future.delayed(_simulatedDelay);

      final dashboardData = DashboardData(
        stats: HomeData.initialStats,
        salesDistribution: HomeData.salesDistribution,
        recentOperations: HomeData.recentOperations,
      );

      return Result.success(dashboardData);
    } catch (e) {
      return Result.error('فشل في تحميل بيانات لوحة التحكم: ${e.toString()}');
    }
  }
}

/// Combined dashboard data for efficient loading
class DashboardData {
  final HomeStats stats;
  final SalesDistribution salesDistribution;
  final List<RecentOperation> recentOperations;

  const DashboardData({
    required this.stats,
    required this.salesDistribution,
    required this.recentOperations,
  });
}
