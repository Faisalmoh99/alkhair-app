import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'registration_controller.g.dart';

const _roleClaimRetryAttempts = 5;
const _roleClaimRetryBaseDelay = Duration(milliseconds: 300);

/// Drives the post-OTP document creation (SECURITY.md §1.3):
///  - donor: `createAccount(role: donor)` → Users doc, done.
///  - volunteer: `createAccount(role: volunteer)` then `completeVolunteer(...)`
///    which updates Users.email + creates the pending Volunteers sub-doc.
@riverpod
class RegistrationController extends _$RegistrationController {
  @override
  FutureOr<void> build() {}

  Future<Either<Failure, void>> createAccount({
    required String uid,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    final result = await ref.read(authRepositoryProvider).createUserProfile(
          uid: uid,
          name: name,
          phone: phone,
          role: role,
        );
    return result.fold(
      (failure) async => left(failure),
      (_) async {
        await _waitForRoleClaim(role);
        return right(null);
      },
    );
  }

  /// The `Users` write above just triggered `onUsersWrite` (SECURITY.md §2.1),
  /// which sets the `role` custom claim server-side asynchronously — the ID
  /// token this session already holds (fetched at OTP sign-in, before the
  /// `Users` doc existed) has no such claim. Without this, the very next
  /// role-gated action (e.g. the donor's `createDonationReport` callable, or
  /// later a volunteer's `isApprovedVolunteer()` rule check) fails with
  /// permission-denied even though the account was just created correctly
  /// (found during the Phase 7 manual E2E). Retry with short backoff rather
  /// than a fixed delay, and fail open — never block registration UX if the
  /// trigger is slow; a subsequent natural token refresh will pick it up.
  Future<void> _waitForRoleClaim(UserRole role) async {
    final auth = ref.read(firebaseAuthProvider);
    for (var attempt = 0; attempt < _roleClaimRetryAttempts; attempt++) {
      final user = auth.currentUser;
      if (user == null) return;
      final tokenResult = await user.getIdTokenResult(true);
      if (tokenResult.claims?['role'] == role.firestoreValue) return;
      await Future<void>.delayed(_roleClaimRetryBaseDelay * (attempt + 1));
    }
  }

  /// Captures a GPS fix the same way FR3 does for donors (Phase 7 Part A1);
  /// on denial/failure it fails open — `current_lat/lng` stay null and
  /// registration still succeeds (the volunteer can set it later via the
  /// manual refresh on the home screen).
  Future<Either<Failure, void>> completeVolunteer({
    required String uid,
    required String email,
    required String vehicleType,
    required String charityId,
  }) async {
    final locationResult =
        await ref.read(locationServiceProvider).getCurrentLocation();
    final position = locationResult.match((_) => null, (position) => position);

    return ref.read(authRepositoryProvider).completeVolunteerRegistration(
          uid: uid,
          email: email,
          vehicleType: vehicleType,
          charityId: charityId,
          latitude: position?.latitude,
          longitude: position?.longitude,
        );
  }
}
