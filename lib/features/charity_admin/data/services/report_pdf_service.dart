import 'dart:typed_data';

import 'package:alkhair_app/features/charity_admin/domain/entities/generated_report.dart';
import 'package:alkhair_app/features/charity_admin/presentation/food_category_label.dart';
import 'package:alkhair_app/features/charity_admin/presentation/widgets/category_report_table.dart'
    show CategoryReportRow;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds the exportable category-report PDF (Screen 12, Fig 5.12): Al-Khair
/// mark, charity name, generation date, and the same category table as
/// Screen 10 — client-side, since no export Cloud Function is planned (see
/// memory/project_alkhair_phase6.md). Cairo is bundled as a `pw.Font` because
/// the `pdf` package can't shape Arabic via `google_fonts`' runtime download.
class ReportPdfService {
  const ReportPdfService();

  Future<Uint8List> buildCategoryReportPdf({
    required GeneratedReport report,
    required String charityName,
    required List<CategoryReportRow> rows,
  }) async {
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Bold.ttf'),
    );
    final logoBytes = await rootBundle.load('assets/images/logo_icon.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final doc = pw.Document();
    final dateLabel = DateFormat('yyyy/MM/dd HH:mm').format(report.generatedAt);

    doc.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        charityName,
                        style: pw.TextStyle(font: boldFont, fontSize: 20),
                      ),
                      pw.Text('تاريخ الإنشاء: $dateLabel'),
                    ],
                  ),
                  pw.Image(logo, width: 56, height: 56),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'إجمالي البلاغات المكتملة: ${report.totalDonations}    '
                'إجمالي الكمية: ${report.totalQuantity}',
                style: pw.TextStyle(font: boldFont, fontSize: 14),
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _cell('الفئة', boldFont),
                      _cell('الكمية', boldFont),
                      _cell('عدد البلاغات', boldFont),
                    ],
                  ),
                  for (final row in rows)
                    pw.TableRow(
                      children: [
                        _cell(foodCategoryLabel(row.category), font),
                        _cell('${row.quantity}', font),
                        _cell('${row.count}', font),
                      ],
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _cell(String text, pw.Font font) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text, style: pw.TextStyle(font: font)),
      );
}
