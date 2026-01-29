import '../model/transaction_model.dart';
import '../data/transactions_data.dart';
import '../../../core/loading_state.dart';

/// Transactions Service
/// API service for transaction operations
/// Implements realistic mocking for development until backend is ready
class TransactionsService {
  TransactionsService._();

  /// Simulated API delay for realistic UX testing
  static const Duration _simulatedDelay = Duration(milliseconds: 600);

  /// Fetch all transactions from API
  static Future<Result<List<Transaction>>> fetchTransactions() async {
    try {
      await Future.delayed(_simulatedDelay);
      return Result.success(TransactionsData.initialTransactions);
    } catch (e) {
      return Result.error('فشل في تحميل المعاملات: ${e.toString()}');
    }
  }

  /// Create a new transaction (payment)
  static Future<Result<Transaction>> createTransaction(
    Transaction transaction,
  ) async {
    try {
      await Future.delayed(_simulatedDelay);

      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch,
        clientId: transaction.clientId,
        clientName: transaction.clientName,
        reference: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
        amount: transaction.amount,
        amountPaid: transaction.amountPaid,
        amountRemaining: transaction.amount - transaction.amountPaid,
        paymentMethod: transaction.paymentMethod,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      return Result.success(newTransaction);
    } catch (e) {
      return Result.error('فشل في تسجيل الدفعة: ${e.toString()}');
    }
  }

  /// Update a transaction
  static Future<Result<Transaction>> updateTransaction(
    Transaction transaction,
  ) async {
    try {
      await Future.delayed(_simulatedDelay);
      return Result.success(transaction);
    } catch (e) {
      return Result.error('فشل في تحديث المعاملة: ${e.toString()}');
    }
  }

  /// Delete a transaction
  static Future<Result<bool>> deleteTransaction(int id) async {
    try {
      await Future.delayed(_simulatedDelay);
      return Result.success(true);
    } catch (e) {
      return Result.error('فشل في حذف المعاملة: ${e.toString()}');
    }
  }

  /// Get transactions by client
  static Future<Result<List<Transaction>>> fetchClientTransactions(
    int clientId,
  ) async {
    try {
      await Future.delayed(_simulatedDelay);

      final filtered = TransactionsData.initialTransactions
          .where((t) => t.clientId == clientId)
          .toList();

      return Result.success(filtered);
    } catch (e) {
      return Result.error('فشل في تحميل معاملات العميل: ${e.toString()}');
    }
  }
}
