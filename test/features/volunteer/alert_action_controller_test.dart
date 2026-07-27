import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/volunteer/presentation/controllers/alert_action_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/donor_mocks.dart';

// Screen 4's accept lifecycle (TEST_PLAN.md Phase 4 Unit): success sets the
// report id for navigation; a ConflictFailure (the repository's race-safety
// signal) maps to alreadyTaken rather than the generic error phase.
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

  test('accept success sets phase=success with the accepted reportId', () async {
    when(() => repo.acceptReport('rep1', 'vol1'))
        .thenAnswer((_) async => right(unit));
    final container = makeContainer();
    final controller = container.read(alertActionControllerProvider.notifier);

    await controller.accept(reportId: 'rep1', volunteerId: 'vol1');

    final state = container.read(alertActionControllerProvider);
    expect(state.phase, AlertActionPhase.success);
    expect(state.reportId, 'rep1');
  });

  test('a ConflictFailure maps to alreadyTaken, not the generic error phase', () async {
    when(() => repo.acceptReport('rep1', 'vol1')).thenAnswer(
      (_) async => left(const Failure.conflict(reason: 'already_assigned')),
    );
    final container = makeContainer();
    final controller = container.read(alertActionControllerProvider.notifier);

    await controller.accept(reportId: 'rep1', volunteerId: 'vol1');

    expect(
      container.read(alertActionControllerProvider).phase,
      AlertActionPhase.alreadyTaken,
    );
  });

  test('any other failure maps to the generic error phase', () async {
    when(() => repo.acceptReport('rep1', 'vol1'))
        .thenAnswer((_) async => left(const Failure.network()));
    final container = makeContainer();
    final controller = container.read(alertActionControllerProvider.notifier);

    await controller.accept(reportId: 'rep1', volunteerId: 'vol1');

    final state = container.read(alertActionControllerProvider);
    expect(state.phase, AlertActionPhase.error);
    expect(state.failure, const Failure.network());
  });
}
