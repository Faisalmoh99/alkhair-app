// Compile-time environment constants injected via --dart-define.
// Usage:
//   flutter run  --dart-define=USE_EMULATOR=false
//
// See SECURITY.md §6 for the full list of expected env variables.

// When true, the app connects to the local Firebase Emulator Suite instead of
// real cloud Firebase. Default ON so phone auth works on the Simulator
// (the Auth emulator skips native APNs/reCAPTCHA verification, which crashes
// on-device there). Opt out for real-cloud testing/demo:
//   --dart-define=USE_EMULATOR=false
const bool kUseEmulator = bool.fromEnvironment('USE_EMULATOR', defaultValue: true);

// Firestore collection names — the 7 domain collections from Table 4.2–4.8.
// Update here first if Firestore collection naming ever changes.
abstract final class Collections {
  static const String users = 'Users';
  static const String volunteers = 'Volunteers';
  static const String charityAdmins = 'CharityAdmins';
  static const String charities = 'Charities';
  static const String donationReports = 'DonationReports';
  static const String notifications = 'Notifications';
  static const String reports = 'Reports';
  // Internal technical collection (approved exception — see SECURITY.md §3):
  static const String rateLimits = 'RateLimits';
}

// Volunteer dispatch radius (FR6 — "configurable radius").
// ASSUMPTION: default 10 km; this value should be moved to Firestore remote config in production.
const double kDefaultDispatchRadiusKm = 10;

// Minimum time the splash screen stays visible after launch, regardless of
// how fast the auth stage resolves (demo/recording readability).
const Duration kMinSplashDuration = Duration(seconds: 2);

// DonationReports.quantity sane upper bound (SECURITY.md §4). Mirrored in
// firestore.rules and in the createDonationReport callable's own validation
// (functions/src/create_donation_report.ts) — kept in sync by hand since the
// two runtimes can't share a constant.
const num kMaxDonationQuantity = 100000;

// Maps API key placeholders — replaced via --dart-define in CI/CD (SECURITY.md §6).
const String kMapsApiKeyAndroid = String.fromEnvironment('MAPS_API_KEY_ANDROID');
const String kMapsApiKeyIos = String.fromEnvironment('MAPS_API_KEY_IOS');
const String kMapsApiKeyWeb = String.fromEnvironment('MAPS_API_KEY_WEB');
