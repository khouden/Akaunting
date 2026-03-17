import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../data/models/transaction_model.dart';
import 'package:get_it/get_it.dart';

class LookupOption {
  final int id;
  final String name;

  const LookupOption({required this.id, required this.name});
}

class TransactionRepository {
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  List<LookupOption> _parseLookupOptions(dynamic responseData) {
    final List<dynamic> data = responseData['data'] ?? [];

    return data
        .whereType<Map<String, dynamic>>()
        .map((item) => LookupOption(
              id: item['id'] as int,
              name: (item['name'] as String?) ??
                  (item['title'] as String?) ??
                  'Unknown',
            ))
        .toList();
  }

  Future<List<TransactionModel>> getTransactions({Map<String, dynamic>? query}) async {
    try {
      final response = await _apiClient.dio.get('/api/transactions', queryParameters: query);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  Future<TransactionModel> getTransaction(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/transactions/$id');
      return TransactionModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load transaction: $e');
    }
  }

  Future<TransactionModel> createTransaction(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/transactions', data: data);
      return TransactionModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create transaction');
      }
      throw Exception('Failed to create transaction: $e');
    }
  }

  Future<TransactionModel> updateTransaction(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('/api/transactions/$id', data: data);
      return TransactionModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update transaction');
      }
      throw Exception('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _apiClient.dio.delete('/api/transactions/$id');
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  Future<List<LookupOption>> getAccounts() async {
    try {
      final response = await _apiClient.dio.get('/api/accounts');

      return _parseLookupOptions(response.data);
    } catch (e) {
      throw Exception('Failed to load accounts: $e');
    }
  }

  Future<List<LookupOption>> getCategories({required String type}) async {
    try {
      final response = await _apiClient.dio
          .get('/api/categories', queryParameters: {'search': 'type:$type'});

      return _parseLookupOptions(response.data);
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<LookupOption>> getContacts({required String type}) async {
    try {
      final response = await _apiClient.dio
          .get('/api/contacts', queryParameters: {'search': 'type:$type'});

      return _parseLookupOptions(response.data);
    } catch (e) {
      throw Exception('Failed to load contacts: $e');
    }
  }

  Future<LookupOption> createDefaultAccount() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final response = await _apiClient.dio.post('/api/accounts', data: {
        'type': 'bank',
        'name': 'Default Account',
        'number': 'ACC-$now',
        'currency_code': 'USD',
        'opening_balance': 0,
        'enabled': 1,
      });

      final data = response.data['data'] as Map<String, dynamic>;

      return LookupOption(
        id: data['id'] as int,
        name: (data['name'] as String?) ?? 'Default Account',
      );
    } catch (e) {
      throw Exception('Failed to create default account: $e');
    }
  }

  Future<LookupOption> createDefaultCategory({required String type}) async {
    try {
      final response = await _apiClient.dio.post('/api/categories', data: {
        'name': type == 'income' ? 'General Income' : 'General Expense',
        'type': type,
        'color': '#6DA252',
      });

      final data = response.data['data'] as Map<String, dynamic>;

      return LookupOption(
        id: data['id'] as int,
        name: (data['name'] as String?) ?? 'General Category',
      );
    } catch (e) {
      throw Exception('Failed to create default category: $e');
    }
  }
}
