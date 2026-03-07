import 'dart:async';
import '../../domain/repositories/auth_repository.dart';

class DevAuthRepository implements AuthRepository {
  // Hardcoded Postman token as requested
  final String _devToken = 'HARDCODED_POSTMAN_TOKEN_HERE';
  
  @override
  Future<String?> getToken() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _devToken;
  }

  @override
  Future<Map<String, dynamic>?> getUser() async {
    return {
      'id': 1,
      'name': 'Dev User',
      'email': 'dev@example.com',
    };
  }

  @override
  Future<bool> login(String email, String password) async {
    return true; // Always succeed in dev mode
  }

  @override
  Future<void> logout() async {
    // Do nothing in dev mode
  }
}
