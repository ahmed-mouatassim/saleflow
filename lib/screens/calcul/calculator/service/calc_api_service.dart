import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_data_model.dart';

/// ===== Calculator API Service =====
/// Handles HTTP requests to fetch/update prices from the database
class CalcApiService {
  CalcApiService._();

  /// API Base URL
  static String get baseUrl {
    // Production: cPanel server
    // Always use production URL since local server is not configured
    return 'https://alidor.ma';
  }

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 15);

  /// Cached API data
  static CalcApiData? _cachedData;
  static DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Clear cache to force refresh
  static void clearCache() {
    _cachedData = null;
    _cacheTime = null;
  }

  /// Fetch all product prices from the database
  /// Returns structured data grouped by type
  static Future<CalcApiResponse> fetchProducts({
    bool forceRefresh = false,
  }) async {
    // Return cached data if valid
    if (!forceRefresh && _cachedData != null && _cacheTime != null) {
      final cacheAge = DateTime.now().difference(_cacheTime!);
      if (cacheAge < _cacheDuration) {
        return CalcApiResponse(
          success: true,
          data: _cachedData,
          message: 'تم التحميل من الذاكرة المؤقتة',
        );
      }
    }

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api.php?endpoint=prices'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          final apiData = _parseApiData(data);

          // Update cache
          _cachedData = apiData;
          _cacheTime = DateTime.now();

          return CalcApiResponse(
            success: true,
            data: apiData,
            message: 'تم تحميل البيانات بنجاح',
          );
        } else {
          return CalcApiResponse(
            success: false,
            message: json['error'] as String? ?? 'فشل في جلب البيانات',
          );
        }
      } else {
        return CalcApiResponse(
          success: false,
          message: 'فشل في الاتصال بالخادم: ${response.statusCode}',
        );
      }
    } on SocketException {
      return CalcApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
      );
    } on TimeoutException {
      return CalcApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال. حاول مرة أخرى.',
      );
    } on FormatException {
      return CalcApiResponse(
        success: false,
        message: 'خطأ في تنسيق البيانات المستلمة.',
      );
    } catch (e) {
      debugPrint('CalcApiService.fetchProducts error: $e');
      return CalcApiResponse(success: false, message: 'حدث خطأ غير متوقع: $e');
    }
  }

  /// Parse API response data into CalcApiData
  /// يتعامل مع أسماء الأنواع كما ترد من قاعدة البيانات
  static CalcApiData _parseApiData(Map<String, dynamic> data) {
    // Parse sponge types
    final Map<String, int> spongeTypes = {};
    if (data['spongeTypes'] != null && data['spongeTypes'] is Map) {
      (data['spongeTypes'] as Map<String, dynamic>).forEach((key, value) {
        spongeTypes[key] = (value as num).toInt();
      });
    }

    // Parse dress types
    final Map<String, double> dressTypes = {};
    if (data['dressTypes'] != null && data['dressTypes'] is Map) {
      (data['dressTypes'] as Map<String, dynamic>).forEach((key, value) {
        dressTypes[key] = (value as num).toDouble();
      });
    }

    // Parse footer types
    final Map<String, double> footerTypes = {};
    if (data['footerTypes'] != null && data['footerTypes'] is Map) {
      (data['footerTypes'] as Map<String, dynamic>).forEach((key, value) {
        footerTypes[key] = (value as num).toDouble();
      });
    }

    // Parse sfifa defaults
    final Map<String, double> sfifa = {};
    if (data['sfifa'] != null && data['sfifa'] is Map) {
      (data['sfifa'] as Map<String, dynamic>).forEach((key, value) {
        sfifa[key] = (value as num).toDouble();
      });
    }

    // إضافة spring إلى sfifa (من API الجديد)
    if (data['spring'] != null && data['spring'] is Map) {
      (data['spring'] as Map<String, dynamic>).forEach((key, value) {
        sfifa[key] = (value as num).toDouble();
      });
    }

    // Parse packaging defaults - دعم كلا الاسمين
    final Map<String, double> packagingDefaults = {};
    // أولاً نحاول الاسم الجديد من API
    final packagingKey = data.containsKey('Packaging Defaults')
        ? 'Packaging Defaults'
        : 'packagingDefaults';
    if (data[packagingKey] != null && data[packagingKey] is Map) {
      (data[packagingKey] as Map<String, dynamic>).forEach((key, value) {
        packagingDefaults[key] = (value as num).toDouble();
      });
    }

    // Parse cost defaults - دعم كلا الاسمين
    final Map<String, double> costDefaults = {};
    // أولاً نحاول الاسم الجديد من API
    final costKey = data.containsKey('Cost Defaults')
        ? 'Cost Defaults'
        : 'costDefaults';
    if (data[costKey] != null && data[costKey] is Map) {
      (data[costKey] as Map<String, dynamic>).forEach((key, value) {
        costDefaults[key] = (value as num).toDouble();
      });
    }

    // Parse all products
    final List<ProductData> allProducts = [];
    if (data['allProducts'] != null) {
      for (final item in data['allProducts'] as List<dynamic>) {
        final product = ProductData.fromJson(item as Map<String, dynamic>);
        allProducts.add(product);
      }
    }

    return CalcApiData(
      spongeTypes: spongeTypes,
      dressTypes: dressTypes,
      footerTypes: footerTypes,
      sfifaDefaults: sfifa,
      packagingDefaults: packagingDefaults,
      costDefaults: costDefaults,
      allProducts: allProducts,
    );
  }

  /// Create a new product/price entry
  static Future<CalcApiResponse> createProduct({
    required String name,
    required String type,
    required double price,
    String editedBy = 'app',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api.php?endpoint=prices'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'type': type,
              'price': price,
              'edite_by': editedBy,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          clearCache(); // Clear cache so next fetch gets updated data
          return CalcApiResponse(
            success: true,
            message: json['message'] as String? ?? 'تم إنشاء السعر بنجاح',
          );
        }
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CalcApiResponse(
        success: false,
        message: json['error'] as String? ?? 'فشل في إنشاء السعر',
      );
    } catch (e) {
      debugPrint('CalcApiService.createProduct error: $e');
      return CalcApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }

  /// Update an existing product/price
  static Future<CalcApiResponse> updateProduct({
    int? id,
    String? name,
    String? type,
    required double price,
    String editedBy = 'app',
  }) async {
    try {
      final body = <String, dynamic>{'price': price, 'edite_by': editedBy};

      if (id != null) {
        body['id'] = id;
      } else if (name != null && type != null) {
        body['name'] = name;
        body['type'] = type;
      } else {
        return CalcApiResponse(
          success: false,
          message: 'يجب تحديد معرف المنتج أو اسمه ونوعه',
        );
      }

      final response = await http
          .put(
            Uri.parse('$baseUrl/api.php?endpoint=prices'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          clearCache();
          return CalcApiResponse(
            success: true,
            message: json['message'] as String? ?? 'تم تحديث السعر بنجاح',
          );
        }
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CalcApiResponse(
        success: false,
        message: json['error'] as String? ?? 'فشل في تحديث السعر',
      );
    } catch (e) {
      debugPrint('CalcApiService.updateProduct error: $e');
      return CalcApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }

  /// Delete a product/price
  static Future<CalcApiResponse> deleteProduct({
    int? id,
    String? name,
    String? type,
  }) async {
    try {
      String queryParams = '';
      if (id != null) {
        queryParams = 'id=$id';
      } else if (name != null && type != null) {
        queryParams =
            'name=${Uri.encodeComponent(name)}&type=${Uri.encodeComponent(type)}';
      } else {
        return CalcApiResponse(
          success: false,
          message: 'يجب تحديد معرف المنتج أو اسمه ونوعه',
        );
      }

      final response = await http
          .delete(Uri.parse('$baseUrl/api.php?endpoint=prices&$queryParams'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          clearCache();
          return CalcApiResponse(
            success: true,
            message: json['message'] as String? ?? 'تم حذف السعر بنجاح',
          );
        }
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CalcApiResponse(
        success: false,
        message: json['error'] as String? ?? 'فشل في حذف السعر',
      );
    } catch (e) {
      debugPrint('CalcApiService.deleteProduct error: $e');
      return CalcApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }

  /// Check database connection
  static Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api.php'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('CalcApiService connection check failed: $e');
      return false;
    }
  }
}

/// Response wrapper for Calculator API
class CalcApiResponse {
  final bool success;
  final String? message;
  final CalcApiData? data;

  CalcApiResponse({required this.success, this.message, this.data});
}

// Note: CalcApiData is imported from product_data_model.dart
// to avoid duplicate class definitions
