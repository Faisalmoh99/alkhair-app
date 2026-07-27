import 'package:alkhair_app/core/constants/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'donation_report_draft.freezed.dart';

/// What Screen 2 collects before calling the `createDonationReport` callable.
/// Server-assigned fields (donor_id, status, created_at, volunteer_id) are
/// deliberately absent — the callable derives/forces them (SECURITY.md §3).
@freezed
class DonationReportDraft with _$DonationReportDraft {
  const factory DonationReportDraft({
    required FoodCategory foodCategory,
    required num quantity,
    required DateTime readinessTime,
    required double latitude,
    required double longitude,
    required bool safetyConfirmed,
  }) = _DonationReportDraft;

  const DonationReportDraft._();

  /// snake_case payload for the `createDonationReport` callable.
  Map<String, dynamic> toCallablePayload() => {
        'food_category': foodCategory.firestoreValue,
        'quantity': quantity,
        'readiness_time': readinessTime.millisecondsSinceEpoch,
        'latitude': latitude,
        'longitude': longitude,
        'safety_confirmed': safetyConfirmed,
      };
}
