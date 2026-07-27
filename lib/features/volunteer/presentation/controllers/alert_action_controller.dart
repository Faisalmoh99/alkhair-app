import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'alert_action_controller.g.dart';

/// Screen 4's accept lifecycle (FR7). Decline is a purely local dismissal —
/// it never reaches this controller, since it performs no write (see
/// firestore.rules' DonationReports "decline leaves the report open" case).
enum AlertActionPhase { idle, accepting, success, alreadyTaken, error }

class AlertActionState {
  const AlertActionState({
    this.phase = AlertActionPhase.idle,
    this.failure,
    this.reportId,
  });

  final AlertActionPhase phase;
  final Failure? failure;
  final String? reportId;

  AlertActionState copyWith({
    AlertActionPhase? phase,
    Failure? failure,
    String? reportId,
    bool clearFailure = false,
  }) {
    return AlertActionState(
      phase: phase ?? this.phase,
      failure: clearFailure ? null : (failure ?? this.failure),
      reportId: reportId ?? this.reportId,
    );
  }
}

/// Drives Screen 4's accept action: a concurrency-safe claim via the
/// repository's client transaction (SECURITY.md-style authorization, guarded
/// by firestore.rules). [AlertActionPhase.alreadyTaken] means another
/// volunteer claimed the report first — the caller should drop the card
/// (the open-reports stream will do so on its own once the write lands).
@riverpod
class AlertActionController extends _$AlertActionController {
  @override
  AlertActionState build() => const AlertActionState();

  Future<void> accept({
    required String reportId,
    required String volunteerId,
  }) async {
    state = state.copyWith(phase: AlertActionPhase.accepting, clearFailure: true);
    final result = await ref
        .read(donationRepositoryProvider)
        .acceptReport(reportId, volunteerId);

    state = result.fold(
      (failure) => switch (failure) {
        ConflictFailure() => state.copyWith(
            phase: AlertActionPhase.alreadyTaken,
            failure: failure,
          ),
        _ => state.copyWith(phase: AlertActionPhase.error, failure: failure),
      },
      (_) => state.copyWith(
        phase: AlertActionPhase.success,
        reportId: reportId,
        clearFailure: true,
      ),
    );
  }

  void reset() => state = const AlertActionState();
}
