import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/auth/domain/entities/app_user.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/generated_report.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/reports_directory_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_mocks.dart';
import '../../helpers/charity_admin_mocks.dart';
import '../../helpers/donor_mocks.dart';

// Screen 8 (TEST_PLAN.md Phase 6 Widget; charity_id filter fixed Phase 7
// follow-up): shows per-type generated_at, and the "not yet generated" empty
// state when a type has never been generated.
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
          charityId: 'charity1',
        ),
      ),
    );
  });

  GeneratedReport report(ReportType type, DateTime generatedAt) => GeneratedReport(
        id: 'r-${type.name}',
        charityId: 'charity1',
        generatedBy: 'admin1',
        reportType: type,
        periodStart: DateTime(2030, 6),
        periodEnd: DateTime(2030, 7),
        totalDonations: 1,
        totalQuantity: 1,
        generatedAt: generatedAt,
      );

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        charityAdminRepositoryProvider.overrideWithValue(repo),
        authRepositoryProvider.overrideWithValue(authRepo),
        firebaseAuthProvider.overrideWithValue(auth),
      ],
      child: const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: [Locale('ar')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: ReportsDirectoryScreen(),
      ),
    );
  }

  testWidgets('shows last-refreshed timestamp for a generated report type', (tester) async {
    when(() => repo.watchGeneratedReports('charity1')).thenAnswer(
      (_) => Stream.value([report(ReportType.monthlySummary, DateTime(2030, 6, 15, 9))]),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('آخر تحديث'), findsOneWidget);
    verify(() => repo.watchGeneratedReports('charity1')).called(1);
  });

  testWidgets('shows the not-yet-generated empty state for all types', (tester) async {
    when(() => repo.watchGeneratedReports('charity1'))
        .thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('لم يتم إنشاؤه بعد'), findsNWidgets(3));
  });

  testWidgets('shows the empty state (not an error) while charity_id is '
      'still resolving — Phase 7 regression: watchGeneratedReports must '
      'never be called without a charity_id filter', (tester) async {
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

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('لم يتم إنشاؤه بعد'), findsNWidgets(3));
    expect(find.text('تعذّر تحميل التقارير.'), findsNothing);
    verifyNever(() => repo.watchGeneratedReports(any()));
  });
}
