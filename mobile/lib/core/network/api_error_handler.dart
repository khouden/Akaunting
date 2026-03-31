import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

/// Mixin that provides standardized error handling for API repositories.
///
/// Usage:
/// ```dart
/// class UserRepository with ApiErrorHandler {
///   Future<User> getUser(int id) async {
///     return handleApiCall(() async {
///       final response = await dio.get('/api/users/$id');
///       return User.fromJson(response.data);
///     });
///   }
/// }
/// ```
mixin ApiErrorHandler {
  /// Wraps an API call with standardized error handling.
  ///
  /// Returns the result of [apiCall] on success.
  /// Throws a user-friendly [Exception] on failure.
  Future<T> handleApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      throw Exception(_parseApiError(e));
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Parse a DioException into a user-friendly error message.
  String _parseApiError(DioException e) {
    // Check for authorization errors first
    if (e.isAuthorizationError) {
      return e.authorizationError!.message;
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // Try to get message from response body
    if (data is Map) {
      // Check for Laravel validation errors
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
      }

      // Check for message field
      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    // Fall back to status code based messages
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'A conflict occurred. The resource may already exist.';
      case 422:
        return 'The provided data is invalid. Please check your input.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'A server error occurred. Please try again later.';
      case 502:
      case 503:
      case 504:
        return 'The server is temporarily unavailable. Please try again later.';
      default:
        if (statusCode != null && statusCode >= 400) {
          return 'Server error ($statusCode). Please try again.';
        }
    }

    // Network errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your network.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to the server. Please check your network.';
      case DioExceptionType.badCertificate:
        return 'Security certificate error. Please contact support.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return e.message ?? 'A network error occurred. Please try again.';
    }
  }
}

/// Extension for Dio responses to extract common data patterns.
extension DioResponseExtension on Response {
  /// Extract the data payload from a wrapped API response.
  ///
  /// Handles both `{ data: {...} }` and `{...}` response formats.
  Map<String, dynamic>? get unwrappedData {
    if (data is! Map<String, dynamic>) return null;

    final responseData = data as Map<String, dynamic>;

    // Check for wrapped response
    if (responseData.containsKey('data')) {
      final innerData = responseData['data'];
      if (innerData is Map<String, dynamic>) {
        return innerData;
      }
    }

    // Check if response already has ID (unwrapped)
    if (responseData.containsKey('id')) {
      return responseData;
    }

    return responseData;
  }

  /// Extract a list of items from a wrapped API response.
  ///
  /// Handles both `{ data: [...] }` and `[...]` response formats.
  List<dynamic> get unwrappedList {
    if (data is List) {
      return data as List<dynamic>;
    }

    if (data is Map<String, dynamic>) {
      final responseData = data as Map<String, dynamic>;
      if (responseData.containsKey('data')) {
        final innerData = responseData['data'];
        if (innerData is List) {
          return innerData;
        }
      }
    }

    return [];
  }
}

/// Result wrapper for operations that can succeed or fail.
class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isPermissionDenied;

  const ApiResult._({
    this.data,
    this.error,
    this.isPermissionDenied = false,
  });

  factory ApiResult.success(T data) => ApiResult._(data: data);

  factory ApiResult.failure(String error, {bool isPermissionDenied = false}) =>
      ApiResult._(error: error, isPermissionDenied: isPermissionDenied);

  bool get isSuccess => data != null && error == null;
  bool get isFailure => error != null;

  /// Execute [onSuccess] if successful, otherwise execute [onFailure].
  R when<R>({
    required R Function(T data) success,
    required R Function(String error, bool isPermissionDenied) failure,
  }) {
    if (isSuccess) {
      return success(data as T);
    }
    return failure(error!, isPermissionDenied);
  }
}
