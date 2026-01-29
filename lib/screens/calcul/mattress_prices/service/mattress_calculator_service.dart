import '../../cost/provider/costs_provider.dart';
import '../../calculator/constants/calc_constants.dart';

/// خدمة حساب أسعار المراتب
/// تقوم بحساب السعر الكامل بناءً على الأبعاد ونوع الروسول وعدد الفوتر
class MattressCalculatorService {
  final CostsProvider costsProvider;

  MattressCalculatorService({required this.costsProvider});

  /// حساب سعر الروسول
  /// [height] الطول بالمتر (مثال: 1.90)
  /// [width] العرض بالمتر (مثال: 0.80)
  /// [springType] نوع الروسول: 'none', 'normal', 'sachet'
  double calculateSpringsPrice(double height, double width, String springType) {
    if (springType == 'none') return 0;

    final springSizeCalcOne = (height - 0.10) * 12;
    final springSizeCalcTow = (width - 0.10) * 9;
    final countOfSprings = springSizeCalcOne * springSizeCalcTow;

    final springUnitPrice = springType == 'sachet'
        ? costsProvider.springSachetValue
        : costsProvider.springValue;

    return countOfSprings * springUnitPrice;
  }

  /// حساب سعر الفوتر
  /// [height] الطول بالمتر
  /// [width] العرض بالمتر
  /// [footerCount] عدد طبقات الفوتر
  double calculateFooterPrice(double height, double width, int footerCount) {
    if (footerCount <= 0) return 0;

    final footerSize = height * width;
    const footerCoefficient = 11.88; // من CalcConstants.footerTypes
    return footerSize * footerCoefficient * footerCount;
  }

  /// حساب سعر الثوب
  /// [height] الطول بالمتر
  /// [width] العرض بالمتر
  /// [dressType] نوع الثوب
  double calculateDressPrice(double height, double width, String dressType) {
    final dressUnitPrice = CalcConstants.dressTypes[dressType] ?? 50.0;

    final x1 = width * 3;
    final x2 = (width + height) * 2;
    const x3 = 2 / 0.30;
    final x4 = x2 / x3;
    final x5 = x1 + x4;
    final x6 = x5 + (8 / 100) * x5;

    return x6 * dressUnitPrice + 4;
  }

  /// حساب سعر التغليف
  double calculatePackagingPrice() {
    return (costsProvider.corners * 4) +
        (costsProvider.tickets * 1) +
        (costsProvider.largeFlyer * 1) +
        (costsProvider.smallFlyer * 2) +
        (costsProvider.plastic * 1) +
        (costsProvider.scotch * 1) +
        (costsProvider.adding * 1) +
        costsProvider.glue;
  }

  /// حساب التكاليف
  double calculateCostPrice() {
    return costsProvider.costPerUnit;
  }

  /// الحساب الكامل للمرتبة
  MattressCalculationResult calculateTotal({
    required double height,
    required double width,
    required String springType,
    required int footerCount,
    required String dressType,
    required double basePrice, // السعر الأساسي من الجدول
  }) {
    final springsPrice = calculateSpringsPrice(height, width, springType);
    final footerPrice = calculateFooterPrice(height, width, footerCount);
    final dressPrice = calculateDressPrice(height, width, dressType);
    final packagingPrice = calculatePackagingPrice();
    final costPrice = calculateCostPrice();

    // السعر الإجمالي = السعر الأساسي + الإضافات
    final additionalCosts = springsPrice + footerPrice;
    final totalPrice = basePrice + additionalCosts;

    return MattressCalculationResult(
      basePrice: basePrice,
      springsPrice: springsPrice,
      footerPrice: footerPrice,
      dressPrice: dressPrice,
      packagingPrice: packagingPrice,
      costPrice: costPrice,
      additionalCosts: additionalCosts,
      totalPrice: totalPrice,
    );
  }
}

/// نتيجة حساب المرتبة
class MattressCalculationResult {
  final double basePrice;
  final double springsPrice;
  final double footerPrice;
  final double dressPrice;
  final double packagingPrice;
  final double costPrice;
  final double additionalCosts;
  final double totalPrice;

  MattressCalculationResult({
    required this.basePrice,
    required this.springsPrice,
    required this.footerPrice,
    required this.dressPrice,
    required this.packagingPrice,
    required this.costPrice,
    required this.additionalCosts,
    required this.totalPrice,
  });
}
