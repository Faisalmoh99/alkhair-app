import 'package:alkhair_app/features/charity_admin/presentation/food_category_label.dart';
import 'package:alkhair_app/features/charity_admin/presentation/widgets/status_badge.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Screen 6's recent-donations list (FR11) — reverse-chronological, each row
/// showing category/quantity and a [StatusBadge]. A list rather than a
/// `DataTable` so it stays responsive without horizontal scrolling on narrow
/// widths (Phase 5's first responsive layout).
class RecentDonationsTable extends StatelessWidget {
  const RecentDonationsTable({required this.reports, super.key});

  final List<DonationReport> reports;

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('لا توجد بلاغات بعد.'),
      );
    }
    return Column(
      children: [
        for (final report in reports)
          ListTile(
            title: Text('${foodCategoryLabel(report.foodCategory)} — ${report.quantity}'),
            subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(report.createdAt)),
            trailing: StatusBadge(status: report.status),
          ),
      ],
    );
  }
}
