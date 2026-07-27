import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report_draft.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Unit-3 (TEST_PLAN.md Phase 3): report DTO <-> DonationReports mapping.
void main() {
  group('DonationReportDraft.toCallablePayload', () {
    test('maps every field to the snake_case callable payload', () {
      final readiness = DateTime(2030, 6, 15, 10, 30);
      final draft = DonationReportDraft(
        foodCategory: FoodCategory.bakedGoods,
        quantity: 12,
        readinessTime: readiness,
        latitude: 24.5,
        longitude: 46.7,
        safetyConfirmed: true,
      );

      expect(draft.toCallablePayload(), {
        'food_category': 'baked_goods',
        'quantity': 12,
        'readiness_time': readiness.millisecondsSinceEpoch,
        'latitude': 24.5,
        'longitude': 46.7,
        'safety_confirmed': true,
      });
    });
  });

  group('DonationReport.fromFirestore', () {
    test('maps a Firestore (id, data) pair into the entity', () {
      final createdAt = DateTime(2030, 1, 1, 8);
      final readiness = DateTime(2030, 1, 2, 9);
      final data = {
        'donor_id': 'donor1',
        'volunteer_id': null,
        'food_category': 'fruits_and_vegetables',
        'quantity': 7,
        'readiness_time': Timestamp.fromDate(readiness),
        'latitude': 21.0,
        'longitude': 41.0,
        'safety_confirmed': true,
        'status': 'assigned',
        'created_at': Timestamp.fromDate(createdAt),
      };

      final report = DonationReport.fromFirestore('rep1', data);

      expect(report.id, 'rep1');
      expect(report.donorId, 'donor1');
      expect(report.volunteerId, isNull);
      expect(report.foodCategory, FoodCategory.fruitsAndVegetables);
      expect(report.quantity, 7);
      expect(report.readinessTime, readiness);
      expect(report.latitude, 21.0);
      expect(report.longitude, 41.0);
      expect(report.safetyConfirmed, isTrue);
      expect(report.status, DonationStatus.assigned);
      expect(report.createdAt, createdAt);
    });
  });
}
