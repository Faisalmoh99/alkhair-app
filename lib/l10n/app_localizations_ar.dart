// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'الخير';

  @override
  String get appTagline => 'منصة توزيع الفائض الغذائي';

  @override
  String get roleDonor => 'متبرع';

  @override
  String get roleVolunteer => 'متطوع';

  @override
  String get roleCharityAdmin => 'مشرف الجمعية';

  @override
  String get statusReported => 'مُسجَّل';

  @override
  String get statusAssigned => 'مُعيَّن';

  @override
  String get statusCollected => 'تم الاستلام';

  @override
  String get statusDelivered => 'تم التسليم';

  @override
  String get statusExpired => 'منتهي';

  @override
  String get categoryMainMeals => 'وجبات رئيسية';

  @override
  String get categoryBakedGoods => 'مخبوزات';

  @override
  String get categoryFruitsAndVegetables => 'فواكه وخضروات';

  @override
  String get categoryCanned => 'معلبات';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get approvalPending => 'في الانتظار';

  @override
  String get approvalApproved => 'مقبول';

  @override
  String get approvalRevoked => 'موقوف';

  @override
  String get errorNetwork =>
      'تعذّر الاتصال بالشبكة. يرجى التحقق من الاتصال والمحاولة مجدداً.';

  @override
  String get errorPermission => 'ليس لديك صلاحية لهذا الإجراء.';

  @override
  String get errorRateLimit =>
      'لقد تجاوزت الحد المسموح به. يرجى المحاولة بعد قليل.';

  @override
  String get errorUnknown => 'حدث خطأ غير متوقع. يرجى المحاولة مجدداً.';

  @override
  String get adminDashboardTitle => 'لوحة الجمعية';

  @override
  String get adminApproveVolunteersTooltip => 'اعتماد المتطوعين';

  @override
  String get adminWeeklyChartTitle => 'البلاغات خلال الأسبوع';

  @override
  String get adminRecentDonationsTitle => 'أحدث البلاغات';

  @override
  String get adminNoDonationsYet => 'لا توجد بلاغات بعد.';

  @override
  String get adminDashboardLoadError => 'تعذّر تحميل بيانات اللوحة.';

  @override
  String get volunteerApprovalTitle => 'اعتماد المتطوعين';

  @override
  String get volunteerApprovalEmpty => 'لا يوجد متطوعون بانتظار الاعتماد.';

  @override
  String get volunteerApprovalLoadError => 'تعذّر تحميل قائمة المتطوعين.';

  @override
  String get volunteerApprovalApprove => 'قبول';

  @override
  String get volunteerApprovalReject => 'رفض';
}
