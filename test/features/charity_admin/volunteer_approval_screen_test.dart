import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/pending_volunteer.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/volunteer_approval_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/charity_admin_mocks.dart';

// Screen 7 (TEST_PLAN.md Phase 5 Widget): approve/reject flips approval_status;
// empty state when no one is pending.
void main() {
  late MockCharityAdminRepository repo;

  setUpAll(() {
    registerFallbackValue(ApprovalStatus.pending);
  });

  setUp(() {
    repo = MockCharityAdminRepository();
  });

  const volunteer = PendingVolunteer(
    uid: 'vol1',
    name: 'أحمد',
    phone: '+966500000001',
    vehicleType: 'سيارة',
    approvalStatus: ApprovalStatus.pending,
    charityId: 'albirr-bisha',
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
        home: VolunteerApprovalScreen(),
      ),
    );
  }

  testWidgets('empty pending list shows the empty state', (tester) async {
    when(() => repo.watchPendingVolunteers()).thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('لا يوجد متطوعون بانتظار الاعتماد.'), findsOneWidget);
  });

  testWidgets('approve calls setApproval with approved', (tester) async {
    when(() => repo.watchPendingVolunteers())
        .thenAnswer((_) => Stream.value(const [volunteer]));
    when(() => repo.setApproval(any(), any())).thenAnswer((_) async => right(unit));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('قبول'));
    await tester.pumpAndSettle();

    verify(() => repo.setApproval('vol1', ApprovalStatus.approved)).called(1);
  });

  testWidgets('reject calls setApproval with revoked', (tester) async {
    when(() => repo.watchPendingVolunteers())
        .thenAnswer((_) => Stream.value(const [volunteer]));
    when(() => repo.setApproval(any(), any())).thenAnswer((_) async => right(unit));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('رفض'));
    await tester.pumpAndSettle();

    verify(() => repo.setApproval('vol1', ApprovalStatus.revoked)).called(1);
  });

  testWidgets('pending volunteer row shows name, phone, and vehicle type', (tester) async {
    when(() => repo.watchPendingVolunteers())
        .thenAnswer((_) => Stream.value(const [volunteer]));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('أحمد'), findsOneWidget);
    expect(find.text('+966500000001'), findsOneWidget);
    expect(find.text('سيارة'), findsOneWidget);
  });
}
