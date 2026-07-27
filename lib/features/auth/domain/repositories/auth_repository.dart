import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/features/auth/domain/entities/app_user.dart';
import 'package:alkhair_app/features/auth/domain/entities/charity.dart';
import 'package:fpdart/fpdart.dart';

/// Abstraction over Phone Auth + the Users/Volunteers/Charities documents.
/// The presentation layer depends only on this interface (mocked in tests); the
/// Firebase-concrete implementation lives in the data layer.
abstract interface class AuthRepository {
  /// Emits the current signed-in uid, or null when signed out.
  Stream<String?> authStateChanges();

  /// Sends an OTP to [phone]. On `codeSent`, returns the verificationId.
  Future<Either<Failure, String>> requestOtp(String phone);

  /// Confirms [smsCode] against [verificationId] and signs in; returns the uid.
  Future<Either<Failure, String>> confirmOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Loads the profile for [uid]; returns null when no `Users` doc exists yet.
  Future<Either<Failure, AppUser?>> loadProfile(String uid);

  /// Creates the `Users` doc (donor or volunteer). role is fixed at create.
  Future<Either<Failure, void>> createUserProfile({
    required String uid,
    required String name,
    required String phone,
    required UserRole role,
  });

  /// Volunteer extra step (SECURITY.md §1.3): updates `Users.email` and creates
  /// `Volunteers` with `approval_status='pending'` and the chosen `charity_id`.
  /// [latitude]/[longitude] are the device GPS fix captured at registration
  /// (Phase 7 Part A1); null when capture fails or permission is denied — the
  /// step must not block on location.
  Future<Either<Failure, void>> completeVolunteerRegistration({
    required String uid,
    required String email,
    required String vehicleType,
    required String charityId,
    double? latitude,
    double? longitude,
  });

  /// On-demand location refresh (Phase 7 Part A1, FR6) — writes only
  /// `current_lat`/`current_lng` on the caller's own `Volunteers` doc.
  Future<Either<Failure, void>> updateVolunteerLocation({
    required String uid,
    required double latitude,
    required double longitude,
  });

  /// Reads the `Charities` reference list for the registration dropdown.
  Future<Either<Failure, List<Charity>>> fetchCharities();

  Future<void> signOut();
}
