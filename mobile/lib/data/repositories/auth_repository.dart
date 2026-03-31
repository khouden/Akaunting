import 'dart:convert';
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
  static const companyKey = 'company_id';

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
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveUser(UserModel user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  /// Get the cached user model.
  Future<UserModel?> getCachedUser() async {
    final userMap = await getUser();
    if (userMap == null) return null;
    try {
      return UserModel.fromJson(userMap);
    } catch (_) {
      return null;
    }
  }

  // ─── Auth actions ────────────────────────────────────────────────────────────

  /// Calls [POST /api/login] and persists the returned access token.
  ///
  /// After login, fetches the user profile to get complete role/permission data.
  /// Returns the authenticated [UserModel] on success.
  /// Throws an [ApiAuthException] on API or network failure.
  Future<UserModel> loginWithCredentials(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/login',
        data: {'email': email, 'password': password},
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataMap = responseData['data'] as Map<String, dynamic>?;

      // Extract the token
      final token = dataMap?['token'] as String?;
      if (token == null || token.isEmpty) {
        throw ApiAuthException('Server returned an empty token.');
      }

      await _saveToken(token);

      // Persist the first company ID so the auth interceptor can send X-Company.
      final companies = dataMap?['user']?['companies'] as List<dynamic>?;
      if (companies != null && companies.isNotEmpty) {
        final companyId = companies[0]['id'];
        await _storage.write(key: companyKey, value: companyId.toString());
      }

      // Extract basic user data from login response
      final userJson = dataMap?['user'] as Map<String, dynamic>?;
      if (userJson == null) {
        throw ApiAuthException('User data missing from response.');
      }

      // Create initial user model from login data
      UserModel user = UserModel.fromJson(userJson);

      // Fetch full profile to get roles and permissions
      try {
        final profileUser = await _fetchProfile();
        if (profileUser != null) {
          user = profileUser;
        }
      } catch (e) {
        // If profile fetch fails, continue with basic user data
        // The user's roles will be empty, showing limited access
      }

      // Cache the user data
      await _saveUser(user);

      return user;
    } on DioException catch (e) {
      final message = _parseDioError(e);
      throw ApiAuthException(message);
    }
  }

  /// Fetches the current user's profile including roles and permissions.
  Future<UserModel?> _fetchProfile() async {
    try {
      final response = await _dio.get('/api/profile');
      final responseData = response.data as Map<String, dynamic>;

      // Handle wrapped response
      Map<String, dynamic>? userData;
      if (responseData.containsKey('data')) {
        userData = responseData['data'] as Map<String, dynamic>?;
      } else if (responseData.containsKey('id')) {
        userData = responseData;
      }

      if (userData == null) return null;
      return UserModel.fromJson(userData);
    } catch (_) {
      return null;
    }
  }

  /// Refresh the current user's profile data.
  Future<UserModel?> refreshProfile() async {
    final user = await _fetchProfile();
    if (user != null) {
      await _saveUser(user);
    }
    return user;
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

  /// Calls [POST /api/logout] (best-effort) and wipes local token.
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
      await _storage.delete(key: companyKey);
    }
  }

  // ─── Company Management ─────────────────────────────────────────────────────

  /// Get the currently active company ID.
  Future<int?> getActiveCompanyId() async {
    final companyId = await _storage.read(key: companyKey);
    if (companyId == null) return null;
    return int.tryParse(companyId);
  }

  /// Switch to a different company.
  Future<void> switchCompany(int companyId) async {
    await _storage.write(key: companyKey, value: companyId.toString());
    // Refresh profile to get company-specific permissions
    await refreshProfile();
  }

  // ─── Utilities ───────────────────────────────────────────────────────────────

  String _parseDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) return data['message'];
      if (e.response!.statusCode == 401) {
        return 'Invalid email or password.';
      }
      if (e.response!.statusCode == 403) {
        return 'Access denied. You do not have permission to perform this action.';
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
  final int? statusCode;
  final bool isPermissionDenied;

  ApiAuthException(
    this.message, {
    this.statusCode,
    this.isPermissionDenied = false,
  });

  factory ApiAuthException.permissionDenied([String? message]) {
    return ApiAuthException(
      message ?? 'You do not have permission to perform this action.',
      statusCode: 403,
      isPermissionDenied: true,
    );
  }

  @override
  String toString() => message;
}
