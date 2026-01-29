import 'package:flutter/material.dart';
import '../model/order_model.dart';
import '../data/orders_data.dart';
import '../../clients/model/client_model.dart';
import '../../clients/data/clients_data.dart';
import '../../products/model/product_model.dart';
import '../../products/data/products_data.dart';

/// Orders Provider
/// State management for orders/sales screen
class OrdersProvider extends ChangeNotifier {
  List<Order> _orders = [];
  List<Client> _clients = [];
  List<Product> _products = [];

  Order? _selectedOrder;
  String _searchQuery = '';
  String _activeStage = 'ALL';
  bool _isCreateModalOpen = false;

  // New order form state
  int _newOrderClientId = 0;
  OrderStage _newOrderStage = OrderStage.de;
  List<OrderItemDraft> _newOrderItems = [];

  OrdersProvider() {
    _initialize();
  }

  void _initialize() {
    _orders = List.from(OrdersData.initialOrders);
    _clients = List.from(ClientsData.initialClients);
    _products = List.from(ProductsData.initialProducts);
  }

  // Getters
  List<Order> get orders => _orders;
  List<Client> get clients => _clients;
  List<Product> get products => _products;
  Order? get selectedOrder => _selectedOrder;
  String get searchQuery => _searchQuery;
  String get activeStage => _activeStage;
  bool get isCreateModalOpen => _isCreateModalOpen;
  int get newOrderClientId => _newOrderClientId;
  OrderStage get newOrderStage => _newOrderStage;
  List<OrderItemDraft> get newOrderItems => _newOrderItems;

  /// Filtered orders based on search and stage
  List<Order> get filteredOrders {
    return _orders.where((o) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          o.reference.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.clientName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStage =
          _activeStage == 'ALL' || o.stage.value == _activeStage;
      return matchesSearch && matchesStage;
    }).toList();
  }

  /// Statistics
  int get totalOrders => _orders.length;
  int get deCount => _orders.where((o) => o.stage == OrderStage.de).length;
  int get bcCount => _orders.where((o) => o.stage == OrderStage.bc).length;
  int get blCount => _orders.where((o) => o.stage == OrderStage.bl).length;
  double get totalRevenue => _orders.fold(0, (acc, o) => acc + o.totalAmount);

  /// Calculate new order form total
  double get formTotal {
    return _newOrderItems.fold(0.0, (acc, item) {
      final product = _products.firstWhere(
        (p) => p.id == item.productId,
        orElse: () => const Product(
          id: 0,
          refArticle: '',
          designation: '',
          category: '',
          dimensions: '',
          priceHT: 0,
          tva: 0,
          priceTTC: 0,
          stock: 0,
          minStock: 0,
          brand: '',
        ),
      );
      return acc + (product.priceTTC * item.quantity);
    });
  }

  // Actions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setActiveStage(String stage) {
    _activeStage = stage;
    notifyListeners();
  }

  void selectOrder(Order? order) {
    _selectedOrder = order;
    notifyListeners();
  }

  void clearSelection() {
    _selectedOrder = null;
    notifyListeners();
  }

  void openCreateModal() {
    _isCreateModalOpen = true;
    _newOrderClientId = 0;
    _newOrderStage = OrderStage.de;
    _newOrderItems = [];
    notifyListeners();
  }

  void closeCreateModal() {
    _isCreateModalOpen = false;
    notifyListeners();
  }

  void setNewOrderClientId(int clientId) {
    _newOrderClientId = clientId;
    notifyListeners();
  }

  void setNewOrderStage(OrderStage stage) {
    _newOrderStage = stage;
    notifyListeners();
  }

  void addNewOrderItem() {
    _newOrderItems.add(OrderItemDraft(productId: 0, quantity: 1));
    notifyListeners();
  }

  void updateNewOrderItem(int index, {int? productId, int? quantity}) {
    if (index < _newOrderItems.length) {
      _newOrderItems[index] = _newOrderItems[index].copyWith(
        productId: productId,
        quantity: quantity,
      );
      notifyListeners();
    }
  }

  void removeNewOrderItem(int index) {
    if (index < _newOrderItems.length) {
      _newOrderItems.removeAt(index);
      notifyListeners();
    }
  }

  void saveOrder() {
    if (_newOrderClientId == 0 || _newOrderItems.isEmpty) return;

    final client = _clients.firstWhere((c) => c.id == _newOrderClientId);
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final orderCount =
        _orders.where((o) => o.stage == _newOrderStage).length + 1;
    final reference =
        '${_newOrderStage.value}-$year-${orderCount.toString().padLeft(4, '0')}';

    final orderItems = _newOrderItems.asMap().entries.map((entry) {
      final idx = entry.key;
      final draft = entry.value;
      final product = _products.firstWhere((p) => p.id == draft.productId);
      return OrderItem(
        itemId: now.millisecondsSinceEpoch + idx,
        commandId: now.millisecondsSinceEpoch,
        refArticle: product.refArticle,
        designation: product.designation,
        quantity: draft.quantity,
        unitPrice: product.priceTTC,
        totalPrice: product.priceTTC * draft.quantity,
      );
    }).toList();

    final totalAmount = orderItems.fold(
      0.0,
      (acc, item) => acc + item.totalPrice,
    );

    final newOrder = Order(
      id: now.millisecondsSinceEpoch,
      reference: reference,
      clientId: client.id,
      clientName: client.name,
      itemsCount: orderItems.length,
      totalAmount: totalAmount,
      stage: _newOrderStage,
      createdAt: now,
      updatedAt: now,
      items: orderItems,
    );

    _orders.insert(0, newOrder);
    closeCreateModal();
    notifyListeners();
  }

  void convertOrderStage(int orderId, OrderStage nextStage) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final order = _orders[index];
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final orderCount = _orders.where((o) => o.stage == nextStage).length + 1;
    final reference =
        '${nextStage.value}-$year-${orderCount.toString().padLeft(4, '0')}';

    _orders[index] = order.copyWith(
      stage: nextStage,
      reference: reference,
      updatedAt: now,
    );

    _selectedOrder = null;
    notifyListeners();
  }

  void deleteOrder(int orderId) {
    _orders.removeWhere((o) => o.id == orderId);
    if (_selectedOrder?.id == orderId) {
      _selectedOrder = null;
    }
    notifyListeners();
  }

  Future<void> printOrder(Order order, BuildContext context) async {
    // Mock print functionality
    await Future.delayed(const Duration(seconds: 1));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال المستند ${order.reference} للطباعة'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void resetFilters() {
    _searchQuery = '';
    _activeStage = 'ALL';
    notifyListeners();
  }
}

/// Draft order item for form
class OrderItemDraft {
  final int productId;
  final int quantity;

  OrderItemDraft({required this.productId, required this.quantity});

  OrderItemDraft copyWith({int? productId, int? quantity}) {
    return OrderItemDraft(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
    );
  }
}
