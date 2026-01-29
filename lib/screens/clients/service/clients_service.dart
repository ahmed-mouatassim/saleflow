import '../model/client_model.dart';
import '../data/clients_data.dart';
import '../../../core/loading_state.dart';

/// Clients Service
/// API service for client operations
/// Implements realistic mocking for development until backend is ready
class ClientsService {
  ClientsService._();

  /// Simulated API delay for realistic UX testing
  static const Duration _simulatedDelay = Duration(milliseconds: 600);

  /// Fetch all clients from API
  static Future<Result<List<Client>>> fetchClients() async {
    try {
      await Future.delayed(_simulatedDelay);
      return Result.success(ClientsData.initialClients);
      //return Result.success(ClientsData.initialClientServer);
    } catch (e) {
      return Result.error('فشل في تحميل العملاء: ${e.toString()}');
    }
  }

  /// Create a new client
  static Future<Result<Client>> createClient(Client client) async {
    try {
      await Future.delayed(_simulatedDelay);

      // Simulate creating client with new ID
      final newClient = client.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return Result.success(newClient);
    } catch (e) {
      return Result.error('فشل في إنشاء العميل: ${e.toString()}');
    }
  }

  /// Update an existing client
  static Future<Result<Client>> updateClient(Client client) async {
    try {
      await Future.delayed(_simulatedDelay);

      final updatedClient = client.copyWith(updatedAt: DateTime.now());

      return Result.success(updatedClient);
    } catch (e) {
      return Result.error('فشل في تحديث العميل: ${e.toString()}');
    }
  }

  /// Delete a client
  static Future<Result<bool>> deleteClient(int clientId) async {
    try {
      await Future.delayed(_simulatedDelay);
      return Result.success(true);
    } catch (e) {
      return Result.error('فشل في حذف العميل: ${e.toString()}');
    }
  }

  /// Search clients by query
  static Future<Result<List<Client>>> searchClients(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final queryLower = query.toLowerCase();
      final filtered = ClientsData.initialClients
          .where(
            (c) =>
                c.name.toLowerCase().contains(queryLower) ||
                c.phone.contains(query) ||
                c.address.toLowerCase().contains(queryLower),
          )
          .toList();

      return Result.success(filtered);
    } catch (e) {
      return Result.error('فشل في البحث: ${e.toString()}');
    }
  }
}
