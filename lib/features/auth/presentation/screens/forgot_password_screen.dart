import 'package:alkhair_app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Forgot-password — support-mediated (ARCHITECTURE.md §6, phone/OTP removal):
/// accounts use synthetic, non-deliverable emails and donors have no real
/// email on file, so no self-service reset is possible. This screen only
/// directs the user to contact their charity admin or Al-Khair support;
/// actual resets happen out-of-band.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('نسيت كلمة المرور')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.support_agent, size: 48),
              const SizedBox(height: 16),
              Text(
                'لإعادة تعيين كلمة المرور، يرجى التواصل مع مسؤول الجمعية '
                'أو فريق دعم الخير.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(Routes.login),
                child: const Text('العودة لتسجيل الدخول'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
