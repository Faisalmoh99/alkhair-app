import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/auth/domain/entities/sign_up_data.dart';
import 'package:alkhair_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/auth_status_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'registration_controller.g.dart';

const _roleClaimRetryAttempts = 5;
const _roleClaimRetryBaseDelay = Duration(milliseconds: 300);

/// True from the moment `createUserWithUsernamePassword` signs the user into
/// Firebase Auth until `RegistrationController.createFromSignUp` finishes
/// (success or failure). That sign-in fires `authStateChanges` immediately,
/// before any of the in-app post-creation work below has run — without this
/// override, the router's guard would derive a stage from whatever Firestore
/// already has for that uid (nothing yet) and could admit the user to a
/// premature screen before the `Users` doc (and, for volunteers, the pending
/// `Volunteers` sub-doc) exist. See `authRedirect`'s
/// `signUpFinalizingInProgress` parameter.
@riverpod
class SignUpFinalizingInProgress extends _$SignUpFinalizingInProgress {
  @override
  bool build() => false;

  void update({required bool inProgress}) => state = inProgress;
}

/// Drives account creation on sign-up submit (no phone/OTP verification —
/// phone is a plain data field, ARCHITECTURE.md §6):
///  - reject duplicate phone numbers (`checkPhoneRegistered`);
///  - create the Firebase Auth account directly with username+password;
///  - create the `Users` doc;
///  - volunteers additionally get the pending `Volunteers` sub-doc.
@riverpod
class RegistrationController extends _$RegistrationController {
  @override
  FutureOr<void> build() {}

  Future<Either<Failure, void>> createFromSignUp(SignUpData data) async {
    ref.read(signUpFinalizingInProgressProvider.notifier).update(inProgress: true);
    try {
      return await _createFromSignUp(data);
    } finally {
      ref.read(signUpFinalizingInProgressProvider.notifier).update(inProgress: false);
    }
  }

  Future<Either<Failure, void>> _createFromSignUp(SignUpData data) async {
    final repo = ref.read(authRepositoryProvider);

    final phoneCheck = await repo.checkPhoneRegistered(data.phone);
    final alreadyRegistered = phoneCheck.fold((_) => false, (registered) => registered);
    if (alreadyRegistered) {
      return left(const Failure.auth(code: 'phone-already-registered'));
    }

    final createResult = await repo.createUserWithUsernamePassword(
      username: data.username,
      password: data.password,
    );
    if (createResult.isLeft()) {
      return createResult.map((_) {});
    }
    final uid = createResult.getOrElse((_) => '');

    final profileResult = await repo.createUserProfile(
      uid: uid,
      name: data.name,
      phone: data.phone,
      username: data.username,
      role: data.role,
    );
    if (profileResult.isLeft()) {
      await _deleteOrphanedAccount(repo);
      return profileResult;
    }

    if (data.role == UserRole.volunteer) {
      final locationResult =
          await ref.read(locationServiceProvider).getCurrentLocation();
      final position = locationResult.match((_) => null, (position) => position);

      final volunteerResult = await repo.completeVolunteerRegistration(
        uid: uid,
        email: data.email!,
        vehicleType: data.vehicleType!,
        charityId: data.charityId!,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
      if (volunteerResult.isLeft()) {
        await _deleteOrphanedAccount(repo);
        return volunteerResult;
      }
    }

    await _waitForRoleClaim(data.role);
    // Deliberately NOT left to the caller (SignUpScreen) to trigger: that
    // screen's own post-await code is guarded by `mounted`, so if the widget
    // was disposed for any reason while this function was still running
    // (e.g. the router navigated away mid-flight), the invalidation would be
    // silently dropped and AuthStatusController would keep serving its
    // stale pre-registration stage forever — the user would be stuck on
    // whatever screen the guard last placed them on, even though the
    // account was fully created. Firing it here ties it to this provider's
    // own lifetime, not the calling widget's.
    ref.invalidate(authStatusControllerProvider);
    return right(null);
  }

  /// A failure anywhere after `createUserWithUsernamePassword` (profile
  /// write, volunteer sub-doc write) must not leave a Firebase Auth account
  /// behind with no matching Firestore doc — that account's synthetic email
  /// (`{username}@alkhair-app.internal`) is then permanently unavailable to
  /// any retry of the same username, since Firebase never allows recreating
  /// an existing email. Deleting the just-created account (rather than just
  /// signing out) frees the username, mirroring the "no orphan accounts"
  /// guarantee the old OTP-linking flow had for free. `currentUser.delete()`
  /// also signs the device out as a side effect; `signOut()` is still called
  /// as a fallback in case delete fails (e.g. a stale/expired session).
  Future<void> _deleteOrphanedAccount(AuthRepository repo) async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    try {
      await user?.delete();
    } on FirebaseAuthException {
      await repo.signOut();
    }
  }

  /// The `Users` write above just triggered `onUsersWrite` (SECURITY.md §2.1),
  /// which sets the `role` custom claim server-side asynchronously — the ID
  /// token this session already holds (fetched at account creation, before
  /// the `Users` doc existed) has no such claim. Without this, the very next
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
}
