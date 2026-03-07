import 'package:get_it/get_it.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/dev_auth_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Authentication
  sl.registerLazySingleton<AuthRepository>(() => DevAuthRepository());
  
  // Future: Switch to ApiAuthRepository when Developer 1 finishes Auth module
  // sl.registerLazySingleton<AuthRepository>(() => ApiAuthRepository(apiClient: sl()));
}
