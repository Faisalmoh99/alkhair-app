import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/auth/domain/entities/auth_stage.dart';

/// Pure route guard. Given the user's [stage] and the current [location],
/// returns the path to redirect to, or null when the location is allowed.
///
/// No Firebase, no widgets — exhaustively unit-tested (TEST_PLAN.md 2c: role
/// isolation). Enforces that each role can only reach its own area.
String? authRedirect({required AuthStage stage, required String location}) {
  if (_isAllowed(stage, location)) {
    return null;
  }
  return _homeFor(stage);
}

/// The single landing route each stage is sent to.
String _homeFor(AuthStage stage) => switch (stage) {
      AuthStage.unauthenticated => Routes.signIn,
      AuthStage.needsProfile => Routes.accountType,
      AuthStage.donor => Routes.donorHome,
      AuthStage.volunteerNeedsDetails => Routes.volunteerExtra,
      AuthStage.volunteerPending => Routes.volunteerExtra,
      AuthStage.volunteerRevoked => Routes.volunteerExtra,
      AuthStage.volunteerApproved => Routes.volunteerHome,
      AuthStage.charityAdmin => Routes.adminDashboard,
    };

/// Whether [location] is within the area allowed for [stage].
bool _isAllowed(AuthStage stage, String location) => switch (stage) {
      AuthStage.unauthenticated =>
        location == Routes.signIn || location == Routes.otp,
      AuthStage.needsProfile => location == Routes.accountType,
      AuthStage.volunteerNeedsDetails ||
      AuthStage.volunteerPending ||
      AuthStage.volunteerRevoked =>
        location == Routes.volunteerExtra,
      AuthStage.donor => location.startsWith('/donor'),
      AuthStage.volunteerApproved => location.startsWith('/volunteer'),
      AuthStage.charityAdmin => location.startsWith('/admin'),
    };
