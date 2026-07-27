import 'package:alkhair_app/core/constants/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

/// The signed-in user's profile, assembled from the `Users` doc (Table 4.2)
/// and — for volunteers — the `Volunteers` sub-doc (Table 4.3), or — for
/// charity admins — the `CharityAdmins` sub-doc (Table 4.4).
///
/// `email`/`approvalStatus` are volunteer-only and null otherwise. `charityId`
/// is populated for both volunteers and charity admins, null for donors. Per
/// SECURITY.md §1.3 `email` lives on `Users`, not `Volunteers`.
@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String name,
    required String phone,
    required UserRole role,
    String? email,
    ApprovalStatus? approvalStatus,
    String? charityId,
  }) = _AppUser;
}
