import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/auth/domain/entities/app_user.dart';

/// Where the user sits in the auth/onboarding journey — the single value the
/// router guard switches on. Traces to the SECURITY.md §1.3 flow.
enum AuthStage {
  unauthenticated,
  needsProfile, // signed in, no Users doc yet → account-type step
  donor,
  volunteerNeedsDetails, // Users(role=volunteer) but no Volunteers sub-doc yet
  volunteerPending, // awaiting approval (FR10) — no documented screen; folded into extra step
  volunteerApproved,
  volunteerRevoked,
  charityAdmin,
}

/// Pure derivation of the stage from the auth uid + loaded profile. Kept free of
/// Firebase so it is exhaustively unit-testable.
AuthStage deriveAuthStage({required String? uid, required AppUser? profile}) {
  if (uid == null) {
    return AuthStage.unauthenticated;
  }
  if (profile == null) {
    return AuthStage.needsProfile;
  }
  switch (profile.role) {
    case UserRole.donor:
      return AuthStage.donor;
    case UserRole.charityAdmin:
      return AuthStage.charityAdmin;
    case UserRole.volunteer:
      final status = profile.approvalStatus;
      if (status == null) {
        return AuthStage.volunteerNeedsDetails;
      }
      return switch (status) {
        ApprovalStatus.pending => AuthStage.volunteerPending,
        ApprovalStatus.approved => AuthStage.volunteerApproved,
        ApprovalStatus.revoked => AuthStage.volunteerRevoked,
      };
  }
}
