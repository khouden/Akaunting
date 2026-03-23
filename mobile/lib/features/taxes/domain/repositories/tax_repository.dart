import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/network/api_client.dart';
import '../../../../data/models/tax_model.dart';

class TaxRepository {
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  Future<List<TaxModel>> getTaxes({Map<String, dynamic>? query}) async {
    try {
      final response = await _apiClient.dio.get('/api/taxes', queryParameters: query);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => TaxModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load taxes: $e');
    }
  }

  Future<TaxModel> getTax(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/taxes/$id');
      return TaxModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load tax: $e');
    }
  }

  Future<TaxModel> createTax(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/taxes', data: data);
      return TaxModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create tax');
      }
      throw Exception('Failed to create tax: $e');
    }
  }

  Future<TaxModel> updateTax(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('/api/taxes/$id', data: data);
      return TaxModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update tax');
      }
      throw Exception('Failed to update tax: $e');
    }
  }

  Future<void> deleteTax(int id) async {
    try {
      await _apiClient.dio.delete('/api/taxes/$id');
    } catch (e) {
      throw Exception('Failed to delete tax: $e');
    }
  }

  Future<TaxModel> enableTax(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/taxes/$id/enable');
      return TaxModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to enable tax: $e');
    }
  }

  Future<TaxModel> disableTax(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/taxes/$id/disable');
      return TaxModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to disable tax: $e');
    }
  }
}
