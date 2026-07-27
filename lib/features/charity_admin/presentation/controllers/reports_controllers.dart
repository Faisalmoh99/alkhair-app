import 'dart:typed_data';

import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/charity_admin/data/services/report_pdf_service.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/generated_report.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/monthly_summary.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/volunteer_ranking.dart';
import 'package:alkhair_app/features/charity_admin/presentation/controllers/admin_controllers.dart';
import 'package:alkhair_app/features/charity_admin/presentation/widgets/category_report_table.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reports_controllers.g.dart';

/// The month selected on Screen 9/10 (FR12). `keepAlive` is deliberate: the
/// selection must survive navigation from Screen 10 to the Screen 12 export
/// so the exported PDF's period matches what the admin was looking at — the
/// same ref.watch/ref.read lesson from this project's E2E bug (a value only
/// ever `ref.read` in a callback doesn't survive a screen transition).
@Riverpod(keepAlive: true)
class SelectedMonth extends _$SelectedMonth {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void next() => state = DateTime(state.year, state.month + 1);

  void previous() => state = DateTime(state.year, state.month - 1);
}

/// Screens 9 & 10's shared aggregation (FR12) — both watch this with the
/// same [month] so their totals always reconcile (see monthly_summary.dart).
@riverpod
Stream<MonthlySummary> monthlySummary(
  MonthlySummaryRef ref, {
  required DateTime month,
}) {
  return ref
      .watch(charityAdminRepositoryProvider)
      .watchAllReports()
      .map((reports) => computeMonthlySummary(reports, month: month));
}

/// Screen 11's all-time volunteer leaderboard (FR12).
@riverpod
Stream<List<VolunteerRanking>> volunteerPerformance(VolunteerPerformanceRef ref) {
  final repo = ref.watch(charityAdminRepositoryProvider);
  return repo.watchAllReports().asyncMap((reports) async {
    final volunteers = await repo.watchApprovedVolunteers().first;
    return computeVolunteerPerformance(reports, volunteers);
  });
}

/// Screen 8's directory of previously generated reports (FR12). The
/// `charity_id` filter is mandatory, not optional — see the doc comment on
/// `CharityAdminRepository.watchGeneratedReports` (Phase 7 follow-up fix).
/// Emits an empty list (mirrors the "not yet generated" empty state) while
/// the admin's charity_id is still resolving, rather than an error state.
@riverpod
Stream<List<GeneratedReport>> generatedReports(GeneratedReportsRef ref) async* {
  final charityId = await ref.watch(currentCharityIdProvider.future);
  if (charityId == null) {
    yield const [];
    return;
  }
  yield* ref.watch(charityAdminRepositoryProvider).watchGeneratedReports(charityId);
}

enum ExportPhase { idle, generating, success, error }

class ExportReportState {
  const ExportReportState({
    this.phase = ExportPhase.idle,
    this.failure,
    this.result,
    this.pdfBytes,
  });

  final ExportPhase phase;
  final Failure? failure;
  final GeneratedReport? result;
  final Uint8List? pdfBytes;

  ExportReportState copyWith({
    ExportPhase? phase,
    Failure? failure,
    GeneratedReport? result,
    Uint8List? pdfBytes,
    bool clearFailure = false,
  }) {
    return ExportReportState(
      phase: phase ?? this.phase,
      failure: clearFailure ? null : (failure ?? this.failure),
      result: result ?? this.result,
      pdfBytes: pdfBytes ?? this.pdfBytes,
    );
  }
}

/// Drives Screen 12's export action (FR12): calls the server-only
/// `generateReport` callable, then builds the client-side PDF. The result and
/// PDF bytes live in watched controller state — not a local variable read
/// once in a callback — so they survive rebuilds/navigation (ref.watch/
/// ref.read lesson).
@riverpod
class ExportReportController extends _$ExportReportController {
  @override
  ExportReportState build() => const ExportReportState();

  Future<void> generateAndExport({
    required ReportType reportType,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String charityName,
  }) async {
    state = state.copyWith(
      phase: ExportPhase.generating,
      clearFailure: true,
    );

    final result = await ref.read(charityAdminRepositoryProvider).generateReport(
          reportType: reportType,
          periodStart: periodStart,
          periodEnd: periodEnd,
        );

    await result.fold(
      (failure) async {
        state = state.copyWith(phase: ExportPhase.error, failure: failure);
      },
      (report) async {
        final summary = computeMonthlySummary(
          await ref
              .read(charityAdminRepositoryProvider)
              .watchAllReports()
              .first,
          month: periodStart,
        );
        final bytes = await const ReportPdfService().buildCategoryReportPdf(
          report: report,
          charityName: charityName,
          rows: categoryReportRows(summary),
        );
        state = state.copyWith(
          phase: ExportPhase.success,
          result: report,
          pdfBytes: bytes,
          clearFailure: true,
        );
      },
    );
  }

  void reset() => state = const ExportReportState();
}
