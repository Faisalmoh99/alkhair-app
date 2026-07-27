import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/monthly_summary.dart';
import 'package:alkhair_app/features/charity_admin/presentation/food_category_label.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Screen 9's category-breakdown pie chart (Fig 5.9, FR12) — one slice per
/// `FoodCategory`, sized by quantity within the selected month.
class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({required this.summary, super.key});

  final MonthlySummary summary;

  static const _colors = [
    AppColors.primaryNavy,
    AppColors.gold,
    Colors.teal,
    AppColors.green,
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    if (summary.totalDonations == 0) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('لا توجد بيانات لهذا الشهر.')),
      );
    }

    final categories = summary.quantityByCategory.keys.toList();
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: [
            for (var i = 0; i < categories.length; i++)
              if ((summary.quantityByCategory[categories[i]] ?? 0) > 0)
                PieChartSectionData(
                  value: (summary.quantityByCategory[categories[i]] ?? 0)
                      .toDouble(),
                  title: foodCategoryLabel(categories[i]),
                  titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                  color: _colors[i % _colors.length],
                  radius: 90,
                ),
          ],
        ),
      ),
    );
  }
}
