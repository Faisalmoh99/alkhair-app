import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/auth/domain/entities/app_user.dart';
import 'package:alkhair_app/features/auth/domain/entities/charity.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/generated_report.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/report_export_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:printing/printing.dart';

import '../../helpers/auth_mocks.dart';
import '../../helpers/charity_admin_mocks.dart';
import '../../helpers/donor_mocks.dart';

// Screen 12 (TEST_PLAN.md Phase 6 Widget): generating a report renders the
// PDF preview (mark/charity/date header + category table are inside the PDF
// bytes themselves, verified by report_pdf_service_test.dart) with the
// built-in share/download actions from PdfPreview. Phase 7 Part A2: the
// export call receives the admin's real resolved charity name.
void main() {
  late MockCharityAdminRepository repo;
  late MockAuthRepository authRepo;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUpAll(() {
    registerFallbackValue(ReportType.categoryDetail);
    registerFallbackValue(DateTime(2030));
  });

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
        home: ReportExportScreen(),
      ),
    );
  }

  testWidgets('generating a report renders the PDF preview', (tester) async {
    when(() => repo.watchAllReports()).thenAnswer((_) => Stream.value(const []));
    when(
      () => repo.generateReport(
        reportType: any(named: 'reportType'),
        periodStart: any(named: 'periodStart'),
        periodEnd: any(named: 'periodEnd'),
      ),
    ).thenAnswer(
      (_) async => right(
        GeneratedReport(
          id: 'r1',
          charityId: 'charity1',
          generatedBy: 'admin1',
          reportType: ReportType.categoryDetail,
          periodStart: DateTime(2030, 6),
          periodEnd: DateTime(2030, 7),
          totalDonations: 0,
          totalQuantity: 0,
          generatedAt: DateTime(2030, 6, 15),
        ),
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('إنشاء التقرير'));
    // PdfPreview runs an internal loading animation that never settles, so
    // pump a bounded number of frames instead of pumpAndSettle.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(PdfPreview), findsOneWidget);
  });
}
