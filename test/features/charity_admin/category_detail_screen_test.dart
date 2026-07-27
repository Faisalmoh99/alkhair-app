import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/category_detail_screen.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/charity_admin_mocks.dart';

// Screen 10 (TEST_PLAN.md Phase 6 Widget): category table sorts and shows
// proportional bars, and reconciles with Screen 9 by sharing the same
// monthlySummaryProvider/selectedMonthProvider.
void main() {
  late MockCharityAdminRepository repo;

  setUp(() {
    repo = MockCharityAdminRepository();
  });

  DonationReport report(FoodCategory category, num quantity, DateTime createdAt) =>
      DonationReport(
        id: 'r-${category.name}-${createdAt.millisecondsSinceEpoch}',
        donorId: 'donor1',
        foodCategory: category,
        quantity: quantity,
        readinessTime: createdAt,
        latitude: 0,
        longitude: 0,
        safetyConfirmed: true,
        status: DonationStatus.delivered,
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
        home: CategoryDetailScreen(),
      ),
    );
  }

  testWidgets('renders category rows with quantity and count for the current month', (tester) async {
    final now = DateTime.now();
    final createdAt = DateTime(now.year, now.month);
    when(() => repo.watchAllReports()).thenAnswer(
      (_) => Stream.value([
        report(FoodCategory.mainMeals, 10, createdAt),
        report(FoodCategory.canned, 7, createdAt),
      ]),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('وجبات رئيسية'), findsOneWidget);
    expect(find.text('معلبات'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('empty month shows the no-data message', (tester) async {
    when(() => repo.watchAllReports()).thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('لا توجد بيانات لهذا الشهر.'), findsOneWidget);
  });
}
