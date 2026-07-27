import 'package:alkhair_app/features/auth/presentation/screens/account_type_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression (manual emulator E2E): typing into the name field opens the
// keyboard, shrinking the viewport, which overflowed the previous bare
// Column by 6.0px. The Form body must be scrollable to absorb that.
void main() {
  Widget buildApp() {
    return const ProviderScope(
      child: MaterialApp(
        locale: Locale('ar'),
        supportedLocales: [Locale('ar')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: AccountTypeScreen(),
      ),
    );
  }

  testWidgets(
    'does not overflow when the keyboard shrinks the viewport',
    (tester) async {
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(400, 350);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(TextFormField), 'فيصل');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
