import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_mocks.dart';

// OTP state machine (SECURITY.md §1.2 / TEST_PLAN.md 2c).
void main() {
  late MockAuthRepository repo;

  setUp(() => repo = MockAuthRepository());

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('requestOtp success → OTP_SENT with verificationId', () async {
    when(() => repo.requestOtp(any())).thenAnswer((_) async => right('vid123'));
    final container = makeContainer();
    final controller = container.read(authControllerProvider.notifier);

    await controller.requestOtp('+966500000000');

    final state = container.read(authControllerProvider);
    expect(state.phase, OtpPhase.otpSent);
    expect(state.verificationId, 'vid123');
    expect(state.phone, '+966500000000');
  });

  test('requestOtp failure → ERROR with the auth code', () async {
    when(() => repo.requestOtp(any()))
        .thenAnswer((_) async => left(const Failure.auth(code: 'invalid-phone-number')));
    final container = makeContainer();
    final controller = container.read(authControllerProvider.notifier);

    await controller.requestOtp('bad');

    final state = container.read(authControllerProvider);
    expect(state.phase, OtpPhase.error);
    expect(state.errorCode, 'invalid-phone-number');
  });

  test('confirmOtp success → SUCCESS with signed-in uid', () async {
    when(() => repo.requestOtp(any())).thenAnswer((_) async => right('vid123'));
    when(() => repo.confirmOtp(
          verificationId: any(named: 'verificationId'),
          smsCode: any(named: 'smsCode'),
        )).thenAnswer((_) async => right('uid-1'));
    final container = makeContainer();
    final controller = container.read(authControllerProvider.notifier);

    await controller.requestOtp('+966500000000');
    await controller.confirmOtp('123456');

    final state = container.read(authControllerProvider);
    expect(state.phase, OtpPhase.success);
    expect(state.signedInUid, 'uid-1');
  });

  test('confirmOtp without a verificationId → session-expired error', () async {
    final container = makeContainer();
    final controller = container.read(authControllerProvider.notifier);

    await controller.confirmOtp('123456');

    final state = container.read(authControllerProvider);
    expect(state.phase, OtpPhase.error);
    expect(state.errorCode, 'session-expired');
  });

  test('wrong code retries, then LOCKS after maxAttempts', () async {
    when(() => repo.requestOtp(any())).thenAnswer((_) async => right('vid123'));
    when(() => repo.confirmOtp(
          verificationId: any(named: 'verificationId'),
          smsCode: any(named: 'smsCode'),
        )).thenAnswer(
      (_) async => left(const Failure.auth(code: 'invalid-verification-code')),
    );
    final container = makeContainer();
    final controller = container.read(authControllerProvider.notifier);
    await controller.requestOtp('+966500000000');

    // First two wrong attempts keep the user on OTP_SENT to retry.
    await controller.confirmOtp('000000');
    expect(container.read(authControllerProvider).phase, OtpPhase.otpSent);
    expect(container.read(authControllerProvider).attempts, 1);

    await controller.confirmOtp('000000');
    expect(container.read(authControllerProvider).phase, OtpPhase.otpSent);
    expect(container.read(authControllerProvider).attempts, 2);

    // Third (== maxAttempts) locks.
    await controller.confirmOtp('000000');
    final locked = container.read(authControllerProvider);
    expect(locked.phase, OtpPhase.locked);
    expect(locked.attempts, AuthController.maxAttempts);
  });

  test('reset returns to IDLE', () async {
    when(() => repo.requestOtp(any())).thenAnswer((_) async => right('vid123'));
    final container = makeContainer();
    final controller = container.read(authControllerProvider.notifier);
    await controller.requestOtp('+966500000000');

    controller.reset();

    expect(container.read(authControllerProvider).phase, OtpPhase.idle);
    expect(container.read(authControllerProvider).verificationId, isNull);
  });
}
