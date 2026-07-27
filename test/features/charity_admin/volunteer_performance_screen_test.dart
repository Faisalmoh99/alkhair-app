import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/approved_volunteer.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/volunteer_performance_screen.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/charity_admin_mocks.dart';

// Screen 11 (TEST_PLAN.md Phase 6 Widget): ranking order + leader badge, and
// the empty state when there are no approved volunteers.
void main() {
  late MockCharityAdminRepository repo;

  setUp(() {
    repo = MockCharityAdminRepository();
  });

  DonationReport report(String volunteerId) => DonationReport(
        id: 'r-$volunteerId-${DateTime.now().microsecondsSinceEpoch}',
        donorId: 'donor1',
        volunteerId: volunteerId,
        foodCategory: FoodCategory.mainMeals,
        quantity: 5,
        readinessTime: DateTime(2030),
        latitude: 0,
        longitude: 0,
        safetyConfirmed: true,
        status: DonationStatus.delivered,
        createdAt: DateTime(2030),
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
        home: VolunteerPerformanceScreen(),
      ),
    );
  }

  testWidgets('top volunteer shows the leader badge', (tester) async {
    when(() => repo.watchApprovedVolunteers()).thenAnswer(
      (_) => Stream.value(const [
        ApprovedVolunteer(uid: 'volA', name: 'أحمد'),
        ApprovedVolunteer(uid: 'volB', name: 'سالم'),
      ]),
    );
    when(() => repo.watchAllReports()).thenAnswer(
      (_) => Stream.value([report('volA'), report('volA'), report('volB')]),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    final names = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
    expect(names, containsAll(['أحمد', 'سالم']));
  });

  testWidgets('no approved volunteers shows the empty state', (tester) async {
    when(() => repo.watchApprovedVolunteers()).thenAnswer((_) => Stream.value(const []));
    when(() => repo.watchAllReports()).thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('لا يوجد متطوعون معتمدون بعد.'), findsOneWidget);
  });
}
