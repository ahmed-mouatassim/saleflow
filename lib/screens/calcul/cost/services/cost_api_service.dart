import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// ===== Costs API Service =====
/// Handles HTTP requests to fetch/update costs (now prices) from the database
class CostsApiService {
  CostsApiService._();

  /// API Base URL - Production server only
  static const String baseUrl = 'https://alidor.ma';

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 30);

  /// Fetch all costs from the database
  /// Returns structured data grouped by category (always fetches from API)
  static Future<CostsApiResponse> fetchCosts() async {
    try {
      // Updated to use prices endpoint
      final response = await http
          .get(Uri.parse('$baseUrl/api.php?endpoint=prices'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          // summary is not returned by prices API, it will be calculated on client side or null
          final apiData = _parseApiData(data);

          return CostsApiResponse(
            success: true,
            data: apiData,
            message: 'تم تحميل التكاليف بنجاح',
          );
        } else {
          return CostsApiResponse(
            success: false,
            message: json['error'] as String? ?? 'فشل في جلب التكاليف',
          );
        }
      } else {
        return CostsApiResponse(
          success: false,
          message: 'فشل في الاتصال بالخادم: ${response.statusCode}',
        );
      }
    } on SocketException {
      return CostsApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
      );
    } on TimeoutException {
      return CostsApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال. حاول مرة أخرى.',
      );
    } on FormatException {
      return CostsApiResponse(
        success: false,
        message: 'خطأ في تنسيق البيانات المستلمة.',
      );
    } catch (e) {
      debugPrint('CostsApiService.fetchCosts error: $e');
      return CostsApiResponse(success: false, message: 'حدث خطأ غير متوقع: $e');
    }
  }

  /// Parse API response data into CostsApiData
  static CostsApiData _parseApiData(Map<String, dynamic> data) {
    // Parse IDs from allProducts
    final Map<String, int> ids = {};
    if (data['allProducts'] != null && data['allProducts'] is List) {
      for (var item in (data['allProducts'] as List)) {
        if (item is Map && item['name'] != null && item['id'] != null) {
          ids[item['name']] = (item['id'] as num).toInt();
        }
      }
    }

    // Parse monthly costs (Handle both camelCase and database keys)
    final Map<String, double> monthly = {};
    final monthlyData = data['costDefaults'] ?? data['Cost Defaults'];
    if (monthlyData != null && monthlyData is Map) {
      (monthlyData as Map<String, dynamic>).forEach((key, value) {
        monthly[key] = (value as num).toDouble();
      });
    }

    // Parse packaging costs
    final Map<String, double> packaging = {};
    final packagingData =
        data['packagingDefaults'] ?? data['Packaging Defaults'];
    if (packagingData != null && packagingData is Map) {
      (packagingData as Map<String, dynamic>).forEach((key, value) {
        packaging[key] = (value as num).toDouble();
      });
    }

    // Parse sfifa and spring costs
    final Map<String, double> sfifa = {};
    if (data['sfifa'] != null && data['sfifa'] is Map) {
      (data['sfifa'] as Map<String, dynamic>).forEach((key, value) {
        sfifa[key] = (value as num).toDouble();
      });
    }

    // Since springs are mixed with sfifa in PHP response
    final Map<String, double> springs = Map.from(sfifa);

    // Also parse explicit 'spring' data if available (overwrites sfifa if duplicate name)
    if (data['spring'] != null && data['spring'] is Map) {
      (data['spring'] as Map<String, dynamic>).forEach((key, value) {
        springs[key] = (value as num).toDouble();
      });
    }

    // Parse flat costs (all costs) - allProducts is a list, convert to map
    final Map<String, double> flat = {};
    if (data['allProducts'] != null && data['allProducts'] is List) {
      for (var item in (data['allProducts'] as List)) {
        if (item is Map && item['name'] != null && item['price'] != null) {
          flat[item['name']] = (item['price'] as num).toDouble();
        }
      }
    }

    // Parse sponge types
    final Map<String, double> spongeTypes = {};
    if (data['spongeTypes'] != null && data['spongeTypes'] is Map) {
      (data['spongeTypes'] as Map<String, dynamic>).forEach((key, value) {
        spongeTypes[key] = (value as num).toDouble();
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

    return CostsApiData(
      monthly: monthly,
      packaging: packaging,
      sfifa: sfifa,
      springs: springs,
      flat: flat,
      ids: ids,
      spongeTypes: spongeTypes,
      dressTypes: dressTypes,
      footerTypes: footerTypes,
    );
  }

  /// Update a single cost
  static Future<CostsApiResponse> updateCost({
    int? id,
    String? name,
    String? category,
    required double value,
    String updatedBy = 'app',
  }) async {
    try {
      // Map category to type expected by prices API
      // We prefer the DB standard names (Space separated)
      String type = 'Cost Defaults';
      if (category != null) {
        if (category.toLowerCase().contains('monthly') ||
            category == 'Cost Defaults' ||
            category == 'costDefaults') {
          type = 'Cost Defaults';
        } else if (category.toLowerCase().contains('packaging') ||
            category == 'Packaging Defaults' ||
            category == 'packagingDefaults') {
          type = 'Packaging Defaults';
        } else if (category.toLowerCase().contains('sfifa')) {
          type = 'sfifa';
        } else if (category.toLowerCase().contains('spring')) {
          type = 'spring';
        } else {
          type = category; // pass through if unknown
        }
      }

      final body = <String, dynamic>{'price': value, 'edite_by': updatedBy};

      if (id != null) {
        body['id'] = id;
      } else if (name != null) {
        body['name'] = name;
        body['type'] = type;
      } else {
        return CostsApiResponse(
          success: false,
          message: 'يجب تحديد معرف التكلفة أو اسمها',
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
          return CostsApiResponse(
            success: true,
            message: json['message'] as String? ?? 'تم تحديث التكلفة بنجاح',
          );
        }
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CostsApiResponse(
        success: false,
        message: json['error'] as String? ?? 'فشل في تحديث التكلفة',
      );
    } on SocketException {
      return CostsApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
      );
    } on TimeoutException {
      return CostsApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال. حاول مرة أخرى.',
      );
    } catch (e) {
      debugPrint('CostsApiService.updateCost error: $e');
      return CostsApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }

  // Removed batchUpdateCosts as it is not supported by prices.php

  /// Create a new cost (price)
  static Future<CostsApiResponse> createCost({
    required String category,
    required String name,
    String? nameAr,
    required double value,
    String? unit,
    String? description,
    String updatedBy = 'app',
  }) async {
    try {
      // Map category to type
      String type = 'costDefaults';
      if (category.toLowerCase().contains('monthly') ||
          category == 'Cost Defaults') {
        type = 'costDefaults';
      } else if (category.toLowerCase().contains('packaging') ||
          category == 'Packaging Defaults') {
        type = 'packagingDefaults';
      } else if (category.toLowerCase().contains('sfifa')) {
        type = 'sfifa';
      } else if (category.toLowerCase().contains('spring')) {
        type = 'spring';
      } else {
        type = category;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/api.php?endpoint=prices'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'type': type,
              'name': name,
              'price': value,
              'edite_by': updatedBy,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          return CostsApiResponse(
            success: true,
            message: json['message'] as String? ?? 'تم إنشاء السعر بنجاح',
          );
        }
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CostsApiResponse(
        success: false,
        message: json['error'] as String? ?? 'فشل في إنشاء السعر',
      );
    } on SocketException {
      return CostsApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
      );
    } on TimeoutException {
      return CostsApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال. حاول مرة أخرى.',
      );
    } catch (e) {
      debugPrint('CostsApiService.createCost error: $e');
      return CostsApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }

  /// Delete a cost (price)
  static Future<CostsApiResponse> deleteCost({
    int? id,
    String? name,
    String? category,
    bool hardDelete = false, // Not used in prices API, always hard delete
  }) async {
    try {
      String queryParams = '';
      if (id != null) {
        queryParams = 'id=$id';
      } else if (name != null && category != null) {
        // Map category to type
        String type = 'costDefaults';
        if (category.toLowerCase().contains('monthly') ||
            category == 'Cost Defaults') {
          type = 'costDefaults';
        } else if (category.toLowerCase().contains('packaging') ||
            category == 'Packaging Defaults') {
          type = 'packagingDefaults';
        } else if (category.toLowerCase().contains('sfifa')) {
          type = 'sfifa';
        } else if (category.toLowerCase().contains('spring')) {
          type = 'spring';
        } else {
          type = category;
        }
        queryParams =
            'name=${Uri.encodeComponent(name)}&type=${Uri.encodeComponent(type)}';
      } else {
        return CostsApiResponse(
          success: false,
          message: 'يجب تحديد معرف أو (اسم ونوع) للحذف',
        );
      }

      final response = await http
          .delete(Uri.parse('$baseUrl/api.php?endpoint=prices&$queryParams'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          return CostsApiResponse(
            success: true,
            message: json['message'] as String? ?? 'تم الحذف بنجاح',
          );
        }
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CostsApiResponse(
        success: false,
        message: json['error'] as String? ?? 'فشل في الحذف',
      );
    } on SocketException {
      return CostsApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
      );
    } on TimeoutException {
      return CostsApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال. حاول مرة أخرى.',
      );
    } catch (e) {
      debugPrint('CostsApiService.deleteCost error: $e');
      return CostsApiResponse(success: false, message: 'حدث خطأ: $e');
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
      debugPrint('CostsApiService connection check failed: $e');
      return false;
    }
  }
}

