import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:alkhair_app/features/auth/domain/entities/auth_stage.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/auth_status_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Volunteer pending/revoked status view. The volunteer details form (email,
/// vehicle, charity) moved to the sign-up form (username+password migration,
/// ARCHITECTURE.md §6) — the `Volunteers` sub-doc is now created at sign-up,
/// not here. This screen only ever shows the post-login pending/revoked
/// state (SECURITY.md §1.3).
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
    final stageAsync = ref.watch(authStatusControllerProvider);
    final stage = stageAsync.valueOrNull;

    final body = switch (stage) {
      AuthStage.volunteerRevoked => const _StatusView(
          icon: Icons.block,
          color: AppColors.error,
          title: 'تم إلغاء اعتماد حسابك',
          message: 'يرجى التواصل مع الجمعية لمزيد من المعلومات.',
        ),
      // volunteerNeedsDetails is unreachable in practice — the Volunteers doc
      // is now created at sign-up — kept as a defensive fallback only.
      _ => const _StatusView(
          icon: Icons.hourglass_top,
          color: AppColors.gold,
          title: 'طلبك قيد المراجعة',
          message: 'سيتم إشعارك عند اعتماد حسابك من قبل الجمعية.',
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('حالة الحساب'),
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
