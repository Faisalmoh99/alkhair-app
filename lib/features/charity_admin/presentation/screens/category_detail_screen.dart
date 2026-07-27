import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/charity_admin/presentation/controllers/reports_controllers.dart';
import 'package:alkhair_app/features/charity_admin/presentation/widgets/category_report_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Screen 10 (Fig 5.10, FR12) — sortable category table over the same
/// [monthlySummaryProvider] as Screen 9, so the two screens' numbers always
/// reconcile (shared [selectedMonthProvider]).
class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final summaryAsync = ref.watch(monthlySummaryProvider(month: month));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.reportMonthly),
        ),
        title: const Text('تفاصيل الفئات'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                DateFormat('yyyy / MM').format(month),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: summaryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('تعذّر تحميل البيانات.')),
                data: (summary) => SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: CategoryReportTable(summary: summary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => context.go(Routes.reportExport),
                child: const Text('تصدير التقرير'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
