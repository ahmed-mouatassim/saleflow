/// ===== Sponge Layer Model =====
/// Represents a single sponge layer with all its properties
class SpongeLayer {
  String? selectedType;
  double? coefficient;
  double layerCount;
  double height;
  double width;
  double length;

  SpongeLayer({
    this.selectedType,
    this.coefficient,
    this.layerCount = 0,
    this.height = 0,
    this.width = 0,
    this.length = 0,
  });

  /// Calculate the price of this layer
  double get price {
    if (coefficient == null || layerCount == 0) return 0;
    final sizeOfLayer = height * width * length;
    return (sizeOfLayer * coefficient!) * layerCount;
  }

  /// Check if the layer has valid data
  bool get isValid =>
      selectedType != null &&
      coefficient != null &&
      layerCount > 0 &&
      height > 0 &&
      width > 0 &&
      length > 0;
}
