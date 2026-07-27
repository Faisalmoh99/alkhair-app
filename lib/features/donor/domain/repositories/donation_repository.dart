import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/features/donor/domain/entities/app_notification.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report_draft.dart';
import 'package:fpdart/fpdart.dart';

/// Abstraction over the `createDonationReport` callable, the donor's
/// DonationReports/Notifications streams, and the volunteer accept/confirm
/// actions (Phase 4). The presentation layer depends only on this interface
/// (mocked in tests); the Firebase-concrete implementation lives in the data
/// layer.
abstract interface class DonationRepository {
  /// Calls the `createDonationReport` callable (SECURITY.md §3). Returns the
  /// new report id, or a [Failure] — [RateLimitFailure] on breach,
  /// [ValidationFailure] when the server re-validation rejects a field.
  Future<Either<Failure, String>> submitReport(DonationReportDraft draft);

  /// Reverse-chronological stream of the donor's own reports (Screen 3).
  Stream<List<DonationReport>> watchMyReports(String donorId);

  /// Reverse-chronological notifications feed for the signed-in user (FR5).
  /// Also drives Screen 4's alert list (FR6) — the dispatch trigger writes a
  /// `new_donation_alert` Notification for each nearby approved volunteer.
  Stream<List<AppNotification>> watchNotifications(String userId);

  /// Reverse-chronological stream of open (unassigned) reports (Screen 4,
  /// FR6/FR7).
  Stream<List<DonationReport>> watchOpenReports();

  /// Reverse-chronological stream of every report ever assigned to
  /// [volunteerId], any status — the volunteer home's "my active pickups"
  /// entry point filters this to `assigned`/`collected` client-side.
  Stream<List<DonationReport>> watchMyAssignments(String volunteerId);

  /// Live single-report stream (Screen 5's status gate for the sequential
  /// collect/deliver confirms, FR9).
  Stream<DonationReport?> watchReport(String reportId);

  /// Concurrency-safe accept (FR7): a client-side Firestore transaction
  /// guarded by firestore.rules' claim rule (`reported`→`assigned`, sets
  /// `volunteer_id`). Returns [ConflictFailure] when another volunteer
  /// already claimed the report first.
  Future<Either<Failure, Unit>> acceptReport(String reportId, String volunteerId);

  /// Sequential status advances (FR9), each gated by firestore.rules'
  /// assigned-volunteer-only advance rule. [ConflictFailure] means the report
  /// was no longer at the expected prior status when the write landed.
  Future<Either<Failure, Unit>> confirmCollection(String reportId);
  Future<Either<Failure, Unit>> confirmDelivery(String reportId);
}
