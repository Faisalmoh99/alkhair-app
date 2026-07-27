import 'package:alkhair_app/core/constants/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_volunteer.freezed.dart';

/// A volunteer awaiting admin action (Screen 7, FR10) — assembled by joining
/// the `Volunteers` sub-doc (Table 4.3) with the volunteer's `Users` doc
/// (Table 4.2) for display fields (name, phone) the approval list needs.
@freezed
class PendingVolunteer with _$PendingVolunteer {
  const factory PendingVolunteer({
    required String uid,
    required String name,
    required String phone,
    required String vehicleType,
    required ApprovalStatus approvalStatus,
    required String charityId,
  }) = _PendingVolunteer;
}
