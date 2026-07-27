import 'package:alkhair_app/core/constants/enums.dart';
import 'package:flutter_test/flutter_test.dart';

// Round-trip tests: firestoreValue → fromFirestore must recover the original variant.
// Covers all enums used by the 7 domain collections (Tables 4.2–4.8).

void main() {
  // ── UserRole (Users.role — Table 4.2) ────────────────────────────────────
  group('UserRole', () {
    test('round-trips for all values', () {
      for (final role in UserRole.values) {
        expect(UserRole.fromFirestore(role.firestoreValue), role);
      }
    });

    test('donor → "donor"', () {
      expect(UserRole.donor.firestoreValue, 'donor');
    });

    test('volunteer → "volunteer"', () {
      expect(UserRole.volunteer.firestoreValue, 'volunteer');
    });

    test('charityAdmin → "charity_admin"', () {
      expect(UserRole.charityAdmin.firestoreValue, 'charity_admin');
    });

    test('unknown value throws', () {
      expect(() => UserRole.fromFirestore('superadmin'), throwsArgumentError);
    });
  });

  // ── ApprovalStatus (Volunteers.approval_status — Table 4.3) ──────────────
  group('ApprovalStatus', () {
    test('round-trips for all values', () {
      for (final s in ApprovalStatus.values) {
        expect(ApprovalStatus.fromFirestore(s.firestoreValue), s);
      }
    });

    test('pending → "pending"', () {
      expect(ApprovalStatus.pending.firestoreValue, 'pending');
    });

    test('approved → "approved"', () {
      expect(ApprovalStatus.approved.firestoreValue, 'approved');
    });

    test('revoked → "revoked"', () {
      expect(ApprovalStatus.revoked.firestoreValue, 'revoked');
    });

    test('unknown value throws', () {
      expect(() => ApprovalStatus.fromFirestore('banned'), throwsArgumentError);
    });
  });

  // ── DonationStatus (DonationReports.status — Table 4.6) ──────────────────
  group('DonationStatus', () {
    test('round-trips for all values', () {
      for (final s in DonationStatus.values) {
        expect(DonationStatus.fromFirestore(s.firestoreValue), s);
      }
    });

    test('reported → "reported"', () {
      expect(DonationStatus.reported.firestoreValue, 'reported');
    });

    test('assigned → "assigned"', () {
      expect(DonationStatus.assigned.firestoreValue, 'assigned');
    });

    test('collected → "collected"', () {
      expect(DonationStatus.collected.firestoreValue, 'collected');
    });

    test('delivered → "delivered"', () {
      expect(DonationStatus.delivered.firestoreValue, 'delivered');
    });

    test('expired → "expired"', () {
      expect(DonationStatus.expired.firestoreValue, 'expired');
    });

    test('unknown value throws', () {
      expect(() => DonationStatus.fromFirestore('cancelled'), throwsArgumentError);
    });
  });

  // ── FoodCategory (DonationReports.food_category — Table 4.6, Fig 5.9/5.10/5.12) ──
  group('FoodCategory', () {
    test('exactly 5 values — matches Figs 5.9, 5.10, 5.12', () {
      expect(FoodCategory.values.length, 5);
    });

    test('round-trips for all values', () {
      for (final c in FoodCategory.values) {
        expect(FoodCategory.fromFirestore(c.firestoreValue), c);
      }
    });

    test('mainMeals → "main_meals"', () {
      expect(FoodCategory.mainMeals.firestoreValue, 'main_meals');
    });

    test('bakedGoods → "baked_goods"', () {
      expect(FoodCategory.bakedGoods.firestoreValue, 'baked_goods');
    });

    test('fruitsAndVegetables → "fruits_and_vegetables"', () {
      expect(FoodCategory.fruitsAndVegetables.firestoreValue, 'fruits_and_vegetables');
    });

    test('canned → "canned"', () {
      expect(FoodCategory.canned.firestoreValue, 'canned');
    });

    test('other → "other"', () {
      expect(FoodCategory.other.firestoreValue, 'other');
    });

    test('unknown value throws', () {
      expect(() => FoodCategory.fromFirestore('dairy'), throwsArgumentError);
    });
  });

  // ── NotificationType (Notifications.type — Table 4.7) ────────────────────
  group('NotificationType', () {
    test('round-trips for all values except general fallback', () {
      final nonFallback = NotificationType.values.where((e) => e != NotificationType.general);
      for (final t in nonFallback) {
        expect(NotificationType.fromFirestore(t.firestoreValue), t);
      }
    });

    test('newDonationAlert → "new_donation_alert"', () {
      expect(NotificationType.newDonationAlert.firestoreValue, 'new_donation_alert');
    });

    test('statusUpdate → "status_update"', () {
      expect(NotificationType.statusUpdate.firestoreValue, 'status_update');
    });

    test('accountApproved → "account_approved"', () {
      expect(NotificationType.accountApproved.firestoreValue, 'account_approved');
    });

    test('accountRevoked → "account_revoked"', () {
      expect(NotificationType.accountRevoked.firestoreValue, 'account_revoked');
    });

    test('unknown value falls back to general (not an error — forward-compat)', () {
      expect(NotificationType.fromFirestore('some_future_type'), NotificationType.general);
    });
  });
}
