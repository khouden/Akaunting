import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_state.dart';

/// Cubit responsible for loading and displaying the list of users.
class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;

  UserCubit({required UserRepository repository})
    : _repository = repository,
      super(UserInitial());

  Future<void> getUsers() async {
    emit(UserLoading());
    try {
      final users = await _repository.getUsers();
      emit(UserLoaded(users: users));
    } catch (e) {
      emit(UserError(_parseError(e)));
    }
  }

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) return msg.substring(11);
    return 'An unexpected error occurred. Please try again.';
  }
}
