import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/app_error_messages.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/donor/data/services/location_service.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:alkhair_app/features/volunteer/presentation/controllers/delivery_controller.dart';
import 'package:alkhair_app/features/volunteer/presentation/controllers/volunteer_feed_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen 5 (Fig 5.5, FR8/FR9) — navigation + pickup/delivery confirmation.
/// FR8's "turn-by-turn navigation" is delivered by handing off to the
/// device's native maps app (real turn-by-turn); the embedded map here draws
/// the route line and distance/ETA header exactly as Ch.5 §5.2.3 describes,
/// without reimplementing a navigation engine (see ARCHITECTURE.md §6).
class VolunteerNavScreen extends ConsumerWidget {
  const VolunteerNavScreen({required this.reportId, super.key});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(deliveryControllerProvider, (previous, next) {
      if (next.phase == DeliveryPhase.delivered) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('تم تسليم الطعام بنجاح.')));
        context.go(Routes.volunteerHome);
      } else if (next.phase == DeliveryPhase.error && next.failure != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(arabicErrorMessage(next.failure!))));
      }
    });

    final reportAsync = ref.watch(watchedReportProvider(reportId));
    final locationAsync = ref.watch(volunteerLocationProvider);
    final deliveryState = ref.watch(deliveryControllerProvider);
    final isBusy = deliveryState.phase == DeliveryPhase.confirming;

    return Scaffold(
      appBar: AppBar(title: const Text('التوجيه والتسليم')),
      body: SafeArea(
        child: reportAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('تعذّر تحميل البلاغ.')),
          data: (report) {
            if (report == null) {
              return const Center(child: Text('لم يعد هذا البلاغ متاحاً.'));
            }
            final position = locationAsync.asData?.value;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('الحالة: ${_statusLabel(report.status)}'),
                const SizedBox(height: 8),
                _DistanceHeader(report: report, volunteerPosition: position),
                const SizedBox(height: 16),
                SizedBox(
                  height: 260,
                  child: position == null
                      ? const _LocatingPlaceholder()
                      : _RouteMap(report: report, volunteerPosition: position),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed:
                      position == null ? null : () => _launchNavigation(report),
                  icon: const Icon(Icons.navigation),
                  label: const Text('بدء التوجيه'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: (report.status == DonationStatus.assigned && !isBusy)
                      ? () => ref
                          .read(deliveryControllerProvider.notifier)
                          .confirmCollection(reportId)
                      : null,
                  child: const Text('تأكيد الاستلام'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: (report.status == DonationStatus.collected && !isBusy)
                      ? () => ref
                          .read(deliveryControllerProvider.notifier)
                          .confirmDelivery(reportId)
                      : null,
                  child: const Text('تأكيد التسليم'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// FR8: external handoff to the device's native maps app for real
// turn-by-turn guidance. The universal Google Maps URL works across
// Android/iOS regardless of which maps app is installed.
Future<void> _launchNavigation(DonationReport report) async {
  final uri = Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '${report.latitude},${report.longitude}',
    'travelmode': 'driving',
  });
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _DistanceHeader extends StatelessWidget {
  const _DistanceHeader({required this.report, required this.volunteerPosition});

  final DonationReport report;
  final GeoPosition? volunteerPosition;

  @override
  Widget build(BuildContext context) {
    final position = volunteerPosition;
    if (position == null) {
      return const Text('يتم تحديد موقعك...');
    }
    final meters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      report.latitude,
      report.longitude,
    );
    final km = meters / 1000;
    // Offline rough ETA (no Directions API call) — average 30 km/h.
    final etaMinutes = (km / 30 * 60).round();
    return Row(
      children: [
        Text('${km.toStringAsFixed(1)} كم'),
        const SizedBox(width: 12),
        Text('~ $etaMinutes دقيقة'),
      ],
    );
  }
}

class _LocatingPlaceholder extends StatelessWidget {
  const _LocatingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFEEEEEE),
      child: Center(child: Text('يتم تحديد موقعك...')),
    );
  }
}

// The embedded GoogleMap (Fig 5.5): donor + volunteer markers and a straight
// route line. No Directions-API polyline yet (deferred — needs network + a
// live Maps key); the distance/ETA header above is computed offline.
class _RouteMap extends StatelessWidget {
  const _RouteMap({required this.report, required this.volunteerPosition});

  final DonationReport report;
  final GeoPosition volunteerPosition;

  @override
  Widget build(BuildContext context) {
    final donorLatLng = LatLng(report.latitude, report.longitude);
    final volunteerLatLng =
        LatLng(volunteerPosition.latitude, volunteerPosition.longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: donorLatLng, zoom: 13),
        markers: {
          Marker(markerId: const MarkerId('donor'), position: donorLatLng),
          Marker(
            markerId: const MarkerId('volunteer'),
            position: volunteerLatLng,
          ),
        },
        polylines: {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [volunteerLatLng, donorLatLng],
            color: Colors.blue,
            width: 4,
          ),
        },
      ),
    );
  }
}

String _statusLabel(DonationStatus status) => switch (status) {
      DonationStatus.reported => 'مُسجَّل',
      DonationStatus.assigned => 'مُعيَّن',
      DonationStatus.collected => 'تم الاستلام',
      DonationStatus.delivered => 'تم التسليم',
      DonationStatus.expired => 'منتهي',
    };
