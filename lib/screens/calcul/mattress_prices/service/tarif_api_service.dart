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

  /// Cached tarif data
  static List<TarifModel>? _cachedData;
  static DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// API Base URL
  static String get baseUrl {
    // Production: cPanel server
    const productionUrl = 'https://alidor.ma';

    // ملاحظة: للتطوير المحلي، غير useProduction إلى false
    const useProduction = true;

    if (useProduction) {
      return productionUrl;
    }
  }

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 15);

  /// Clear cache to force refresh
  static void clearCache() {
    _cachedData = null;
    _cacheTime = null;
  }

  /// Fetch all tarif data with price details
  /// Returns cached data if available and not expired
  static Future<TarifApiResponse> fetchTarifDetails({
    bool forceRefresh = false,
  }) async {
    // Return cached data if valid
    if (!forceRefresh && _cachedData != null && _cacheTime != null) {
      final cacheAge = DateTime.now().difference(_cacheTime!);
      if (cacheAge < _cacheDuration) {
        return TarifApiResponse(
          success: true,
          data: _cachedData!,
          message: 'تم التحميل من الذاكرة المؤقتة',
        );
      }
    }

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

          // Update cache
          _cachedData = data;
          _cacheTime = DateTime.now();

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

  /// Get unique mattress names from cached data
  static List<String> getMattressNames() {
    if (_cachedData == null) return [];
    final names = _cachedData!.map((t) => t.name).toSet().toList();
    names.sort();
    return names;
  }

  /// Get unique sizes from cached data
  static List<String> getSizes() {
    if (_cachedData == null) return [];
    final sizes = _cachedData!.map((t) => t.size).toSet().toList();
    // Sort by length then width
    sizes.sort((a, b) {
      final aParts = a.split('/');
      final bParts = b.split('/');
      if (aParts.length != 2 || bParts.length != 2) return a.compareTo(b);
      final aLength = int.tryParse(aParts[0]) ?? 0;
      final bLength = int.tryParse(bParts[0]) ?? 0;
      if (aLength != bLength) return aLength.compareTo(bLength);
      final aWidth = int.tryParse(aParts[1]) ?? 0;
      final bWidth = int.tryParse(bParts[1]) ?? 0;
      return aWidth.compareTo(bWidth);
    });
    return sizes;
  }

  /// Get tarif by name and size
  static TarifModel? getTarif(String name, String size) {
    if (_cachedData == null) return null;
    try {
      return _cachedData!.firstWhere((t) => t.name == name && t.size == size);
    } catch (_) {
      return null;
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
    String? refMattress,
  }) async {
    try {
      // Clear cache to ensure next fetch gets the new data
      clearCache();

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
    String? refMattress,
  }) async {
    try {
      // Clear cache to ensure next fetch gets the updated data
      clearCache();

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
    } catch (e) {
      return TarifApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }

  /// Delete tarif from database
  static Future<TarifApiResponse> deleteTarif(int id) async {
    try {
      // Clear cache to ensure next fetch gets the updated data
      clearCache();

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
