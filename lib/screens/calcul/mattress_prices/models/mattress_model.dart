/// نموذج بيانات المراتب
class MattressModel {
  final String name;
  final List<String> sizes;

  const MattressModel({required this.name, required this.sizes});

  /// الحصول على جميع المقاسات المتاحة
  List<String> get availableSizes => sizes;

  /// التحقق من توفر مقاس معين
  bool hasSize(String size) => sizes.contains(size);
}
