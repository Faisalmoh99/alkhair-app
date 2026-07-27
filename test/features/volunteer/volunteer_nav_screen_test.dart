import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:alkhair_app/features/volunteer/presentation/screens/volunteer_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/donor_mocks.dart';

// Screen 5 (TEST_PLAN.md Phase 4 Widget, FR8/FR9): the two confirm buttons
// gate on the live report status, each calling the matching repository
// method exactly once. Location is stubbed to fail in every case here so the
// map section renders its placeholder rather than the real GoogleMap
// platform view (which does not render in the widget-test host).
void main() {
  late MockDonationRepository repo;
  late MockLocationService location;

  setUp(() {
    repo = MockDonationRepository();
    location = MockLocationService();
    when(() => location.getCurrentLocation()).thenAnswer(
      (_) async => left(const Failure.permission(action: 'location')),
    );
  });

  DonationReport report(DonationStatus status) => DonationReport(
        id: 'rep1',
        donorId: 'donor1',
        volunteerId: 'vol1',
        foodCategory: FoodCategory.mainMeals,
        quantity: 5,
        readinessTime: DateTime(2030),
        latitude: 20,
        longitude: 42.5,
        safetyConfirmed: true,
        status: status,
        createdAt: DateTime(2030),
      );

  Widget buildApp() {
    // A real GoRouter (rather than plain MaterialApp) because the screen's
    // ref.listen navigates to Routes.volunteerHome once delivery completes.
    final router = GoRouter(
      initialLocation: Routes.volunteerNav,
      routes: [
        GoRoute(
          path: Routes.volunteerNav,
          builder: (_, __) => const VolunteerNavScreen(reportId: 'rep1'),
        ),
        GoRoute(
          path: Routes.volunteerHome,
          builder: (_, __) => const Scaffold(body: Text('الرئيسية')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
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

  FilledButton findButton(WidgetTester tester, String label) {
    return tester.widget<FilledButton>(
      find.ancestor(of: find.text(label), matching: find.byType(FilledButton)),
    );
  }

  testWidgets(
    'confirm collection is enabled only at status=assigned and calls confirmCollection',
    (tester) async {
      when(() => repo.watchReport('rep1'))
          .thenAnswer((_) => Stream.value(report(DonationStatus.assigned)));
      when(() => repo.confirmCollection('rep1'))
          .thenAnswer((_) async => right(unit));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(findButton(tester, 'تأكيد الاستلام').onPressed, isNotNull);
      expect(findButton(tester, 'تأكيد التسليم').onPressed, isNull);

      await tester.tap(find.text('تأكيد الاستلام'));
      await tester.pumpAndSettle();

      verify(() => repo.confirmCollection('rep1')).called(1);
      verifyNever(() => repo.confirmDelivery(any()));
    },
  );

  testWidgets(
    'confirm delivery is enabled only at status=collected and calls confirmDelivery',
    (tester) async {
      when(() => repo.watchReport('rep1'))
          .thenAnswer((_) => Stream.value(report(DonationStatus.collected)));
      when(() => repo.confirmDelivery('rep1'))
          .thenAnswer((_) async => right(unit));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(findButton(tester, 'تأكيد الاستلام').onPressed, isNull);
      expect(findButton(tester, 'تأكيد التسليم').onPressed, isNotNull);

      await tester.tap(find.text('تأكيد التسليم'));
      await tester.pumpAndSettle();

      verify(() => repo.confirmDelivery('rep1')).called(1);
      verifyNever(() => repo.confirmCollection(any()));
    },
  );

  testWidgets('both confirm buttons are disabled once the report is delivered', (
    tester,
  ) async {
    when(() => repo.watchReport('rep1'))
        .thenAnswer((_) => Stream.value(report(DonationStatus.delivered)));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(findButton(tester, 'تأكيد الاستلام').onPressed, isNull);
    expect(findButton(tester, 'تأكيد التسليم').onPressed, isNull);
  });
}
