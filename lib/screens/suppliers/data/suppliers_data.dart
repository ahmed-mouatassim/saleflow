import '../model/supplier_model.dart';

/// Sample Suppliers Data
/// Mock data for suppliers matching the app's Arabic design
class SuppliersData {
  static List<Supplier> getSampleSuppliers() {
    return [
      Supplier(
        id: 1,
        name: 'شركة الحديد المغربية',
        phone: '0522123456',
        email: 'contact@hadid.ma',
        address: 'المنطقة الصناعية عين السبع',
        city: 'الدار البيضاء',
        category: 'مواد خام معدنية',
        totalPurchases: 125000.0,
        totalPaid: 100000.0,
        amountOwed: 25000.0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Supplier(
        id: 2,
        name: 'مصنع البلاستيك الحديث',
        phone: '0537654321',
        email: 'info@plastic-moderne.ma',
        address: 'حي السلام، شارع الصناعة',
        city: 'الرباط',
        category: 'مواد بلاستيكية',
        totalPurchases: 85000.0,
        totalPaid: 85000.0,
        amountOwed: 0.0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Supplier(
        id: 3,
        name: 'مؤسسة الألمنيوم الذهبي',
        phone: '0528987654',
        email: 'gold.alu@gmail.com',
        address: 'المنطقة الحرة أكادير',
        city: 'أكادير',
        category: 'ألمنيوم',
        totalPurchases: 200000.0,
        totalPaid: 150000.0,
        amountOwed: 50000.0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 450)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Supplier(
        id: 4,
        name: 'شركة الكيماويات المتحدة',
        phone: '0539112233',
        email: 'united.chem@hotmail.com',
        address: 'المنطقة الصناعية سيدي معروف',
        city: 'الدار البيضاء',
        category: 'مواد كيميائية',
        totalPurchases: 45000.0,
        totalPaid: 30000.0,
        amountOwed: 15000.0,
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Supplier(
        id: 5,
        name: 'مؤسسة الأخشاب الأطلسية',
        phone: '0524556677',
        email: 'atlas.wood@yahoo.com',
        address: 'شارع الزرقطوني',
        city: 'مراكش',
        category: 'أخشاب',
        totalPurchases: 95000.0,
        totalPaid: 95000.0,
        amountOwed: 0.0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  /// Get supplier categories
  static List<String> getCategories() {
    return [
      'الكل',
      'مواد خام معدنية',
      'مواد بلاستيكية',
      'ألمنيوم',
      'مواد كيميائية',
      'أخشاب',
      'عام',
    ];
  }
}
