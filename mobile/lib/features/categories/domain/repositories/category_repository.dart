import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/network/api_client.dart';
import '../../../../data/models/category_model.dart';

class CategoryRepository {
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  Future<List<CategoryModel>> getCategories({Map<String, dynamic>? query}) async {
    try {
      final response = await _apiClient.dio.get('/api/categories', queryParameters: query);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<CategoryModel> getCategory(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/categories/$id');
      return CategoryModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load category: $e');
    }
  }

  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/categories', data: data);
      return CategoryModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create category');
      }
      throw Exception('Failed to create category: $e');
    }
  }

  Future<CategoryModel> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('/api/categories/$id', data: data);
      return CategoryModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update category');
      }
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _apiClient.dio.delete('/api/categories/$id');
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<CategoryModel> enableCategory(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/categories/$id/enable');
      return CategoryModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to enable category: $e');
    }
  }

  Future<CategoryModel> disableCategory(int id) async {
    try {
      final response = await _apiClient.dio.get('/api/categories/$id/disable');
      return CategoryModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to disable category: $e');
    }
  }
}
