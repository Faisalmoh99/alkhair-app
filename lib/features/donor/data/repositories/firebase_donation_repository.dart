import 'package:alkhair_app/core/constants/app_constants.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/features/donor/domain/entities/app_notification.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report_draft.dart';
import 'package:alkhair_app/features/donor/domain/repositories/donation_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fpdart/fpdart.dart';

/// Firebase-concrete [DonationRepository]: the `createDonationReport` callable
/// (SECURITY.md §3) plus DonationReports/Notifications read streams. Raw
/// exceptions are translated into [Failure] at this boundary (SECURITY.md §7).
class FirebaseDonationRepository implements DonationRepository {
  FirebaseDonationRepository({
    required FirebaseFunctions functions,
    required FirebaseFirestore firestore,
  })  : _functions = functions,
        _db = firestore;

  final FirebaseFunctions _functions;
  final FirebaseFirestore _db;

  @override
  Future<Either<Failure, String>> submitReport(
    DonationReportDraft draft,
  ) async {
    try {
      final callable = _functions.httpsCallable('createDonationReport');
      final result = await callable.call<dynamic>(draft.toCallablePayload());
      // The platform channel returns Map<Object?, Object?>; rebuild it as a
      // typed map rather than casting, which throws at runtime.
      final data = Map<String, dynamic>.from(result.data as Map);
      return right(data['report_id'] as String);
    } on FirebaseFunctionsException catch (e) {
      return left(_mapFunctions(e));
    } on Exception catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Stream<List<DonationReport>> watchMyReports(String donorId) {
    return _db
        .collection(Collections.donationReports)
        .where('donor_id', isEqualTo: donorId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => DonationReport.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _db
        .collection(Collections.notifications)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => AppNotification.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<List<DonationReport>> watchOpenReports() {
    return _db
        .collection(Collections.donationReports)
        .where('status', isEqualTo: 'reported')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => DonationReport.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<List<DonationReport>> watchMyAssignments(String volunteerId) {
    return _db
        .collection(Collections.donationReports)
        .where('volunteer_id', isEqualTo: volunteerId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => DonationReport.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<DonationReport?> watchReport(String reportId) {
    return _db
        .collection(Collections.donationReports)
        .doc(reportId)
        .snapshots()
        .map(
          (snap) => snap.exists
              ? DonationReport.fromFirestore(snap.id, snap.data()!)
              : null,
        );
  }

  @override
  Future<Either<Failure, Unit>> acceptReport(
    String reportId,
    String volunteerId,
  ) async {
    final ref = _db.collection(Collections.donationReports).doc(reportId);
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final data = snap.data();
        if (data == null ||
            data['status'] != 'reported' ||
            data['volunteer_id'] != null) {
          throw const _TransactionConflict();
        }
        tx.update(ref, {'status': 'assigned', 'volunteer_id': volunteerId});
      });
      return right(unit);
    } on _TransactionConflict {
      return left(const Failure.conflict(reason: 'already_assigned'));
    } on FirebaseException catch (e) {
      return left(_mapFirestoreException(e));
    } on Exception catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmCollection(String reportId) =>
      _advanceStatus(reportId, from: 'assigned', to: 'collected');

  @override
  Future<Either<Failure, Unit>> confirmDelivery(String reportId) =>
      _advanceStatus(reportId, from: 'collected', to: 'delivered');

  // Shared implementation for the two sequential FR9 confirms: reads the
  // current status inside a transaction so a stale/duplicate tap (or a
  // second device) fails cleanly with ConflictFailure instead of silently
  // re-writing an already-advanced report.
  Future<Either<Failure, Unit>> _advanceStatus(
    String reportId, {
    required String from,
    required String to,
  }) async {
    final ref = _db.collection(Collections.donationReports).doc(reportId);
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (snap.data()?['status'] != from) {
          throw const _TransactionConflict();
        }
        tx.update(ref, {'status': to});
      });
      return right(unit);
    } on _TransactionConflict {
      return left(const Failure.conflict(reason: 'stale_status'));
    } on FirebaseException catch (e) {
      return left(_mapFirestoreException(e));
    } on Exception catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  // firestore.rules denies the update outright (permission-denied) when a
  // competing write already changed the document between this client's read
  // and its commit attempt — the transaction retries on Firestore's own
  // ABORTED conflicts, so a surviving permission-denied here means someone
  // else's write won the race, i.e. a conflict from the caller's point of view.
  Failure _mapFirestoreException(FirebaseException e) => switch (e.code) {
        'permission-denied' => const Failure.conflict(reason: 'already_assigned'),
        'unavailable' => const Failure.network(),
        _ => Failure.unknown(message: e.code),
      };

  Failure _mapFunctions(FirebaseFunctionsException e) {
    final details = e.details;
    final code = details is Map ? details['code'] as String? : null;
    return switch (code) {
      'RATE_LIMIT_EXCEEDED' => const Failure.rateLimit(),
      'VALIDATION_FAILED' =>
        Failure.validation(field: 'report', reason: e.message ?? e.code),
      _ => switch (e.code) {
          'permission-denied' => const Failure.permission(action: 'submit_report'),
          'unavailable' => const Failure.network(),
          _ => Failure.unknown(message: e.code),
        },
    };
  }
}

// Internal sentinel thrown inside a transaction body when the read shows the
// document is no longer in the state the caller expected (already claimed by
// another volunteer, or already advanced past the expected prior status).
// Never leaks past this file — callers only see [ConflictFailure].
class _TransactionConflict implements Exception {
  const _TransactionConflict();
}
