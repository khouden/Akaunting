import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_action_state.dart';

/// Cubit responsible for user mutations: create, update, delete, enable, disable.
/// Separated from UserCubit so that list loading is not interrupted by background actions.
class UserActionCubit extends Cubit<UserActionState> {
  final UserRepository _repository;

  UserActionCubit({required UserRepository repository})
    : _repository = repository,
      super(UserActionIdle());

  Future<void> createUser(Map<String, dynamic> data) async {
    emit(UserActionLoading());
    try {
      final user = await _repository.createUser(data);
      emit(UserActionSaved(user));
    } catch (e) {
      emit(UserActionError(_parseError(e)));
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    emit(UserActionLoading());
    try {
      final user = await _repository.updateUser(id, data);
      emit(UserActionSaved(user));
    } catch (e) {
      emit(UserActionError(_parseError(e)));
    }
  }

  Future<void> deleteUser(int id) async {
    emit(UserActionLoading());
    try {
      await _repository.deleteUser(id);
      emit(UserActionDeleted());
    } catch (e) {
      emit(UserActionError(_parseError(e)));
    }
  }

  Future<void> enableUser(int id) async {
    emit(UserActionLoading());
    try {
      final user = await _repository.enableUser(id);
      emit(UserActionToggled(user));
    } catch (e) {
      emit(UserActionError(_parseError(e)));
    }
  }

  Future<void> disableUser(int id) async {
    emit(UserActionLoading());
    try {
      final user = await _repository.disableUser(id);
      emit(UserActionToggled(user));
    } catch (e) {
      emit(UserActionError(_parseError(e)));
    }
  }

  void reset() => emit(UserActionIdle());

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) return msg.substring(11);
    return 'An unexpected error occurred. Please try again.';
  }
}
