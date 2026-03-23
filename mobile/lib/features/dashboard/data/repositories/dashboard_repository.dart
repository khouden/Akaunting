import 'package:dio/dio.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../data/models/dashboard_model.dart';

class ApiDashboardRepository implements DashboardRepository {
  final Dio _dio;

  ApiDashboardRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<DashboardModel>> getDashboards({String? search, int page = 1}) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = 'name:$search';
      }

      final response = await _dio.get('/api/dashboards', queryParameters: queryParams);
      final data = response.data as Map<String, dynamic>;
      final List items = data['data'] as List;
      return items.map((json) => DashboardModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DashboardModel> getDashboard(int id) async {
    try {
      final response = await _dio.get('/api/dashboards/$id');
      final data = response.data as Map<String, dynamic>;
      return DashboardModel.fromJson(data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DashboardModel> createDashboard(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/dashboards', data: data);
      final responseData = response.data as Map<String, dynamic>;
      return DashboardModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DashboardModel> updateDashboard(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/api/dashboards/$id', data: data);
      final responseData = response.data as Map<String, dynamic>;
      return DashboardModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteDashboard(int id) async {
    try {
      await _dio.delete('/api/dashboards/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DashboardModel> enableDashboard(int id) async {
    try {
      final response = await _dio.get('/api/dashboards/$id/enable');
      final data = response.data as Map<String, dynamic>;
      return DashboardModel.fromJson(data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DashboardModel> disableDashboard(int id) async {
    try {
      final response = await _dio.get('/api/dashboards/$id/disable');
      final data = response.data as Map<String, dynamic>;
      return DashboardModel.fromJson(data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) {
        return Exception(data['message']);
      }
      return Exception('Server error: ${e.response!.statusCode}');
    }
    return Exception('Network error. Please check your connection.');
  }
}
