import 'package:flutter/material.dart';
import 'dart:async';
import '../model/home_model.dart';
import '../service/home_service.dart';
import '../../../core/loading_state.dart';

/// Home Provider
/// State management for home/dashboard screen
/// Properly connected to HomeService with loading state handling
class HomeProvider extends ChangeNotifier with BaseProviderState {
  HomeStats _stats = HomeStats.empty();
  SalesDistribution _salesDistribution = const SalesDistribution(
    devisAmount: 0,
    ordersAmount: 0,
    deliveredAmount: 0,
  );
  List<RecentOperation> _recentOperations = [];
  LoadingState _loadingState = LoadingState.initial;
  String? _errorMessage;
  Timer? _timeTimer;

  HomeProvider() {
    _initializeTimeUpdater();
    // Load data on construction
    loadDashboardData();
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    super.dispose();
  }

  /// Start a timer to update current time every minute
  void _initializeTimeUpdater() {
    _timeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      notifyListeners();
    });
  }

  // Getters
  HomeStats get stats => _stats;
  SalesDistribution get salesDistribution => _salesDistribution;
  List<RecentOperation> get recentOperations => _recentOperations;

  @override
  LoadingState get loadingState => _loadingState;

  @override
  String? get errorMessage => _errorMessage;

  @override
  bool get isLoading => _loadingState == LoadingState.loading;

  @override
  bool get hasError => _loadingState == LoadingState.error;

  /// Current time formatted
  String get currentTime {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Current date formatted in Arabic
  String get currentDate {
    final now = DateTime.now();
    final arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${now.day} ${arabicMonths[now.month - 1]} ${now.year}';
  }

  /// Total pipeline value
  double get totalPipelineValue => _salesDistribution.total;

  /// Load all dashboard data
  Future<void> loadDashboardData() async {
    _loadingState = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await HomeService.fetchDashboardData();

    result.when(
      success: (data) {
        _stats = data.stats;
        _salesDistribution = data.salesDistribution;
        _recentOperations = data.recentOperations;
        _loadingState = LoadingState.success;
      },
      error: (error) {
        _errorMessage = error;
        _loadingState = LoadingState.error;
      },
    );

    notifyListeners();
  }

  /// Refresh data - alias for loadDashboardData
  Future<void> refreshData() => loadDashboardData();

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    if (_loadingState == LoadingState.error) {
      _loadingState = LoadingState.initial;
    }
    notifyListeners();
  }
}
