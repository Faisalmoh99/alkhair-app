import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/donor/domain/entities/app_notification.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'donor_feed_controllers.g.dart';

/// Reverse-chronological stream of the given donor's own reports (Screen 3).
@riverpod
Stream<List<DonationReport>> myReports(MyReportsRef ref, String donorId) {
  return ref.watch(donationRepositoryProvider).watchMyReports(donorId);
}

/// Reverse-chronological notifications feed for the given user (FR5).
@riverpod
Stream<List<AppNotification>> myNotifications(
  MyNotificationsRef ref,
  String userId,
) {
  return ref.watch(donationRepositoryProvider).watchNotifications(userId);
}
