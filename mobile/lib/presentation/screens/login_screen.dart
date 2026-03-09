import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/ui/components/inputs/base_input.dart';
import '../../../../core/ui/components/base_button.dart';
import '../../../../logic/cubits/auth_cubit.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/ui/layouts/main_layout.dart';

/// Login screen mirroring Akaunting's visual language:
/// — Clean white card on a light grey background
/// — #00D084 primary green accent color
/// — Reuses existing [BaseInput] and [BaseButton] components
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ─── Form ────────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  // ─── Akaunting brand colors ───────────────────────────────────────────────────
  static const _green = Color(0xFF00D084);
  static const _bgGrey = Color(0xFFF4F6F8);
  static const _textDark = Color(0xFF1A2332);
  static const _textSubtle = Color(0xFF6B7A99);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────

  void _submit(AuthCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.login(_emailCtrl.text.trim(), _passwordCtrl.text);
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainLayout()),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            _navigateToHome(context);
          }
        },
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          final isLoading = state is Authenticating;
          final errorMessage = state is AuthError ? state.message : null;

          return Scaffold(
            backgroundColor: _bgGrey,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Logo / Brand ──────────────────────────────────────
                      _buildLogo(),
                      const SizedBox(height: 32),

                      // ── Card ──────────────────────────────────────────────
                      _buildCard(
                        context,
                        cubit: cubit,
                        isLoading: isLoading,
                        errorMessage: errorMessage,
                      ),
                      const SizedBox(height: 24),

                      // ── Footer ────────────────────────────────────────────
                      Text(
                        '© ${DateTime.now().year} Akaunting',
                        style: const TextStyle(
                          color: _textSubtle,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Sub-widgets ─────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _green.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.account_balance_wallet_rounded,
              color: Colors.white, size: 34),
        ),
        const SizedBox(height: 14),
        const Text(
          'Akaunting',
          style: TextStyle(
            color: _textDark,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sign in to your account',
          style: TextStyle(color: _textSubtle, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required AuthCubit cubit,
    required bool isLoading,
    String? errorMessage,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Error banner ──────────────────────────────────────────────
            if (errorMessage != null) ...[
              _buildErrorBanner(errorMessage),
              const SizedBox(height: 20),
            ],

            // ── Email ─────────────────────────────────────────────────────
            BaseInput(
              label: 'Email Address',
              isRequired: true,
              placeholder: 'you@company.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prependIcon: Icons.email_outlined,
              disabled: isLoading,
            ),
            const SizedBox(height: 20),

            // ── Password ──────────────────────────────────────────────────
            BaseInput(
              label: 'Password',
              isRequired: true,
              placeholder: '••••••••',
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              prependIcon: Icons.lock_outline_rounded,
              appendIcon: _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              disabled: isLoading,
            ),
            // Visibility toggle — small interactive button below the field.
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                child: Text(
                  _obscurePassword ? 'Show password' : 'Hide password',
                  style: const TextStyle(color: _green, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Submit ────────────────────────────────────────────────────
            BaseButton(
              onPressed: isLoading ? null : () => _submit(cubit),
              type: ButtonType.primary,
              size: ButtonSize.lg,
              block: true,
              loading: isLoading,
              child: Text(isLoading ? 'Signing in…' : 'Sign In'),
            ),
            const SizedBox(height: 16),

            // ── Forgot password ───────────────────────────────────────────
            Center(
              child: BaseButton(
                onPressed: isLoading ? null : () {},
                type: ButtonType.primary,
                link: true,
                child: const Text('Forgot your password?'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        border: Border.all(color: const Color(0xFFFFCDD2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
