import 'package:alkhair_app/core/constants/app_constants.dart';

/// Pure, l10n-free client validators (SECURITY.md §4 — client half of double
/// validation for the report form). The screen maps each code to Arabic text;
/// no widget/Firebase dependency here, so these are plain unit-testable
/// functions (TEST_PLAN.md Phase 3 Unit-1).
enum ReportValidationError { required, notPositive, tooLarge, notInFuture }

ReportValidationError? validateQuantity(
  num? quantity, {
  num maxQuantity = kMaxDonationQuantity,
}) {
  if (quantity == null) return ReportValidationError.required;
  if (quantity <= 0) return ReportValidationError.notPositive;
  if (quantity > maxQuantity) return ReportValidationError.tooLarge;
  return null;
}

ReportValidationError? validateReadinessTime(DateTime? time, {DateTime? now}) {
  if (time == null) return ReportValidationError.required;
  if (!time.isAfter(now ?? DateTime.now())) {
    return ReportValidationError.notInFuture;
  }
  return null;
}

ReportValidationError? validateSafetyConfirmed({required bool confirmed}) =>
    confirmed ? null : ReportValidationError.required;
