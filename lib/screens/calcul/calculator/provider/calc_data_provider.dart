import 'package:flutter/material.dart';

import '../models/product_data_model.dart';
import '../models/tarif_data.dart';
import '../service/calc_api_service.dart';

/// ===== Calculator Data Provider =====
/// Manages product data from API with fallback to static constants
class CalcDataProvider extends ChangeNotifier {
  CalcDataProvider() {
    loadData();
    loadTarifData();
  }
  // Loading state
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _errorMessage;

  // API data
  CalcApiData? _apiData;

  // Tarif data
  List<TarifData> _tarifList = [];
  bool _isTarifLoading = false;
  bool _isTarifLoaded = false;

  // ========== GETTERS ==========

  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  CalcApiData? get apiData => _apiData;

  // Tarif getters
  List<TarifData> get tarifList => List.unmodifiable(_tarifList);
  bool get isTarifLoading => _isTarifLoading;
  bool get isTarifLoaded => _isTarifLoaded;

  /// Get unique product names from tarif list
  List<String> get uniqueProductNames {
    final namesSet = <String>{};
    for (final tarif in _tarifList) {
      if (tarif.name.isNotEmpty) {
        namesSet.add(tarif.name);
      }
    }
    return namesSet.toList()..sort();
  }

  /// Get tarif entries by product name
  List<TarifData> getTarifByName(String name) {
    return _tarifList.where((t) => t.name == name).toList();
  }

  /// Sponge types - from API only
  Map<String, int> get spongeTypes {
    if (_apiData != null && _apiData!.spongeTypes.isNotEmpty) {
      return _apiData!.spongeTypes;
    }
    return {};
  }

  /// Dress types - from API only
  Map<String, double> get dressTypes {
    if (_apiData != null && _apiData!.dressTypes.isNotEmpty) {
      return _apiData!.dressTypes;
    }
    return {};
  }

  /// Footer types - from API only
  Map<String, double> get footerTypes {
    if (_apiData != null && _apiData!.footerTypes.isNotEmpty) {
      return _apiData!.footerTypes;
    }
    return {};
  }

  /// Spring types from API - يستخدم الأسماء الحقيقية من allProducts
  /// يجلب جميع المنتجات من نوع 'spring' بأسمائها الحقيقية
  Map<String, double> get springTypes {
    final springs = <String, double>{};

    if (_apiData != null && _apiData!.allProducts.isNotEmpty) {
      // جلب أنواع الروسول من allProducts باستخدام الاسم الحقيقي (name)
      for (final product in _apiData!.allProducts) {
        if (product.type == 'spring') {
          springs[product.name] = product.price;
        }
      }
    }

    // إذا وجدنا بيانات من allProducts، نُرجعها
    if (springs.isNotEmpty) {
      return springs;
    }

    // Fallback: إذا لم تكن هناك بيانات spring في allProducts
    // نستخدم springTypes القديمة (لكنها تحتوي على keys تقنية)
    if (_apiData != null && _apiData!.springTypes.isNotEmpty) {
      return _apiData!.springTypes;
    }

    return {};
  }

  /// Default spring value
  double get defaultSpringValue {
    return _apiData?.getDefault('defaultSpringValue', 0.0) ?? 0.0;
  }

  /// Default ribbon 36mm price
  double get defaultRibbon36mm {
    return _apiData?.getDefault('defaultRibbon36mm', 0.0) ?? 0.0;
  }

  /// Default ribbon 18mm price
  double get defaultRibbon18mm {
    return _apiData?.getDefault('defaultRibbon18mm', 0.0) ?? 0.0;
  }

  /// Default ribbon 3D price
  double get defaultRibbon3D {
    return _apiData?.getDefault('defaultRibbon3D', 0.0) ?? 0.0;
  }

  /// Default chain price
  double get defaultChainPrice {
    return _apiData?.getDefault('defaultChainPrice', 0.0) ?? 0.0;
  }

