import '../model/transaction_model.dart';

/// Initial Transactions Data
/// Static data matching the React constants.tsx
class TransactionsData {
  TransactionsData._();

  static final List<Transaction> initialTransactions = [
    Transaction(
      id: 1,
      reference: 'BL-24-1-0001',
      clientId: 1,
      clientName: 'أنس تيك',
      date: DateTime.parse('2025-11-08'),
      amount: 2000.0,
      amountPaid: 500.0,
      amountRemaining: 1500.0,
      paymentMethod: 'نقداً',
      createdAt: DateTime.parse('2025-11-08 10:30:00'),
    ),
  ];
}
