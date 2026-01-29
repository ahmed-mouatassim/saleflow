import '../model/client_model.dart';

/// Initial Clients Data
/// Static data matching the React constants.tsx
class ClientsData {
  ClientsData._();

  static final List<Client> initialClients = [
    Client(
      id: 1,
      name: 'أنس تيك',
      limitPrice: 5000.0,
      amountRemaining: 1500.0,
      amountPaid: 500.0,
      totalAmount: 2000.0,
      phone: '0612345678',
      address: 'الدار البيضاء، المغرب',
      isActive: true,
      createdAt: DateTime.parse('2025-11-08 10:00:00'),
      updatedAt: DateTime.parse('2025-11-08 10:30:00'),
    ),
    Client(
      id: 2,
      name: 'متجر محمد',
      limitPrice: 10000.0,
      amountRemaining: 0.0,
      amountPaid: 3500.0,
      totalAmount: 3500.0,
      phone: '0623456789',
      address: 'الرباط، المغرب',
      isActive: true,
      createdAt: DateTime.parse('2025-11-07 09:00:00'),
      updatedAt: DateTime.parse('2025-11-08 11:00:00'),
    ),
  ];
  static final List<Client> initialClientServer = [];
}
