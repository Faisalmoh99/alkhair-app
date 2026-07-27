import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/monthly_summary.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:flutter_test/flutter_test.dart';

// Screens 9 & 10's shared aggregation (TEST_PLAN.md Phase 6 Unit): governing
// filter is status == delivered AND created_at within the selected month
// (resolved Figure 5.9-prose vs Table 4.8-field-semantics conflict — see
// memory/project_alkhair_phase6.md). Pure — no Firebase.
void main() {
  DonationReport report({
    required String id,
    required DonationStatus status,
    required DateTime createdAt,
    FoodCategory category = FoodCategory.mainMeals,
    num quantity = 5,
  }) {
    return DonationReport(
      id: id,
      donorId: 'donor1',
      foodCategory: category,
      quantity: quantity,
      readinessTime: createdAt,
      latitude: 0,
      longitude: 0,
      safetyConfirmed: true,
      status: status,
      createdAt: createdAt,
    );
  }

  final month = DateTime(2030, 6);

  test('counts only delivered reports created within the month', () {
    final reports = [
      report(id: 'in-month-delivered', status: DonationStatus.delivered, createdAt: DateTime(2030, 6, 10)),
      report(id: 'in-month-reported', status: DonationStatus.reported, createdAt: DateTime(2030, 6, 11)),
      report(id: 'prev-month-delivered', status: DonationStatus.delivered, createdAt: DateTime(2030, 5, 30)),
      report(id: 'next-month-delivered', status: DonationStatus.delivered, createdAt: DateTime(2030, 7)),
    ];

    final summary = computeMonthlySummary(reports, month: month);

    expect(summary.totalDonations, 1);
  });

  test('sums quantity per category for delivered in-window reports', () {
    final reports = [
      report(
        id: 'r1',
        status: DonationStatus.delivered,
        createdAt: DateTime(2030, 6, 5),
        category: FoodCategory.bakedGoods,
        quantity: 10,
      ),
      report(
        id: 'r2',
        status: DonationStatus.delivered,
        createdAt: DateTime(2030, 6, 20),
        category: FoodCategory.bakedGoods,
        quantity: 3,
      ),
      report(
        id: 'r3',
        status: DonationStatus.delivered,
        createdAt: DateTime(2030, 6, 15),
        category: FoodCategory.canned,
        quantity: 7,
      ),
    ];

    final summary = computeMonthlySummary(reports, month: month);

    expect(summary.totalDonations, 3);
    expect(summary.totalQuantity, 20);
    expect(summary.countByCategory[FoodCategory.bakedGoods], 2);
    expect(summary.quantityByCategory[FoodCategory.bakedGoods], 13);
    expect(summary.countByCategory[FoodCategory.canned], 1);
    expect(summary.quantityByCategory[FoodCategory.canned], 7);
    expect(summary.countByCategory[FoodCategory.other], 0);
  });

  test('empty month yields zeros without crashing', () {
    final summary = computeMonthlySummary(const [], month: month);

    expect(summary.totalDonations, 0);
    expect(summary.totalQuantity, 0);
    for (final c in FoodCategory.values) {
      expect(summary.countByCategory[c], 0);
      expect(summary.quantityByCategory[c], 0);
    }
  });

  test('a month with reports but none delivered yields zeros', () {
    final reports = [
      report(id: 'r1', status: DonationStatus.reported, createdAt: DateTime(2030, 6, 5)),
      report(id: 'r2', status: DonationStatus.assigned, createdAt: DateTime(2030, 6, 6)),
      report(id: 'r3', status: DonationStatus.expired, createdAt: DateTime(2030, 6, 7)),
    ];

    final summary = computeMonthlySummary(reports, month: month);

    expect(summary.totalDonations, 0);
    expect(summary.totalQuantity, 0);
  });
}