/// Response wrapper for Costs API
class CostsApiResponse {
  final bool success;
  final String? message;
  final CostsApiData? data;

  CostsApiResponse({required this.success, this.message, this.data});
}

/// Structured API data for costs
class CostsApiData {
  final Map<String, double> monthly;
  final Map<String, double> packaging;
  final Map<String, double> sfifa;
  final Map<String, double> springs;
  final Map<String, double> flat;
  final Map<String, int> ids; // Map name -> ID

  // Material types
  final Map<String, double> spongeTypes;
  final Map<String, double> dressTypes;
  final Map<String, double> footerTypes;

  // Summary data - calculated client side if needed
  final double? totalMonthlyCosts;
  final double? dailyCost;
  final double? costPerUnit;
  final int? production;

  CostsApiData({
    required this.monthly,
    required this.packaging,
    required this.sfifa,
    required this.springs,
    required this.flat,
    required this.ids,
    this.spongeTypes = const {},
    this.dressTypes = const {},
    this.footerTypes = const {},
    this.totalMonthlyCosts,
    this.dailyCost,
    this.costPerUnit,
    this.production,
  });

  /// Get cost value by name, return fallback if not found
  double getValue(String name, double fallback) {
    if (flat.containsKey(name)) return flat[name]!;
    return fallback;
  }

  /// Get ID by name
  int? getId(String name) {
    return ids[name];
  }

  /// Get monthly cost by name
  double getMonthly(String name, double fallback) {
    return monthly[name] ?? fallback;
  }

  /// Get packaging cost by name
  double getPackaging(String name, double fallback) {
    return packaging[name] ?? fallback;
  }

  /// Get sfifa cost by name
  double getSfifa(String name, double fallback) {
    return sfifa[name] ?? fallback;
  }

  /// Get springs cost by name
  double getSprings(String name, double fallback) {
    return springs[name] ?? fallback;
  }
}
