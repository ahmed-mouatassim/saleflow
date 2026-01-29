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

  /// API Base URL - Change this based on your environment
  /// For Android Emulator: use 10.0.2.2 instead of localhost
  /// For iOS Simulator: use localhost
  /// For Physical Device: use your computer's IP address
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/C:/xampp/htdocs/alidor_backend';
    }
    // For mobile emulators/simulators
    if (Platform.isAndroid) {
      return 'http://10.0.2.2/alidor_backend';
    }
    return 'http://localhost/alidor_backend';
  }

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 10);

  /// Fetch all products from the database
  static Future<ApiResponse<CalcApiData>> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/get_products.php'))
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
