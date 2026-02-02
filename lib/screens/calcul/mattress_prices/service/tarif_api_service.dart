import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/tarif_model.dart';

/// ===== Tarif API Service =====
/// Handles HTTP requests to fetch tarif data from database
class TarifApiService {
  TarifApiService._();

  /// API Base URL - Production server only
  static const String baseUrl = 'https://alidor.ma';

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 30);

  /// Fetch all tarif data with price details (always fetches from API)
  static Future<TarifApiResponse> fetchTarifDetails() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api.php?endpoint=tarif'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (json['success'] == true && json['data'] != null) {
          final List<dynamic> dataList = json['data'] as List<dynamic>;
          final data = dataList
              .map((item) => TarifModel.fromJson(item as Map<String, dynamic>))
              .toList();

          return TarifApiResponse(
            success: true,
            data: data,
            count: json['count'] as int? ?? data.length,
          );
        } else {
          return TarifApiResponse(
            success: false,
            message: json['message'] as String? ?? 'فشل في جلب البيانات',
          );
        }
      } else {
        return TarifApiResponse(
          success: false,
          message: 'فشل في الاتصال بالخادم: ${response.statusCode}',
        );
      }
    } on SocketException {
      return TarifApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
      );
    } on TimeoutException {
      return TarifApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال. حاول مرة أخرى.',
      );
    } on FormatException {
      return TarifApiResponse(
        success: false,
        message: 'خطأ في تنسيق البيانات المستلمة.',
      );
    } catch (e) {
      debugPrint('TarifApiService.fetchTarifDetails error: $e');
      return TarifApiResponse(success: false, message: 'حدث خطأ غير متوقع: $e');
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
      debugPrint('Connection check failed: $e');
      return false;
    }
  }

  /// Save new tarif to database
  static Future<TarifApiResponse> saveTarif({
    required String name,
    required String size,
    required double spongePrice,
    required double springsPrice,
    required double dressPrice,
    required double sfifaPrice,
    required double packagingPrice,
    required double footerPrice,
    required double costPrice,
    required double profitPrice,
    required double finalPrice,
    int laMarge = 0,
    String? refMattress,
  }) async {
    try {
      // Generate a reference if not provided
      final ref = refMattress ?? 'REF-${DateTime.now().millisecondsSinceEpoch}';

      final response = await http
          .post(
            Uri.parse('$baseUrl/api.php?endpoint=tarif'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'ref_mattress': ref,
              'name': name,
              'size': size,
              'sponge_price': spongePrice,
              'springs_price': springsPrice,
              'dress_price': dressPrice,
              'sfifa_price': sfifaPrice,
              'packaging_price': packagingPrice,
              'footer_price': footerPrice,
              'cost_price': costPrice,
              'profit_price': profitPrice,
              'la_marge': laMarge,
              'final_price': finalPrice,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return TarifApiResponse(
          success: json['success'] == true,
          message: json['message'],
        );
      } else {
        return TarifApiResponse(
          success: false,
          message: 'فشل في الاتصال بالخادم: ${response.statusCode}',
        );
      }
    } on SocketException {
      return TarifApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
      );
    } on TimeoutException {
      return TarifApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال. حاول مرة أخرى.',
      );
    } catch (e) {
      debugPrint('TarifApiService.saveTarif error: $e');
      return TarifApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }

  /// Update existing tarif in database
  static Future<TarifApiResponse> updateTarif({
    required int id,
    required String name,
    required String size,
    required double spongePrice,
    required double springsPrice,
    required double dressPrice,
    required double sfifaPrice,
    required double packagingPrice,
    required double footerPrice,
    required double costPrice,
    required double profitPrice,
    required double finalPrice,
    int laMarge = 0,
    String? refMattress,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/api.php?endpoint=tarif'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': id,
              'ref_mattress': refMattress ?? 'REF-$id',
              'name': name,
              'size': size,
              'sponge_price': spongePrice,
              'springs_price': springsPrice,
              'dress_price': dressPrice,
              'sfifa_price': sfifaPrice,
              'packaging_price': packagingPrice,
              'footer_price': footerPrice,
              'cost_price': costPrice,
              'profit_price': profitPrice,
              'la_marge': laMarge,
              'final_price': finalPrice,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return TarifApiResponse(
          success: json['success'] == true,
          message: json['message'] ?? 'تم التحديث بنجاح',
        );
      } else {
        return TarifApiResponse(
          success: false,
          message: 'فشل في الاتصال بالخادم: ${response.statusCode}',
        );
      }
    } on SocketException {
      return TarifApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
      );
    } on TimeoutException {
      return TarifApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال. حاول مرة أخرى.',
      );
    } catch (e) {
      return TarifApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }

  /// Delete tarif from database
  static Future<TarifApiResponse> deleteTarif(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/api.php?endpoint=tarif&id=$id'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return TarifApiResponse(
          success: json['success'] == true,
          message: json['message'] ?? 'تم الحذف بنجاح',
        );
      } else {
        return TarifApiResponse(
          success: false,
          message: 'فشل في الاتصال بالخادم: ${response.statusCode}',
        );
      }
    } on SocketException {
      return TarifApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
      );
    } on TimeoutException {
      return TarifApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال. حاول مرة أخرى.',
      );
    } catch (e) {
      debugPrint('TarifApiService.deleteTarif error: $e');
      return TarifApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }
}

/// Response wrapper for Tarif API
class TarifApiResponse {
  final bool success;
  final String? message;
  final List<TarifModel>? data;
  final int? count;

  TarifApiResponse({
    required this.success,
    this.message,
    this.data,
    this.count,
  });
}
