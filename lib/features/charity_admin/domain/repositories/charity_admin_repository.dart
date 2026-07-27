import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/approved_volunteer.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/generated_report.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/pending_volunteer.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:fpdart/fpdart.dart';

/// Abstraction over the charity-admin reads (Screen 6 dashboard, Screen 7
/// approval list) and the volunteer approval write (FR10). The presentation
/// layer depends only on this interface (mocked in tests); the
/// Firebase-concrete implementation lives in the data layer.
abstract interface class CharityAdminRepository {
  /// All `DonationReports`, reverse-chronological (Screen 6, FR11). Single-
  /// charity MVP: reads every report, not scoped by `charity_id` (that field
  /// doesn't exist on DonationReports yet — see Phase 5 plan's scoping note).
  Stream<List<DonationReport>> watchAllReports();

  /// Volunteers with `approval_status == 'pending'`, joined with their
  /// `Users` doc for name/phone (Screen 7, FR10).
  Stream<List<PendingVolunteer>> watchPendingVolunteers();

  /// Approves or revokes a volunteer (FR10). Authorized by firestore.rules'
  /// same-charity admin update path — a direct client write, unlike report
  /// creation which must go through a callable.
  Future<Either<Failure, Unit>> setApproval(String uid, ApprovalStatus status);

  /// Volunteers with `approval_status == 'approved'`, joined with their
  /// `Users` doc for display name (Screen 11, FR12).
  Stream<List<ApprovedVolunteer>> watchApprovedVolunteers();

  /// Persisted `Reports` documents (Table 4.8) for [charityId], reverse-
  /// chronological (Screen 8, FR12). Written only via [generateReport]; rules
  /// scope reads to the same-charity admin — the `where` filter here is
  /// mandatory, not optional: firestore.rules' `Reports` read rule requires
  /// `resource.data.charity_id` to match on every document with no
  /// unconditional admin branch, and Firestore rejects an entire *list* query
  /// outright (not just individual documents) when it can't statically prove
  /// that holds for every possible result. Found via a real bug where this
  /// filter was missing (Phase 7 follow-up).
  Stream<List<GeneratedReport>> watchGeneratedReports(String charityId);

  /// Generates and persists a `Reports` document for [reportType] over
  /// [periodStart, periodEnd) via the server-only `generateReport` callable
  /// (Screen 12 export, FR12) — mirrors report creation's callable-only
  /// write path, since firestore.rules denies direct client writes on
  /// `Reports`.
  Future<Either<Failure, GeneratedReport>> generateReport({
    required ReportType reportType,
    required DateTime periodStart,
    required DateTime periodEnd,
  });
}
