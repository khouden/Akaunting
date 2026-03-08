import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Concrete implementation of [AuthRepository] that communicates with the
/// Akaunting backend API and persists tokens via flutter_secure_storage.
class ApiAuthRepository implements AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  ApiAuthRepository({required Dio dio, FlutterSecureStorage? storage})
      : _dio = dio,
        _storage = storage ?? const FlutterSecureStorage();

  // ─── Token helpers ──────────────────────────────────────────────────────────

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> _clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // ─── User helpers ────────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>?> getUser() async {
    // Return cached user map if stored, or fetch from API if needed.
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    // Lightweight parse — full model used in cubit layer.
    return {'raw': raw};
  }

  // ─── Auth actions ────────────────────────────────────────────────────────────

  /// Calls [POST /api/auth/login] and persists the returned access token.
  ///
  /// Returns the authenticated [UserModel] on success.
  /// Throws an [ApiAuthException] on API or network failure.
Future<UserModel> loginWithCredentials(String email, String password) async {
  try {
    final response = await _dio.post(
      '/api/login', // Keep '/api' but remove '/auth' to match your artisan route:list
      data: {'email': email, 'password': password},
    );

    final responseData = response.data as Map<String, dynamic>;

    // Target the 'data' map from your screenshot
    final dataMap = responseData['data'] as Map<String, dynamic>?;

    // Extract the token: '4|L9YGeM...'
    final token = dataMap?['token'] as String?;

    if (token == null || token.isEmpty) {
      throw ApiAuthException('Server returned an empty token.');
    }

    await _saveToken(token);

    // Extract user object from the same 'data' map
    final userJson = dataMap?['user'] as Map<String, dynamic>?;

    if (userJson == null) {
      throw ApiAuthException('User data missing from response.');
    }

    return UserModel.fromJson(userJson);
  } on DioException catch (e) {
    final message = _parseDioError(e);
    throw ApiAuthException(message);
  }
}

  @override
  Future<bool> login(String email, String password) async {
    try {
      await loginWithCredentials(email, password);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Calls [POST /api/auth/logout] (best-effort) and wipes local token.
  @override
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _dio.post('/api/logout');
      }
    } catch (_) {
      // Ignore server-side errors — always wipe locally.
    } finally {
      await _clearToken();
      await _storage.delete(key: _userKey);
    }
  }

  // ─── Utilities ───────────────────────────────────────────────────────────────

  String _parseDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) return data['message'];
      if (e.response!.statusCode == 401) {
        return 'Invalid email or password.';
      }
      return 'Server error (${e.response!.statusCode}).';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Check your network.';
    }
    return 'Network error. Please try again.';
  }
}

class ApiAuthException implements Exception {
  final String message;
  ApiAuthException(this.message);

  @override
  String toString() => message;
}
