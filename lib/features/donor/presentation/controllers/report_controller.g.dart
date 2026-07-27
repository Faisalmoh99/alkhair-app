// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportControllerHash() => r'91ef19afd6bd63a3249c4a072c7cc5703d5e06c7';

/// Drives Screen 2's submit flow: captures GPS (FR3) then calls the
/// `createDonationReport` callable via the donation repository.
///
/// Copied from [ReportController].
@ProviderFor(ReportController)
final reportControllerProvider =
    AutoDisposeNotifierProvider<ReportController, ReportSubmitState>.internal(
      ReportController.new,
      name: r'reportControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reportControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReportController = AutoDisposeNotifier<ReportSubmitState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
