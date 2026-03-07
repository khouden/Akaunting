import 'package:dio/dio.dart';
import '../di/injection_container.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

class ApiClient {
  late Dio dio;

  ApiClient({String baseUrl = 'https://api.example.com/'}) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get the repository from DI
          final authRepo = sl<AuthRepository>();
          final token = await authRepo.getToken();
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer \$token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle global errors here (e.g., 401 Unauthorized -> logout)
          return handler.next(e);
        },
      ),
    );
  }
}
