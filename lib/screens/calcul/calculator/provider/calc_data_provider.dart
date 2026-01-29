import 'package:flutter/material.dart';
import '../constants/calc_constants.dart';
import '../models/product_data_model.dart';
import '../service/calc_api_service.dart';

/// ===== Calculator Data Provider =====
/// Manages product data from API with fallback to static constants
class CalcDataProvider extends ChangeNotifier {
  // Loading state
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _errorMessage;

  // API data
  CalcApiData? _apiData;

  // ========== GETTERS ==========

  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  CalcApiData? get apiData => _apiData;

  /// Sponge types - from API or fallback to constants
  Map<String, int> get spongeTypes {
    if (_apiData != null && _apiData!.spongeTypes.isNotEmpty) {
      return _apiData!.spongeTypes;
    }
    return CalcConstants.spongeTypes;
  }

  /// Dress types - from API or fallback to constants
  Map<String, double> get dressTypes {
    if (_apiData != null && _apiData!.dressTypes.isNotEmpty) {
      return _apiData!.dressTypes;
    }
    return CalcConstants.dressTypes;
  }

  /// Footer types - from API or fallback to constants
  Map<String, double> get footerTypes {
    if (_apiData != null && _apiData!.footerTypes.isNotEmpty) {
      return _apiData!.footerTypes;
    }
    return CalcConstants.footerTypes;
  }

  /// Default spring value
  double get defaultSpringValue {
    return _apiData?.getDefault(
          'defaultSpringValue',
          CalcConstants.defaultSpringValue,
        ) ??
        CalcConstants.defaultSpringValue;
  }

  /// Default ribbon 36mm price
  double get defaultRibbon36mm {
    return _apiData?.getDefault(
          'defaultRibbon36mm',
          CalcConstants.defaultRibbon36mm,
        ) ??
        CalcConstants.defaultRibbon36mm;
  }

  /// Default ribbon 18mm price
  double get defaultRibbon18mm {
    return _apiData?.getDefault(
          'defaultRibbon18mm',
          CalcConstants.defaultRibbon18mm,
        ) ??
        CalcConstants.defaultRibbon18mm;
  }

  /// Default ribbon 3D price
  double get defaultRibbon3D {
    return _apiData?.getDefault(
          'defaultRibbon3D',
          CalcConstants.defaultRibbon3D,
        ) ??
        CalcConstants.defaultRibbon3D;
  }

  /// Default chain price
  double get defaultChainPrice {
    return _apiData?.getDefault(
          'defaultChainPrice',
          CalcConstants.defaultChainPrice,
        ) ??
        CalcConstants.defaultChainPrice;
  }

  /// Default elastic price
  double get defaultElasticPrice {
    return _apiData?.getDefault(
          'defaultElasticPrice',
          CalcConstants.defaultElasticPrice,
        ) ??
        CalcConstants.defaultElasticPrice;
  }

  /// Default corners
  double get defaultCorners {
    return _apiData?.getDefault(
          'defaultCorners',
          CalcConstants.defaultCorners,
        ) ??
        CalcConstants.defaultCorners;
  }

  /// Default tickets
  double get defaultTickets {
    return _apiData?.getDefault(
          'defaultTickets',
          CalcConstants.defaultTickets,
        ) ??
        CalcConstants.defaultTickets;
  }

  /// Default plastic
  double get defaultPlastic {
    return _apiData?.getDefault(
          'defaultPlastic',
          CalcConstants.defaultPlastic,
        ) ??
        CalcConstants.defaultPlastic;
  }

  /// Default rent
  double get defaultRent {
    return _apiData?.getDefault('defaultRent', CalcConstants.defaultRent) ??
        CalcConstants.defaultRent;
  }

  /// Default employees
  double get defaultEmployees {
    return _apiData?.getDefault(
          'defaultEmployees',
          CalcConstants.defaultEmployees,
        ) ??
        CalcConstants.defaultEmployees;
  }

  /// Default diesel
  double get defaultDiesel {
    return _apiData?.getDefault('defaultDiesel', CalcConstants.defaultDiesel) ??
        CalcConstants.defaultDiesel;
  }

  /// Default electricity
  double get defaultElectricity {
    return _apiData?.getDefault(
          'defaultElectricity',
          CalcConstants.defaultElectricity,
        ) ??
        CalcConstants.defaultElectricity;
  }

  /// Default production
  int get defaultProduction {
    final value =
        _apiData?.getDefault(
          'defaultProduction',
          CalcConstants.defaultProduction.toDouble(),
        ) ??
        CalcConstants.defaultProduction.toDouble();
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
