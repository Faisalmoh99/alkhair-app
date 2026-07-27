import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report_draft.dart';
import 'package:alkhair_app/features/donor/presentation/controllers/report_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/donor_mocks.dart';

// Unit-2 (TEST_PLAN.md Phase 3): GPS capture (FR3) maps to latitude/longitude
// on the submitted draft.
void main() {
  late MockLocationService locationService;
  late MockDonationRepository donationRepository;

  setUpAll(() {
    registerFallbackValue(
      DonationReportDraft(
        foodCategory: FoodCategory.other,
        quantity: 1,
        readinessTime: DateTime(2030),
        latitude: 0,
        longitude: 0,
        safetyConfirmed: true,
      ),
    );
  });

  setUp(() {
    locationService = MockLocationService();
    donationRepository = MockDonationRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        locationServiceProvider.overrideWithValue(locationService),
        donationRepositoryProvider.overrideWithValue(donationRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('captured GPS position maps onto the draft latitude/longitude', () async {
    when(() => locationService.getCurrentLocation())
        .thenAnswer((_) async => right((latitude: 20.5, longitude: 42.75)));
    when(() => donationRepository.submitReport(any()))
        .thenAnswer((_) async => right('rep1'));

    final controller = makeContainer().read(reportControllerProvider.notifier);
    await controller.submit(
      foodCategory: FoodCategory.mainMeals,
      quantity: 3,
      readinessTime: DateTime(2030),
      safetyConfirmed: true,
    );

    final captured = verify(
      () => donationRepository.submitReport(captureAny()),
    ).captured.single as DonationReportDraft;
    expect(captured.latitude, 20.5);
    expect(captured.longitude, 42.75);
  });

  test('a location failure surfaces as an error state and never submits', () async {
    when(() => locationService.getCurrentLocation())
        .thenAnswer((_) async => left(const Failure.permission(action: 'location')));

    final container = makeContainer();
    final controller = container.read(reportControllerProvider.notifier);
    await controller.submit(
      foodCategory: FoodCategory.mainMeals,
      quantity: 3,
      readinessTime: DateTime(2030),
      safetyConfirmed: true,
    );

    expect(
      container.read(reportControllerProvider).phase,
      ReportSubmitPhase.error,
    );
    verifyNever(() => donationRepository.submitReport(any()));
  });
}
