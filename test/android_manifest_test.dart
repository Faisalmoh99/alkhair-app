import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Regression tests for Android-native config that has no Dart-level
// equivalent to unit-test, and has bitten this project before: all prior
// E2E testing ran on iOS Simulator only, so gaps in AndroidManifest.xml
// went unnoticed until an actual Android run crashed or silently failed.
void main() {
  late String manifest;

  setUpAll(() {
    manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
  });

  test('AndroidManifest.xml declares the location permissions Geolocator needs', () {
    // Counterpart of the Phase 7 iOS NSLocationWhenInUseUsageDescription gap:
    // GeolocatorLocationService (shared by donor report submission and the
    // volunteer manual location refresh) throws at runtime without these —
    // a failure the mocked LocationService unit tests can't catch
    // (see location_capture_test.dart).
    expect(
      manifest,
      contains('android.permission.ACCESS_FINE_LOCATION'),
      reason: 'Geolocator.getCurrentPosition/requestPermission requires this permission '
          'to be declared, or it throws at runtime on Android.',
    );
    expect(
      manifest,
      contains('android.permission.ACCESS_COARSE_LOCATION'),
      reason: 'Geolocator.getCurrentPosition/requestPermission requires this permission '
          'to be declared, or it throws at runtime on Android.',
    );
  });

  test('AndroidManifest.xml declares INTERNET permission', () {
    // No firebase_core/google_maps_flutter plugin manifest bundles this —
    // confirmed by inspecting their AndroidManifest.xml in pub-cache. Without
    // it, every network call (Firebase Auth/Firestore/Functions/FCM, Maps
    // tiles) fails on Android. iOS needs no Info.plist equivalent (HTTPS
    // access is sandboxed-default).
    expect(manifest, contains('android.permission.INTERNET'));
  });

  test('AndroidManifest.xml wires the Maps API key meta-data', () {
    // GoogleMap widget throws IllegalStateException("API key not found") at
    // runtime without this, mirroring iOS's Info.plist GMSApiKey.
    expect(manifest, contains('com.google.android.geo.API_KEY'));
    expect(manifest, contains(r'${MAPS_API_KEY_ANDROID}'));
  });
}
