import '../../data/models/user_model.dart';

abstract class UserRepository {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUser(int id);
  Future<UserModel> createUser(Map<String, dynamic> data);
  Future<UserModel> updateUser(int id, Map<String, dynamic> data);
  Future<void> deleteUser(int id);
  Future<UserModel> enableUser(int id);
  Future<UserModel> disableUser(int id);
}
