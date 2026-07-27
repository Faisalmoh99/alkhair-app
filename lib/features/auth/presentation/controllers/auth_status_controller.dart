import 'package:alkhair_app/core/constants/app_constants.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/auth/domain/entities/auth_stage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_status_controller.g.dart';

/// The reactive [AuthStage] the router guard consumes. Watches the auth uid and
/// loads the profile to derive the stage. Invalidate after profile writes
/// (account-type / volunteer extra step) to force a re-derive.
///
/// The first emission is delayed, if needed, until [kMinSplashDuration] has
/// elapsed since [appLaunchTimeProvider] — this keeps the splash screen
/// visible for a minimum duration without any router/widget changes, since
/// the splash is shown for as long as this stream stays in AsyncLoading.
/// Later emissions (e.g. after account-type invalidates this provider) are
/// never delayed, since [appLaunchTimeProvider] is keepAlive and long past.
@riverpod
class AuthStatusController extends _$AuthStatusController {
  @override
  Stream<AuthStage> build() async* {
    final launchedAt = ref.watch(appLaunchTimeProvider);
    final repo = ref.watch(authRepositoryProvider);
    var isFirstEmission = true;
    await for (final uid in repo.authStateChanges()) {
      final stage = uid == null
          ? AuthStage.unauthenticated
          : (await repo.loadProfile(uid)).fold(
              (_) => AuthStage.unauthenticated,
              (user) => deriveAuthStage(uid: uid, profile: user),
            );
      if (isFirstEmission) {
        isFirstEmission = false;
        final remaining =
            kMinSplashDuration - DateTime.now().difference(launchedAt);
        if (remaining > Duration.zero) {
          await Future<void>.delayed(remaining);
        }
      }
      yield stage;
    }
  }
}
