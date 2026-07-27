// All domain enums — sourced from Chapter Four data dictionary (Tables 4.2–4.8).
// Dart names are camelCase; Firestore/JSON values are snake_case via json_serializable.

/// Users.role (Table 4.2).
enum UserRole {
  donor,
  volunteer,
  charityAdmin;

  String get firestoreValue => switch (this) {
        UserRole.donor => 'donor',
        UserRole.volunteer => 'volunteer',
        UserRole.charityAdmin => 'charity_admin',
      };

  static UserRole fromFirestore(String v) => switch (v) {
        'donor' => UserRole.donor,
        'volunteer' => UserRole.volunteer,
        'charity_admin' => UserRole.charityAdmin,
        _ => throw ArgumentError('Unknown UserRole: $v'),
      };
}

/// Volunteers.approval_status (Table 4.3).
enum ApprovalStatus {
  pending,
  approved,
  revoked;

  String get firestoreValue => name; // pending | approved | revoked

  static ApprovalStatus fromFirestore(String v) =>
      values.firstWhere((e) => e.name == v, orElse: () => throw ArgumentError('Unknown ApprovalStatus: $v'));
}

/// DonationReports.status (Table 4.6).
/// Transitions: reported → assigned → collected → delivered | reported → expired.
/// UI Arabic labels are defined in app_ar.arb; this enum is the data-layer source of truth.
enum DonationStatus {
  reported,
  assigned,
  collected,
  delivered,
  expired;

  String get firestoreValue => name;

  static DonationStatus fromFirestore(String v) =>
      values.firstWhere((e) => e.name == v, orElse: () => throw ArgumentError('Unknown DonationStatus: $v'));
}

/// DonationReports.food_category (Table 4.6).
/// The five values below are authoritative: they appear consistently in Chapter Five
/// Figures 5.9, 5.10, and 5.12 (monthly summary pie chart, category-detail table,
/// and PDF export layout). Arabic labels: وجبات رئيسية / مخبوزات / فواكه وخضروات /
/// معلبات / أخرى — stored as snake_case in Firestore.
enum FoodCategory {
  mainMeals,
  bakedGoods,
  fruitsAndVegetables,
  canned,
  other;

  String get firestoreValue => switch (this) {
        FoodCategory.mainMeals => 'main_meals',
        FoodCategory.bakedGoods => 'baked_goods',
        FoodCategory.fruitsAndVegetables => 'fruits_and_vegetables',
        FoodCategory.canned => 'canned',
        FoodCategory.other => 'other',
      };

  static FoodCategory fromFirestore(String v) => switch (v) {
        'main_meals' => FoodCategory.mainMeals,
        'baked_goods' => FoodCategory.bakedGoods,
        'fruits_and_vegetables' => FoodCategory.fruitsAndVegetables,
        'canned' => FoodCategory.canned,
        'other' => FoodCategory.other,
        _ => throw ArgumentError('Unknown FoodCategory: $v'),
      };
}

/// Notifications.type (Table 4.7 — "such as new donation alert or status update").
enum NotificationType {
  newDonationAlert,
  statusUpdate,
  accountApproved,
  accountRevoked,
  general;

  String get firestoreValue => switch (this) {
        NotificationType.newDonationAlert => 'new_donation_alert',
        NotificationType.statusUpdate => 'status_update',
        NotificationType.accountApproved => 'account_approved',
        NotificationType.accountRevoked => 'account_revoked',
        NotificationType.general => 'general',
      };

  static NotificationType fromFirestore(String v) => switch (v) {
        'new_donation_alert' => NotificationType.newDonationAlert,
        'status_update' => NotificationType.statusUpdate,
        'account_approved' => NotificationType.accountApproved,
        'account_revoked' => NotificationType.accountRevoked,
        'general' => NotificationType.general,
        _ => NotificationType.general,
      };
}
