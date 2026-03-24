import '../../data/models/user_model.dart';

abstract class UserActionState {
  const UserActionState();
}

class UserActionIdle extends UserActionState {}

class UserActionLoading extends UserActionState {}

class UserActionSaved extends UserActionState {
  final UserModel user;

  const UserActionSaved(this.user);
}

class UserActionDeleted extends UserActionState {}

class UserActionToggled extends UserActionState {
  final UserModel user;

  const UserActionToggled(this.user);
}

class UserActionError extends UserActionState {
  final String message;

  const UserActionError(this.message);
}
