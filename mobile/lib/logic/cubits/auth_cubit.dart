import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository.dart' as api;
import '../../data/models/user_model.dart';
import '../../core/auth/permission_service.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthState {
  const AuthState();
}

/// Initial state — no session check has been done yet.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A session is available. User is logged in.
class Authenticated extends AuthState {
  final UserModel user;
  final PermissionService permissions;

  Authenticated(this.user) : permissions = PermissionService(user: user);

  /// Check if user has a specific permission.
  bool hasPermission(String permission) => permissions.hasPermission(permission);

  /// Check if user can perform CRUD action on a resource.
  bool can(String action, String resource) => permissions.can(action, resource);
}

/// No session. User must log in.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Login/logout action is in progress.
class Authenticating extends AuthState {
  const Authenticating();
}

/// An authentication operation failed.
class AuthError extends AuthState {
  final String message;
  final bool isPermissionDenied;

  const AuthError(this.message, {this.isPermissionDenied = false});
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

/// Manages the authentication lifecycle:
/// - [checkAuth]  — hydrate state from stored token on app start
/// - [login]      — perform credentials login via the API
/// - [logout]     — wipe token and reset to [Unauthenticated]
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepo;

  AuthCubit({required AuthRepository authRepository})
      : _authRepo = authRepository,
        super(const AuthInitial());

  /// Get the current user if authenticated.
  UserModel? get currentUser {
    final currentState = state;
    if (currentState is Authenticated) {
      return currentState.user;
    }
    return null;
  }

  /// Get the permission service if authenticated.
  PermissionService? get permissions {
    final currentState = state;
    if (currentState is Authenticated) {
      return currentState.permissions;
    }
    return null;
  }

  /// Called at app startup to restore an existing session.
  Future<void> checkAuth() async {
    try {
      final token = await _authRepo.getToken();
      if (token != null && token.isNotEmpty) {
        // Try to get cached user with roles
        if (_authRepo is api.ApiAuthRepository) {
          final cachedUser =
              await (_authRepo as api.ApiAuthRepository).getCachedUser();
          if (cachedUser != null) {
            emit(Authenticated(cachedUser));
            // Refresh profile in background to get latest permissions
            _refreshProfileInBackground();
            return;
          }
        }

        // Fallback: get basic user data
        final userMap = await _authRepo.getUser();
        if (userMap != null && userMap['id'] != null) {
          emit(Authenticated(UserModel.fromJson(userMap)));
        } else {
          // Token exists but no user data — create placeholder
          emit(Authenticated(const UserModel(
            id: 0,
            name: 'User',
            email: '',
          )));
        }

        // Try to refresh profile to get roles
        _refreshProfileInBackground();
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  /// Refresh profile in background to get latest roles/permissions.
  Future<void> _refreshProfileInBackground() async {
    if (_authRepo is api.ApiAuthRepository) {
      try {
        final user =
            await (_authRepo as api.ApiAuthRepository).refreshProfile();
        if (user != null && state is Authenticated) {
          emit(Authenticated(user));
        }
      } catch (_) {
        // Ignore refresh errors — user still has cached access
      }
    }
  }

  /// Force refresh the user profile and permissions.
  Future<void> refreshProfile() async {
    if (_authRepo is api.ApiAuthRepository) {
      try {
        final user =
            await (_authRepo as api.ApiAuthRepository).refreshProfile();
        if (user != null) {
          emit(Authenticated(user));
        }
      } catch (e) {
        // Don't change state on error, just log
      }
    }
  }

  /// Attempts login with [email] and [password].
  /// Emits [Authenticating] → [Authenticated] or [AuthError].
  Future<void> login(String email, String password) async {
    emit(const Authenticating());
    try {
      // Use the richer API implementation if available.
      if (_authRepo is api.ApiAuthRepository) {
        final user = await (_authRepo as api.ApiAuthRepository)
            .loginWithCredentials(email, password);
        emit(Authenticated(user));
      } else {
        // Fallback for DevAuthRepository or other implementations.
        final success = await _authRepo.login(email, password);
        if (success) {
          emit(Authenticated(UserModel(
            id: 0,
            name: 'Developer',
            email: email,
          )));
        } else {
          emit(const AuthError('Invalid email or password.'));
        }
      }
    } on api.ApiAuthException catch (e) {
      emit(AuthError(e.message, isPermissionDenied: e.isPermissionDenied));
    } catch (e) {
      emit(const AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  /// Switch to a different company.
  Future<void> switchCompany(int companyId) async {
    if (_authRepo is api.ApiAuthRepository) {
      await (_authRepo as api.ApiAuthRepository).switchCompany(companyId);
      // Refresh to get company-specific permissions
      await refreshProfile();
    }
  }

  /// Get the active company ID.
  Future<int?> getActiveCompanyId() async {
    if (_authRepo is api.ApiAuthRepository) {
      return await (_authRepo as api.ApiAuthRepository).getActiveCompanyId();
    }
    return null;
  }

  /// Clears the session and returns to [Unauthenticated].
  Future<void> logout() async {
    emit(const Authenticating());
    await _authRepo.logout();
    emit(const Unauthenticated());
  }
}
