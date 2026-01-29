import '../model/product_model.dart';

/// Initial Products Data
/// Static data matching the React constants.tsx
class ProductsData {
  ProductsData._();

  static final List<Product> initialProducts = [
    const Product(
      id: 1,
      refArticle: 'MAT-PREM-190',
      designation: 'مرتبة بريميوم فندقية الملكية',
      category: 'Premium',
      dimensions: '190x90',
      priceHT: 1250.0,
      tva: 250.0,
      priceTTC: 1500.0,
      stock: 25,
      minStock: 5,
      brand: 'ComfortCloud',
    ),
    const Product(
      id: 2,
      refArticle: 'MAT-ORTH-200',
      designation: 'مرتبة طبية لآلام الظهر والعمود الفقري',
      category: 'Orthopedic',
      dimensions: '200x160',
      priceHT: 2800.0,
      tva: 560.0,
      priceTTC: 3360.0,
      stock: 8,
      minStock: 10,
      brand: 'MediBack',
    ),
    const Product(
      id: 3,
      refArticle: 'MAT-KIDS-120',
      designation: 'مرتبة أطفال ميموري فوم ناعمة',
      category: 'Kids',
      dimensions: '120x60',
      priceHT: 650.0,
      tva: 130.0,
      priceTTC: 780.0,
      stock: 45,
      minStock: 15,
      brand: 'SoftSleep',
    ),
    const Product(
      id: 4,
      refArticle: 'MAT-LUX-200',
      designation: 'مرتبة لوتس الفاخرة بطبقة مزدوجة',
      category: 'Premium',
      dimensions: '200x200',
      priceHT: 4500.0,
      tva: 900.0,
      priceTTC: 5400.0,
      stock: 2,
      minStock: 5,
      brand: 'ComfortCloud',
    ),
  ];
}
