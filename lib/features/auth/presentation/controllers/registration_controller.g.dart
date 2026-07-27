// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$registrationControllerHash() =>
    r'9d549b1cf5f476f93c521bf5ac2e60188a1ad57d';

/// Drives the post-OTP document creation (SECURITY.md §1.3):
///  - donor: `createAccount(role: donor)` → Users doc, done.
///  - volunteer: `createAccount(role: volunteer)` then `completeVolunteer(...)`
///    which updates Users.email + creates the pending Volunteers sub-doc.
///
/// Copied from [RegistrationController].
@ProviderFor(RegistrationController)
final registrationControllerProvider =
    AutoDisposeAsyncNotifierProvider<RegistrationController, void>.internal(
      RegistrationController.new,
      name: r'registrationControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$registrationControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RegistrationController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
