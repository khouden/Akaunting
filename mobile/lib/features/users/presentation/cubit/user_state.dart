import '../../data/models/user_model.dart';

abstract class UserState {
  const UserState();
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserModel> users;

  const UserLoaded({required this.users});

  UserLoaded copyWith({List<UserModel>? users}) {
    return UserLoaded(users: users ?? this.users);
  }
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);
}
