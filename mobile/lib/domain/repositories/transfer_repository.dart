import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../data/models/transfer_model.dart';

class LookupOption {
  final int id;
  final String name;

  const LookupOption({required this.id, required this.name});
}

class TransferRepository {
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  Future<List<TransferModel>> getTransfers({Map<String, dynamic>? query}) async {
    try {
      final response = await _apiClient.dio.get('/api/transfers', queryParameters: query);
      final List<dynamic> data = response.data['data'] ?? [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(TransferModel.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Failed to load transfers: $e');
    }
  }

  Future<TransferModel> getTransfer(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/transfers/$id');

      return TransferModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load transfer: $e');
    }
  }

  Future<TransferModel> createTransfer(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/transfers', data: data);

      return TransferModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create transfer');
      }

      throw Exception('Failed to create transfer: $e');
    }
  }

  Future<TransferModel> updateTransfer(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('/api/transfers/$id', data: data);

      return TransferModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update transfer');
      }

      throw Exception('Failed to update transfer: $e');
    }
  }

  Future<void> deleteTransfer(int id) async {
    try {
      await _apiClient.dio.delete('/api/transfers/$id');
    } catch (e) {
      throw Exception('Failed to delete transfer: $e');
    }
  }

  Future<List<LookupOption>> getAccounts() async {
    try {
      final response = await _apiClient.dio.get('/api/accounts');
      final List<dynamic> data = response.data['data'] ?? [];

      return data
          .whereType<Map<String, dynamic>>()
          .map((item) => LookupOption(
                id: item['id'] as int,
                name: (item['name'] as String?) ?? 'Unknown',
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to load accounts: $e');
    }
  }
}
