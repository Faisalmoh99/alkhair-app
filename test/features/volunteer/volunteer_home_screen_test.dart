import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/volunteer/presentation/screens/volunteer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_mocks.dart';
import '../../helpers/donor_mocks.dart';

// Phase 7 Part A1: the manual "تحديث موقعي" refresh action on the volunteer
// home screen — the on-demand half of the volunteer-location fix.
void main() {
  late MockAuthRepository authRepo;
  late MockLocationService location;
  late MockDonationRepository donationRepo;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    authRepo = MockAuthRepository();
    location = MockLocationService();
    donationRepo = MockDonationRepository();
    auth = MockFirebaseAuth();
    user = MockUser();
    when(() => user.uid).thenReturn('vol1');
    when(() => auth.currentUser).thenReturn(user);
    when(() => donationRepo.watchMyAssignments('vol1'))
        .thenAnswer((_) => Stream.value([]));
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(auth),
        authRepositoryProvider.overrideWithValue(authRepo),
        locationServiceProvider.overrideWithValue(location),
        donationRepositoryProvider.overrideWithValue(donationRepo),
      ],
      child: const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: [Locale('ar')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: VolunteerHomeScreen(),
      ),
    );
  }

  testWidgets('tapping the refresh button captures location and writes it, '
      'then shows a success SnackBar', (tester) async {
    when(() => location.getCurrentLocation())
        .thenAnswer((_) async => right((latitude: 20.5, longitude: 42.75)));
    when(() => authRepo.updateVolunteerLocation(
          uid: 'vol1',
          latitude: 20.5,
          longitude: 42.75,
        )).thenAnswer((_) async => right(null));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('تحديث موقعي'));
    await tester.pumpAndSettle();

    verify(() => authRepo.updateVolunteerLocation(
          uid: 'vol1',
          latitude: 20.5,
          longitude: 42.75,
        )).called(1);
    expect(find.text('تم تحديث موقعك.'), findsOneWidget);
  });

  testWidgets('a location failure shows an error SnackBar and writes nothing', (
    tester,
  ) async {
    when(() => location.getCurrentLocation()).thenAnswer(
      (_) async => left(const Failure.permission(action: 'location')),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('تحديث موقعي'));
    await tester.pumpAndSettle();

    verifyNever(() => authRepo.updateVolunteerLocation(
          uid: any(named: 'uid'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ));
    expect(find.byIcon(Icons.my_location), findsOneWidget);
  });
}
