import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../di/injection_container.dart';
import '../../logic/cubits/auth_cubit.dart';

/// Dio [Interceptor] that attaches a Sanctum Bearer token to every outgoing
/// request and automatically triggers a logout when the server responds with
/// 401 Unauthorized.
///
/// Also handles 403 Forbidden errors with specific permission denied messaging.
///
/// Usage:
/// ```dart
/// dio.interceptors.add(AuthInterceptor(storage: secureStorage));
/// ```
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  /// Storage key that [ApiAuthRepository] uses to persist the Sanctum token.
  static const _tokenKey = 'auth_token';

  /// Storage key for the active company ID (saved during login).
  static const _companyKey = 'company_id';

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
  /// `Authorization` header, and attaches the `X-Company` header so the
  /// backend resolves the correct company context for permission checks.
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

      // Attach the company ID required by Akaunting's API.
      final companyId = await _storage.read(key: _companyKey);
      if (companyId != null && companyId.isNotEmpty) {
        options.headers['X-Company'] = companyId;
      }
    }

    return handler.next(options);
  }

  // ─── Error ──────────────────────────────────────────────────────────────────

  /// Handles authentication and authorization errors:
  /// - **401 Unauthorized**: Wipes the local token and triggers logout
  /// - **403 Forbidden**: Enhances error with permission denied details
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;

    if (statusCode == 401) {
      // Clear the persisted token immediately.
      await _storage.delete(key: _tokenKey);

      // Trigger a full logout via the AuthCubit (updates UI state).
      if (sl.isRegistered<AuthCubit>()) {
        await sl<AuthCubit>().logout();
      }

      // Enhance error message
      final enhancedError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: AuthorizationError(
          'Your session has expired. Please log in again.',
          statusCode: 401,
          isSessionExpired: true,
        ),
      );
      return handler.next(enhancedError);
    }

    if (statusCode == 403) {
      // Extract resource name from the request path for better messaging
      final resourceName = _extractResourceName(err.requestOptions.path);
      final action = _extractAction(err.requestOptions.method);

      // Try to get server message if available
      String serverMessage = '';
      if (err.response?.data is Map) {
        serverMessage = err.response?.data['message']?.toString() ?? '';
      }

      final message = serverMessage.isNotEmpty
          ? serverMessage
          : 'You do not have permission to $action $resourceName.';

      final enhancedError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: AuthorizationError(
          message,
          statusCode: 403,
          isPermissionDenied: true,
          resource: resourceName,
          action: action,
        ),
      );
      return handler.next(enhancedError);
    }

    // Always forward the error so callers can still handle it.
    return handler.next(err);
  }

  /// Extract a human-readable resource name from the API path.
  String _extractResourceName(String path) {
    // Remove /api/ prefix and query parameters
    final cleanPath = path.replaceFirst('/api/', '').split('?').first;
    final segments = cleanPath.split('/');

    if (segments.isEmpty) return 'this resource';

    // Get the main resource (usually the first segment)
    final resource = segments.first;

    // Map API resources to human-readable names
    const resourceNames = {
      'users': 'users',
      'companies': 'companies',
      'dashboards': 'dashboards',
      'items': 'items',
      'contacts': 'contacts',
      'documents': 'documents',
      'accounts': 'bank accounts',
      'transactions': 'transactions',
      'transfers': 'transfers',
      'reconciliations': 'reconciliations',
      'reports': 'reports',
      'categories': 'categories',
      'currencies': 'currencies',
      'taxes': 'taxes',
      'settings': 'settings',
      'profile': 'your profile',
    };

    return resourceNames[resource] ?? resource;
  }

  /// Extract a human-readable action from the HTTP method.
  String _extractAction(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return 'view';
      case 'POST':
        return 'create';
      case 'PUT':
      case 'PATCH':
        return 'update';
      case 'DELETE':
        return 'delete';
      default:
        return 'access';
    }
  }
}

/// Custom error class for authorization failures.
class AuthorizationError implements Exception {
  final String message;
  final int statusCode;
  final bool isSessionExpired;
  final bool isPermissionDenied;
  final String? resource;
  final String? action;

  AuthorizationError(
    this.message, {
    required this.statusCode,
    this.isSessionExpired = false,
    this.isPermissionDenied = false,
    this.resource,
    this.action,
  });

  @override
  String toString() => message;
}

/// Extension to extract authorization errors from DioException.
extension DioExceptionAuthExtension on DioException {
  /// Check if this is an authorization error.
  bool get isAuthorizationError => error is AuthorizationError;

  /// Get the authorization error if present.
  AuthorizationError? get authorizationError =>
      error is AuthorizationError ? error as AuthorizationError : null;

  /// Check if this is a permission denied error.
  bool get isPermissionDenied =>
      authorizationError?.isPermissionDenied ?? false;

  /// Check if this is a session expired error.
  bool get isSessionExpired => authorizationError?.isSessionExpired ?? false;

  /// Get a user-friendly error message.
  String get userMessage {
    if (authorizationError != null) {
      return authorizationError!.message;
    }

    final statusCode = response?.statusCode;
    if (statusCode == 401) {
      return 'Your session has expired. Please log in again.';
    }
    if (statusCode == 403) {
      return 'You do not have permission to perform this action.';
    }
    if (statusCode == 404) {
      return 'The requested resource was not found.';
    }
    if (statusCode == 422) {
      // Validation error
      if (response?.data is Map) {
        final errors = response?.data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
        final message = response?.data['message'];
        if (message != null) {
          return message.toString();
        }
      }
      return 'The provided data is invalid.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'A server error occurred. Please try again later.';
    }

    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please check your network.';
    }
    if (type == DioExceptionType.connectionError) {
      return 'Unable to connect to the server. Please check your network.';
    }

    return message ?? 'An unexpected error occurred.';
  }
}
