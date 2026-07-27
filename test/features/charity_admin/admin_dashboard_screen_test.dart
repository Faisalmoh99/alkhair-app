import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/auth/domain/entities/app_user.dart';
import 'package:alkhair_app/features/auth/domain/entities/charity.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:alkhair_app/features/charity_admin/presentation/widgets/summary_card.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_mocks.dart';
import '../../helpers/charity_admin_mocks.dart';
import '../../helpers/donor_mocks.dart';

// Screen 6 (TEST_PLAN.md Phase 5 Widget): cards/chart/table render from the
// DonationReports stream; the layout is responsive at the web breakpoint.
// Phase 7 Part A2: the AppBar title also resolves the admin's real charity
// name via currentCharityNameProvider.
void main() {
  late MockCharityAdminRepository repo;
  late MockAuthRepository authRepo;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    repo = MockCharityAdminRepository();
    authRepo = MockAuthRepository();
    auth = MockFirebaseAuth();
    user = MockUser();
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
  });

  DonationReport report(DonationStatus status, DateTime createdAt) => DonationReport(
        id: 'r-${status.name}-${createdAt.millisecondsSinceEpoch}',
        donorId: 'donor1',
        foodCategory: FoodCategory.mainMeals,
        quantity: 5,
        readinessTime: createdAt,
        latitude: 0,
        longitude: 0,
        safetyConfirmed: true,
        status: status,
        createdAt: createdAt,
      );

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        charityAdminRepositoryProvider.overrideWithValue(repo),
        firebaseAuthProvider.overrideWithValue(auth),
        authRepositoryProvider.overrideWithValue(authRepo),
      ],
      child: const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: [Locale('ar')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: AdminDashboardScreen(),
      ),
    );
  }

  testWidgets('AppBar title resolves the real charity name', (tester) async {
    when(() => repo.watchAllReports()).thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('لوحة جمعية البر بمحافظة بيشة'), findsOneWidget);
  });

  testWidgets('summary cards show the per-status counts', (tester) async {
    final now = DateTime(2030, 6, 15);
    when(() => repo.watchAllReports()).thenAnswer(
      (_) => Stream.value([
        report(DonationStatus.reported, now),
        report(DonationStatus.reported, now),
        report(DonationStatus.delivered, now),
      ]),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final values = tester
        .widgetList<SummaryCard>(find.byType(SummaryCard))
        .map((c) => c.value)
        .toList();
    expect(values, containsAll(<int>[2, 1, 0, 0, 0]));
  });

  testWidgets('empty stream renders an empty recent-donations state', (tester) async {
    when(() => repo.watchAllReports()).thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('لا توجد بلاغات بعد.'), findsOneWidget);
  });

  testWidgets('narrow width renders the single-column layout', (tester) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    when(() => repo.watchAllReports()).thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('wide width renders the two-column layout', (tester) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    when(() => repo.watchAllReports()).thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsNothing);
  });
}
