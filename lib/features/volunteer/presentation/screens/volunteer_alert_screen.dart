import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/app_error_messages.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/donor/data/services/location_service.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:alkhair_app/features/volunteer/presentation/controllers/alert_action_controller.dart';
import 'package:alkhair_app/features/volunteer/presentation/controllers/volunteer_feed_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

/// Screen 4 (Fig 5.4, FR6/FR7) — volunteer incoming-alert screen. Lists open
/// (unassigned) reports as summary cards (food category, quantity, distance,
/// time-since-posted) with accept/decline actions. FCM push is deferred (no
/// `fcm_token` field in the data dictionary yet); this screen is driven by a
/// live Firestore stream of open reports instead, which satisfies FR6's
/// real-time intent while the app is foregrounded.
class VolunteerAlertScreen extends ConsumerStatefulWidget {
  const VolunteerAlertScreen({super.key});

  @override
  ConsumerState<VolunteerAlertScreen> createState() =>
      _VolunteerAlertScreenState();
}

class _VolunteerAlertScreenState extends ConsumerState<VolunteerAlertScreen> {
  // Decline is a local-only dismissal (firestore.rules has no write path for
  // it — see the Phase 4 rules tests); this session-local set just hides the
  // card until it naturally drops out of the open-reports stream.
  final _declinedIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;

    ref.listen(alertActionControllerProvider, (previous, next) {
      if (next.phase == AlertActionPhase.success && next.reportId != null) {
        final controller = ref.read(alertActionControllerProvider.notifier);
        final reportId = next.reportId!;
        controller.reset();
        context.go(Routes.volunteerNav, extra: reportId);
      } else if (next.phase == AlertActionPhase.alreadyTaken) {
        ref.read(alertActionControllerProvider.notifier).reset();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('تم تعيين هذا البلاغ لمتطوع آخر للتو.')),
          );
      } else if (next.phase == AlertActionPhase.error && next.failure != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(arabicErrorMessage(next.failure!))));
      }
    });

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('يرجى تسجيل الدخول')));
    }

    final reportsAsync = ref.watch(openReportsProvider);
    final locationAsync = ref.watch(volunteerLocationProvider);
    final actionState = ref.watch(alertActionControllerProvider);
    final isBusy = actionState.phase == AlertActionPhase.accepting;

    return Scaffold(
      appBar: AppBar(title: const Text('التنبيهات الواردة')),
      body: SafeArea(
        child: reportsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('تعذّر تحميل البلاغات.')),
          data: (reports) {
            final visible =
                reports.where((r) => !_declinedIds.contains(r.id)).toList();
            if (visible.isEmpty) {
              return const Center(child: Text('لا توجد بلاغات قريبة حالياً.'));
            }
            final position = locationAsync.asData?.value;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visible.length,
              itemBuilder: (context, i) {
                final report = visible[i];
                return _AlertCard(
                  report: report,
                  volunteerPosition: position,
                  isBusy: isBusy,
                  onAccept: () => ref
                      .read(alertActionControllerProvider.notifier)
                      .accept(reportId: report.id, volunteerId: uid),
                  onDecline: () =>
                      setState(() => _declinedIds.add(report.id)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.report,
    required this.volunteerPosition,
    required this.isBusy,
    required this.onAccept,
    required this.onDecline,
  });

  final DonationReport report;
  final GeoPosition? volunteerPosition;
  final bool isBusy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant),
                const SizedBox(width: 8),
                Text(
                  _categoryLabel(report.foodCategory),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('الكمية: ${report.quantity}'),
            const SizedBox(height: 4),
            Text('المسافة: ${_distanceLabel(volunteerPosition, report)}'),
            const SizedBox(height: 4),
            Text('منذ: ${_timeSinceLabel(report.createdAt)}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isBusy ? null : onDecline,
                    child: const Text('رفض'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isBusy ? null : onAccept,
                    child: isBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('قبول'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _categoryLabel(FoodCategory c) => switch (c) {
      FoodCategory.mainMeals => 'وجبات رئيسية',
      FoodCategory.bakedGoods => 'مخبوزات',
      FoodCategory.fruitsAndVegetables => 'فواكه وخضروات',
      FoodCategory.canned => 'معلبات',
      FoodCategory.other => 'أخرى',
    };

String _distanceLabel(GeoPosition? volunteerPosition, DonationReport report) {
  if (volunteerPosition == null) {
    return 'غير معروفة';
  }
  final meters = Geolocator.distanceBetween(
    volunteerPosition.latitude,
    volunteerPosition.longitude,
    report.latitude,
    report.longitude,
  );
  return '${(meters / 1000).toStringAsFixed(1)} كم';
}

String _timeSinceLabel(DateTime createdAt) {
  final elapsed = DateTime.now().difference(createdAt);
  if (elapsed.inMinutes < 1) return 'الآن';
  if (elapsed.inHours < 1) return 'قبل ${elapsed.inMinutes} دقيقة';
  if (elapsed.inDays < 1) return 'قبل ${elapsed.inHours} ساعة';
  return 'قبل ${elapsed.inDays} يوم';
}
