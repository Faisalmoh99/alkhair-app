import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/registration_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_mocks.dart';
import '../../helpers/donor_mocks.dart';

// Post-OTP branch (SECURITY.md §1.3 / TEST_PLAN.md 2c): donor creates only the
// Users doc; volunteer creates Users then the Volunteers sub-doc.
void main() {
  late MockAuthRepository repo;
  late MockLocationService locationService;
  late MockFirebaseAuth auth;
  late MockUser user;

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

  test('donor branch calls createUserProfile(role: donor) only', () async {
    when(() => repo.createUserProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          role: any(named: 'role'),
        )).thenAnswer((_) async => right(null));
    final controller = makeContainer().read(registrationControllerProvider.notifier);

    final result = await controller.createAccount(
      uid: 'u1',
      name: 'Faisal',
      phone: '+966500000000',
      role: UserRole.donor,
    );

    expect(result.isRight(), isTrue);
    verify(() => repo.createUserProfile(
          uid: 'u1',
          name: 'Faisal',
          phone: '+966500000000',
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

  test('volunteer branch creates Users then the pending Volunteers sub-doc '
      'with the captured GPS fix', () async {
    when(() => repo.createUserProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          role: any(named: 'role'),
        )).thenAnswer((_) async => right(null));
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

    await controller.createAccount(
      uid: 'v1',
      name: 'Volunteer',
      phone: '+966500000001',
      role: UserRole.volunteer,
    );
    final result = await controller.completeVolunteer(
      uid: 'v1',
      email: 'v@example.com',
      vehicleType: 'سيارة',
      charityId: 'charityA',
    );

    expect(result.isRight(), isTrue);
    verify(() => repo.createUserProfile(
          uid: 'v1',
          name: 'Volunteer',
          phone: '+966500000001',
          role: UserRole.volunteer,
        )).called(1);
    verify(() => repo.completeVolunteerRegistration(
          uid: 'v1',
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

    final result = await controller.completeVolunteer(
      uid: 'v2',
      email: 'v2@example.com',
      vehicleType: 'دراجة',
      charityId: 'charityA',
    );

    expect(result.isRight(), isTrue);
    verify(() => repo.completeVolunteerRegistration(
          uid: 'v2',
          email: 'v2@example.com',
          vehicleType: 'دراجة',
          charityId: 'charityA',
        )).called(1);
  });

  test('createAccount retries the ID token refresh until the role claim '
      'catches up with onUsersWrite (Phase 7 token-refresh fix)', () async {
    when(() => repo.createUserProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          role: any(named: 'role'),
        )).thenAnswer((_) async => right(null));
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

    final result = await controller.createAccount(
      uid: 'u3',
      name: 'Faisal',
      phone: '+966500000002',
      role: UserRole.donor,
    );

    expect(result.isRight(), isTrue);
    verify(() => user.getIdTokenResult(true)).called(2);
  });

  test('createAccount fails open when the role claim never catches up '
      'within the retry budget', () async {
    when(() => repo.createUserProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          role: any(named: 'role'),
        )).thenAnswer((_) async => right(null));
    when(() => user.getIdTokenResult(true)).thenAnswer((_) async {
      final token = MockIdTokenResult();
      when(() => token.claims).thenReturn({});
      return token;
    });
    final controller = makeContainer().read(registrationControllerProvider.notifier);

    final result = await controller.createAccount(
      uid: 'u4',
      name: 'Faisal',
      phone: '+966500000003',
      role: UserRole.donor,
    );

    expect(result.isRight(), isTrue);
    verify(() => user.getIdTokenResult(true)).called(5);
  });
}
