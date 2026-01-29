import '../model/order_model.dart';

/// Initial Orders Data
/// Static data matching the React constants.tsx
class OrdersData {
  OrdersData._();

  static final List<Order> initialOrders = [
    Order(
      id: 1,
      reference: 'DE-24-001',
      clientId: 1,
      clientName: 'أنس تيك',
      itemsCount: 2,
      totalAmount: 2000.0,
      stage: OrderStage.de,
      createdAt: DateTime.parse('2025-11-08 10:00:00'),
      updatedAt: DateTime.parse('2025-11-08 10:00:00'),
      items: const [
        OrderItem(
          itemId: 1,
          commandId: 1,
          refArticle: 'MAT190',
          designation: 'شاشة سامسونج 24',
          quantity: 1,
          unitPrice: 1500.0,
          totalPrice: 1500.0,
        ),
        OrderItem(
          itemId: 2,
          commandId: 1,
          refArticle: 'ACC05',
          designation: 'لوحة مفاتيح لاسلكية',
          quantity: 1,
          unitPrice: 500.0,
          totalPrice: 500.0,
        ),
      ],
    ),
    Order(
      id: 2,
      reference: 'BC-24-042',
      clientId: 2,
      clientName: 'متجر محمد',
      itemsCount: 1,
      totalAmount: 3500.0,
      stage: OrderStage.bc,
      createdAt: DateTime.parse('2025-11-07 09:00:00'),
      updatedAt: DateTime.parse('2025-11-07 09:00:00'),
      items: const [
        OrderItem(
          itemId: 3,
          commandId: 2,
          refArticle: 'LAP-HP-01',
          designation: 'HP Laptop i7',
          quantity: 1,
          unitPrice: 3500.0,
          totalPrice: 3500.0,
        ),
      ],
    ),
    Order(
      id: 3,
      reference: 'BL-24-105',
      clientId: 1,
      clientName: 'أنس تيك',
      itemsCount: 1,
      totalAmount: 1200.0,
      stage: OrderStage.bl,
      createdAt: DateTime.parse('2025-11-09 11:30:00'),
      updatedAt: DateTime.parse('2025-11-09 11:30:00'),
      items: const [
        OrderItem(
          itemId: 4,
          commandId: 3,
          refArticle: 'PRN-CAN-01',
          designation: 'طابعة كانون G3411',
          quantity: 1,
          unitPrice: 1200.0,
          totalPrice: 1200.0,
        ),
      ],
    ),
  ];
}
