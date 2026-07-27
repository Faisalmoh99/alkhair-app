import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/charity_admin/data/services/report_pdf_service.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/generated_report.dart';
import 'package:alkhair_app/features/charity_admin/presentation/widgets/category_report_table.dart';
import 'package:flutter_test/flutter_test.dart';

// Screen 12's PDF builder (TEST_PLAN.md Phase 6 Unit): produces bytes for
// both populated and empty data, without throwing. Uses the real Cairo font
// + logo assets via rootBundle, so it runs as a widget test (TestWidgetsFlutterBinding).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  GeneratedReport report() => GeneratedReport(
        id: 'r1',
        charityId: 'charity1',
        generatedBy: 'admin1',
        reportType: ReportType.categoryDetail,
        periodStart: DateTime(2030, 6),
        periodEnd: DateTime(2030, 7),
        totalDonations: 3,
        totalQuantity: 42,
        generatedAt: DateTime(2030, 6, 15, 10),
      );

  test('builds non-empty PDF bytes for populated category rows', () async {
    final bytes = await const ReportPdfService().buildCategoryReportPdf(
      report: report(),
      charityName: 'جمعية الخير',
      rows: const [
        CategoryReportRow(category: FoodCategory.mainMeals, quantity: 20, count: 2),
        CategoryReportRow(category: FoodCategory.canned, quantity: 22, count: 1),
      ],
    );

    expect(bytes, isNotEmpty);
  });

  test('builds non-empty PDF bytes for an empty category list without throwing', () async {
    final bytes = await const ReportPdfService().buildCategoryReportPdf(
      report: report(),
      charityName: 'جمعية الخير',
      rows: const [],
    );

    expect(bytes, isNotEmpty);
  });
}
