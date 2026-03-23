import 'package:get_it/get_it.dart';
import '../../../../core/network/api_client.dart';

class TranslationRepository {
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  Future<Map<String, dynamic>> getAll(String locale) async {
    try {
      final response = await _apiClient.dio.get('/api/translations/$locale/all');
      return Map<String, dynamic>.from(response.data['data'] ?? {});
    } catch (e) {
      throw Exception('Failed to load translations: $e');
    }
  }

  Future<Map<String, dynamic>> getFile(String locale, String file) async {
    try {
      final response = await _apiClient.dio.get('/api/translations/$locale/$file');
      return Map<String, dynamic>.from(response.data['data'] ?? {});
    } catch (e) {
      throw Exception('Failed to load translation file: $e');
    }
  }
}
