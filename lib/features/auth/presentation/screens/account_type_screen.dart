import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/app_error_messages.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/auth_status_controller.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/registration_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Post-OTP account-type step (Fig 5.1) — collects the name and role. Creates
/// the `Users` doc; volunteers then continue to the extra step (SECURITY.md §1.3).
class AccountTypeScreen extends ConsumerStatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  ConsumerState<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends ConsumerState<AccountTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _choose(UserRole role) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final flow = ref.read(authControllerProvider);
    final uid = flow.signedInUid;
    final phone = flow.phone;
    if (uid == null || phone == null) return;

    setState(() => _submitting = true);
    final result = await ref.read(registrationControllerProvider.notifier).createAccount(
          uid: uid,
          name: _nameController.text.trim(),
          phone: phone,
          role: role,
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    result.match(
      (failure) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(arabicErrorMessage(failure)))),
      // Re-derive the stage; the router sends donors home and volunteers to the
      // extra step.
      (_) => ref.invalidate(authStatusControllerProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep authControllerProvider (autoDispose) alive while this screen is
    // mounted — it holds signedInUid/phone set during the OTP flow, and the
    // previous screen (OtpScreen) stops watching it once the router redirects
    // here, which would otherwise dispose it before _choose() can read it.
    ref.watch(authControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('نوع الحساب')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 16),
                Text('أكمل بياناتك', style: textTheme.headlineMedium),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      (value?.trim().isEmpty ?? true) ? 'يرجى إدخال الاسم' : null,
                ),
                const SizedBox(height: 32),
                Text('اختر نوع الحساب', style: textTheme.titleMedium),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _submitting ? null : () => _choose(UserRole.donor),
                  icon: const Icon(Icons.volunteer_activism),
                  label: const Text('متبرّع'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _submitting ? null : () => _choose(UserRole.volunteer),
                  icon: const Icon(Icons.directions_car),
                  label: const Text('متطوّع'),
                ),
                if (_submitting) ...[
                  const SizedBox(height: 24),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
