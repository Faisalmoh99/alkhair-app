import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/donor/data/services/location_service.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'volunteer_feed_controllers.g.dart';

/// Reverse-chronological stream of open (unassigned) reports (Screen 4,
/// FR6/FR7).
@riverpod
Stream<List<DonationReport>> openReports(OpenReportsRef ref) {
  return ref.watch(donationRepositoryProvider).watchOpenReports();
}

/// Every report ever assigned to [volunteerId] — the volunteer home's "my
/// active pickups" entry point filters this to assigned/collected.
@riverpod
Stream<List<DonationReport>> myAssignments(
  MyAssignmentsRef ref,
  String volunteerId,
) {
  return ref.watch(donationRepositoryProvider).watchMyAssignments(volunteerId);
}

/// Live single-report stream backing Screen 5's status gate (FR9).
@riverpod
Stream<DonationReport?> watchedReport(WatchedReportRef ref, String reportId) {
  return ref.watch(donationRepositoryProvider).watchReport(reportId);
}

/// The volunteer's current GPS fix, used for the distance shown on Screen 4's
/// alert cards and Screen 5's navigation header. `null` on failure (permission
/// denied / service disabled) rather than propagating a failure — the
/// screens degrade to hiding the distance rather than blocking the list.
@riverpod
Future<GeoPosition?> volunteerLocation(VolunteerLocationRef ref) async {
  final result = await ref.watch(locationServiceProvider).getCurrentLocation();
  return result.match((_) => null, (position) => position);
}
