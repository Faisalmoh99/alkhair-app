import 'package:alkhair_app/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';

/// A captured GPS fix (FR3).
typedef GeoPosition = ({double latitude, double longitude});

/// Abstraction over `geolocator`, so the report controller is testable
/// without touching real device location services (TEST_PLAN.md Phase 3
/// Unit-2). The device-concrete implementation is [GeolocatorLocationService].
// ignore: one_member_abstracts
abstract interface class LocationService {
  Future<Either<Failure, GeoPosition>> getCurrentLocation();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<Either<Failure, GeoPosition>> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return left(
        const Failure.permission(action: 'location_service_disabled'),
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return left(const Failure.permission(action: 'location'));
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return right(
        (latitude: position.latitude, longitude: position.longitude),
      );
    } on Exception catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }
}
