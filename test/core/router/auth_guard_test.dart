import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/core/router/auth_guard.dart';
import 'package:alkhair_app/features/auth/domain/entities/auth_stage.dart';
import 'package:flutter_test/flutter_test.dart';

// authRedirect — role isolation (TEST_PLAN.md 2c). Each stage may only reach its
// own area; anything else redirects to that stage's home.
void main() {
  group('allowed locations return null (no redirect)', () {
    test('unauthenticated on login / sign-up / forgot-password', () {
      expect(authRedirect(stage: AuthStage.unauthenticated, location: Routes.login), isNull);
      expect(authRedirect(stage: AuthStage.unauthenticated, location: Routes.signUp), isNull);
      expect(
        authRedirect(stage: AuthStage.unauthenticated, location: Routes.forgotPassword),
        isNull,
      );
    });
    test('needsProfile stays on the sign-up screen (finishing account creation)', () {
      expect(authRedirect(stage: AuthStage.needsProfile, location: Routes.signUp), isNull);
    });
    test('donor within /donor', () {
      expect(authRedirect(stage: AuthStage.donor, location: Routes.donorHome), isNull);
      expect(authRedirect(stage: AuthStage.donor, location: Routes.donorReport), isNull);
    });
    test('volunteerNeedsDetails / pending / revoked on the extra step', () {
      for (final stage in [
        AuthStage.volunteerNeedsDetails,
        AuthStage.volunteerPending,
        AuthStage.volunteerRevoked,
      ]) {
        expect(authRedirect(stage: stage, location: Routes.volunteerExtra), isNull);
      }
    });
    test('approved volunteer within /volunteer', () {
      expect(authRedirect(stage: AuthStage.volunteerApproved, location: Routes.volunteerHome), isNull);
    });
    test('charity admin within /admin', () {
      expect(authRedirect(stage: AuthStage.charityAdmin, location: Routes.adminDashboard), isNull);
    });
  });

  group('cross-role access is redirected home', () {
    test('unauthenticated cannot reach a role area', () {
      expect(
        authRedirect(stage: AuthStage.unauthenticated, location: Routes.donorHome),
        Routes.login,
      );
    });
    test('donor cannot reach volunteer or admin areas', () {
      expect(authRedirect(stage: AuthStage.donor, location: Routes.volunteerHome), Routes.donorHome);
      expect(authRedirect(stage: AuthStage.donor, location: Routes.adminDashboard), Routes.donorHome);
    });
    test('approved volunteer cannot reach donor or admin areas', () {
      expect(
        authRedirect(stage: AuthStage.volunteerApproved, location: Routes.donorHome),
        Routes.volunteerHome,
      );
      expect(
        authRedirect(stage: AuthStage.volunteerApproved, location: Routes.adminDashboard),
        Routes.volunteerHome,
      );
    });
    test('charity admin cannot reach donor or volunteer areas', () {
      expect(
        authRedirect(stage: AuthStage.charityAdmin, location: Routes.donorHome),
        Routes.adminDashboard,
      );
      expect(
        authRedirect(stage: AuthStage.charityAdmin, location: Routes.volunteerHome),
        Routes.adminDashboard,
      );
    });
    test('pending volunteer cannot reach the approved volunteer area', () {
      expect(
        authRedirect(stage: AuthStage.volunteerPending, location: Routes.volunteerHome),
        Routes.volunteerExtra,
      );
    });
    test('a signed-in donor is pushed off the splash/login screens', () {
      expect(authRedirect(stage: AuthStage.donor, location: Routes.splash), Routes.donorHome);
      expect(authRedirect(stage: AuthStage.donor, location: Routes.login), Routes.donorHome);
    });
  });

  group('signUpFinalizingInProgress overrides the stage entirely', () {
    test('holds on the sign-up screen regardless of the derived stage', () {
      // Covers the account-creation race: createUserWithUsernamePassword's
      // sign-in can make AuthStatusController briefly derive a premature
      // stage before RegistrationController finishes writing the Users doc.
      for (final stage in [
        AuthStage.unauthenticated,
        AuthStage.needsProfile,
        AuthStage.donor,
        AuthStage.volunteerApproved,
        AuthStage.charityAdmin,
      ]) {
        expect(
          authRedirect(
            stage: stage,
            location: Routes.signUp,
            signUpFinalizingInProgress: true,
          ),
          isNull,
        );
      }
    });
    test('redirects any other location to the sign-up screen', () {
      expect(
        authRedirect(
          stage: AuthStage.donor,
          location: Routes.donorHome,
          signUpFinalizingInProgress: true,
        ),
        Routes.signUp,
      );
    });
  });
}
