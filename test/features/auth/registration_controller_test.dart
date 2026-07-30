import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/auth/domain/entities/sign_up_data.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/registration_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_mocks.dart';
import '../../helpers/donor_mocks.dart';

// Account creation on sign-up submit, no phone/OTP verification
// (ARCHITECTURE.md §6 / TEST_PLAN.md 2c): donor creates only the Users doc
// (after direct account creation); volunteer additionally creates the
// Volunteers sub-doc.
void main() {
  late MockAuthRepository repo;
  late MockLocationService locationService;
  late MockFirebaseAuth auth;
  late MockUser user;

  const donorSignUp = SignUpData(
    username: 'faisal',
    password: 'secret1',
    name: 'Faisal',
    phone: '+966500000000',
    role: UserRole.donor,
  );
  const volunteerSignUp = SignUpData(
    username: 'volunteer1',
    password: 'secret1',
    name: 'Volunteer',
    phone: '+966500000001',
    role: UserRole.volunteer,
    email: 'v@example.com',
    vehicleType: 'سيارة',
    charityId: 'charityA',
  );

  setUpAll(() => registerFallbackValue(UserRole.donor));
  setUp(() {
    repo = MockAuthRepository();
    locationService = MockLocationService();
    auth = MockFirebaseAuth();
    user = MockUser();
    when(() => locationService.getCurrentLocation())
        .thenAnswer((_) async => right((latitude: 20.5, longitude: 42.75)));
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdTokenResult(true)).thenAnswer((_) async {
      final token = MockIdTokenResult();
      when(() => token.claims).thenReturn({'role': 'donor'});
      return token;
    });
    when(() => repo.checkPhoneRegistered(any())).thenAnswer((_) async => right(false));
    when(() => repo.createUserWithUsernamePassword(
          username: any(named: 'username'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => right('u1'));
    when(() => repo.createUserProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          username: any(named: 'username'),
          role: any(named: 'role'),
        )).thenAnswer((_) async => right(null));
    when(() => repo.signOut()).thenAnswer((_) async {});
    when(() => user.delete()).thenAnswer((_) async {});
    // createFromSignUp invalidates authStatusControllerProvider on success,
    // which rebuilds AuthStatusController and re-subscribes to this.
    when(() => repo.authStateChanges()).thenAnswer((_) => const Stream.empty());
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        locationServiceProvider.overrideWithValue(locationService),
        firebaseAuthProvider.overrideWithValue(auth),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('donor branch checks the phone, creates the account, then calls '
      'createUserProfile(role: donor) only', () async {
    final controller = makeContainer().read(registrationControllerProvider.notifier);

    final result = await controller.createFromSignUp(donorSignUp);

    expect(result.isRight(), isTrue);
    verify(() => repo.checkPhoneRegistered('+966500000000')).called(1);
    verify(() => repo.createUserWithUsernamePassword(username: 'faisal', password: 'secret1'))
        .called(1);
    verify(() => repo.createUserProfile(
          uid: 'u1',
          name: 'Faisal',
          phone: '+966500000000',
          username: 'faisal',
          role: UserRole.donor,
        )).called(1);
    verifyNever(() => repo.completeVolunteerRegistration(
          uid: any(named: 'uid'),
          email: any(named: 'email'),
          vehicleType: any(named: 'vehicleType'),
          charityId: any(named: 'charityId'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ));
  });

  test('duplicate phone is rejected before any account is created', () async {
    when(() => repo.checkPhoneRegistered(any())).thenAnswer((_) async => right(true));
    final controller = makeContainer().read(registrationControllerProvider.notifier);

    final result = await controller.createFromSignUp(donorSignUp);

    expect(
      result.fold((f) => (f as AuthFailure).code, (_) => null),
      'phone-already-registered',
    );
    verifyNever(() => repo.createUserWithUsernamePassword(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ));
  });

  test('account-creation failure (duplicate username) short-circuits before '
      'any Users doc is written', () async {
    when(() => repo.createUserWithUsernamePassword(
          username: any(named: 'username'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => left(const Failure.auth(code: 'username-already-in-use')));
    final controller = makeContainer().read(registrationControllerProvider.notifier);

    final result = await controller.createFromSignUp(donorSignUp);

    expect(result.isLeft(), isTrue);
    verifyNever(() => repo.createUserProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          username: any(named: 'username'),
          role: any(named: 'role'),
        ));
  });

  test('a Users-doc write failure deletes the just-created Auth account, so '
      'a partially-created account never leaves the device silently '
      'authenticated and the username stays free to retry', () async {
    when(() => repo.createUserProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          username: any(named: 'username'),
          role: any(named: 'role'),
        )).thenAnswer((_) async => left(const Failure.unknown(message: 'boom')));
    final controller = makeContainer().read(registrationControllerProvider.notifier);

    await controller.createFromSignUp(donorSignUp);

    verify(() => user.delete()).called(1);
    verifyNever(() => repo.signOut());
  });

  test('a Users-doc write failure falls back to signOut when deleting the '
      'Auth account itself fails', () async {
    when(() => repo.createUserProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          username: any(named: 'username'),
          role: any(named: 'role'),
        )).thenAnswer((_) async => left(const Failure.unknown(message: 'boom')));
    when(() => user.delete()).thenThrow(
      FirebaseAuthException(code: 'requires-recent-login'),
    );
    final controller = makeContainer().read(registrationControllerProvider.notifier);

    await controller.createFromSignUp(donorSignUp);

    verify(() => repo.signOut()).called(1);
  });

  test('volunteer branch creates Users then the pending Volunteers sub-doc '
      'with the captured GPS fix', () async {
    when(() => user.getIdTokenResult(true)).thenAnswer((_) async {
      final token = MockIdTokenResult();
      when(() => token.claims).thenReturn({'role': 'volunteer'});
      return token;
    });
    when(() => repo.completeVolunteerRegistration(
          uid: any(named: 'uid'),
          email: any(named: 'email'),
          vehicleType: any(named: 'vehicleType'),
          charityId: any(named: 'charityId'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async => right(null));
    final controller = makeContainer().read(registrationControllerProvider.notifier);

    final result = await controller.createFromSignUp(volunteerSignUp);

    expect(result.isRight(), isTrue);
    verify(() => repo.createUserProfile(
          uid: 'u1',
          name: 'Volunteer',
          phone: '+966500000001',
          username: 'volunteer1',
          role: UserRole.volunteer,
        )).called(1);
    verify(() => repo.completeVolunteerRegistration(
          uid: 'u1',
          email: 'v@example.com',
          vehicleType: 'سيارة',
          charityId: 'charityA',
          latitude: 20.5,
          longitude: 42.75,
        )).called(1);
  });

  test('volunteer branch fails open on location denial — registration still '
      'succeeds with null coordinates', () async {
    when(() => locationService.getCurrentLocation()).thenAnswer(
      (_) async => left(const Failure.permission(action: 'location')),
    );
    when(() => repo.completeVolunteerRegistration(
          uid: any(named: 'uid'),
          email: any(named: 'email'),
          vehicleType: any(named: 'vehicleType'),
          charityId: any(named: 'charityId'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async => right(null));
    final controller = makeContainer().read(registrationControllerProvider.notifier);

    final result = await controller.createFromSignUp(volunteerSignUp);

    expect(result.isRight(), isTrue);
    verify(() => repo.completeVolunteerRegistration(
          uid: 'u1',
          email: 'v@example.com',
          vehicleType: 'سيارة',
          charityId: 'charityA',
        )).called(1);
  });

  test('createFromSignUp retries the ID token refresh until the role claim '
      'catches up with onUsersWrite (Phase 7 token-refresh fix)', () async {
    var call = 0;
    when(() => user.getIdTokenResult(true)).thenAnswer((_) async {
      call++;
      final token = MockIdTokenResult();
      // First call returns the stale (pre-registration) token with no role
      // claim yet; the trigger has "caught up" by the second call.
      when(() => token.claims).thenReturn(call == 1 ? {} : {'role': 'donor'});
      return token;
    });
    final controller = makeContainer().read(registrationControllerProvider.notifier);

    final result = await controller.createFromSignUp(donorSignUp);

    expect(result.isRight(), isTrue);
    verify(() => user.getIdTokenResult(true)).called(2);
  });

  test('createFromSignUp fails open when the role claim never catches up '
      'within the retry budget', () async {
    when(() => user.getIdTokenResult(true)).thenAnswer((_) async {
      final token = MockIdTokenResult();
      when(() => token.claims).thenReturn({});
      return token;
    });
    final controller = makeContainer().read(registrationControllerProvider.notifier);

    final result = await controller.createFromSignUp(donorSignUp);

    expect(result.isRight(), isTrue);
    verify(() => user.getIdTokenResult(true)).called(5);
  });
}
