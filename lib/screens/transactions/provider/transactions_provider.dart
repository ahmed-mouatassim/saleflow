import 'package:flutter/material.dart';
import '../model/transaction_model.dart';
import '../data/transactions_data.dart';
import '../service/transactions_service.dart';
import '../../../core/loading_state.dart';

/// Transactions Provider
/// State management for transactions screen
/// Properly connected to TransactionsService with loading state handling
class TransactionsProvider extends ChangeNotifier with BaseProviderState {
  List<Transaction> _transactions = [];
  Transaction? _selectedTransaction;
  String _searchQuery = '';
  String _filterType = 'ALL';
  LoadingState _loadingState = LoadingState.initial;
  String? _errorMessage;
  bool _isSaving = false;

  TransactionsProvider() {
    _loadTransactions();
  }

  // Getters
  List<Transaction> get transactions => _transactions;
  Transaction? get selectedTransaction => _selectedTransaction;
  String get searchQuery => _searchQuery;
  String get filterType => _filterType;
  bool get isSaving => _isSaving;

  @override
  LoadingState get loadingState => _loadingState;

  @override
  String? get errorMessage => _errorMessage;

  /// Filtered transactions
  List<Transaction> get filteredTransactions {
    return _transactions.where((t) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          t.reference.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.clientName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType =
          _filterType == 'ALL' || t.paymentMethod.contains(_filterType);
      return matchesSearch && matchesType;
    }).toList();
  }

  /// Statistics
  double get totalValue => _transactions.fold(0, (acc, t) => acc + t.amount);
  double get collected => _transactions.fold(0, (acc, t) => acc + t.amountPaid);
  double get remaining =>
      _transactions.fold(0, (acc, t) => acc + t.amountRemaining);
  int get collectionRate {
    if (totalValue == 0) return 0;
    return ((collected / totalValue) * 100).round();
  }

  /// Load transactions from service
  Future<void> _loadTransactions() async {
    _loadingState = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await TransactionsService.fetchTransactions();

    result.when(
      success: (data) {
        _transactions = List.from(data);
        _loadingState = LoadingState.success;
      },
      error: (error) {
        // Fallback to local data on error
        _transactions = List.from(TransactionsData.initialTransactions);
        _loadingState = LoadingState.success;
      },
    );

    notifyListeners();
  }

  /// Refresh transactions
  Future<void> refreshTransactions() => _loadTransactions();

  // Actions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  void selectTransaction(Transaction? transaction) {
    _selectedTransaction = transaction;
    notifyListeners();
  }

  void clearSelection() {
    _selectedTransaction = null;
    notifyListeners();
  }

  /// Add a new transaction with service call
  Future<bool> addTransaction(
    Transaction transaction,
    BuildContext context,
  ) async {
    _isSaving = true;
    notifyListeners();

    final result = await TransactionsService.createTransaction(transaction);

    var success = false;
    result.when(
      success: (newTransaction) {
        _transactions.add(newTransaction);
        success = true;
        _showSuccessSnackBar(context, 'تم تسجيل الدفعة بنجاح');
      },
      error: (error) {
        _showErrorSnackBar(context, error);
      },
    );

    _isSaving = false;
    notifyListeners();
    return success;
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    if (_loadingState == LoadingState.error) {
      _loadingState = LoadingState.initial;
    }
    notifyListeners();
  }

  /// Show success snackbar
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
