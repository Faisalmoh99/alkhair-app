import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/volunteer/presentation/controllers/delivery_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/donor_mocks.dart';

// Screen 5's sequential confirm lifecycle (TEST_PLAN.md Phase 4 Unit, FR9).
void main() {
  late MockDonationRepository repo;

  setUp(() => repo = MockDonationRepository());

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [donationRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('confirmCollection success sets phase=collected', () async {
    when(() => repo.confirmCollection('rep1')).thenAnswer((_) async => right(unit));
    final container = makeContainer();
    final controller = container.read(deliveryControllerProvider.notifier);

    await controller.confirmCollection('rep1');

    expect(container.read(deliveryControllerProvider).phase, DeliveryPhase.collected);
  });

  test('confirmDelivery success sets phase=delivered', () async {
    when(() => repo.confirmDelivery('rep1')).thenAnswer((_) async => right(unit));
    final container = makeContainer();
    final controller = container.read(deliveryControllerProvider.notifier);

    await controller.confirmDelivery('rep1');

    expect(container.read(deliveryControllerProvider).phase, DeliveryPhase.delivered);
  });

  test('a stale-status conflict on confirmCollection surfaces as the error phase', () async {
    when(() => repo.confirmCollection('rep1')).thenAnswer(
      (_) async => left(const Failure.conflict(reason: 'stale_status')),
    );
    final container = makeContainer();
    final controller = container.read(deliveryControllerProvider.notifier);

    await controller.confirmCollection('rep1');

    final state = container.read(deliveryControllerProvider);
    expect(state.phase, DeliveryPhase.error);
    expect(state.failure, const Failure.conflict(reason: 'stale_status'));
  });
}
