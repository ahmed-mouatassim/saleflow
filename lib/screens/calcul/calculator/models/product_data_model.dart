/// ===== Product Data Model =====
/// Models for API data from the products table
library;

/// Single product from database
class ProductData {
  final int id;
  final String name;
  final String type;
  final double price;
  final DateTime date;
  final String editedBy;

  ProductData({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.date,
    required this.editedBy,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      price: json['price'] is double
          ? json['price']
          : double.parse(json['price'].toString()),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      editedBy: json['edite_by'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'price': price,
    'date': date.toIso8601String().split('T').first,
    'edite_by': editedBy,
  };
}

/// Grouped API data for calculator
class CalcApiData {
  final Map<String, int> spongeTypes;
  final Map<String, double> dressTypes;
  final Map<String, double> footerTypes;
  final Map<String, double> sfifaDefaults;
  final Map<String, double> springTypes; // أنواع الروسول من الـ API
  final Map<String, double> packagingDefaults;
  final Map<String, double> costDefaults;
  final List<ProductData> allProducts;

  CalcApiData({
    required this.spongeTypes,
    required this.dressTypes,
    required this.footerTypes,
    required this.sfifaDefaults,
    required this.springTypes,
    required this.packagingDefaults,
    required this.costDefaults,
    required this.allProducts,
  });

  factory CalcApiData.fromJson(Map<String, dynamic> json) {
    // Parse sponge types (int values)
    final spongeTypesRaw = json['spongeTypes'] as Map<String, dynamic>? ?? {};
    final spongeTypes = <String, int>{};
    spongeTypesRaw.forEach((key, value) {
      spongeTypes[key] = value is int ? value : int.parse(value.toString());
    });

    // Parse dress types (double values)
    final dressTypesRaw = json['dressTypes'] as Map<String, dynamic>? ?? {};
    final dressTypes = <String, double>{};
    dressTypesRaw.forEach((key, value) {
      dressTypes[key] = value is double
          ? value
          : double.parse(value.toString());
    });

    // Parse footer types
    final footerTypesRaw = json['footerTypes'] as Map<String, dynamic>? ?? {};
    final footerTypes = <String, double>{};
    footerTypesRaw.forEach((key, value) {
      footerTypes[key] = value is double
          ? value
          : double.parse(value.toString());
    });

    // Parse sfifa defaults
    final sfifaRaw = json['sfifa'] as Map<String, dynamic>? ?? {};
    final sfifa = <String, double>{};
    sfifaRaw.forEach((key, value) {
      sfifa[key] = value is double ? value : double.parse(value.toString());
    });

    // Parse spring types separately (من API)
    final springRaw = json['spring'] as Map<String, dynamic>? ?? {};
    final spring = <String, double>{};
    springRaw.forEach((key, value) {
      spring[key] = value is double ? value : double.parse(value.toString());
      // Also add to sfifa for backward compatibility
      sfifa[key] = value is double ? value : double.parse(value.toString());
    });

    // Parse packaging defaults - دعم كلا الاسمين
    final packagingKey = json.containsKey('Packaging Defaults')
        ? 'Packaging Defaults'
        : 'packagingDefaults';
    final packagingRaw = json[packagingKey] as Map<String, dynamic>? ?? {};
    final packaging = <String, double>{};
    packagingRaw.forEach((key, value) {
      packaging[key] = value is double ? value : double.parse(value.toString());
    });

    // Parse cost defaults - دعم كلا الاسمين
    final costKey = json.containsKey('Cost Defaults')
        ? 'Cost Defaults'
        : 'costDefaults';
    final costRaw = json[costKey] as Map<String, dynamic>? ?? {};
    final cost = <String, double>{};
    costRaw.forEach((key, value) {
      cost[key] = value is double ? value : double.parse(value.toString());
    });

    // Parse all products list
    final allProductsRaw = json['allProducts'] as List<dynamic>? ?? [];
    final allProducts = allProductsRaw
        .map((p) => ProductData.fromJson(p as Map<String, dynamic>))
        .toList();

    return CalcApiData(
      spongeTypes: spongeTypes,
      dressTypes: dressTypes,
      footerTypes: footerTypes,
      sfifaDefaults: sfifa,
      springTypes: spring,
      packagingDefaults: packaging,
      costDefaults: cost,
      allProducts: allProducts,
    );
  }

  /// Check if data is empty
  bool get isEmpty =>
      spongeTypes.isEmpty && dressTypes.isEmpty && footerTypes.isEmpty;

  /// Get default value by name with fallback
  double getDefault(String name, double fallback) {
    if (sfifaDefaults.containsKey(name)) return sfifaDefaults[name]!;
    if (packagingDefaults.containsKey(name)) return packagingDefaults[name]!;
    if (costDefaults.containsKey(name)) return costDefaults[name]!;
    return fallback;
  }
}

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;

  ApiResponse({required this.success, this.data, this.message = ''});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) dataParser,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? dataParser(json['data']) : null,
      message: json['message'] ?? '',
    );
  }
}
