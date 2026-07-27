import 'package:alkhair_app/core/constants/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';

/// A server-authored `Notifications` doc (Table 4.7). Named `AppNotification`
/// to avoid colliding with Flutter's own `Notification` widget class.
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String userId,
    required String message,
    required NotificationType type,
    required bool isRead,
    required DateTime createdAt,
    String? reportId,
  }) = _AppNotification;

  const AppNotification._();

  /// Built from a plain (id, data) pair rather than a `DocumentSnapshot` — the
  /// SDK type is sealed and can't be mocked, and the entity doesn't need the
  /// rest of the snapshot API.
  factory AppNotification.fromFirestore(String id, Map<String, dynamic> data) {
    return AppNotification(
      id: id,
      userId: data['user_id'] as String,
      reportId: data['report_id'] as String?,
      message: data['message'] as String,
      type: NotificationType.fromFirestore(data['type'] as String),
      isRead: data['is_read'] as bool,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }
}
