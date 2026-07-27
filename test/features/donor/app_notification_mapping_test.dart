import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/donor/domain/entities/app_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Phase 7 Part B (coverage gap): AppNotification.fromFirestore mapping — the
// entity is server-authored/read-only on the client, so this mapper is its
// only unit-testable surface.
void main() {
  group('AppNotification.fromFirestore', () {
    test('maps a Firestore (id, data) pair into the entity', () {
      final createdAt = DateTime(2030, 1, 1, 8);
      final data = {
        'user_id': 'vol1',
        'report_id': 'rep1',
        'message': 'بلاغ جديد بالقرب منك',
        'type': 'new_donation_alert',
        'is_read': false,
        'created_at': Timestamp.fromDate(createdAt),
      };

      final notification = AppNotification.fromFirestore('n1', data);

      expect(notification.id, 'n1');
      expect(notification.userId, 'vol1');
      expect(notification.reportId, 'rep1');
      expect(notification.message, 'بلاغ جديد بالقرب منك');
      expect(notification.type, NotificationType.newDonationAlert);
      expect(notification.isRead, isFalse);
      expect(notification.createdAt, createdAt);
    });

    test('reportId is null when absent (server-authored non-report notifications)', () {
      final data = {
        'user_id': 'vol1',
        'report_id': null,
        'message': 'تم اعتماد حسابك',
        'type': 'account_approved',
        'is_read': true,
        'created_at': Timestamp.fromDate(DateTime(2030)),
      };

      final notification = AppNotification.fromFirestore('n2', data);

      expect(notification.reportId, isNull);
      expect(notification.type, NotificationType.accountApproved);
    });
  });
}
