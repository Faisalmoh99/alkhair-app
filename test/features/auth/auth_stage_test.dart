import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/auth/domain/entities/app_user.dart';
import 'package:alkhair_app/features/auth/domain/entities/auth_stage.dart';
import 'package:flutter_test/flutter_test.dart';

// deriveAuthStage — the pure mapping the router guard depends on (SECURITY.md §1.3).
void main() {
  AppUser user({
    UserRole role = UserRole.donor,
    ApprovalStatus? approval,
  }) =>
      AppUser(
        uid: 'u1',
        name: 'N',
        phone: '+9665',
        role: role,
        approvalStatus: approval,
      );

  test('null uid → unauthenticated', () {
    expect(
      deriveAuthStage(uid: null, profile: null),
      AuthStage.unauthenticated,
    );
  });

  test('signed in but no profile → needsProfile', () {
    expect(
      deriveAuthStage(uid: 'u1', profile: null),
      AuthStage.needsProfile,
    );
  });

  test('donor profile → donor', () {
    expect(
      deriveAuthStage(uid: 'u1', profile: user()),
      AuthStage.donor,
    );
  });

  test('charity admin profile → charityAdmin', () {
    expect(
      deriveAuthStage(uid: 'u1', profile: user(role: UserRole.charityAdmin)),
      AuthStage.charityAdmin,
    );
  });

  test('volunteer without sub-doc (null approval) → volunteerNeedsDetails', () {
    expect(
      deriveAuthStage(uid: 'u1', profile: user(role: UserRole.volunteer)),
      AuthStage.volunteerNeedsDetails,
    );
  });

  test('volunteer pending → volunteerPending', () {
    expect(
      deriveAuthStage(
        uid: 'u1',
        profile: user(role: UserRole.volunteer, approval: ApprovalStatus.pending),
      ),
      AuthStage.volunteerPending,
    );
  });

  test('volunteer approved → volunteerApproved', () {
    expect(
      deriveAuthStage(
        uid: 'u1',
        profile: user(role: UserRole.volunteer, approval: ApprovalStatus.approved),
      ),
      AuthStage.volunteerApproved,
    );
  });

  test('volunteer revoked → volunteerRevoked', () {
    expect(
      deriveAuthStage(
        uid: 'u1',
        profile: user(role: UserRole.volunteer, approval: ApprovalStatus.revoked),
      ),
      AuthStage.volunteerRevoked,
    );
  });
}
