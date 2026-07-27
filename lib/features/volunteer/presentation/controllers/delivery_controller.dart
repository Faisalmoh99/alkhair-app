import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delivery_controller.g.dart';

/// Screen 5's sequential confirm lifecycle (FR9). [DeliveryPhase.collected]
/// and [DeliveryPhase.delivered] are terminal-per-step markers the screen
/// uses to show a brief success state before the live report stream (the
/// source of truth for button gating) reflects the new status.
enum DeliveryPhase { idle, confirming, collected, delivered, error }

class DeliveryState {
  const DeliveryState({this.phase = DeliveryPhase.idle, this.failure});

  final DeliveryPhase phase;
  final Failure? failure;

  DeliveryState copyWith({
    DeliveryPhase? phase,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return DeliveryState(
      phase: phase ?? this.phase,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

/// Drives Screen 5's two sequential confirm actions. Each call is a guarded
/// transaction (firestore.rules' assigned-volunteer-only advance rule); a
/// stale/duplicate tap surfaces as [ConflictFailure] rather than corrupting
/// the status sequence.
@riverpod
class DeliveryController extends _$DeliveryController {
  @override
  DeliveryState build() => const DeliveryState();

  Future<void> confirmCollection(String reportId) async {
    state = state.copyWith(phase: DeliveryPhase.confirming, clearFailure: true);
    final result =
        await ref.read(donationRepositoryProvider).confirmCollection(reportId);
    state = result.fold(
      (failure) => state.copyWith(phase: DeliveryPhase.error, failure: failure),
      (_) => state.copyWith(phase: DeliveryPhase.collected, clearFailure: true),
    );
  }

  Future<void> confirmDelivery(String reportId) async {
    state = state.copyWith(phase: DeliveryPhase.confirming, clearFailure: true);
    final result =
        await ref.read(donationRepositoryProvider).confirmDelivery(reportId);
    state = result.fold(
      (failure) => state.copyWith(phase: DeliveryPhase.error, failure: failure),
      (_) => state.copyWith(phase: DeliveryPhase.delivered, clearFailure: true),
    );
  }

  void reset() => state = const DeliveryState();
}
