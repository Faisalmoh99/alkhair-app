import 'package:alkhair_app/core/constants/app_constants.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Shared bootstrap called by lib/main.dart. See SECURITY.md §6 for the
// USE_EMULATOR / App Check environment setup.
Future<void> bootstrap(FirebaseOptions options) async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase(options);
  runApp(const ProviderScope(child: AlKhairApp()));
}

Future<void> _initFirebase(FirebaseOptions options) async {
  try {
    await Firebase.initializeApp(options: options);
    debugPrint(
      '[Al-Khair] Firebase.initializeApp OK — app="${Firebase.app().name}" '
      'projectId="${Firebase.app().options.projectId}"',
    );
  } on Object catch (e, st) {
    debugPrint('[Al-Khair] Firebase.initializeApp FAILED: $e\n$st');
    return;
  }

  if (kUseEmulator) {
    final host =
        defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';

    try {
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      debugPrint(
        '[Al-Khair] useAuthEmulator OK — auth.app.name="${FirebaseAuth.instance.app.name}" '
        '@ $host:9099',
      );
    } on Object catch (e, st) {
      debugPrint('[Al-Khair] useAuthEmulator FAILED: $e\n$st');
    }

    try {
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8085);
      debugPrint('[Al-Khair] useFirestoreEmulator OK @ $host:8085');
    } on Object catch (e, st) {
      debugPrint('[Al-Khair] useFirestoreEmulator FAILED: $e\n$st');
    }

    try {
      FirebaseFunctions.instanceFor(region: 'europe-west1')
          .useFunctionsEmulator(host, 5001);
      debugPrint('[Al-Khair] useFunctionsEmulator OK @ $host:5001');
    } on Object catch (e, st) {
      debugPrint('[Al-Khair] useFunctionsEmulator FAILED: $e\n$st');
    }
  }

  if (kUseEmulator) {
    try {
      await FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: true,
      );
      debugPrint(
        '[Al-Khair] setSettings(appVerificationDisabledForTesting: true) OK — '
        'auth.app.name="${FirebaseAuth.instance.app.name}" '
        'projectId="${FirebaseAuth.instance.app.options.projectId}"',
      );
    } on Object catch (e, st) {
      debugPrint(
        '[Al-Khair] setSettings(appVerificationDisabledForTesting) FAILED: $e\n$st',
      );
    }
  }

  try {
    // Debug providers only — see ARCHITECTURE.md §6 (consolidation decision):
    // real attestation (Play Integrity / App Attest) is out of scope for the
    // one-time production demo.
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
    debugPrint('[Al-Khair] FirebaseAppCheck.activate OK');
  } on Object catch (e, st) {
    debugPrint('[Al-Khair] FirebaseAppCheck.activate FAILED: $e\n$st');
  }
}

class AlKhairApp extends ConsumerWidget {
  const AlKhairApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'الخير',
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
