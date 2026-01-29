import 'package:flutter/material.dart';
import '../model/supplier_model.dart';
import '../data/suppliers_data.dart';

/// Suppliers Provider
/// State management for suppliers module
class SuppliersProvider extends ChangeNotifier {
  List<Supplier> _suppliers = [];
  Supplier? _selectedSupplier;
  String _searchQuery = '';
  String _categoryFilter = 'الكل';
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  // Getters
  List<Supplier> get suppliers => _suppliers;
  Supplier? get selectedSupplier => _selectedSupplier;
  String get searchQuery => _searchQuery;
  String get categoryFilter => _categoryFilter;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  /// Get filtered suppliers
  List<Supplier> get filteredSuppliers {
    var result = _suppliers;

    // Apply category filter
    if (_categoryFilter != 'الكل') {
      result = result.where((s) => s.category == _categoryFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where(
            (s) =>
                s.name.toLowerCase().contains(query) ||
                s.phone.contains(query) ||
                s.city.toLowerCase().contains(query),
          )
          .toList();
    }

    return result;
  }

  /// Get active suppliers count
  int get activeCount => _suppliers.where((s) => s.isActive).length;

  /// Get total purchases
  double get totalPurchases =>
      _suppliers.fold(0.0, (sum, s) => sum + s.totalPurchases);

  /// Get total amount owed
  double get totalAmountOwed =>
      _suppliers.fold(0.0, (sum, s) => sum + s.amountOwed);

  /// Get total paid
  double get totalPaid => _suppliers.fold(0.0, (sum, s) => sum + s.totalPaid);

  /// Initialize provider
  SuppliersProvider() {
    _loadSuppliers();
  }

  /// Load suppliers (mock data for now)
  Future<void> _loadSuppliers() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      _suppliers = SuppliersData.getSampleSuppliers();
      _isLoading = false;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'فشل في تحميل بيانات الموردين';
      _isLoading = false;
    }
    notifyListeners();
  }

  /// Refresh suppliers
  Future<void> refreshSuppliers() async {
    await _loadSuppliers();
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set category filter
  void setCategoryFilter(String category) {
    _categoryFilter = category;
    notifyListeners();
  }

  /// Select supplier
  void selectSupplier(Supplier supplier) {
    _selectedSupplier = supplier;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedSupplier = null;
    notifyListeners();
  }

  /// Add supplier
  Future<void> addSupplier(Supplier supplier, BuildContext context) async {
    final newSupplier = supplier.copyWith(
      id: DateTime.now().millisecondsSinceEpoch,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _suppliers.add(newSupplier);
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة المورد "${supplier.name}" بنجاح'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Update supplier
  Future<void> updateSupplier(Supplier supplier, BuildContext context) async {
    final index = _suppliers.indexWhere((s) => s.id == supplier.id);
    if (index != -1) {
      _suppliers[index] = supplier.copyWith(updatedAt: DateTime.now());
      if (_selectedSupplier?.id == supplier.id) {
        _selectedSupplier = _suppliers[index];
      }
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث بيانات المورد "${supplier.name}" بنجاح'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Toggle supplier status
  Future<void> toggleSupplierStatus(
    Supplier supplier,
    BuildContext context,
  ) async {
    final updatedSupplier = supplier.copyWith(
      isActive: !supplier.isActive,
      updatedAt: DateTime.now(),
    );
    await updateSupplier(updatedSupplier, context);
  }

  /// Delete supplier
  Future<void> deleteSupplier(Supplier supplier, BuildContext context) async {
    _suppliers.removeWhere((s) => s.id == supplier.id);
    if (_selectedSupplier?.id == supplier.id) {
      _selectedSupplier = null;
    }
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف المورد "${supplier.name}"'),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
