import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/charity_admin/presentation/controllers/admin_controllers.dart';
import 'package:alkhair_app/features/charity_admin/presentation/status_badge_style.dart';
import 'package:alkhair_app/features/charity_admin/presentation/widgets/recent_donations_table.dart';
import 'package:alkhair_app/features/charity_admin/presentation/widgets/summary_card.dart';
import 'package:alkhair_app/features/charity_admin/presentation/widgets/weekly_donations_chart.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:alkhair_app/features/donor/presentation/screens/donor_status_screen.dart'
    show statusLabel;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The width at which the dashboard switches from a single stacked column to
/// the two-column layout suited to the Flutter-Web admin build (responsive-
/// first per the Phase 5 plan; the web target itself ships in a later phase).
const kAdminWideBreakpoint = 720.0;

/// Screen 6 (Fig 5.6, FR11) — summary cards, weekly-donations chart, and the
/// recent-donations table, all driven by a live DonationReports stream.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final charityName = ref.watch(currentCharityNameProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(charityName == null ? 'لوحة الجمعية' : 'لوحة $charityName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: 'اعتماد المتطوعين',
            onPressed: () => context.go(Routes.adminVolunteers),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'التقارير',
            onPressed: () => context.go(Routes.reportsDirectory),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('تعذّر تحميل بيانات اللوحة.')),
          data: (stats) => LayoutBuilder(
            builder: (context, constraints) {
              final cards = _SummaryCardsRow(statusCounts: stats.statusCounts);
              final chart = _ChartSection(weeklyCounts: stats.weeklyCounts);
              final table = _TableSection(recent: stats.recent);

              if (constraints.maxWidth >= kAdminWideBreakpoint) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      cards,
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: chart),
                          const SizedBox(width: 16),
                          Expanded(child: table),
                        ],
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [cards, const SizedBox(height: 16), chart, const SizedBox(height: 16), table],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryCardsRow extends StatelessWidget {
  const _SummaryCardsRow({required this.statusCounts});

  final Map<DonationStatus, int> statusCounts;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final status in DonationStatus.values)
          SizedBox(
            width: 150,
            child: SummaryCard(
              label: statusLabel(status),
              value: statusCounts[status] ?? 0,
              color: statusBadgeColor(status),
            ),
          ),
      ],
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({required this.weeklyCounts});

  final List<int> weeklyCounts;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('البلاغات خلال الأسبوع', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            WeeklyDonationsChart(weeklyCounts: weeklyCounts),
          ],
        ),
      ),
    );
  }
}

class _TableSection extends StatelessWidget {
  const _TableSection({required this.recent});

  final List<DonationReport> recent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('أحدث البلاغات', style: Theme.of(context).textTheme.titleMedium),
            RecentDonationsTable(reports: recent),
          ],
        ),
      ),
    );
  }
}
