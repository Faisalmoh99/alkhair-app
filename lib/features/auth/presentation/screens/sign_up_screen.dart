import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/app_error_messages.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/core/utils/phone_number.dart';
import 'package:alkhair_app/features/auth/domain/entities/sign_up_data.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/charities_controller.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/registration_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Sign-up — one form (ARCHITECTURE.md §6): all fields are collected here and
/// the account is created directly on submit. Phone is a plain data field
/// (Saudi-format validated only, never verified) — no OTP.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _vehicleController = TextEditingController();
  UserRole _role = UserRole.donor;
  String? _charityId;
  bool _isBusy = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_role == UserRole.volunteer && _charityId == null) return;
    final e164 = normalizeSaudiPhone(_phoneController.text);
    if (e164 == null) return;

    setState(() => _isBusy = true);
    final result =
        await ref.read(registrationControllerProvider.notifier).createFromSignUp(
              SignUpData(
                username: _usernameController.text.trim(),
                password: _passwordController.text,
                name: _nameController.text.trim(),
                phone: e164,
                role: _role,
                email: _role == UserRole.volunteer ? _emailController.text.trim() : null,
                vehicleType: _role == UserRole.volunteer ? _vehicleController.text.trim() : null,
                charityId: _role == UserRole.volunteer ? _charityId : null,
              ),
            );
    if (!mounted) return;
    setState(() => _isBusy = false);
    result.match(
      (failure) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(arabicErrorMessage(failure))),
          );
      },
      // authStatusControllerProvider is invalidated inside
      // RegistrationController itself on success; the router's guard admits
      // the user without any explicit navigation here.
      (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isBusy;
    final textTheme = Theme.of(context).textTheme;
    final charitiesAsync = ref.watch(charitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('اختر نوع الحساب', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(
                      value: UserRole.donor,
                      label: Text('متبرّع'),
                      icon: Icon(Icons.volunteer_activism),
                    ),
                    ButtonSegment(
                      value: UserRole.volunteer,
                      label: Text('متطوّع'),
                      icon: Icon(Icons.directions_car),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (selection) => setState(() => _role = selection.first),
                ),
                const SizedBox(height: 24),
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
                  validator: (value) {
                    if ((value?.length ?? 0) < 6) {
                      return arabicErrorMessage(const Failure.auth(code: 'weak-password'));
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) =>
                      (value?.trim().isEmpty ?? true) ? 'يرجى إدخال الاسم' : null,
                ),
                const SizedBox(height: 16),
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
                if (_role == UserRole.volunteer) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return 'يرجى إدخال البريد الإلكتروني';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                        return 'صيغة البريد الإلكتروني غير صحيحة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehicleController,
                    decoration: const InputDecoration(
                      labelText: 'نوع المركبة',
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                    validator: (value) =>
                        (value?.trim().isEmpty ?? true) ? 'يرجى إدخال نوع المركبة' : null,
                  ),
                  const SizedBox(height: 16),
                  charitiesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('تعذّر تحميل قائمة الجمعيات.'),
                    data: (charities) => DropdownButtonFormField<String>(
                      initialValue: _charityId,
                      decoration: const InputDecoration(
                        labelText: 'الجمعية',
                        prefixIcon: Icon(Icons.apartment),
                      ),
                      items: [
                        for (final c in charities)
                          DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ],
                      onChanged: (value) => setState(() => _charityId = value),
                      validator: (value) => value == null ? 'يرجى اختيار الجمعية' : null,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: isBusy ? null : _submit,
                  child: isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('إنشاء الحساب'),
                ),
                TextButton(
                  onPressed: () => context.go(Routes.login),
                  child: const Text('لديك حساب بالفعل؟ تسجيل الدخول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
