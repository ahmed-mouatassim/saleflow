/// Stock Movement Model
/// Represents inventory movement (IN/OUT)
class StockMovement {
  final int id;
  final int productId;
  final MovementType type;
  final int quantity;
  final String reason;
  final DateTime date;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.reason,
    required this.date,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as int,
      productId: json['productId'] as int,
      type: json['type'] == 'IN' ? MovementType.stockIn : MovementType.stockOut,
      quantity: json['quantity'] as int,
      reason: json['reason'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'type': type == MovementType.stockIn ? 'IN' : 'OUT',
      'quantity': quantity,
      'reason': reason,
      'date': date.toIso8601String(),
    };
  }
}

enum MovementType { stockIn, stockOut }

/// Product Model
/// Data class representing a product/mattress in the inventory
class Product {
  final int id;
  final String refArticle;
  final String designation;
  final String category;
  final String dimensions;
  final double priceHT;
  final double tva;
  final double priceTTC;
  final int stock;
  final int minStock;
  final String brand;
  final List<StockMovement> movements;

  const Product({
    required this.id,
    required this.refArticle,
    required this.designation,
    required this.category,
    required this.dimensions,
    required this.priceHT,
    required this.tva,
    required this.priceTTC,
    required this.stock,
    required this.minStock,
    required this.brand,
    this.movements = const [],
  });

  /// Check if stock is low
  bool get isLowStock => stock <= minStock && stock > 0;

  /// Check if out of stock
  bool get isOutOfStock => stock == 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      refArticle: json['refArticle'] as String,
      designation: json['designation'] as String,
      category: json['category'] as String,
      dimensions: json['dimensions'] as String,
      priceHT: (json['priceHT'] as num).toDouble(),
      tva: (json['tva'] as num).toDouble(),
      priceTTC: (json['priceTTC'] as num).toDouble(),
      stock: json['stock'] as int,
      minStock: json['minStock'] as int,
      brand: json['brand'] as String,
      movements:
          (json['movements'] as List<dynamic>?)
              ?.map((m) => StockMovement.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'refArticle': refArticle,
      'designation': designation,
      'category': category,
      'dimensions': dimensions,
      'priceHT': priceHT,
      'tva': tva,
      'priceTTC': priceTTC,
      'stock': stock,
      'minStock': minStock,
      'brand': brand,
      'movements': movements.map((m) => m.toJson()).toList(),
    };
  }

  Product copyWith({
    int? id,
    String? refArticle,
    String? designation,
    String? category,
    String? dimensions,
    double? priceHT,
    double? tva,
    double? priceTTC,
    int? stock,
    int? minStock,
    String? brand,
    List<StockMovement>? movements,
  }) {
    return Product(
      id: id ?? this.id,
      refArticle: refArticle ?? this.refArticle,
      designation: designation ?? this.designation,
      category: category ?? this.category,
      dimensions: dimensions ?? this.dimensions,
      priceHT: priceHT ?? this.priceHT,
      tva: tva ?? this.tva,
      priceTTC: priceTTC ?? this.priceTTC,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      brand: brand ?? this.brand,
      movements: movements ?? this.movements,
    );
  }
}
