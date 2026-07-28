import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Regression test for the Android counterpart of the Phase 7 iOS
// NSLocationWhenInUseUsageDescription gap: GeolocatorLocationService
// (shared by donor report submission and the volunteer manual location
// refresh) throws at runtime without these manifest permissions, but
// that failure can't be caught by the mocked LocationService unit tests
// (see location_capture_test.dart) — only by checking the manifest itself.
void main() {
  test('AndroidManifest.xml declares the location permissions Geolocator needs', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

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
}
