import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/charity_admin/presentation/controllers/reports_controllers.dart';
import 'package:alkhair_app/features/charity_admin/presentation/widgets/category_pie_chart.dart';
import 'package:alkhair_app/features/charity_admin/presentation/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Screen 9 (Fig 5.9, FR12) — month selector, totals, and a category-
/// breakdown pie chart, all reading [monthlySummaryProvider] over the
/// selected month so it reconciles with Screen 10.
class MonthlySummaryScreen extends ConsumerWidget {
  const MonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final summaryAsync = ref.watch(monthlySummaryProvider(month: month));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.reportsDirectory),
        ),
        title: const Text('الملخص الشهري'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _MonthSelector(month: month),
            Expanded(
              child: summaryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('تعذّر تحميل الملخص.')),
                data: (summary) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              label: 'إجمالي البلاغات',
                              value: summary.totalDonations,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SummaryCard(
                              label: 'إجمالي الكمية',
                              value: summary.totalQuantity.toInt(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'التوزيع حسب الفئة',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              CategoryPieChart(summary: summary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => context.go(Routes.reportCategory),
                        child: const Text('عرض تفاصيل الفئات'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthSelector extends ConsumerWidget {
  const _MonthSelector({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () =>
                ref.read(selectedMonthProvider.notifier).previous(),
          ),
          Text(
            DateFormat('yyyy / MM').format(month),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(selectedMonthProvider.notifier).next(),
          ),
        ],
      ),
    );
  }
}
