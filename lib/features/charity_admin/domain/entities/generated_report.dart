import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated_report.freezed.dart';

/// Report type persisted alongside a [GeneratedReport] — an extension beyond
/// Table 4.8's documented fields, needed so Screen 8 can show a distinct
/// "last refreshed" per report type (see memory/project_alkhair_phase6.md).
enum ReportType {
  monthlySummary,
  categoryDetail,
  volunteerPerformance;

  String get firestoreValue => name;

  static ReportType fromFirestore(String v) => values.firstWhere(
        (e) => e.name == v,
        orElse: () => throw ArgumentError('Unknown ReportType: $v'),
      );
}

/// A persisted `Reports` document (Table 4.8), written only by the
/// `generateReport` callable on export (Screen 12). Read side only — writes
/// are server-only (firestore.rules `Reports.write: false`).
@freezed
class GeneratedReport with _$GeneratedReport {
  const factory GeneratedReport({
    required String id,
    required String charityId,
    required String generatedBy,
    required ReportType reportType,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int totalDonations,
    required num totalQuantity,
    required DateTime generatedAt,
  }) = _GeneratedReport;

  const GeneratedReport._();

  factory GeneratedReport.fromFirestore(String id, Map<String, dynamic> data) {
    return GeneratedReport(
      id: id,
      charityId: data['charity_id'] as String,
      generatedBy: data['generated_by'] as String,
      reportType: ReportType.fromFirestore(data['report_type'] as String),
      periodStart: (data['period_start'] as Timestamp).toDate(),
      periodEnd: (data['period_end'] as Timestamp).toDate(),
      totalDonations: data['total_donations'] as int,
      totalQuantity: data['total_quantity'] as num,
      generatedAt: (data['generated_at'] as Timestamp).toDate(),
    );
  }
}
