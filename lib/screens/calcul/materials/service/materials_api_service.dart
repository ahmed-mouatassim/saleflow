import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/material_item.dart';

/// ===== Materials API Service =====
/// خدمة API لإدارة المواد (CRUD كامل)
class MaterialsApiService {
  MaterialsApiService._();

  /// API Base URL
  static const String baseUrl = 'https://alidor.ma';

  /// Request timeout
  static const Duration timeout = Duration(seconds: 30);

  /// Fetch all materials from API
  static Future<MaterialsApiResponse> fetchMaterials() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api.php?endpoint=prices'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          final materials = _parseMaterials(data);

          return MaterialsApiResponse(
            success: true,
            materials: materials,
            message: 'تم تحميل المواد بنجاح',
          );
        } else {
          return MaterialsApiResponse(
            success: false,
            message: json['error'] as String? ?? 'فشل في جلب البيانات',
          );
        }
      } else {
        return MaterialsApiResponse(
          success: false,
          message: 'فشل في الاتصال بالخادم: ${response.statusCode}',
        );
      }
    } on SocketException {
      return MaterialsApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
      );
    } on TimeoutException {
      return MaterialsApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال. حاول مرة أخرى.',
      );
    } on FormatException {
      return MaterialsApiResponse(
        success: false,
        message: 'خطأ في تنسيق البيانات المستلمة.',
      );
    } catch (e) {
      debugPrint('MaterialsApiService.fetchMaterials error: $e');
      return MaterialsApiResponse(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }

  /// Parse materials from API response
  static Map<String, List<MaterialItem>> _parseMaterials(
    Map<String, dynamic> data,
  ) {
    final result = <String, List<MaterialItem>>{
      'spongeTypes': [],
      'dressTypes': [],
      'footerTypes': [],
    };

    // Parse from allProducts array (more detailed info)
    if (data['allProducts'] != null && data['allProducts'] is List) {
      for (final item in data['allProducts'] as List) {
        final material = MaterialItem.fromJson(item as Map<String, dynamic>);

        // Only include material types (sponge, dress, footer)
        if (result.containsKey(material.type)) {
          result[material.type]!.add(material);
        }
      }
    } else {
      // Fallback: parse from grouped objects
      for (final type in result.keys) {
        if (data[type] != null && data[type] is Map) {
          (data[type] as Map<String, dynamic>).forEach((name, price) {
            result[type]!.add(
              MaterialItem(
                name: name,
                type: type,
                price: (price as num).toDouble(),
              ),
            );
          });
        }
      }
    }

    return result;
  }

  /// Create a new material
  static Future<MaterialsApiResponse> createMaterial({
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

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (json['success'] == true) {
          MaterialItem? createdItem;
          if (json['data'] != null) {
            createdItem = MaterialItem.fromJson(
              json['data'] as Map<String, dynamic>,
            );
          }

          return MaterialsApiResponse(
            success: true,
            message: json['message'] as String? ?? 'تم إنشاء المادة بنجاح',
            createdItem: createdItem,
          );
        }
      }

      return MaterialsApiResponse(
        success: false,
        message: json['error'] as String? ?? 'فشل في إنشاء المادة',
      );
    } on SocketException {
      return MaterialsApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم.',
      );
    } on TimeoutException {
      return MaterialsApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال.',
      );
    } catch (e) {
      debugPrint('MaterialsApiService.createMaterial error: $e');
      return MaterialsApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }

  /// Update an existing material
  static Future<MaterialsApiResponse> updateMaterial({
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
        return MaterialsApiResponse(
          success: false,
          message: 'يجب تحديد معرف المادة أو اسمها ونوعها',
        );
      }

      final response = await http
          .put(
            Uri.parse('$baseUrl/api.php?endpoint=prices'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && json['success'] == true) {
        MaterialItem? updatedItem;
        if (json['data'] != null) {
          updatedItem = MaterialItem.fromJson(
            json['data'] as Map<String, dynamic>,
          );
        }

        return MaterialsApiResponse(
          success: true,
          message: json['message'] as String? ?? 'تم تحديث المادة بنجاح',
          updatedItem: updatedItem,
          previousPrice: (json['previous_price'] as num?)?.toDouble(),
        );
      }

      return MaterialsApiResponse(
        success: false,
        message: json['error'] as String? ?? 'فشل في تحديث المادة',
      );
    } on SocketException {
      return MaterialsApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم.',
      );
    } on TimeoutException {
      return MaterialsApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال.',
      );
    } catch (e) {
      debugPrint('MaterialsApiService.updateMaterial error: $e');
      return MaterialsApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }

  /// Delete a material
  static Future<MaterialsApiResponse> deleteMaterial({
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
        return MaterialsApiResponse(
          success: false,
          message: 'يجب تحديد معرف المادة أو اسمها ونوعها',
        );
      }

      final response = await http
          .delete(Uri.parse('$baseUrl/api.php?endpoint=prices&$queryParams'))
          .timeout(timeout);

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && json['success'] == true) {
        return MaterialsApiResponse(
          success: true,
          message: json['message'] as String? ?? 'تم حذف المادة بنجاح',
          deletedCount: json['deleted_count'] as int?,
        );
      }

      return MaterialsApiResponse(
        success: false,
        message: json['error'] as String? ?? 'فشل في حذف المادة',
      );
    } on SocketException {
      return MaterialsApiResponse(
        success: false,
        message: 'لا يمكن الاتصال بالخادم.',
      );
    } on TimeoutException {
      return MaterialsApiResponse(
        success: false,
        message: 'انتهت مهلة الاتصال.',
      );
    } catch (e) {
      debugPrint('MaterialsApiService.deleteMaterial error: $e');
      return MaterialsApiResponse(success: false, message: 'حدث خطأ: $e');
    }
  }
}

/// Response wrapper for Materials API
class MaterialsApiResponse {
  final bool success;
  final String? message;
  final Map<String, List<MaterialItem>>? materials;
  final MaterialItem? createdItem;
  final MaterialItem? updatedItem;
  final double? previousPrice;
  final int? deletedCount;

  MaterialsApiResponse({
    required this.success,
    this.message,
    this.materials,
    this.createdItem,
    this.updatedItem,
    this.previousPrice,
    this.deletedCount,
  });
}
