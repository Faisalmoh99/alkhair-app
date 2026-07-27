import 'package:alkhair_app/core/errors/app_error_messages.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:alkhair_app/core/utils/phone_number.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen 1 (Fig 5.1) — phone entry. Sends the OTP, then moves to the OTP screen.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final e164 = normalizeSaudiPhone(_phoneController.text);
      if (e164 == null) return;
      ref.read(authControllerProvider.notifier).requestOtp(e164);
    }
  }

  @override
  Widget build(BuildContext context) {
    // React to flow transitions: advance to OTP on send, surface errors.
    ref.listen(authControllerProvider, (previous, next) {
      if (next.phase == OtpPhase.otpSent && previous?.phase != OtpPhase.otpSent) {
        context.go(Routes.otp);
      } else if (next.phase == OtpPhase.error && next.errorCode != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(arabicErrorMessage(Failure.auth(code: next.errorCode!)))),
          );
      }
    });

    final state = ref.watch(authControllerProvider);
    final isBusy = state.phase == OtpPhase.requestingOtp;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                const SizedBox(height: 8),
                Text(
                  'أدخل رقم جوالك لإرسال رمز التحقق',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'رقم الجوال',
                    hintText: '+9665XXXXXXXX',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    final v = value ?? '';
                    if (v.trim().isEmpty) return 'يرجى إدخال رقم الجوال';
                    if (normalizeSaudiPhone(v) == null) {
                      return 'رقم الجوال غير صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isBusy ? null : _submit,
                  child: isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('إرسال رمز التحقق'),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
