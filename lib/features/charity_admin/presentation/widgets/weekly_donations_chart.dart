import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Screen 6's weekly-donations bar chart (FR11) — [weeklyCounts] has 7
/// entries, oldest first, ending today (see `computeDashboardStats`).
class WeeklyDonationsChart extends StatelessWidget {
  const WeeklyDonationsChart({required this.weeklyCounts, super.key});

  final List<int> weeklyCounts;

  static const _dayLabels = ['6', '5', '4', '3', '2', 'أمس', 'اليوم'];

  @override
  Widget build(BuildContext context) {
    final maxCount = weeklyCounts.isEmpty
        ? 0
        : weeklyCounts.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: (maxCount + 1).toDouble(),
          gridData: const FlGridData(drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
            ),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= _dayLabels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_dayLabels[i], style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < weeklyCounts.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: weeklyCounts[i].toDouble(),
                    color: AppColors.primaryNavy,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
