// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appLaunchTimeHash() => r'19ab6b21371da072e44dff98fe58d51731e4e586';

/// Captured once at first read (≈ app launch), stable across later rebuilds —
/// the reference point for the splash screen's minimum-visible-duration gate.
/// See `AuthStatusController`.
///
/// Copied from [appLaunchTime].
@ProviderFor(appLaunchTime)
final appLaunchTimeProvider = Provider<DateTime>.internal(
  appLaunchTime,
  name: r'appLaunchTimeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appLaunchTimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppLaunchTimeRef = ProviderRef<DateTime>;
String _$firebaseAuthHash() => r'c8e57c3e164ad1c2cad48c4508e47f6097e350a7';

/// See also [firebaseAuth].
@ProviderFor(firebaseAuth)
final firebaseAuthProvider = Provider<FirebaseAuth>.internal(
  firebaseAuth,
  name: r'firebaseAuthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAuthRef = ProviderRef<FirebaseAuth>;
String _$firestoreHash() => r'4963ca786eb54685cef6453544040c7567e77c0f';

/// See also [firestore].
@ProviderFor(firestore)
final firestoreProvider = Provider<FirebaseFirestore>.internal(
  firestore,
  name: r'firestoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firestoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirestoreRef = ProviderRef<FirebaseFirestore>;
String _$firebaseFunctionsHash() => r'58a17c9c600ff735c6180e76b68dba201e98818c';

/// See also [firebaseFunctions].
@ProviderFor(firebaseFunctions)
final firebaseFunctionsProvider = Provider<FirebaseFunctions>.internal(
  firebaseFunctions,
  name: r'firebaseFunctionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseFunctionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseFunctionsRef = ProviderRef<FirebaseFunctions>;
String _$authRepositoryHash() => r'a6509d3c509774da42bfe127e1b2f31e672102f3';

/// The single seam the whole auth feature depends on. Overridden with a mock in
/// unit tests and with the real Firebase implementation in the app.
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = Provider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = ProviderRef<AuthRepository>;
String _$locationServiceHash() => r'7e4fb149b395c4bc921f43324c27f48d146c1d6c';

/// Device GPS capture (FR3). Overridden with a mock in unit tests.
///
/// Copied from [locationService].
@ProviderFor(locationService)
final locationServiceProvider = Provider<LocationService>.internal(
  locationService,
  name: r'locationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationServiceRef = ProviderRef<LocationService>;
String _$donationRepositoryHash() =>
    r'4ecfe82845886a34dc4eb5e123858ac30ef4b3ad';

/// The single seam the donor feature depends on for report creation +
/// DonationReports/Notifications streams (SECURITY.md §3).
///
/// Copied from [donationRepository].
@ProviderFor(donationRepository)
final donationRepositoryProvider = Provider<DonationRepository>.internal(
  donationRepository,
  name: r'donationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$donationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DonationRepositoryRef = ProviderRef<DonationRepository>;
String _$charityAdminRepositoryHash() =>
    r'0676e4ff26b31d915670867029546f2e561f3d22';

/// The single seam the charity-admin feature depends on for the dashboard
/// (FR11) and volunteer approval (FR10) reads/writes.
///
/// Copied from [charityAdminRepository].
@ProviderFor(charityAdminRepository)
final charityAdminRepositoryProvider =
    Provider<CharityAdminRepository>.internal(
      charityAdminRepository,
      name: r'charityAdminRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$charityAdminRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CharityAdminRepositoryRef = ProviderRef<CharityAdminRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
