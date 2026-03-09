import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository.dart' as api;
import '../../logic/cubits/auth_cubit.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Infrastructure ────────────────────────────────────────────────────────
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(storage: sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: 'http://10.0.2.2:8000',
      authInterceptor: sl<AuthInterceptor>(),
    ),
  );

  // ── Auth ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => api.ApiAuthRepository(
      dio: sl<ApiClient>().dio,
      storage: sl<FlutterSecureStorage>(),
    ),
  );

  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(authRepository: sl<AuthRepository>()),
  );
}

