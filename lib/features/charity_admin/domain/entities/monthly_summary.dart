import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';

/// Derived aggregates for Screens 9 & 10 (FR12), computed client-side over the
/// `DonationReports` stream for a selected month — mirrors `computeDashboardStats`'s
/// pure-aggregation pattern so it stays unit-testable without Firestore.
///
/// Governing filter (resolved conflict — see memory/project_alkhair_phase6.md):
/// only `status == delivered` reports within the month count, per Table 4.8's
/// field semantics ("count of donations completed" / "quantity of food
/// recovered"), not Figure 5.9's looser "created within the month" prose.
class MonthlySummary {
  const MonthlySummary({
    required this.totalDonations,
    required this.totalQuantity,
    required this.countByCategory,
    required this.quantityByCategory,
  });

  final int totalDonations;
  final num totalQuantity;
  final Map<FoodCategory, int> countByCategory;
  final Map<FoodCategory, num> quantityByCategory;
}

/// Pure aggregation function (unit-tested independently of Firestore/widgets).
/// [month] identifies the calendar month; only its year/month are used.
MonthlySummary computeMonthlySummary(
  List<DonationReport> reports, {
  required DateTime month,
}) {
  final start = DateTime(month.year, month.month);
  final end = DateTime(month.year, month.month + 1);

  final countByCategory = <FoodCategory, int>{
    for (final c in FoodCategory.values) c: 0,
  };
  final quantityByCategory = <FoodCategory, num>{
    for (final c in FoodCategory.values) c: 0,
  };

  var totalDonations = 0;
  num totalQuantity = 0;

  for (final report in reports) {
    if (report.status != DonationStatus.delivered) continue;
    if (report.createdAt.isBefore(start) || !report.createdAt.isBefore(end)) {
      continue;
    }
    totalDonations += 1;
    totalQuantity += report.quantity;
    countByCategory[report.foodCategory] =
        (countByCategory[report.foodCategory] ?? 0) + 1;
    quantityByCategory[report.foodCategory] =
        (quantityByCategory[report.foodCategory] ?? 0) + report.quantity;
  }

  return MonthlySummary(
    totalDonations: totalDonations,
    totalQuantity: totalQuantity,
    countByCategory: countByCategory,
    quantityByCategory: quantityByCategory,
  );
}
