import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/injection_container.dart';
import 'features/auth/presentation/pages/auth_check_page.dart';
import 'logic/cubits/auth_cubit.dart';
import 'features/companies/presentation/cubit/company_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/users/presentation/cubit/user_cubit.dart';
import 'features/users/presentation/cubit/user_action_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const AkauntingMobileApp());
}

class AkauntingMobileApp extends StatelessWidget {
  const AkauntingMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<CompanyCubit>(create: (_) => sl<CompanyCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()),
        BlocProvider<UserCubit>(create: (_) => sl<UserCubit>()),
        BlocProvider<UserActionCubit>(create: (_) => sl<UserActionCubit>()),
      ],
      child: MaterialApp(
        title: 'Akaunting Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00D084),
            primary: const Color(0xFF00D084),
          ),
          primaryColor: const Color(0xFF00D084),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        home: const AuthCheckPage(),
      ),
    );
  }
}
