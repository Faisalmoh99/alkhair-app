import 'package:alkhair_app/core/errors/app_error_messages.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:alkhair_app/features/auth/domain/entities/auth_stage.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/auth_status_controller.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/charities_controller.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/registration_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Volunteer extra registration step (SECURITY.md §1.3). ONE screen / route
/// family that renders BOTH the details form and — after submit — the pending
/// / revoked state.
///
/// FLAGGED ASSUMPTION (ARCHITECTURE.md §7): no documented screen among the 12
/// covers a volunteer's pending-approval state (Fig 5.4 is the alert screen for
/// already-approved volunteers). Per the precedent that this step is logically
/// part of Screen 1, the pending view is folded in here, not added as a new
/// screen.
class VolunteerExtraStepScreen extends ConsumerWidget {
  const VolunteerExtraStepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // See account_type_screen.dart: keep authControllerProvider (autoDispose)
    // alive across the registration chain so _submit() below can still read
    // signedInUid after the account-type screen unmounts.
    ref.watch(authControllerProvider);
    final stageAsync = ref.watch(authStatusControllerProvider);
    final stage = stageAsync.valueOrNull;

    final body = switch (stage) {
      AuthStage.volunteerPending => const _StatusView(
          icon: Icons.hourglass_top,
          color: AppColors.gold,
          title: 'طلبك قيد المراجعة',
          message: 'سيتم إشعارك عند اعتماد حسابك من قبل الجمعية.',
        ),
      AuthStage.volunteerRevoked => const _StatusView(
          icon: Icons.block,
          color: AppColors.error,
          title: 'تم إلغاء اعتماد حسابك',
          message: 'يرجى التواصل مع الجمعية لمزيد من المعلومات.',
        ),
      _ => const _VolunteerDetailsForm(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('بيانات المتطوّع'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }
}

class _VolunteerDetailsForm extends ConsumerStatefulWidget {
  const _VolunteerDetailsForm();

  @override
  ConsumerState<_VolunteerDetailsForm> createState() => _VolunteerDetailsFormState();
}

class _VolunteerDetailsFormState extends ConsumerState<_VolunteerDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _vehicleController = TextEditingController();
  String? _charityId;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_charityId == null) return;
    final uid = ref.read(authControllerProvider).signedInUid;
    if (uid == null) return;

    setState(() => _submitting = true);
    final result = await ref.read(registrationControllerProvider.notifier).completeVolunteer(
          uid: uid,
          email: _emailController.text.trim(),
          vehicleType: _vehicleController.text.trim(),
          charityId: _charityId!,
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    result.match(
      (failure) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(arabicErrorMessage(failure)))),
      (_) => ref.invalidate(authStatusControllerProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final charitiesAsync = ref.watch(charitiesProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 8),
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
            // FLAGGED ASSUMPTION: vehicle_type has no enumerated set in the docs,
            // so this is a free-text field rather than invented enum values.
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
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('إرسال الطلب'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: color),
            const SizedBox(height: 24),
            Text(title, textAlign: TextAlign.center, style: textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
