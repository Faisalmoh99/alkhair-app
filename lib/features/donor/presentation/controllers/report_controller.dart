import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report_draft.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'report_controller.g.dart';

/// Screen 2's submit lifecycle (FR2/FR3/FR4).
enum ReportSubmitPhase { idle, capturingLocation, submitting, success, error }

/// Immutable snapshot of the submit flow.
class ReportSubmitState {
  const ReportSubmitState({
    this.phase = ReportSubmitPhase.idle,
    this.failure,
    this.reportId,
  });

  final ReportSubmitPhase phase;
  final Failure? failure;
  final String? reportId;

  ReportSubmitState copyWith({
    ReportSubmitPhase? phase,
    Failure? failure,
    String? reportId,
    bool clearFailure = false,
  }) {
    return ReportSubmitState(
      phase: phase ?? this.phase,
      failure: clearFailure ? null : (failure ?? this.failure),
      reportId: reportId ?? this.reportId,
    );
  }
}

/// Drives Screen 2's submit flow: captures GPS (FR3) then calls the
/// `createDonationReport` callable via the donation repository.
@riverpod
class ReportController extends _$ReportController {
  @override
  ReportSubmitState build() => const ReportSubmitState();

  Future<void> submit({
    required FoodCategory foodCategory,
    required num quantity,
    required DateTime readinessTime,
    required bool safetyConfirmed,
  }) async {
    state = state.copyWith(
      phase: ReportSubmitPhase.capturingLocation,
      clearFailure: true,
    );
    final locationResult =
        await ref.read(locationServiceProvider).getCurrentLocation();

    await locationResult.match(
      (failure) async {
        state = state.copyWith(phase: ReportSubmitPhase.error, failure: failure);
      },
      (position) async {
        state = state.copyWith(phase: ReportSubmitPhase.submitting);
        final draft = DonationReportDraft(
          foodCategory: foodCategory,
          quantity: quantity,
          readinessTime: readinessTime,
          latitude: position.latitude,
          longitude: position.longitude,
          safetyConfirmed: safetyConfirmed,
        );
        final result =
            await ref.read(donationRepositoryProvider).submitReport(draft);
        state = result.fold(
          (failure) =>
              state.copyWith(phase: ReportSubmitPhase.error, failure: failure),
          (reportId) => state.copyWith(
            phase: ReportSubmitPhase.success,
            reportId: reportId,
            clearFailure: true,
          ),
        );
      },
    );
  }

  void reset() => state = const ReportSubmitState();
}
