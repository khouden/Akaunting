import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository.dart' as api;
import '../../logic/cubits/auth_cubit.dart';
import '../../features/accounts/domain/repositories/account_repository.dart';
import '../../features/accounts/data/repositories/account_repository.dart';
import '../../logic/cubits/account_cubit.dart';
import '../../features/reconciliations/domain/repositories/reconciliation_repository.dart';
import '../../features/reconciliations/data/repositories/reconciliation_repository.dart';
import '../../logic/cubits/reconciliation_cubit.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../features/transactions/presentation/cubit/transaction_cubit.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Infrastructure
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(storage: sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000',
      authInterceptor: sl<AuthInterceptor>(),
    ),
  );

  // Auth
  sl.registerLazySingleton<AuthRepository>(
    () => api.ApiAuthRepository(
      dio: sl<ApiClient>().dio,
      storage: sl<FlutterSecureStorage>(),
    ),
  );

  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(authRepository: sl<AuthRepository>()),
  );

  // Accounts
  sl.registerLazySingleton<AccountRepository>(
    () => ApiAccountRepository(dio: sl<ApiClient>().dio),
  );

  sl.registerFactory<AccountCubit>(
    () => AccountCubit(accountRepository: sl<AccountRepository>()),
  );

  // Reconciliations
  sl.registerLazySingleton<ReconciliationRepository>(
    () => ApiReconciliationRepository(dio: sl<ApiClient>().dio),
  );

  sl.registerFactory<ReconciliationCubit>(
    () => ReconciliationCubit(reconciliationRepository: sl<ReconciliationRepository>()),
  );

  // Transactions
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(),
  );

  sl.registerFactory<TransactionCubit>(
    () => TransactionCubit(),
  );
}
