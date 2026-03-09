import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../di/injection_container.dart';
import '../../logic/cubits/auth_cubit.dart';

/// Dio [Interceptor] that attaches a Sanctum Bearer token to every outgoing
/// request and automatically triggers a logout when the server responds with
/// 401 Unauthorized.
///
/// Usage:
/// ```dart
/// dio.interceptors.add(AuthInterceptor(storage: secureStorage));
/// ```
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  /// Storage key that [ApiAuthRepository] uses to persist the Sanctum token.
  static const _tokenKey = 'auth_token';

  /// Paths that should **not** carry the Authorization header (e.g. login)
  /// to avoid circular 401 loops.
  static const _publicPaths = <String>[
    '/api/login',
    '/api/register',
  ];

  AuthInterceptor({required FlutterSecureStorage storage})
      : _storage = storage;

  // ─── Request ────────────────────────────────────────────────────────────────

  /// Reads the stored Sanctum token and sets it as a Bearer token on the
  /// `Authorization` header, unless the request targets a public endpoint.
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublic = _publicPaths.any((p) => options.path.contains(p));

    if (!isPublic) {
      final token = await _storage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  // ─── Error ──────────────────────────────────────────────────────────────────

  /// When the server returns **401 Unauthorized**, wipes the local token and
  /// triggers a logout through [AuthCubit] so the UI redirects to login.
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Clear the persisted token immediately.
      await _storage.delete(key: _tokenKey);

      // Trigger a full logout via the AuthCubit (updates UI state).
      if (sl.isRegistered<AuthCubit>()) {
        await sl<AuthCubit>().logout();
      }
    }

    // Always forward the error so callers can still handle it.
    return handler.next(err);
  }
}
