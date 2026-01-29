/// Order Stage Enum
/// Represents the stage of an order in the sales pipeline
enum OrderStage {
  de('DE'), // Devis - Quote
  bc('BC'), // Bon de Commande - Purchase Order
  bl('BL'); // Bon de Livraison - Delivery Note

  final String value;
  const OrderStage(this.value);

  static OrderStage fromString(String value) {
    return OrderStage.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStage.de,
    );
  }
}

/// Order Item Model
/// Represents a single item in an order
class OrderItem {
  final int itemId;
  final int commandId;
  final String refArticle;
  final String designation;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItem({
    required this.itemId,
    required this.commandId,
    required this.refArticle,
    required this.designation,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['itemId'] as int,
      commandId: json['commandId'] as int,
      refArticle: json['refArticle'] as String,
      designation: json['designation'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'commandId': commandId,
      'refArticle': refArticle,
      'designation': designation,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  OrderItem copyWith({
    int? itemId,
    int? commandId,
    String? refArticle,
    String? designation,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return OrderItem(
      itemId: itemId ?? this.itemId,
      commandId: commandId ?? this.commandId,
      refArticle: refArticle ?? this.refArticle,
      designation: designation ?? this.designation,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

/// Order Model
/// Data class representing a sales order
class Order {
  final int id;
  final String reference;
  final int clientId;
  final String clientName;
  final int itemsCount;
  final double totalAmount;
  final OrderStage stage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.reference,
    required this.clientId,
    required this.clientName,
    required this.itemsCount,
    required this.totalAmount,
    required this.stage,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  /// Calculate HT (before tax)
  double get amountHT => totalAmount / 1.2;

  /// Calculate TVA (20%)
  double get tvaAmount => totalAmount - amountHT;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      reference: json['reference'] as String,
      clientId: json['clientId'] as int,
      clientName: json['clientName'] as String,
      itemsCount: json['itemsCount'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      stage: OrderStage.fromString(json['stage'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'clientId': clientId,
      'clientName': clientName,
      'itemsCount': itemsCount,
      'totalAmount': totalAmount,
      'stage': stage.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  Order copyWith({
    int? id,
    String? reference,
    int? clientId,
    String? clientName,
    int? itemsCount,
    double? totalAmount,
    OrderStage? stage,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      itemsCount: itemsCount ?? this.itemsCount,
      totalAmount: totalAmount ?? this.totalAmount,
      stage: stage ?? this.stage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}
