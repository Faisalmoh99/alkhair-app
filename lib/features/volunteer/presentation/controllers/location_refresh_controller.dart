import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_refresh_controller.g.dart';

/// Manual "تحديث موقعي" action on the volunteer home screen (Phase 7 Part
/// A1). Narrow scope by design: on-demand refresh only, no background
/// tracking or periodic auto-refresh.
enum LocationRefreshPhase { idle, refreshing, success, error }

class LocationRefreshState {
  const LocationRefreshState({
    this.phase = LocationRefreshPhase.idle,
    this.failure,
  });

  final LocationRefreshPhase phase;
  final Failure? failure;

  LocationRefreshState copyWith({
    LocationRefreshPhase? phase,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return LocationRefreshState(
      phase: phase ?? this.phase,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

@riverpod
class LocationRefreshController extends _$LocationRefreshController {
  @override
  LocationRefreshState build() => const LocationRefreshState();

  Future<void> refresh(String uid) async {
    state = state.copyWith(phase: LocationRefreshPhase.refreshing, clearFailure: true);
    final locationResult =
        await ref.read(locationServiceProvider).getCurrentLocation();

    await locationResult.match(
      (failure) async {
        state = state.copyWith(phase: LocationRefreshPhase.error, failure: failure);
      },
      (position) async {
        final result = await ref.read(authRepositoryProvider).updateVolunteerLocation(
              uid: uid,
              latitude: position.latitude,
              longitude: position.longitude,
            );
        state = result.fold(
          (failure) => state.copyWith(phase: LocationRefreshPhase.error, failure: failure),
          (_) => state.copyWith(phase: LocationRefreshPhase.success, clearFailure: true),
        );
      },
    );
  }
}
