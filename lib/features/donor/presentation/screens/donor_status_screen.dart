import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/donor/domain/entities/app_notification.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:alkhair_app/features/donor/presentation/controllers/donor_feed_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Screen 3 (Fig 5.3, FR5) — status tracker for the donor's most recent
/// report, plus the reverse-chronological Notifications feed.
class DonorStatusScreen extends ConsumerWidget {
  const DonorStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('يرجى تسجيل الدخول')));
    }

    final reportsAsync = ref.watch(myReportsProvider(uid));
    final notificationsAsync = ref.watch(myNotificationsProvider(uid));

    return Scaffold(
      appBar: AppBar(
        // Reached via context.go() (not push) right after report submission,
        // which replaces the nav stack — no default back button appears, and
        // without an explicit way out a donor is stranded here after every
        // submission (found during the Phase 7 manual E2E). Mirrors the
        // home/sign-out action pattern on every other top-level screen.
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'الرئيسية',
          onPressed: () => context.go(Routes.donorHome),
        ),
        title: const Text('حالة البلاغات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('آخر بلاغ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            reportsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('تعذّر تحميل البلاغات.'),
              data: (reports) => reports.isEmpty
                  ? const Text('لا توجد بلاغات بعد.')
                  : _StatusTracker(report: reports.first),
            ),
            const Divider(height: 32),
            Text('الإشعارات', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('تعذّر تحميل الإشعارات.'),
              data: (notifications) => notifications.isEmpty
                  ? const Text('لا توجد إشعارات بعد.')
                  : Column(
                      children: [
                        for (final n in notifications)
                          _NotificationTile(notification: n),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTracker extends StatelessWidget {
  const _StatusTracker({required this.report});

  final DonationReport report;

  static const _steps = [
    DonationStatus.reported,
    DonationStatus.assigned,
    DonationStatus.collected,
    DonationStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    if (report.status == DonationStatus.expired) {
      return Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Text(statusLabel(DonationStatus.expired)),
        ],
      );
    }

    final currentIndex = _steps.indexOf(report.status);
    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          if (i > 0) const Expanded(child: Divider()),
          Column(
            children: [
              Icon(
                i <= currentIndex ? Icons.check_circle : Icons.circle_outlined,
                color: i <= currentIndex ? Colors.green : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                statusLabel(_steps[i]),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        notification.isRead
            ? Icons.notifications_none
            : Icons.notifications_active,
      ),
      title: Text(notification.message),
      subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(notification.createdAt)),
    );
  }
}

/// DonationStatus → Arabic label (TEST_PLAN.md Phase 3 Widget-2).
String statusLabel(DonationStatus status) => switch (status) {
      DonationStatus.reported => 'مُسجَّل',
      DonationStatus.assigned => 'مُعيَّن',
      DonationStatus.collected => 'تم الاستلام',
      DonationStatus.delivered => 'تم التسليم',
      DonationStatus.expired => 'منتهي',
    };
