import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/cubits/auth_cubit.dart';
import 'login_page.dart';
import '../../../../core/ui/layouts/main_layout.dart';

/// Splash-like gate page that triggers [AuthCubit.checkAuth] on start,
/// then navigates to [MainLayout] or [LoginPage] based on session state.
class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    // Trigger token check after widget tree is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        } else if (state is Unauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      },
      child: const Scaffold(
        backgroundColor: Color(0xFFF4F6F8),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00D084),
          ),
        ),
      ),
    );
  }
}
