import Flutter
import FirebaseAuth
import GoogleMaps
import UIKit

// FlutterAppDelegate hardcodes didReceiveRemoteNotification as a "plugin-handled"
// selector: -respondsToSelector: for it only reports true if a registered
// FlutterApplicationLifeCycleDelegate responds to it, regardless of what
// AppDelegate itself implements. Registering this as a life cycle delegate is
// what lets FirebaseAuth's notification-forwarding probe see it, and returning
// false when Auth doesn't own the notification keeps FCM delivery to
// FLTFirebaseMessagingPlugin (also in the fan-out list) working as before.
private class AuthRemoteNotificationForwarder: NSObject, FlutterApplicationLifeCycleDelegate {
  func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) -> Bool {
    guard Auth.auth().canHandleNotification(userInfo) else { return false }
    completionHandler(.noData)
    return true
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let authNotificationForwarder = AuthRemoteNotificationForwarder()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Must run before super.application(...) — that's what registers the
    // google_maps_flutter plugin, and GMSServices crashes (EXC_CRASH/SIGABRT)
    // if a GoogleMap widget initializes before a key is provided. The key
    // itself comes from Info.plist's GMSApiKey, substituted at build time
    // from MAPS_API_KEY_IOS in Secrets.xcconfig (SECURITY.md §6 — never
    // committed, dart-define alone can't reach native code at this point
    // since Dart hasn't started running yet).
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !apiKey.isEmpty {
      GMSServices.provideAPIKey(apiKey)
    }

    // addApplicationLifeCycleDelegate(_:) is declared on FlutterAppDelegate via the
    // FlutterAppLifeCycleProvider protocol, but isn't visible to Swift's ClangImporter
    // here — dispatch it dynamically instead.
    _ = self.perform(
      NSSelectorFromString("addApplicationLifeCycleDelegate:"),
      with: authNotificationForwarder
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
