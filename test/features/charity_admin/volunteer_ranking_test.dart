import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/approved_volunteer.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/volunteer_ranking.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:flutter_test/flutter_test.dart';

// Screen 11's leaderboard aggregation (TEST_PLAN.md Phase 6 Unit):
// delivered-only, grouped by volunteer_id, ranked desc, leader badge on the
// top count, approved-only, zero-delivery volunteers included last.
void main() {
  DonationReport report({
    required String id,
    required DonationStatus status,
    String? volunteerId,
  }) {
    return DonationReport(
      id: id,
      donorId: 'donor1',
      volunteerId: volunteerId,
      foodCategory: FoodCategory.mainMeals,
      quantity: 5,
      readinessTime: DateTime(2030),
      latitude: 0,
      longitude: 0,
      safetyConfirmed: true,
      status: status,
      createdAt: DateTime(2030),
    );
  }

  const volA = ApprovedVolunteer(uid: 'volA', name: 'Volunteer A');
  const volB = ApprovedVolunteer(uid: 'volB', name: 'Volunteer B');
  const volC = ApprovedVolunteer(uid: 'volC', name: 'Volunteer C');

  test('counts only delivered reports, grouped by volunteer', () {
    final reports = [
      report(id: 'r1', status: DonationStatus.delivered, volunteerId: 'volA'),
      report(id: 'r2', status: DonationStatus.delivered, volunteerId: 'volA'),
      report(id: 'r3', status: DonationStatus.assigned, volunteerId: 'volA'),
      report(id: 'r4', status: DonationStatus.delivered, volunteerId: 'volB'),
    ];

    final ranking = computeVolunteerPerformance(reports, [volA, volB]);

    final a = ranking.firstWhere((r) => r.uid == 'volA');
    final b = ranking.firstWhere((r) => r.uid == 'volB');
    expect(a.deliveredCount, 2);
    expect(b.deliveredCount, 1);
  });

  test('ranks descending with the top count marked as leader', () {
    final reports = [
      report(id: 'r1', status: DonationStatus.delivered, volunteerId: 'volA'),
      report(id: 'r2', status: DonationStatus.delivered, volunteerId: 'volB'),
      report(id: 'r3', status: DonationStatus.delivered, volunteerId: 'volB'),
      report(id: 'r4', status: DonationStatus.delivered, volunteerId: 'volB'),
    ];

    final ranking = computeVolunteerPerformance(reports, [volA, volB]);

    expect(ranking.first.uid, 'volB');
    expect(ranking.first.isLeader, isTrue);
    expect(ranking.last.isLeader, isFalse);
  });

  test('ignores reports assigned to volunteers not in the approved list', () {
    final reports = [
      report(id: 'r1', status: DonationStatus.delivered, volunteerId: 'unknownVol'),
      report(id: 'r2', status: DonationStatus.delivered, volunteerId: 'volA'),
    ];

    final ranking = computeVolunteerPerformance(reports, [volA]);

    expect(ranking, hasLength(1));
    expect(ranking.first.deliveredCount, 1);
  });

  test('zero-delivery approved volunteers are included, no leader when all are zero', () {
    final ranking = computeVolunteerPerformance(const [], [volA, volB, volC]);

    expect(ranking, hasLength(3));
    expect(ranking.every((r) => r.deliveredCount == 0), isTrue);
    expect(ranking.every((r) => !r.isLeader), isTrue);
  });

  test('ties: multiple volunteers at the top count are all marked leader', () {
    final reports = [
      report(id: 'r1', status: DonationStatus.delivered, volunteerId: 'volA'),
      report(id: 'r2', status: DonationStatus.delivered, volunteerId: 'volB'),
    ];

    final ranking = computeVolunteerPerformance(reports, [volA, volB, volC]);

    final leaders = ranking.where((r) => r.isLeader).map((r) => r.uid).toSet();
    expect(leaders, {'volA', 'volB'});
  });
}
