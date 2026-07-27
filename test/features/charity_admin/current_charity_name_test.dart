import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/auth/domain/entities/app_user.dart';
import 'package:alkhair_app/features/auth/domain/entities/charity.dart';
import 'package:alkhair_app/features/charity_admin/presentation/controllers/admin_controllers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_mocks.dart';
import '../../helpers/donor_mocks.dart';

// Phase 7 Part A2: currentCharityNameProvider is the single source of truth
// consumed by both the dashboard header and the PDF export screen.
void main() {
  late MockAuthRepository authRepo;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    authRepo = MockAuthRepository();
    auth = MockFirebaseAuth();
    user = MockUser();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(auth),
        authRepositoryProvider.overrideWithValue(authRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test("resolves the admin's charity name via CharityAdmins.charity_id", () async {
    when(() => user.uid).thenReturn('admin1');
    when(() => auth.currentUser).thenReturn(user);
    when(() => authRepo.loadProfile('admin1')).thenAnswer(
      (_) async => right(
        const AppUser(
          uid: 'admin1',
          name: 'Admin',
          phone: '+966500000099',
          role: UserRole.charityAdmin,
          charityId: 'albirr-bisha',
        ),
      ),
    );
    when(() => authRepo.fetchCharities()).thenAnswer(
      (_) async => right([
        const Charity(id: 'albirr-bisha', name: 'جمعية البر بمحافظة بيشة'),
      ]),
    );

    final name = await makeContainer().read(currentCharityNameProvider.future);

    expect(name, 'جمعية البر بمحافظة بيشة');
  });

  test('returns null when signed out', () async {
    when(() => auth.currentUser).thenReturn(null);

    final name = await makeContainer().read(currentCharityNameProvider.future);

    expect(name, isNull);
  });

  test('returns null when the admin has no charity_id yet', () async {
    when(() => user.uid).thenReturn('admin1');
    when(() => auth.currentUser).thenReturn(user);
    when(() => authRepo.loadProfile('admin1')).thenAnswer(
      (_) async => right(
        const AppUser(
          uid: 'admin1',
          name: 'Admin',
          phone: '+966500000099',
          role: UserRole.charityAdmin,
        ),
      ),
    );

    final name = await makeContainer().read(currentCharityNameProvider.future);

    expect(name, isNull);
  });

  test('returns null when charity_id has no matching Charities doc', () async {
    when(() => user.uid).thenReturn('admin1');
    when(() => auth.currentUser).thenReturn(user);
    when(() => authRepo.loadProfile('admin1')).thenAnswer(
      (_) async => right(
        const AppUser(
          uid: 'admin1',
          name: 'Admin',
          phone: '+966500000099',
          role: UserRole.charityAdmin,
          charityId: 'unknown-charity',
        ),
      ),
    );
    when(() => authRepo.fetchCharities()).thenAnswer((_) async => right([]));

    final name = await makeContainer().read(currentCharityNameProvider.future);

    expect(name, isNull);
  });
}
