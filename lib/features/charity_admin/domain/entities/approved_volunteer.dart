import 'package:freezed_annotation/freezed_annotation.dart';

part 'approved_volunteer.freezed.dart';

/// A volunteer with `approval_status == 'approved'` (Screen 11, FR12) —
/// assembled by joining `Volunteers` (Table 4.3) with `Users` (Table 4.2),
/// mirroring `PendingVolunteer`'s join but scoped to approved-only and
/// trimmed to the fields the performance ranking needs.
@freezed
class ApprovedVolunteer with _$ApprovedVolunteer {
  const factory ApprovedVolunteer({
    required String uid,
    required String name,
  }) = _ApprovedVolunteer;
}
