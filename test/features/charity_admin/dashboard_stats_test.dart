import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/dashboard_stats.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:flutter_test/flutter_test.dart';

// Screen 6's aggregation (TEST_PLAN.md Phase 5 Unit): status counts, weekly
// bucketing by created_at, and recent ordering. Pure — no Firebase.
void main() {
  DonationReport report({
    required String id,
    required DonationStatus status,
    required DateTime createdAt,
  }) {
    return DonationReport(
      id: id,
      donorId: 'donor1',
      foodCategory: FoodCategory.mainMeals,
      quantity: 5,
      readinessTime: createdAt,
      latitude: 0,
      longitude: 0,
      safetyConfirmed: true,
      status: status,
      createdAt: createdAt,
    );
  }

  final now = DateTime(2030, 6, 15, 12);

  test('counts reports per status, including zero for absent statuses', () {
    final reports = [
      report(id: 'r1', status: DonationStatus.reported, createdAt: now),
      report(id: 'r2', status: DonationStatus.reported, createdAt: now),
      report(id: 'r3', status: DonationStatus.delivered, createdAt: now),
    ];

    final stats = computeDashboardStats(reports, now: now);

    expect(stats.statusCounts[DonationStatus.reported], 2);
    expect(stats.statusCounts[DonationStatus.delivered], 1);
    expect(stats.statusCounts[DonationStatus.assigned], 0);
    expect(stats.statusCounts[DonationStatus.collected], 0);
    expect(stats.statusCounts[DonationStatus.expired], 0);
    expect(stats.total, 3);
  });

  test('buckets reports into the last 7 days, oldest first ending today', () {
    final reports = [
      report(id: 'today', status: DonationStatus.reported, createdAt: now),
      report(
        id: 'yesterday',
        status: DonationStatus.reported,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      report(
        id: 'sixDaysAgo',
        status: DonationStatus.reported,
        createdAt: now.subtract(const Duration(days: 6)),
      ),
    ];

    final stats = computeDashboardStats(reports, now: now);

    expect(stats.weeklyCounts, [1, 0, 0, 0, 0, 1, 1]);
  });

  test('drops reports older than 7 days from the weekly bucket', () {
    final reports = [
      report(
        id: 'old',
        status: DonationStatus.reported,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
    ];

    final stats = computeDashboardStats(reports, now: now);

    expect(stats.weeklyCounts, [0, 0, 0, 0, 0, 0, 0]);
  });

  test('recent is sorted newest-first regardless of input order', () {
    final oldest = report(
      id: 'oldest',
      status: DonationStatus.reported,
      createdAt: now.subtract(const Duration(days: 2)),
    );
    final newest = report(id: 'newest', status: DonationStatus.reported, createdAt: now);
    final middle = report(
      id: 'middle',
      status: DonationStatus.reported,
      createdAt: now.subtract(const Duration(days: 1)),
    );

    final stats = computeDashboardStats([oldest, newest, middle], now: now);

    expect(stats.recent.map((r) => r.id).toList(), ['newest', 'middle', 'oldest']);
  });
}
