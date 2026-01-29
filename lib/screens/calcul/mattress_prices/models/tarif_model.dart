/// Model for Tarif data from database
/// Represents a mattress with its size and price details
class TarifModel {
  final int id;
  final String? refMattress;
  final String name;
  final String size;
  final double spongePrice;
  final double springsPrice;
  final double dressPrice;
  final double sfifaPrice;
  final double footerPrice;
  final double packagingPrice;
  final double costPrice;
  final double finalPrice;

  const TarifModel({
    required this.id,
    this.refMattress,
    required this.name,
    required this.size,
    this.spongePrice = 0,
    this.springsPrice = 0,
    this.dressPrice = 0,
    this.sfifaPrice = 0,
    this.footerPrice = 0,
    this.packagingPrice = 0,
    this.costPrice = 0,
    this.finalPrice = 0,
  });

  /// Create TarifModel from JSON response
  factory TarifModel.fromJson(Map<String, dynamic> json) {
    return TarifModel(
      id: json['id'] as int? ?? 0,
      refMattress: json['ref_mattress'] as String?,
      name: json['name'] as String? ?? '',
      size: json['size'] as String? ?? '',
      spongePrice: (json['sponge_price'] as num?)?.toDouble() ?? 0,
      springsPrice: (json['springs_price'] as num?)?.toDouble() ?? 0,
      dressPrice: (json['dress_price'] as num?)?.toDouble() ?? 0,
      sfifaPrice: (json['sfifa_price'] as num?)?.toDouble() ?? 0,
      footerPrice: (json['footer_price'] as num?)?.toDouble() ?? 0,
      packagingPrice: (json['packaging_price'] as num?)?.toDouble() ?? 0,
      costPrice: (json['cost_price'] as num?)?.toDouble() ?? 0,
      finalPrice: (json['final_price'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Get total price (sum of all components)
  double get totalComponents =>
      spongePrice +
      springsPrice +
      dressPrice +
      sfifaPrice +
      footerPrice +
      packagingPrice +
      costPrice;

  /// Convert to JSON
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
    'final_price': finalPrice,
  };

  @override
  String toString() =>
      'TarifModel(name: $name, size: $size, finalPrice: $finalPrice)';
}
