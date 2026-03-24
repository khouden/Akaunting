import 'package:dio/dio.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final Dio _dio;

  UserRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _dio.get('/api/users');
      final data = response.data as Map<String, dynamic>;
      final List<dynamic> usersJson = data['data'] ?? [];
      return usersJson
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> getUser(int id) async {
    try {
      final response = await _dio.get('/api/users/$id');
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/users', data: data);
      final responseData = response.data as Map<String, dynamic>;
      return UserModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/api/users/$id', data: data);
      final responseData = response.data as Map<String, dynamic>;
      return UserModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('/api/users/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> enableUser(int id) async {
    try {
      final response = await _dio.get('/api/users/$id/enable');
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> disableUser(int id) async {
    try {
      final response = await _dio.get('/api/users/$id/disable');
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please try again.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return Exception('Network error. Please check your connection.');
    }

    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      if (statusCode == 401) {
        return Exception('Unauthorized. Please login again.');
      }

      if (statusCode == 403) {
        return Exception('Access forbidden.');
      }

      if (data is Map && data['message'] != null) {
        return Exception(data['message']);
      }

      return Exception('Server error: $statusCode');
    }

    return Exception('An unexpected error occurred.');
  }
}
