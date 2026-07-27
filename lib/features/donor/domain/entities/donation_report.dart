import 'package:alkhair_app/core/constants/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'donation_report.freezed.dart';

/// A donor's surplus-food report (Table 4.6), read back from Firestore.
/// Written only via the `createDonationReport` callable (SECURITY.md §3) —
/// this entity is the read side.
@freezed
class DonationReport with _$DonationReport {
  const factory DonationReport({
    required String id,
    required String donorId,
    required FoodCategory foodCategory,
    required num quantity,
    required DateTime readinessTime,
    required double latitude,
    required double longitude,
    required bool safetyConfirmed,
    required DonationStatus status,
    required DateTime createdAt,
    String? volunteerId,
  }) = _DonationReport;

  const DonationReport._();

  /// Built from a plain (id, data) pair rather than a `DocumentSnapshot` — the
  /// SDK type is sealed and can't be mocked, and the entity doesn't need the
  /// rest of the snapshot API.
  factory DonationReport.fromFirestore(String id, Map<String, dynamic> data) {
    return DonationReport(
      id: id,
      donorId: data['donor_id'] as String,
      volunteerId: data['volunteer_id'] as String?,
      foodCategory: FoodCategory.fromFirestore(data['food_category'] as String),
      quantity: data['quantity'] as num,
      readinessTime: (data['readiness_time'] as Timestamp).toDate(),
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      safetyConfirmed: data['safety_confirmed'] as bool,
      status: DonationStatus.fromFirestore(data['status'] as String),
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }
}
