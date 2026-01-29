import 'package:flutter/material.dart';
import '../model/client_model.dart';
import '../service/clients_service.dart';
import '../../orders/data/orders_data.dart';
import '../../orders/model/order_model.dart';
import '../../transactions/model/transaction_model.dart';
import '../../transactions/data/transactions_data.dart';
import '../../../core/loading_state.dart';

/// Clients Provider
/// State management for clients screen
/// Properly connected to ClientsService with loading state handling
class ClientsProvider extends ChangeNotifier with BaseProviderState {
  List<Client> _clients = [];
  List<Transaction> _transactions = [];
  Client? _selectedClient;
  String _searchQuery = '';
  LoadingState _loadingState = LoadingState.initial;
  String? _errorMessage;
  bool _isSaving = false;

  ClientsProvider() {
    _loadClients();
  }

  // Getters
  List<Client> get clients => _clients;
  List<Transaction> get transactions => _transactions;
  Client? get selectedClient => _selectedClient;
  String get searchQuery => _searchQuery;
  bool get isSaving => _isSaving;

  @override
  LoadingState get loadingState => _loadingState;

  @override
  String? get errorMessage => _errorMessage;

  @override
  bool get isLoading => _loadingState == LoadingState.loading;

  @override
  bool get hasError => _loadingState == LoadingState.error;

  /// Filtered clients based on search
  List<Client> get filteredClients {
    if (_searchQuery.isEmpty) return _clients;

    final query = _searchQuery.toLowerCase();
    return _clients
        .where(
          (c) =>
              c.name.toLowerCase().contains(query) ||
              c.phone.contains(query) ||
              c.address.toLowerCase().contains(query),
        )
        .toList();
  }

  /// Transactions for selected client
  List<Transaction> get clientTransactions {
    if (_selectedClient == null) return [];
    return _transactions
        .where((t) => t.clientId == _selectedClient!.id)
        .toList();
  }

  /// Orders for selected client
  List<Order> get clientOrders {
    if (_selectedClient == null) return [];
    return OrdersData.initialOrders
        .where((o) => o.clientId == _selectedClient!.id)
        .toList();
  }

  /// Statistics
  int get totalClients => _clients.length;
  int get activeClients => _clients.where((c) => c.isActive).length;
  double get totalDue => _clients.fold(0, (acc, c) => acc + c.amountRemaining);
  double get avgLimit {
    if (_clients.isEmpty) return 0;
    return _clients.fold(0.0, (acc, c) => acc + c.limitPrice) / _clients.length;
  }

  /// Load clients from service
  Future<void> _loadClients() async {
    _loadingState = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await ClientsService.fetchClients();

    result.when(
      success: (data) {
        _clients = List.from(data);
        _transactions = List.from(TransactionsData.initialTransactions);
        _loadingState = LoadingState.success;
      },
      error: (error) {
        _errorMessage = error;
        _loadingState = LoadingState.error;
      },
    );

    notifyListeners();
  }

  /// Refresh clients
  Future<void> refreshClients() => _loadClients();

  // Actions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectClient(Client? client) {
    _selectedClient = client;
    notifyListeners();
  }

  void clearSelection() {
    _selectedClient = null;
    notifyListeners();
  }

  /// Add a new client with service call
  Future<bool> addClient(Client client, BuildContext context) async {
    _isSaving = true;
    notifyListeners();

    final result = await ClientsService.createClient(client);

    var success = false;
    result.when(
      success: (newClient) {
        _clients.add(newClient);
        success = true;
        _showSuccessSnackBar(context, 'تم إضافة العميل بنجاح');
      },
      error: (error) {
        _showErrorSnackBar(context, error);
      },
    );

    _isSaving = false;
    notifyListeners();
    return success;
  }

  /// Update an existing client with service call
  Future<bool> updateClient(Client updatedClient, BuildContext context) async {
    _isSaving = true;
    notifyListeners();

    final result = await ClientsService.updateClient(updatedClient);

    var success = false;
    result.when(
      success: (client) {
        final index = _clients.indexWhere((c) => c.id == client.id);
        if (index != -1) {
          _clients[index] = client;
          if (_selectedClient?.id == client.id) {
            _selectedClient = client;
          }
        }
        success = true;
        _showSuccessSnackBar(context, 'تم تحديث العميل بنجاح');
      },
      error: (error) {
        _showErrorSnackBar(context, error);
      },
    );

    _isSaving = false;
    notifyListeners();
    return success;
  }

  /// Delete a client with service call
  Future<bool> deleteClient(int clientId, BuildContext context) async {
    _isSaving = true;
    notifyListeners();

    final result = await ClientsService.deleteClient(clientId);

    var success = false;
    result.when(
      success: (_) {
        _clients.removeWhere((c) => c.id == clientId);
        if (_selectedClient?.id == clientId) {
          _selectedClient = null;
        }
        success = true;
        _showSuccessSnackBar(context, 'تم حذف العميل بنجاح');
      },
      error: (error) {
        _showErrorSnackBar(context, error);
      },
    );

    _isSaving = false;
    notifyListeners();
    return success;
  }

  /// Toggle client status
  Future<bool> toggleClientStatus(Client client, BuildContext context) async {
    final updatedClient = client.copyWith(isActive: !client.isActive);
    return updateClient(updatedClient, context);
  }

  /// Export client data
  Future<void> exportClientData(Client client, BuildContext context) async {
    // Mock export functionality
    _isSaving = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      _showSuccessSnackBar(
        context,
        'تم تصدير بيانات العميل ${client.name} بنجاح إلى ملف PDF',
      );
    }

    _isSaving = false;
    notifyListeners();
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
