/// ===== Calculation Result Model =====
/// Holds all the calculated prices for display
class CalculationResult {
  final double footerPrice;
  final double springsPrice;
  final double dressPrice;
  final double sfifaPrice;
  final double packagingPrice;
  final double costPrice;
  final double spongePrice;
  final double profitMargin;
  final double profitAmount;
  final double finalPrice;

  const CalculationResult({
    required this.footerPrice,
    required this.springsPrice,
    required this.dressPrice,
    required this.sfifaPrice,
    required this.packagingPrice,
    required this.costPrice,
    required this.spongePrice,
    required this.profitMargin,
    required this.profitAmount,
    required this.finalPrice,
  });
}
