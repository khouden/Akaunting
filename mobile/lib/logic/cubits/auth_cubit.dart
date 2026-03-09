import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository.dart' as api;
import '../../data/models/user_model.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthState {}

/// Initial state — no session check has been done yet.
class AuthInitial extends AuthState {}

/// A session is available. User is logged in.
class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
}

/// No session. User must log in.
class Unauthenticated extends AuthState {}

/// Login/logout action is in progress.
class Authenticating extends AuthState {}

/// An authentication operation failed.
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
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
        super(AuthInitial());

  /// Called at app startup to restore an existing session.
  Future<void> checkAuth() async {
    try {
      final token = await _authRepo.getToken();
      if (token != null && token.isNotEmpty) {
        // If we have a token, try to get user details.
        final userMap = await _authRepo.getUser();
        if (userMap != null && userMap['id'] != null) {
          emit(Authenticated(UserModel.fromJson(userMap)));
        } else {
          // Token exists but user data isn't cached — treat as authenticated
          // with placeholder until a real user fetch is implemented.
          emit(Authenticated(const UserModel(
            id: 0,
            name: 'User',
            email: '',
          )));
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  /// Attempts login with [email] and [password].
  /// Emits [Authenticating] → [Authenticated] or [AuthError].
  Future<void> login(String email, String password) async {
    emit(Authenticating());
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
          emit(AuthError('Invalid email or password.'));
        }
      }
    } on api.ApiAuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  /// Clears the session and returns to [Unauthenticated].
  Future<void> logout() async {
    emit(Authenticating());
    await _authRepo.logout();
    emit(Unauthenticated());
  }
}
