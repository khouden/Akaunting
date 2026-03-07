abstract class AuthRepository {
  Future<String?> getToken();
  Future<Map<String, dynamic>?> getUser();
  Future<bool> login(String email, String password);
  Future<void> logout();
}
