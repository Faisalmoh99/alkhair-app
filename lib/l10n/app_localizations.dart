import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// Application name
  ///
  /// In ar, this message translates to:
  /// **'الخير'**
  String get appName;

  /// Splash screen tagline
  ///
  /// In ar, this message translates to:
  /// **'منصة توزيع الفائض الغذائي'**
  String get appTagline;

  /// UserRole.donor label
  ///
  /// In ar, this message translates to:
  /// **'متبرع'**
  String get roleDonor;

  /// UserRole.volunteer label
  ///
  /// In ar, this message translates to:
  /// **'متطوع'**
  String get roleVolunteer;

  /// UserRole.charityAdmin label
  ///
  /// In ar, this message translates to:
  /// **'مشرف الجمعية'**
  String get roleCharityAdmin;

  /// DonationStatus.reported
  ///
  /// In ar, this message translates to:
  /// **'مُسجَّل'**
  String get statusReported;

  /// DonationStatus.assigned
  ///
  /// In ar, this message translates to:
  /// **'مُعيَّن'**
  String get statusAssigned;

  /// DonationStatus.collected
  ///
  /// In ar, this message translates to:
  /// **'تم الاستلام'**
  String get statusCollected;

  /// DonationStatus.delivered
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get statusDelivered;

  /// DonationStatus.expired
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get statusExpired;

  /// FoodCategory.mainMeals — Fig 5.9/5.10/5.12
  ///
  /// In ar, this message translates to:
  /// **'وجبات رئيسية'**
  String get categoryMainMeals;

  /// FoodCategory.bakedGoods — Fig 5.9/5.10/5.12
  ///
  /// In ar, this message translates to:
  /// **'مخبوزات'**
  String get categoryBakedGoods;

  /// FoodCategory.fruitsAndVegetables — Fig 5.9/5.10/5.12
  ///
  /// In ar, this message translates to:
  /// **'فواكه وخضروات'**
  String get categoryFruitsAndVegetables;

  /// FoodCategory.canned — Fig 5.9/5.10/5.12
  ///
  /// In ar, this message translates to:
  /// **'معلبات'**
  String get categoryCanned;

  /// FoodCategory.other — Fig 5.9/5.10/5.12
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get categoryOther;

  /// ApprovalStatus.pending
  ///
  /// In ar, this message translates to:
  /// **'في الانتظار'**
  String get approvalPending;

  /// ApprovalStatus.approved
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get approvalApproved;

  /// ApprovalStatus.revoked
  ///
  /// In ar, this message translates to:
  /// **'موقوف'**
  String get approvalRevoked;

  /// NetworkFailure Arabic message
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال بالشبكة. يرجى التحقق من الاتصال والمحاولة مجدداً.'**
  String get errorNetwork;

  /// PermissionFailure Arabic message
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك صلاحية لهذا الإجراء.'**
  String get errorPermission;

  /// RateLimitFailure Arabic message
  ///
  /// In ar, this message translates to:
  /// **'لقد تجاوزت الحد المسموح به. يرجى المحاولة بعد قليل.'**
  String get errorRateLimit;

  /// UnknownFailure Arabic message
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. يرجى المحاولة مجدداً.'**
  String get errorUnknown;

  /// Screen 6 app bar title (FR11)
  ///
  /// In ar, this message translates to:
  /// **'لوحة الجمعية'**
  String get adminDashboardTitle;

  /// Screen 6 nav action to Screen 7
  ///
  /// In ar, this message translates to:
  /// **'اعتماد المتطوعين'**
  String get adminApproveVolunteersTooltip;

  /// Screen 6 weekly-donations chart heading
  ///
  /// In ar, this message translates to:
  /// **'البلاغات خلال الأسبوع'**
  String get adminWeeklyChartTitle;

  /// Screen 6 recent-donations list heading
  ///
  /// In ar, this message translates to:
  /// **'أحدث البلاغات'**
  String get adminRecentDonationsTitle;

  /// Screen 6 empty state
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بلاغات بعد.'**
  String get adminNoDonationsYet;

  /// Screen 6 stream error state
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل بيانات اللوحة.'**
  String get adminDashboardLoadError;

  /// Screen 7 app bar title (FR10)
  ///
  /// In ar, this message translates to:
  /// **'اعتماد المتطوعين'**
  String get volunteerApprovalTitle;

  /// Screen 7 empty state
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد متطوعون بانتظار الاعتماد.'**
  String get volunteerApprovalEmpty;

  /// Screen 7 stream error state
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل قائمة المتطوعين.'**
  String get volunteerApprovalLoadError;

  /// Screen 7 approve action tooltip
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get volunteerApprovalApprove;

  /// Screen 7 reject action tooltip
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get volunteerApprovalReject;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
