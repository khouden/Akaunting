import 'package:dio/dio.dart';
import '../di/injection_container.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../logic/cubits/auth_cubit.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({String baseUrl = 'http://10.0.2.2:8000'}) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final authRepo = sl<AuthRepository>();
          final token = await authRepo.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Automatically log the user out on 401 Unauthorized.
            if (sl.isRegistered<AuthCubit>()) {
              await sl<AuthCubit>().logout();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}
