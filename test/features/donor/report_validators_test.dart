import 'package:alkhair_app/features/donor/domain/report_validators.dart';
import 'package:flutter_test/flutter_test.dart';

// Unit-1 (TEST_PLAN.md Phase 3): client validators — quantity > 0, mandatory
// safety checkbox, readiness time. Pure functions, no widget/Firebase.
void main() {
  group('validateQuantity', () {
    test('null is required', () {
      expect(validateQuantity(null), ReportValidationError.required);
    });

    test('zero or negative is notPositive', () {
      expect(validateQuantity(0), ReportValidationError.notPositive);
      expect(validateQuantity(-5), ReportValidationError.notPositive);
    });

    test('above the sane cap is tooLarge', () {
      expect(validateQuantity(100001), ReportValidationError.tooLarge);
    });

    test('a valid quantity passes', () {
      expect(validateQuantity(5), isNull);
    });
  });

  group('validateReadinessTime', () {
    final now = DateTime(2030, 1, 1, 12);

    test('null is required', () {
      expect(validateReadinessTime(null, now: now), ReportValidationError.required);
    });

    test('now or the past is notInFuture', () {
      expect(validateReadinessTime(now, now: now), ReportValidationError.notInFuture);
      expect(
        validateReadinessTime(now.subtract(const Duration(hours: 1)), now: now),
        ReportValidationError.notInFuture,
      );
    });

    test('a future time passes', () {
      expect(
        validateReadinessTime(now.add(const Duration(hours: 1)), now: now),
        isNull,
      );
    });
  });

  group('validateSafetyConfirmed (FR4)', () {
    test('unchecked is required — mandatory', () {
      expect(
        validateSafetyConfirmed(confirmed: false),
        ReportValidationError.required,
      );
    });

    test('checked passes', () {
      expect(validateSafetyConfirmed(confirmed: true), isNull);
    });
  });
}
