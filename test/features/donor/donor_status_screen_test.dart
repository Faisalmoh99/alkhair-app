import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/donor/domain/entities/app_notification.dart';
import 'package:alkhair_app/features/donor/domain/entities/donation_report.dart';
import 'package:alkhair_app/features/donor/presentation/screens/donor_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/donor_mocks.dart';

// Widget-2 & Widget-3 (TEST_PLAN.md Phase 3): status tracker maps enum ->
// Arabic labels; notifications feed renders reverse-chronological.
void main() {
  late MockDonationRepository donationRepository;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    donationRepository = MockDonationRepository();
    auth = MockFirebaseAuth();
    user = MockUser();
    when(() => user.uid).thenReturn('donor1');
    when(() => auth.currentUser).thenReturn(user);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(auth),
        donationRepositoryProvider.overrideWithValue(donationRepository),
      ],
      child: const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: [Locale('ar')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: DonorStatusScreen(),
      ),
    );
  }

  DonationReport report(DonationStatus status) => DonationReport(
        id: 'rep1',
        donorId: 'donor1',
        foodCategory: FoodCategory.mainMeals,
        quantity: 5,
        readinessTime: DateTime(2030),
        latitude: 0,
        longitude: 0,
        safetyConfirmed: true,
        status: status,
        createdAt: DateTime(2030),
      );

  testWidgets('has a home action so the donor is never stranded here '
      '(Phase 7 dead-end fix)', (tester) async {
    when(() => donationRepository.watchMyReports('donor1'))
        .thenAnswer((_) => Stream.value(const []));
    when(() => donationRepository.watchNotifications('donor1'))
        .thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byTooltip('الرئيسية'), findsOneWidget);
    expect(find.byTooltip('تسجيل الخروج'), findsOneWidget);
  });

  testWidgets('status tracker shows the Arabic label for the current status', (
    tester,
  ) async {
    when(() => donationRepository.watchMyReports('donor1'))
        .thenAnswer((_) => Stream.value([report(DonationStatus.assigned)]));
    when(() => donationRepository.watchNotifications('donor1'))
        .thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text(statusLabel(DonationStatus.assigned)), findsOneWidget);
  });

  testWidgets('the expired status renders its own Arabic label', (
    tester,
  ) async {
    when(() => donationRepository.watchMyReports('donor1'))
        .thenAnswer((_) => Stream.value([report(DonationStatus.expired)]));
    when(() => donationRepository.watchNotifications('donor1'))
        .thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text(statusLabel(DonationStatus.expired)), findsOneWidget);
  });

  testWidgets('notifications feed renders reverse-chronological', (
    tester,
  ) async {
    final newest = AppNotification(
      id: 'n3',
      userId: 'donor1',
      message: 'الأحدث',
      type: NotificationType.general,
      isRead: false,
      createdAt: DateTime(2030, 1, 3),
    );
    final middle = AppNotification(
      id: 'n2',
      userId: 'donor1',
      message: 'وسط',
      type: NotificationType.general,
      isRead: false,
      createdAt: DateTime(2030, 1, 2),
    );
    final oldest = AppNotification(
      id: 'n1',
      userId: 'donor1',
      message: 'الأقدم',
      type: NotificationType.general,
      isRead: true,
      createdAt: DateTime(2030),
    );

    when(() => donationRepository.watchMyReports('donor1'))
        .thenAnswer((_) => Stream.value(const []));
    // The repository stream already arrives reverse-chronological
    // (Firestore orderBy created_at desc); the widget must preserve order.
    when(() => donationRepository.watchNotifications('donor1'))
        .thenAnswer((_) => Stream.value([newest, middle, oldest]));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final messages = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title! as Text).data)
        .toList();
    expect(messages, ['الأحدث', 'وسط', 'الأقدم']);
  });
}
