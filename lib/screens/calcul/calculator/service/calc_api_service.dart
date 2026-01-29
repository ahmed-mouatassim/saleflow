import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_data_model.dart';

/// ===== Calculator API Service =====
/// Handles all HTTP requests to the PHP backend
class CalcApiService {
  CalcApiService._();

  /// API Base URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://alidor.ma';
    }
    // For mobile emulators/simulators
    if (Platform.isAndroid) {
      return 'https://alidor.ma';
    }
    return 'https://alidor.ma';
  }

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 10);

  /// Fetch all products from the database
  static Future<ApiResponse<CalcApiData>> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api.php?endpoint=prices'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        return ApiResponse.fromJson(
          json,
          (data) => CalcApiData.fromJson(data as Map<String, dynamic>),
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'فشل في الاتصال بالخادم: ${response.statusCode}',
        );
      }
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
      );
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال. حاول مرة أخرى.',
      );
    } on FormatException {
      return ApiResponse(
        success: false,
        message: 'خطأ في تنسيق البيانات المستلمة.',
      );
    } catch (e) {
      debugPrint('CalcApiService.fetchProducts error: $e');
      return ApiResponse(success: false, message: 'حدث خطأ غير متوقع: $e');
    }
  }

  /// Update a product's price
  static Future<ApiResponse<ProductData>> updateProduct({
    required int id,
    required double price,
    String editedBy = 'app',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/update_product.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id': id, 'price': price, 'edite_by': editedBy}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        return ApiResponse.fromJson(
          json,
          (data) => ProductData.fromJson(data as Map<String, dynamic>),
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'فشل في تحديث المنتج: ${response.statusCode}',
        );
      }
    } on SocketException {
      return ApiResponse(success: false, message: 'لا يمكن الاتصال بالخادم.');
    } on TimeoutException {
      return ApiResponse(success: false, message: 'انتهت مهلة الاتصال.');
    } catch (e) {
      debugPrint('CalcApiService.updateProduct error: $e');
      return ApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }

  /// Fetch products filtered by type
  static Future<ApiResponse<CalcApiData>> fetchProductsByType(
    String type,
  ) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/get_products.php?type=$type'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        return ApiResponse.fromJson(
          json,
          (data) => CalcApiData.fromJson(data as Map<String, dynamic>),
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'فشل في جلب البيانات: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }
}
