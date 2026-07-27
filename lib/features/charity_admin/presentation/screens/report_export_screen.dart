import 'package:alkhair_app/core/errors/app_error_messages.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/generated_report.dart';
import 'package:alkhair_app/features/charity_admin/presentation/controllers/admin_controllers.dart';
import 'package:alkhair_app/features/charity_admin/presentation/controllers/reports_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

/// Screen 12 (Fig 5.12, FR12) — generates + persists a `Reports` doc for the
/// selected month via [ExportReportController], then previews the resulting
/// PDF (Al-Khair mark, charity name, generation date, category table) with
/// download/share actions.
class ReportExportScreen extends ConsumerWidget {
  const ReportExportScreen({super.key});

  static const _fallbackCharityName = 'الجمعية';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final exportState = ref.watch(exportReportControllerProvider);
    final charityName =
        ref.watch(currentCharityNameProvider).valueOrNull ?? _fallbackCharityName;

    ref.listen(exportReportControllerProvider, (previous, next) {
      if (next.phase == ExportPhase.error && next.failure != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(arabicErrorMessage(next.failure!))));
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.reportCategory),
        ),
        title: const Text('تصدير التقرير'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: switch (exportState.phase) {
                ExportPhase.idle => Center(
                    child: ElevatedButton(
                      onPressed: () => ref
                          .read(exportReportControllerProvider.notifier)
                          .generateAndExport(
                            reportType: ReportType.categoryDetail,
                            periodStart: DateTime(month.year, month.month),
                            periodEnd: DateTime(month.year, month.month + 1),
                            charityName: charityName,
                          ),
                      child: const Text('إنشاء التقرير'),
                    ),
                  ),
                ExportPhase.generating =>
                  const Center(child: CircularProgressIndicator()),
                ExportPhase.error => const Center(child: Text('تعذّر إنشاء التقرير.')),
                ExportPhase.success => exportState.pdfBytes == null
                    ? const Center(child: Text('تعذّر إنشاء التقرير.'))
                    : PdfPreview(
                        build: (format) async => exportState.pdfBytes!,
                        canChangePageFormat: false,
                      ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
