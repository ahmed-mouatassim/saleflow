import 'package:flutter/material.dart';
import '../model/product_model.dart';
import '../data/products_data.dart';

/// Products Provider
/// State management for products/inventory screen
class ProductsProvider extends ChangeNotifier {
  List<Product> _products = [];
  Product? _selectedProduct;
  String _searchQuery = '';
  String _activeCategory = 'ALL';

  // Modal states
  bool _isModalOpen = false;
  bool _isMovementModalOpen = false;
  Product? _editingProduct;

  // Movement data
  MovementType _movementType = MovementType.stockIn;
  int _movementQuantity = 0;
  String _movementReason = '';

  ProductsProvider() {
    _initialize();
  }

  void _initialize() {
    _products = List.from(ProductsData.initialProducts);
  }

  // Getters
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  String get searchQuery => _searchQuery;
  String get activeCategory => _activeCategory;
  bool get isModalOpen => _isModalOpen;
  bool get isMovementModalOpen => _isMovementModalOpen;
  Product? get editingProduct => _editingProduct;
  MovementType get movementType => _movementType;
  int get movementQuantity => _movementQuantity;
  String get movementReason => _movementReason;

  /// Get unique categories
  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    return ['ALL', ...cats];
  }

  /// Filtered products based on search and category
  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          p.designation.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.refArticle.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _activeCategory == 'ALL' || p.category == _activeCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// Statistics
  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.isLowStock).length;
  int get outOfStockCount => _products.where((p) => p.isOutOfStock).length;
  double get totalInventoryValue =>
      _products.fold(0, (acc, p) => acc + (p.priceTTC * p.stock));

  // Actions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setActiveCategory(String category) {
    _activeCategory = category;
    notifyListeners();
  }

  void selectProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void clearSelection() {
    _selectedProduct = null;
    notifyListeners();
  }

  void openModal([Product? product]) {
    _editingProduct = product;
    _isModalOpen = true;
    notifyListeners();
  }

  void closeModal() {
    _isModalOpen = false;
    _editingProduct = null;
    notifyListeners();
  }

  void openMovementModal() {
    _isMovementModalOpen = true;
    _movementType = MovementType.stockIn;
    _movementQuantity = 0;
    _movementReason = '';
    notifyListeners();
  }

  void closeMovementModal() {
    _isMovementModalOpen = false;
    notifyListeners();
  }

  void setMovementType(MovementType type) {
    _movementType = type;
    notifyListeners();
  }

  void setMovementQuantity(int quantity) {
    _movementQuantity = quantity;
    notifyListeners();
  }

  void setMovementReason(String reason) {
    _movementReason = reason;
    notifyListeners();
  }

  void saveProduct(Product product) {
    final existingIndex = _products.indexWhere((p) => p.id == product.id);

    if (existingIndex != -1) {
      _products[existingIndex] = product;
    } else {
      // Generate new ID
      final newId = DateTime.now().millisecondsSinceEpoch;
      final newProduct = product.copyWith(id: newId);
      _products.add(newProduct);
    }

    closeModal();
    notifyListeners();
  }

  void deleteProduct(int productId) {
    _products.removeWhere((p) => p.id == productId);
    if (_selectedProduct?.id == productId) {
      _selectedProduct = null;
    }
    notifyListeners();
  }

  void executeStockMovement() {
    if (_selectedProduct == null || _movementQuantity <= 0) return;

    final change = _movementType == MovementType.stockIn
        ? _movementQuantity
        : -_movementQuantity;
    final newStock = (_selectedProduct!.stock + change).clamp(0, 999999);

    final movement = StockMovement(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: _selectedProduct!.id,
      type: _movementType,
      quantity: _movementQuantity,
      reason: _movementReason,
      date: DateTime.now(),
    );

    final updatedProduct = _selectedProduct!.copyWith(
      stock: newStock,
      movements: [movement, ..._selectedProduct!.movements],
    );

    final index = _products.indexWhere((p) => p.id == _selectedProduct!.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      _selectedProduct = updatedProduct;
    }

    closeMovementModal();
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _activeCategory = 'ALL';
    notifyListeners();
  }
}
