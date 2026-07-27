import 'package:alkhair_app/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:alkhair_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:alkhair_app/features/charity_admin/data/repositories/firebase_charity_admin_repository.dart';
import 'package:alkhair_app/features/charity_admin/domain/repositories/charity_admin_repository.dart';
import 'package:alkhair_app/features/donor/data/repositories/firebase_donation_repository.dart';
import 'package:alkhair_app/features/donor/data/services/location_service.dart';
import 'package:alkhair_app/features/donor/domain/repositories/donation_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

/// Captured once at first read (≈ app launch), stable across later rebuilds —
/// the reference point for the splash screen's minimum-visible-duration gate.
/// See `AuthStatusController`.
@Riverpod(keepAlive: true)
DateTime appLaunchTime(AppLaunchTimeRef ref) => DateTime.now();

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
FirebaseFirestore firestore(FirestoreRef ref) => FirebaseFirestore.instance;

// Firestore-trigger and callable functions must share the database's region.
// europe-west1, not the originally-documented me-central2 — see
// functions/src/region.ts and ARCHITECTURE.md §6.
@Riverpod(keepAlive: true)
FirebaseFunctions firebaseFunctions(FirebaseFunctionsRef ref) =>
    FirebaseFunctions.instanceFor(region: 'europe-west1');

/// The single seam the whole auth feature depends on. Overridden with a mock in
/// unit tests and with the real Firebase implementation in the app.
@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) => FirebaseAuthRepository(
      auth: ref.watch(firebaseAuthProvider),
      firestore: ref.watch(firestoreProvider),
    );

/// Device GPS capture (FR3). Overridden with a mock in unit tests.
@Riverpod(keepAlive: true)
LocationService locationService(LocationServiceRef ref) =>
    const GeolocatorLocationService();

/// The single seam the donor feature depends on for report creation +
/// DonationReports/Notifications streams (SECURITY.md §3).
@Riverpod(keepAlive: true)
DonationRepository donationRepository(DonationRepositoryRef ref) =>
    FirebaseDonationRepository(
      functions: ref.watch(firebaseFunctionsProvider),
      firestore: ref.watch(firestoreProvider),
    );

/// The single seam the charity-admin feature depends on for the dashboard
/// (FR11) and volunteer approval (FR10) reads/writes.
@Riverpod(keepAlive: true)
CharityAdminRepository charityAdminRepository(CharityAdminRepositoryRef ref) =>
    FirebaseCharityAdminRepository(
      firestore: ref.watch(firestoreProvider),
      functions: ref.watch(firebaseFunctionsProvider),
    );
