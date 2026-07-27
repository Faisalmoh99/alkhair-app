import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/donor/presentation/screens/donor_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/donor_mocks.dart';

// Widget-1 (TEST_PLAN.md Phase 3): the report screen blocks submit until the
// mandatory safety_confirmed checkbox is ticked (FR4).
void main() {
  Widget buildApp() {
    return ProviderScope(
      overrides: [
        donationRepositoryProvider.overrideWithValue(MockDonationRepository()),
        locationServiceProvider.overrideWithValue(MockLocationService()),
      ],
      child: const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: [Locale('ar')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: DonorReportScreen(),
      ),
    );
  }

  testWidgets(
    'submit is disabled until safety_confirmed is checked, then enabled, '
    'then disabled again when unchecked',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      FilledButton submitButton() =>
          tester.widget<FilledButton>(find.byType(FilledButton));

      expect(submitButton().onPressed, isNull);

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      expect(submitButton().onPressed, isNotNull);

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      expect(submitButton().onPressed, isNull);
    },
  );
}
