import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/approved_volunteer.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'volunteer_ranking.freezed.dart';

/// One row in Screen 11's leaderboard (FR12) — an approved volunteer's
/// all-time delivered-donation count, with [isLeader] marking the top rank.
@freezed
class VolunteerRanking with _$VolunteerRanking {
  const factory VolunteerRanking({
    required String uid,
    required String name,
    required int deliveredCount,
    required bool isLeader,
  }) = _VolunteerRanking;
}

/// Pure aggregation function (unit-tested independently of Firestore/widgets).
/// Delivered-only, all-time (Screen 11 has no period selector), grouped by
/// `volunteer_id` and ranked descending; approved volunteers with zero
/// deliveries are included, sorted last. The leader is the top count, if > 0.
List<VolunteerRanking> computeVolunteerPerformance(
  List<DonationReport> reports,
  List<ApprovedVolunteer> volunteers,
) {
  final counts = <String, int>{for (final v in volunteers) v.uid: 0};

  for (final report in reports) {
    if (report.status != DonationStatus.delivered) continue;
    final volunteerId = report.volunteerId;
    if (volunteerId == null || !counts.containsKey(volunteerId)) continue;
    counts[volunteerId] = (counts[volunteerId] ?? 0) + 1;
  }

  final ranked = [...volunteers]
    ..sort((a, b) => (counts[b.uid] ?? 0).compareTo(counts[a.uid] ?? 0));

  final topCount = ranked.isEmpty ? 0 : (counts[ranked.first.uid] ?? 0);

  return [
    for (final v in ranked)
      VolunteerRanking(
        uid: v.uid,
        name: v.name,
        deliveredCount: counts[v.uid] ?? 0,
        isLeader: topCount > 0 && counts[v.uid] == topCount,
      ),
  ];
}
