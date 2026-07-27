import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';

/// Derived aggregates for Screen 6 (FR11), computed client-side over the
/// `DonationReports` stream (ARCHITECTURE.md:153 — no aggregation Cloud
/// Function this phase; see Phase 5 plan's aggregation note).
class DashboardStats {
  const DashboardStats({
    required this.statusCounts,
    required this.weeklyCounts,
    required this.recent,
  });

  /// Count of reports at each [DonationStatus] (status-badge summary cards).
  final Map<DonationStatus, int> statusCounts;

  /// Report counts for the last 7 days, oldest first, ending today — feeds
  /// the weekly-donations bar chart.
  final List<int> weeklyCounts;

  /// The most recent reports, newest first, for the recent-donations table.
  final List<DonationReport> recent;

  int get total => statusCounts.values.fold(0, (sum, c) => sum + c);
}

const _recentLimit = 10;
const _weekLength = 7;

/// Pure aggregation function (unit-tested independently of Firestore/widgets).
/// [now] is injectable so weekly-bucket boundaries are deterministic in tests.
DashboardStats computeDashboardStats(
  List<DonationReport> reports, {
  DateTime? now,
}) {
  final today = _dateOnly(now ?? DateTime.now());

  final statusCounts = <DonationStatus, int>{
    for (final s in DonationStatus.values) s: 0,
  };
  for (final report in reports) {
    statusCounts[report.status] = (statusCounts[report.status] ?? 0) + 1;
  }

  final weeklyCounts = List<int>.filled(_weekLength, 0);
  for (final report in reports) {
    final offset = today.difference(_dateOnly(report.createdAt)).inDays;
    if (offset >= 0 && offset < _weekLength) {
      weeklyCounts[_weekLength - 1 - offset] += 1;
    }
  }

  final recent = [...reports]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return DashboardStats(
    statusCounts: statusCounts,
    weeklyCounts: weeklyCounts,
    recent: recent.take(_recentLimit).toList(),
  );
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
