import 'package:alkhair_app/features/charity_admin/domain/entities/generated_report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Phase 7 Part B (coverage gap): GeneratedReport.fromFirestore mapping and
// ReportType round-tripping — the Reports doc (Table 4.8) is read-only on
// the client, so this is the entity's only unit-testable surface.
void main() {
  group('GeneratedReport.fromFirestore', () {
    test('maps a Firestore (id, data) pair into the entity', () {
      final periodStart = DateTime(2030, 6);
      final periodEnd = DateTime(2030, 7);
      final generatedAt = DateTime(2030, 6, 15, 9);
      final data = {
        'charity_id': 'albirr-bisha',
        'generated_by': 'admin1',
        'report_type': 'categoryDetail',
        'period_start': Timestamp.fromDate(periodStart),
        'period_end': Timestamp.fromDate(periodEnd),
        'total_donations': 12,
        'total_quantity': 340,
        'generated_at': Timestamp.fromDate(generatedAt),
      };

      final report = GeneratedReport.fromFirestore('r1', data);

      expect(report.id, 'r1');
      expect(report.charityId, 'albirr-bisha');
      expect(report.generatedBy, 'admin1');
      expect(report.reportType, ReportType.categoryDetail);
      expect(report.periodStart, periodStart);
      expect(report.periodEnd, periodEnd);
      expect(report.totalDonations, 12);
      expect(report.totalQuantity, 340);
      expect(report.generatedAt, generatedAt);
    });
  });

  group('ReportType', () {
    test('firestoreValue/fromFirestore round-trip for every value', () {
      for (final type in ReportType.values) {
        expect(ReportType.fromFirestore(type.firestoreValue), type);
      }
    });

    test('fromFirestore throws on an unknown value', () {
      expect(() => ReportType.fromFirestore('unknown'), throwsArgumentError);
    });
  });
}
