import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/monthly_summary_screen.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/charity_admin_mocks.dart';

// Screen 9 (TEST_PLAN.md Phase 6 Widget): pie renders for a populated month,
// and the empty-month message shows without crashing when there's no data.
void main() {
  late MockCharityAdminRepository repo;

  setUp(() {
    repo = MockCharityAdminRepository();
  });

  DonationReport report(DateTime createdAt, DonationStatus status) => DonationReport(
        id: 'r-${createdAt.millisecondsSinceEpoch}-${status.name}',
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
      overrides: [charityAdminRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: [Locale('ar')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MonthlySummaryScreen(),
      ),
    );
  }

  testWidgets('shows totals for the current month from delivered reports', (tester) async {
    final now = DateTime.now();
    when(() => repo.watchAllReports()).thenAnswer(
      (_) => Stream.value([
        report(DateTime(now.year, now.month), DonationStatus.delivered),
        report(DateTime(now.year, now.month, 2), DonationStatus.delivered),
        report(DateTime(now.year, now.month, 3), DonationStatus.reported),
      ]),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('empty month shows the no-data message', (tester) async {
    when(() => repo.watchAllReports()).thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('لا توجد بيانات لهذا الشهر.'), findsOneWidget);
  });
}