  /// Default elastic price
  double get defaultElasticPrice {
    return _apiData?.getDefault('defaultElasticPrice', 0.0) ?? 0.0;
  }

  /// Default corners
  double get defaultCorners {
    return _apiData?.getDefault('defaultCorners', 0.0) ?? 0.0;
  }

  /// Default tickets
  double get defaultTickets {
    return _apiData?.getDefault('defaultTickets', 0.0) ?? 0.0;
  }

  /// Default plastic
  double get defaultPlastic {
    return _apiData?.getDefault('defaultPlastic', 0.0) ?? 0.0;
  }

  /// Default rent
  double get defaultRent {
    return _apiData?.getDefault('defaultRent', 0.0) ?? 0.0;
  }

  /// Default employees
  double get defaultEmployees {
    return _apiData?.getDefault('defaultEmployees', 0.0) ?? 0.0;
  }

  /// Default diesel
  double get defaultDiesel {
    return _apiData?.getDefault('defaultDiesel', 0.0) ?? 0.0;
  }

  /// Default electricity
  double get defaultElectricity {
    return _apiData?.getDefault('defaultElectricity', 0.0) ?? 0.0;
  }

  /// Default production
  int get defaultProduction {
    final value = _apiData?.getDefault('defaultProduction', 0.0) ?? 0.0;
    return value.toInt();
  }

  /// All products list
  List<ProductData> get allProducts => _apiData?.allProducts ?? [];

  // ========== METHODS ==========

  /// Load data from API
  Future<void> loadData() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await CalcApiService.fetchProducts();

      if (response.success && response.data != null) {
        _apiData = response.data;
        _isLoaded = true;
        _errorMessage = null;
        debugPrint('CalcDataProvider: Loaded ${allProducts.length} products');
      } else {
        _errorMessage = response.message;
        debugPrint('CalcDataProvider: API error - ${response.message}');
        // Keep using fallback data (CalcConstants)
      }
    } catch (e) {
      _errorMessage = 'خطأ في تحميل البيانات: $e';
      debugPrint('CalcDataProvider: Exception - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reload data from API
  Future<void> refresh() async {
    _isLoaded = false;
    await loadData();
  }

  /// Load tarif data from API
  Future<void> loadTarifData() async {
    if (_isTarifLoading) return;

    _isTarifLoading = true;
    notifyListeners();

    try {
      final response = await CalcApiService.fetchTarif();

      if (response.success) {
        _tarifList = response.data;
        _isTarifLoaded = true;
        debugPrint(
          'CalcDataProvider: Loaded ${_tarifList.length} tarif entries',
        );
        debugPrint(
          'CalcDataProvider: Unique names: ${uniqueProductNames.length}',
        );
      } else {
        debugPrint('CalcDataProvider: Tarif API error - ${response.message}');
      }
    } catch (e) {
      debugPrint('CalcDataProvider: Tarif Exception - $e');
    } finally {
      _isTarifLoading = false;
      notifyListeners();
    }
  }

  /// Reload tarif data from API
  Future<void> refreshTarif() async {
    _isTarifLoaded = false;
    await loadTarifData();
  }

  /// Update a product's price
  Future<bool> updateProductPrice({
    required int productId,
    required double newPrice,
    String editedBy = 'app',
  }) async {
    try {
      final response = await CalcApiService.updateProduct(
        id: productId,
        price: newPrice,
        editedBy: editedBy,
      );

      if (response.success) {
        // Refresh data to get updated values
        await refresh();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'خطأ في تحديث المنتج: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get sponge coefficient by type name
  int? getSpongeCoefficient(String typeName) {
    return spongeTypes[typeName];
  }

  /// Get dress price by type name
  double? getDressPrice(String typeName) {
    return dressTypes[typeName];
  }

  /// Get footer coefficient by type name
  double? getFooterCoefficient(String typeName) {
    return footerTypes[typeName];
  }
}
