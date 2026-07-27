// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_status_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStatusControllerHash() =>
    r'1a604a44d7607ed07c39a9d297512005ccebde8f';

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
///
/// Copied from [AuthStatusController].
@ProviderFor(AuthStatusController)
final authStatusControllerProvider =
    AutoDisposeStreamNotifierProvider<AuthStatusController, AuthStage>.internal(
      AuthStatusController.new,
      name: r'authStatusControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authStatusControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthStatusController = AutoDisposeStreamNotifier<AuthStage>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
