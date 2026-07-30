// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$signUpFinalizingInProgressHash() =>
    r'e22d95b1af1eac9cc5dd26a7e13defc6035ef951';

/// True from the moment `createUserWithUsernamePassword` signs the user into
/// Firebase Auth until `RegistrationController.createFromSignUp` finishes
/// (success or failure). That sign-in fires `authStateChanges` immediately,
/// before any of the in-app post-creation work below has run — without this
/// override, the router's guard would derive a stage from whatever Firestore
/// already has for that uid (nothing yet) and could admit the user to a
/// premature screen before the `Users` doc (and, for volunteers, the pending
/// `Volunteers` sub-doc) exist. See `authRedirect`'s
/// `signUpFinalizingInProgress` parameter.
///
/// Copied from [SignUpFinalizingInProgress].
@ProviderFor(SignUpFinalizingInProgress)
final signUpFinalizingInProgressProvider =
    AutoDisposeNotifierProvider<SignUpFinalizingInProgress, bool>.internal(
      SignUpFinalizingInProgress.new,
      name: r'signUpFinalizingInProgressProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$signUpFinalizingInProgressHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SignUpFinalizingInProgress = AutoDisposeNotifier<bool>;
String _$registrationControllerHash() =>
    r'f95153d9662f8b4ea39f968a3a9b4477c7eee338';

/// Drives account creation on sign-up submit (no phone/OTP verification —
/// phone is a plain data field, ARCHITECTURE.md §6):
///  - reject duplicate phone numbers (`checkPhoneRegistered`);
///  - create the Firebase Auth account directly with username+password;
///  - create the `Users` doc;
///  - volunteers additionally get the pending `Volunteers` sub-doc.
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
