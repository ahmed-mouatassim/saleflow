/// ===== Material Item Model =====
/// نموذج بيانات المادة (إسفنج، ثوب، فوتر)
class MaterialItem {
  final int? id;
  final String name;
  final String type;
  final double price;
  final String? date;
  final String? editedBy;

  const MaterialItem({
    this.id,
    required this.name,
    required this.type,
    required this.price,
    this.date,
    this.editedBy,
  });

  /// Factory constructor from API JSON
  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] as String?,
      editedBy: json['edite_by'] as String?,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      'price': price,
      if (editedBy != null) 'edite_by': editedBy,
    };
  }

  /// Create a copy with updated fields
  MaterialItem copyWith({
    int? id,
    String? name,
    String? type,
    double? price,
    String? date,
    String? editedBy,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      date: date ?? this.date,
      editedBy: editedBy ?? this.editedBy,
    );
  }

  /// Get Arabic type label
  String get typeLabel {
    switch (type) {
      case 'spongeTypes':
        return 'إسفنج';
      case 'dressTypes':
        return 'ثوب';
      case 'footerTypes':
        return 'فوتر';
      case 'spring':
        return 'روسول';
      case 'sfifa':
        return 'سفيفة';
      case 'Packaging Defaults':
        return 'تغليف';
      case 'Cost Defaults':
        return 'تكاليف';
      default:
        return type;
    }
  }

  /// Get unit label based on type
  String get unitLabel {
    switch (type) {
      case 'spongeTypes':
        return 'درهم/طن';
      case 'dressTypes':
        return 'درهم/متر';
      case 'footerTypes':
        return 'درهم/وحدة';
      case 'spring':
        return 'درهم/وحدة';
      default:
        return 'درهم';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaterialItem && other.name == name && other.type == type;
  }

  @override
  int get hashCode => name.hashCode ^ type.hashCode;

  @override
  String toString() {
    return 'MaterialItem(id: $id, name: $name, type: $type, price: $price)';
  }
}

/// Material type enum for easier handling
enum MaterialType {
  sponge('spongeTypes', 'الإسفنج', 'درهم/طن'),
  dress('dressTypes', 'الثوب', 'درهم/متر'),
  footer('footerTypes', 'الفوتر', 'درهم/وحدة');

  final String apiType;
  final String arabicName;
  final String unit;

  const MaterialType(this.apiType, this.arabicName, this.unit);

  static MaterialType? fromApiType(String type) {
    for (final mt in MaterialType.values) {
      if (mt.apiType == type) return mt;
    }
    return null;
  }
}
