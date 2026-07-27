import 'package:alkhair_app/core/constants/app_constants.dart';
import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/approved_volunteer.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/generated_report.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/pending_volunteer.dart';
import 'package:alkhair_app/features/charity_admin/domain/repositories/charity_admin_repository.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fpdart/fpdart.dart';

/// Firebase-concrete [CharityAdminRepository]: DonationReports/Volunteers
/// read streams plus the approval-status write. Raw exceptions are translated
/// into [Failure] at this boundary (SECURITY.md §7).
class FirebaseCharityAdminRepository implements CharityAdminRepository {
  FirebaseCharityAdminRepository({
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  })  : _db = firestore,
        _functions = functions;

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  @override
  Stream<List<DonationReport>> watchAllReports() {
    return _db
        .collection(Collections.donationReports)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => DonationReport.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<List<PendingVolunteer>> watchPendingVolunteers() {
    return _db
        .collection(Collections.volunteers)
        .where(
          'approval_status',
          isEqualTo: ApprovalStatus.pending.firestoreValue,
        )
        .snapshots()
        .asyncMap((snap) async {
      return Future.wait(
        snap.docs.map((d) async {
          final data = d.data();
          final userDoc =
              await _db.collection(Collections.users).doc(d.id).get();
          final userData = userDoc.data();
          return PendingVolunteer(
            uid: d.id,
            name: (userData?['name'] as String?) ?? '',
            phone: (userData?['phone'] as String?) ?? '',
            vehicleType: data['vehicle_type'] as String,
            approvalStatus:
                ApprovalStatus.fromFirestore(data['approval_status'] as String),
            charityId: data['charity_id'] as String,
          );
        }),
      );
    });
  }

  @override
  Future<Either<Failure, Unit>> setApproval(
    String uid,
    ApprovalStatus status,
  ) async {
    try {
      await _db.collection(Collections.volunteers).doc(uid).update({
        'approval_status': status.firestoreValue,
      });
      return right(unit);
    } on FirebaseException catch (e) {
      return left(_mapFirestore(e));
    }
  }

  Failure _mapFirestore(FirebaseException e) => switch (e.code) {
        'permission-denied' => const Failure.permission(action: 'set_approval'),
        'unavailable' => const Failure.network(),
        _ => Failure.unknown(message: e.code),
      };

  @override
  Stream<List<ApprovedVolunteer>> watchApprovedVolunteers() {
    return _db
        .collection(Collections.volunteers)
        .where(
          'approval_status',
          isEqualTo: ApprovalStatus.approved.firestoreValue,
        )
        .snapshots()
        .asyncMap((snap) async {
      return Future.wait(
        snap.docs.map((d) async {
          final userDoc =
              await _db.collection(Collections.users).doc(d.id).get();
          return ApprovedVolunteer(
            uid: d.id,
            name: (userDoc.data()?['name'] as String?) ?? '',
          );
        }),
      );
    });
  }

  @override
  Stream<List<GeneratedReport>> watchGeneratedReports(String charityId) {
    return _db
        .collection(Collections.reports)
        .where('charity_id', isEqualTo: charityId)
        .orderBy('generated_at', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => GeneratedReport.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<Either<Failure, GeneratedReport>> generateReport({
    required ReportType reportType,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateReport');
      final result = await callable.call<dynamic>({
        'report_type': reportType.firestoreValue,
        'period_start': periodStart.millisecondsSinceEpoch,
        'period_end': periodEnd.millisecondsSinceEpoch,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      return right(
        GeneratedReport(
          id: data['report_id'] as String,
          charityId: data['charity_id'] as String,
          generatedBy: data['generated_by'] as String,
          reportType: ReportType.fromFirestore(data['report_type'] as String),
          periodStart:
              DateTime.fromMillisecondsSinceEpoch(data['period_start'] as int),
          periodEnd:
              DateTime.fromMillisecondsSinceEpoch(data['period_end'] as int),
          totalDonations: data['total_donations'] as int,
          totalQuantity: data['total_quantity'] as num,
          generatedAt:
              DateTime.fromMillisecondsSinceEpoch(data['generated_at'] as int),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      return left(_mapFunctions(e));
    } on Exception catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  Failure _mapFunctions(FirebaseFunctionsException e) => switch (e.code) {
        'permission-denied' =>
          const Failure.permission(action: 'generate_report'),
        'unavailable' => const Failure.network(),
        _ => Failure.unknown(message: e.code),
      };
}
