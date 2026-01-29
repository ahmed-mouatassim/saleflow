/// Client Model
/// Data class representing a client in the system
class Client {
  final int id;
  final String name;
  final double limitPrice;
  final double amountRemaining;
  final double amountPaid;
  final double totalAmount;
  final String phone;
  final String address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Client({
    required this.id,
    required this.name,
    required this.limitPrice,
    required this.amountRemaining,
    required this.amountPaid,
    required this.totalAmount,
    required this.phone,
    required this.address,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Client from JSON
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as int,
      name: json['name'] as String,
      limitPrice: (json['limitPrice'] as num).toDouble(),
      amountRemaining: (json['amountRemaining'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      phone: json['phone'] as String,
      address: json['address'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert Client to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'limitPrice': limitPrice,
      'amountRemaining': amountRemaining,
      'amountPaid': amountPaid,
      'totalAmount': totalAmount,
      'phone': phone,
      'address': address,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Copy with modified fields
  Client copyWith({
    int? id,
    String? name,
    double? limitPrice,
    double? amountRemaining,
    double? amountPaid,
    double? totalAmount,
    String? phone,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      limitPrice: limitPrice ?? this.limitPrice,
      amountRemaining: amountRemaining ?? this.amountRemaining,
      amountPaid: amountPaid ?? this.amountPaid,
      totalAmount: totalAmount ?? this.totalAmount,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
