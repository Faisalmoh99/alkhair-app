// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_action_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$alertActionControllerHash() =>
    r'c68adc1a2f5c40215f23168d79ce4fa6d9f92adc';

/// Drives Screen 4's accept action: a concurrency-safe claim via the
/// repository's client transaction (SECURITY.md-style authorization, guarded
/// by firestore.rules). [AlertActionPhase.alreadyTaken] means another
/// volunteer claimed the report first — the caller should drop the card
/// (the open-reports stream will do so on its own once the write lands).
///
/// Copied from [AlertActionController].
@ProviderFor(AlertActionController)
final alertActionControllerProvider =
    AutoDisposeNotifierProvider<
      AlertActionController,
      AlertActionState
    >.internal(
      AlertActionController.new,
      name: r'alertActionControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$alertActionControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AlertActionController = AutoDisposeNotifier<AlertActionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
