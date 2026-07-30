import 'package:alkhair_app/core/errors/app_error_messages.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Login — username + password only (ARCHITECTURE.md §6). Phone is a plain,
/// unverified data field; it plays no role in authentication.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _errorCode;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _errorCode = null;
    });
    final result = await ref.read(authRepositoryProvider).signInWithUsernamePassword(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    result.match(
      (failure) => setState(
        () => _errorCode = switch (failure) {
          AuthFailure(:final code) => code,
          _ => 'unknown',
        },
      ),
      // The router redirects to the right home once authStateChanges emits.
      (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      Image.asset('assets/images/logo_icon.png', width: 96, height: 96),
                      const SizedBox(height: 24),
                      Text(
                        'تسجيل الدخول',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(color: AppColors.primaryNavy),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم المستخدم',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                            (value?.trim().isEmpty ?? true) ? 'يرجى إدخال اسم المستخدم' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) =>
                            (value?.isEmpty ?? true) ? 'يرجى إدخال كلمة المرور' : null,
                      ),
                      if (_errorCode != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          arabicErrorMessage(Failure.auth(code: _errorCode!)),
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('تسجيل الدخول'),
                      ),
                      TextButton(
                        onPressed: () => context.go(Routes.forgotPassword),
                        child: const Text('نسيت كلمة المرور؟'),
                      ),
                      TextButton(
                        onPressed: () => context.go(Routes.signUp),
                        child: const Text('ليس لديك حساب؟ إنشاء حساب جديد'),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
