import 'package:get_it/get_it.dart';
import '../../../../core/network/api_client.dart';
import '../../../../data/models/setting_model.dart';

class SettingRepository {
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  Future<List<SettingModel>> getSettings() async {
    try {
      final response = await _apiClient.dio.get('/api/settings');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => SettingModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load settings: $e');
    }
  }

  Future<SettingModel> getSetting(dynamic id) async {
    try {
      final response = await _apiClient.dio.get('/api/settings/$id');
      return SettingModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load setting: $e');
    }
  }

  Future<SettingModel> createSetting(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/settings', data: data);
      return SettingModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create setting: $e');
    }
  }

  Future<SettingModel> updateSetting(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('/api/settings/$id', data: data);
      return SettingModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update setting: $e');
    }
  }

  Future<void> deleteSetting(int id) async {
    try {
      await _apiClient.dio.delete('/api/settings/$id');
    } catch (e) {
      throw Exception('Failed to delete setting: $e');
    }
  }
}
