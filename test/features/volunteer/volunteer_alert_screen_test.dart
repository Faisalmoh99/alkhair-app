import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:alkhair_app/features/volunteer/presentation/screens/volunteer_alert_screen.dart';
import 'package:alkhair_app/features/volunteer/presentation/screens/volunteer_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/donor_mocks.dart';

// Screen 4 (TEST_PLAN.md Phase 4 Widget, FR6/FR7): card fields, accept
// concurrency-safety hookup + navigation, and decline's no-write dismissal.
void main() {
  late MockDonationRepository repo;
  late MockLocationService location;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    repo = MockDonationRepository();
    location = MockLocationService();
    auth = MockFirebaseAuth();
    user = MockUser();
    when(() => user.uid).thenReturn('vol1');
    when(() => auth.currentUser).thenReturn(user);
    // Same lat/lng as the report below -> a deterministic 0.0 km distance.
    when(() => location.getCurrentLocation())
        .thenAnswer((_) async => right((latitude: 20, longitude: 42.5)));
  });

  DonationReport report({
    String id = 'rep1',
    DonationStatus status = DonationStatus.reported,
  }) =>
      DonationReport(
        id: id,
        donorId: 'donor1',
        volunteerId: status == DonationStatus.reported ? null : 'vol1',
        foodCategory: FoodCategory.mainMeals,
        quantity: 7,
        readinessTime: DateTime(2030),
        latitude: 20,
        longitude: 42.5,
        safetyConfirmed: true,
        status: status,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      );

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: Routes.volunteerAlert,
      routes: [
        GoRoute(
          path: Routes.volunteerAlert,
          builder: (_, __) => const VolunteerAlertScreen(),
        ),
        GoRoute(
          path: Routes.volunteerNav,
          builder: (_, state) =>
              VolunteerNavScreen(reportId: state.extra! as String),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(auth),
        donationRepositoryProvider.overrideWithValue(repo),
        locationServiceProvider.overrideWithValue(location),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }

  testWidgets('alert card shows category, quantity, distance, and time-since', (
    tester,
  ) async {
    when(() => repo.watchOpenReports()).thenAnswer((_) => Stream.value([report()]));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('وجبات رئيسية'), findsOneWidget);
    expect(find.text('الكمية: 7'), findsOneWidget);
    expect(find.text('المسافة: 0.0 كم'), findsOneWidget);
    expect(find.text('منذ: قبل 3 ساعة'), findsOneWidget);
  });

  testWidgets('accept calls acceptReport with the volunteer uid and navigates to Screen 5', (
    tester,
  ) async {
    when(() => repo.watchOpenReports()).thenAnswer((_) => Stream.value([report()]));
    when(() => repo.acceptReport('rep1', 'vol1'))
        .thenAnswer((_) async => right(unit));
    // Screen 5 is reached after accepting; its own stream needs a stub too.
    when(() => repo.watchReport('rep1')).thenAnswer(
      (_) => Stream.value(report(status: DonationStatus.assigned)),
    );
    // Fails on Screen 5 too -> the map placeholder renders, not the real
    // GoogleMap platform view (which does not render in the test host).
    when(() => location.getCurrentLocation()).thenAnswer(
      (_) async => left(const Failure.permission(action: 'location')),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('قبول'));
    await tester.pumpAndSettle();

    verify(() => repo.acceptReport('rep1', 'vol1')).called(1);
    expect(find.text('التوجيه والتسليم'), findsOneWidget);
  });

  testWidgets('decline dismisses the card locally and performs no repository write', (
    tester,
  ) async {
    when(() => repo.watchOpenReports()).thenAnswer((_) => Stream.value([report()]));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('وجبات رئيسية'), findsOneWidget);

    await tester.tap(find.text('رفض'));
    await tester.pumpAndSettle();

    expect(find.text('وجبات رئيسية'), findsNothing);
    expect(find.text('لا توجد بلاغات قريبة حالياً.'), findsOneWidget);
    verifyNever(() => repo.acceptReport(any(), any()));
  });
}
