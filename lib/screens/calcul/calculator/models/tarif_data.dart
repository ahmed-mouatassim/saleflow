// ===== Tarif Data Model =====
// Model for tarif data from API endpoint: /api.php?endpoint=tarif
library;

class TarifData {
  final int id;
  final String refMattress;
  final String name;
  final String size;
  final double spongePrice;
  final double springsPrice;
  final double dressPrice;
  final double sfifaPrice;
  final double footerPrice;
  final double packagingPrice;
  final double costPrice;
  final double profitPrice;
  final double finalPrice;

  TarifData({
    required this.id,
    required this.refMattress,
    required this.name,
    required this.size,
    required this.spongePrice,
    required this.springsPrice,
    required this.dressPrice,
    required this.sfifaPrice,
    required this.footerPrice,
    required this.packagingPrice,
    required this.costPrice,
    required this.profitPrice,
    required this.finalPrice,
  });

  factory TarifData.fromJson(Map<String, dynamic> json) {
    return TarifData(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      refMattress: json['ref_mattress'] ?? '',
      name: json['name'] ?? '',
      size: json['size'] ?? '',
      spongePrice: _parseDouble(json['sponge_price']),
      springsPrice: _parseDouble(json['springs_price']),
      dressPrice: _parseDouble(json['dress_price']),
      sfifaPrice: _parseDouble(json['sfifa_price']),
      footerPrice: _parseDouble(json['footer_price']),
      packagingPrice: _parseDouble(json['packaging_price']),
      costPrice: _parseDouble(json['cost_price']),
      profitPrice: _parseDouble(json['profit_price']),
      finalPrice: _parseDouble(json['final_price']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ref_mattress': refMattress,
    'name': name,
    'size': size,
    'sponge_price': spongePrice,
    'springs_price': springsPrice,
    'dress_price': dressPrice,
    'sfifa_price': sfifaPrice,
    'footer_price': footerPrice,
    'packaging_price': packagingPrice,
    'cost_price': costPrice,
    'profit_price': profitPrice,
    'final_price': finalPrice,
  };

  /// Get height and width from size string (format: "height/width")
  /// Returns null if size format is invalid
  (double height, double width)? get dimensions {
    try {
      final parts = size.split('/');
      if (parts.length != 2) return null;
      final height = double.tryParse(parts[0]);
      final width = double.tryParse(parts[1]);
      if (height == null || width == null) return null;
      return (height, width);
    } catch (e) {
      return null;
    }
  }
}

/// Response wrapper for Tarif API
class TarifApiResponse {
  final bool success;
  final int count;
  final List<TarifData> data;
  final String? message;

  TarifApiResponse({
    required this.success,
    required this.count,
    required this.data,
    this.message,
  });

  factory TarifApiResponse.fromJson(Map<String, dynamic> json) {
    final dataList = <TarifData>[];
    if (json['data'] != null && json['data'] is List) {
      for (final item in json['data'] as List) {
        dataList.add(TarifData.fromJson(item as Map<String, dynamic>));
      }
    }

    return TarifApiResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: dataList,
      message: json['message'] as String?,
    );
  }
}
