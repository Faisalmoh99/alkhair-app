import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/monthly_summary.dart';
import 'package:alkhair_app/features/charity_admin/presentation/food_category_label.dart';
import 'package:flutter/material.dart';

/// One category's aggregated row (Screens 10 & 12) — plain data class so it's
/// reusable between the on-screen table and the exported PDF layout.
class CategoryReportRow {
  const CategoryReportRow({
    required this.category,
    required this.quantity,
    required this.count,
  });

  final FoodCategory category;
  final num quantity;
  final int count;
}

List<CategoryReportRow> categoryReportRows(MonthlySummary summary) {
  final rows = [
    for (final category in FoodCategory.values)
      CategoryReportRow(
        category: category,
        quantity: summary.quantityByCategory[category] ?? 0,
        count: summary.countByCategory[category] ?? 0,
      ),
  ]..sort((a, b) => b.quantity.compareTo(a.quantity));
  return rows;
}

/// Screen 10's sortable category-detail table (Fig 5.10, FR12) — category,
/// quantity in kg, donation count, and a bar proportional to that category's
/// share of the month's total quantity.
class CategoryReportTable extends StatefulWidget {
  const CategoryReportTable({required this.summary, super.key});

  final MonthlySummary summary;

  @override
  State<CategoryReportTable> createState() => _CategoryReportTableState();
}

enum _SortColumn { category, quantity, count }

class _CategoryReportTableState extends State<CategoryReportTable> {
  _SortColumn _sortColumn = _SortColumn.quantity;
  bool _ascending = false;

  @override
  Widget build(BuildContext context) {
    final rows = [...categoryReportRows(widget.summary)]..sort((a, b) {
      final cmp = switch (_sortColumn) {
        _SortColumn.category =>
          foodCategoryLabel(a.category).compareTo(foodCategoryLabel(b.category)),
        _SortColumn.quantity => a.quantity.compareTo(b.quantity),
        _SortColumn.count => a.count.compareTo(b.count),
      };
      return _ascending ? cmp : -cmp;
    });

    final maxQuantity = rows.isEmpty
        ? 0
        : rows.map((r) => r.quantity).reduce((a, b) => a > b ? a : b);

    if (widget.summary.totalDonations == 0) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('لا توجد بيانات لهذا الشهر.'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _SortColumn.values.indexOf(_sortColumn),
        sortAscending: _ascending,
        columns: [
          DataColumn(
            label: const Text('الفئة'),
            onSort: (_, asc) => _onSort(_SortColumn.category, asc),
          ),
          DataColumn(
            label: const Text('الكمية'),
            numeric: true,
            onSort: (_, asc) => _onSort(_SortColumn.quantity, asc),
          ),
          DataColumn(
            label: const Text('عدد البلاغات'),
            numeric: true,
            onSort: (_, asc) => _onSort(_SortColumn.count, asc),
          ),
          const DataColumn(label: Text('النسبة')),
        ],
        rows: [
          for (final row in rows)
            DataRow(
              cells: [
                DataCell(Text(foodCategoryLabel(row.category))),
                DataCell(Text('${row.quantity}')),
                DataCell(Text('${row.count}')),
                DataCell(
                  SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: maxQuantity == 0 ? 0 : row.quantity / maxQuantity,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _onSort(_SortColumn column, bool ascending) {
    setState(() {
      _sortColumn = column;
      _ascending = ascending;
    });
  }
}
