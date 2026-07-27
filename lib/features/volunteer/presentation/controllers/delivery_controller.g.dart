// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deliveryControllerHash() =>
    r'f0d73e912ce1ca9b6c049fe0af731ce866572425';

/// Drives Screen 5's two sequential confirm actions. Each call is a guarded
/// transaction (firestore.rules' assigned-volunteer-only advance rule); a
/// stale/duplicate tap surfaces as [ConflictFailure] rather than corrupting
/// the status sequence.
///
/// Copied from [DeliveryController].
@ProviderFor(DeliveryController)
final deliveryControllerProvider =
    AutoDisposeNotifierProvider<DeliveryController, DeliveryState>.internal(
      DeliveryController.new,
      name: r'deliveryControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deliveryControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeliveryController = AutoDisposeNotifier<DeliveryState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
