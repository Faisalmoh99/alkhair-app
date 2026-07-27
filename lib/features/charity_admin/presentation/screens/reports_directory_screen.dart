import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/generated_report.dart';
import 'package:alkhair_app/features/charity_admin/presentation/controllers/reports_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Screen 8 (Fig 5.8, FR12) — lists the three report types, each showing when
/// its underlying `Reports` doc was last generated (or "not yet generated").
class ReportsDirectoryScreen extends ConsumerWidget {
  const ReportsDirectoryScreen({super.key});

  static const _entries = [
    (ReportType.monthlySummary, 'الملخص الشهري', Routes.reportMonthly),
    (ReportType.categoryDetail, 'تفاصيل الفئات', Routes.reportCategory),
    (ReportType.volunteerPerformance, 'أداء المتطوعين', Routes.reportPerformance),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(generatedReportsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.adminDashboard),
        ),
        title: const Text('التقارير'),
      ),
      body: SafeArea(
        child: reportsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('تعذّر تحميل التقارير.')),
          data: (reports) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final entry in _entries)
                  _ReportTile(
                    label: entry.$2,
                    lastGenerated: _latestFor(reports, entry.$1),
                    onTap: () => context.go(entry.$3),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  DateTime? _latestFor(List<GeneratedReport> reports, ReportType type) {
    final matching = reports.where((r) => r.reportType == type);
    if (matching.isEmpty) return null;
    return matching.map((r) => r.generatedAt).reduce((a, b) => a.isAfter(b) ? a : b);
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.label,
    required this.lastGenerated,
    required this.onTap,
  });

  final String label;
  final DateTime? lastGenerated;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = lastGenerated == null
        ? 'لم يتم إنشاؤه بعد'
        : 'آخر تحديث: ${DateFormat('yyyy/MM/dd HH:mm').format(lastGenerated!)}';
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}
