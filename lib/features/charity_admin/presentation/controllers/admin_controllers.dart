import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/dashboard_stats.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/pending_volunteer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_controllers.g.dart';

/// Screen 6's aggregates (FR11), derived client-side from the DonationReports
/// stream (see [computeDashboardStats]).
@riverpod
Stream<DashboardStats> dashboardStats(DashboardStatsRef ref) {
  return ref
      .watch(charityAdminRepositoryProvider)
      .watchAllReports()
      .map(computeDashboardStats);
}

/// Resolves the signed-in charity admin's own `charity_id` (Table 4.4) via
/// `CharityAdmins.charity_id`. Shared by [currentCharityName] and any query
/// that must filter on the admin's own charity to satisfy firestore.rules
/// (e.g. `Reports` — see `watchGeneratedReports`, Phase 7 follow-up).
@riverpod
Future<String?> currentCharityId(CurrentCharityIdRef ref) async {
  final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
  if (uid == null) return null;

  final repo = ref.watch(authRepositoryProvider);
  final profile = await repo.loadProfile(uid);
  return profile.fold((_) => null, (user) => user?.charityId);
}

/// Resolves the signed-in charity admin's own charity name (Table 4.5).
/// Single source of truth for both the dashboard header (Screen 6) and the
/// PDF export header (Screen 12, Phase 7 Part A2) — null while unresolved or
/// if no match is found; callers fall back to a neutral label, never a
/// hardcoded name.
@riverpod
Future<String?> currentCharityName(CurrentCharityNameRef ref) async {
  final charityId = await ref.watch(currentCharityIdProvider.future);
  if (charityId == null) return null;

  final repo = ref.watch(authRepositoryProvider);
  final charities = await repo.fetchCharities();
  return charities.fold((_) => null, (list) {
    for (final charity in list) {
      if (charity.id == charityId) return charity.name;
    }
    return null;
  });
}

/// Screen 7's pending-approval list (FR10).
@riverpod
Stream<List<PendingVolunteer>> pendingVolunteers(PendingVolunteersRef ref) {
  return ref.watch(charityAdminRepositoryProvider).watchPendingVolunteers();
}

enum ApprovalActionPhase { idle, submitting, success, error }

class ApprovalActionState {
  const ApprovalActionState({
    this.phase = ApprovalActionPhase.idle,
    this.failure,
    this.targetUid,
  });

  final ApprovalActionPhase phase;
  final Failure? failure;
  final String? targetUid;

  ApprovalActionState copyWith({
    ApprovalActionPhase? phase,
    Failure? failure,
    String? targetUid,
    bool clearFailure = false,
  }) {
    return ApprovalActionState(
      phase: phase ?? this.phase,
      failure: clearFailure ? null : (failure ?? this.failure),
      targetUid: targetUid ?? this.targetUid,
    );
  }
}

/// Drives Screen 7's approve/reject actions (FR10): a direct client write
/// authorized by firestore.rules' same-charity admin update path.
@riverpod
class ApprovalActionController extends _$ApprovalActionController {
  @override
  ApprovalActionState build() => const ApprovalActionState();

  Future<void> setApproval(String uid, ApprovalStatus status) async {
    state = state.copyWith(
      phase: ApprovalActionPhase.submitting,
      targetUid: uid,
      clearFailure: true,
    );
    final result =
        await ref.read(charityAdminRepositoryProvider).setApproval(uid, status);

    state = result.fold(
      (failure) =>
          state.copyWith(phase: ApprovalActionPhase.error, failure: failure),
      (_) => state.copyWith(
        phase: ApprovalActionPhase.success,
        clearFailure: true,
      ),
    );
  }

  void reset() => state = const ApprovalActionState();
}
