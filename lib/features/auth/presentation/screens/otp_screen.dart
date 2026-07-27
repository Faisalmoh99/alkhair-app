import 'package:alkhair_app/core/errors/app_error_messages.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OTP code entry — this is the masked "password" field shown in Fig 5.1,
/// implemented as the verification code per SECURITY.md §1.1. On success the
/// router guard takes over routing (sign-in flips the auth stage).
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verify() {
    final code = _codeController.text.trim();
    if (code.length >= 4) {
      ref.read(authControllerProvider.notifier).confirmOtp(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next.errorCode != null && next.errorCode != previous?.errorCode) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(arabicErrorMessage(Failure.auth(code: next.errorCode!)))),
          );
      }
    });

    final state = ref.watch(authControllerProvider);
    final isBusy = state.phase == OtpPhase.verifying;
    final isLocked = state.phase == OtpPhase.locked;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('رمز التحقق')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'أدخل رمز التحقق المرسل إلى',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              Text(
                state.phone ?? '',
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: textTheme.titleMedium?.copyWith(color: AppColors.primaryNavy),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                obscureText: true,
                enabled: !isLocked,
                maxLength: 6,
                style: textTheme.headlineMedium,
                decoration: const InputDecoration(counterText: ''),
              ),
              const SizedBox(height: 16),
              if (isLocked)
                Text(
                  'تم إيقاف المحاولات مؤقتاً. يرجى طلب رمز جديد بعد قليل.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: (isBusy || isLocked) ? null : _verify,
                child: isBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('تحقق'),
              ),
              TextButton(
                onPressed: () => ref.read(authControllerProvider.notifier).reset(),
                child: const Text('تغيير رقم الجوال'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
