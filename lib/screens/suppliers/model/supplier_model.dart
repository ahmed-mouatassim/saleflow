/// Supplier Model
/// Data class representing a supplier in the system
class Supplier {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String category; // مصنفات المواد
  final double totalPurchases;
  final double totalPaid;
  final double amountOwed;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.category,
    required this.totalPurchases,
    required this.totalPaid,
    required this.amountOwed,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Supplier from JSON
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      category: json['category'] as String? ?? 'عام',
      totalPurchases: (json['totalPurchases'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      amountOwed: (json['amountOwed'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert Supplier to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'category': category,
      'totalPurchases': totalPurchases,
      'totalPaid': totalPaid,
      'amountOwed': amountOwed,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Copy with modified fields
  Supplier copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? category,
    double? totalPurchases,
    double? totalPaid,
    double? amountOwed,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      category: category ?? this.category,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalPaid: totalPaid ?? this.totalPaid,
      amountOwed: amountOwed ?? this.amountOwed,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
