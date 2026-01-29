import '../model/product_model.dart';
import '../data/products_data.dart';
import '../../../core/loading_state.dart';

/// Products Service
/// API service for product/inventory operations
/// Implements realistic mocking for development until backend is ready
class ProductsService {
  ProductsService._();

  /// Simulated API delay for realistic UX testing
  static const Duration _simulatedDelay = Duration(milliseconds: 600);

  /// Fetch all products from API
  static Future<Result<List<Product>>> fetchProducts() async {
    try {
      await Future.delayed(_simulatedDelay);
      return Result.success(ProductsData.initialProducts);
    } catch (e) {
      return Result.error('فشل في تحميل المنتجات: ${e.toString()}');
    }
  }

  /// Create a new product
  static Future<Result<Product>> createProduct(Product product) async {
    try {
      await Future.delayed(_simulatedDelay);

      final newProduct = product.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
      );

      return Result.success(newProduct);
    } catch (e) {
      return Result.error('فشل في إنشاء المنتج: ${e.toString()}');
    }
  }

  /// Update an existing product
  static Future<Result<Product>> updateProduct(Product product) async {
    try {
      await Future.delayed(_simulatedDelay);
      return Result.success(product);
    } catch (e) {
      return Result.error('فشل في تحديث المنتج: ${e.toString()}');
    }
  }

  /// Delete a product
  static Future<Result<bool>> deleteProduct(int id) async {
    try {
      await Future.delayed(_simulatedDelay);
      return Result.success(true);
    } catch (e) {
      return Result.error('فشل في حذف المنتج: ${e.toString()}');
    }
  }

  /// Record stock movement
  static Future<Result<StockMovement>> recordMovement({
    required int productId,
    required MovementType type,
    required int quantity,
    required String reason,
  }) async {
    try {
      await Future.delayed(_simulatedDelay);

      final movement = StockMovement(
        id: DateTime.now().millisecondsSinceEpoch,
        productId: productId,
        type: type,
        quantity: quantity,
        reason: reason,
        date: DateTime.now(),
      );

      return Result.success(movement);
    } catch (e) {
      return Result.error('فشل في تسجيل الحركة: ${e.toString()}');
    }
  }
}
