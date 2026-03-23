import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/network/api_client.dart';
import '../../../../data/models/currency_model.dart';

class CurrencyRepository {
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  Future<List<CurrencyModel>> getCurrencies({Map<String, dynamic>? query}) async {
    try {
      final response = await _apiClient.dio.get('/api/currencies', queryParameters: query);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => CurrencyModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load currencies: $e');
    }
  }

  Future<CurrencyModel> getCurrency(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/currencies/$id');
      return CurrencyModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load currency: $e');
    }
  }

  Future<CurrencyModel> createCurrency(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/currencies', data: data);
      return CurrencyModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create currency');
      }
      throw Exception('Failed to create currency: $e');
    }
  }

  Future<CurrencyModel> updateCurrency(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('/api/currencies/$id', data: data);
      return CurrencyModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update currency');
      }
      throw Exception('Failed to update currency: $e');
    }
  }

  Future<void> deleteCurrency(int id) async {
    try {
      await _apiClient.dio.delete('/api/currencies/$id');
    } catch (e) {
      throw Exception('Failed to delete currency: $e');
    }
  }

  Future<CurrencyModel> enableCurrency(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/currencies/$id/enable');
      return CurrencyModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to enable currency: $e');
    }
  }

  Future<CurrencyModel> disableCurrency(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/currencies/$id/disable');
      return CurrencyModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to disable currency: $e');
    }
  }
}
