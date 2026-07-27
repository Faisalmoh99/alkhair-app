import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/app_error_messages.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/volunteer/presentation/controllers/location_refresh_controller.dart';
import 'package:alkhair_app/features/volunteer/presentation/controllers/volunteer_feed_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Approved-volunteer landing (Phase 4): entry points to Screen 4 (incoming
/// alerts, FR6/FR7) and Screen 5 (my active pickups, FR8/FR9). Also hosts the
/// manual location-refresh action (Phase 7 Part A1) — this screen is where an
/// approved volunteer with no active alert lands, but Figures 5.4/5.5 don't
/// document an idle state, so this button's placement is a UI assumption.
class VolunteerHomeScreen extends ConsumerWidget {
  const VolunteerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;

    ref.listen(locationRefreshControllerProvider, (previous, next) {
      final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
      switch (next.phase) {
        case LocationRefreshPhase.success:
          messenger.showSnackBar(const SnackBar(content: Text('تم تحديث موقعك.')));
        case LocationRefreshPhase.error:
          messenger.showSnackBar(
            SnackBar(content: Text(arabicErrorMessage(next.failure!))),
          );
        case LocationRefreshPhase.idle:
        case LocationRefreshPhase.refreshing:
          break;
      }
    });
    final refreshPhase = ref.watch(
      locationRefreshControllerProvider.select((s) => s.phase),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('المتطوّع'),
        actions: [
          IconButton(
            icon: refreshPhase == LocationRefreshPhase.refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            tooltip: 'تحديث موقعي',
            onPressed: uid == null || refreshPhase == LocationRefreshPhase.refreshing
                ? null
                : () => ref.read(locationRefreshControllerProvider.notifier).refresh(uid),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: () => context.go(Routes.volunteerAlert),
                icon: const Icon(Icons.notifications_active),
                label: const Text('التنبيهات الواردة'),
              ),
              const SizedBox(height: 16),
              Text(
                'عمليات الاستلام الجارية',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: uid == null
                    ? const SizedBox.shrink()
                    : _ActivePickups(volunteerId: uid),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivePickups extends ConsumerWidget {
  const _ActivePickups({required this.volunteerId});

  final String volunteerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(myAssignmentsProvider(volunteerId));

    return assignmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('تعذّر تحميل عمليات الاستلام.'),
      data: (reports) {
        final active = reports
            .where(
              (r) =>
                  r.status == DonationStatus.assigned ||
                  r.status == DonationStatus.collected,
            )
            .toList();
        if (active.isEmpty) {
          return const Text('لا توجد عمليات استلام جارية.');
        }
        return ListView.builder(
          itemCount: active.length,
          itemBuilder: (context, i) {
            final report = active[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text('الكمية: ${report.quantity}'),
                subtitle: Text(_statusLabel(report.status)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.go(Routes.volunteerNav, extra: report.id),
              ),
            );
          },
        );
      },
    );
  }
}

String _statusLabel(DonationStatus status) => switch (status) {
      DonationStatus.reported => 'مُسجَّل',
      DonationStatus.assigned => 'مُعيَّن',
      DonationStatus.collected => 'تم الاستلام',
      DonationStatus.delivered => 'تم التسليم',
      DonationStatus.expired => 'منتهي',
    };
