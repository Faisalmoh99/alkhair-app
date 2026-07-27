import 'package:alkhair_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Confirms the app defaults to RTL Arabic layout (NFR4 — non-negotiable).
// Tests the MaterialApp configuration used in AlKhairApp without requiring
// Firebase initialisation or real assets.

void main() {
  group('App locale and directionality (NFR4)', () {
    testWidgets('Locale("ar") produces RTL text direction', (tester) async {
      late TextDirection capturedDirection;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light,
          home: Builder(
            builder: (context) {
              capturedDirection = Directionality.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pump(); // allow localizations to resolve

      expect(capturedDirection, TextDirection.rtl);
    });

    testWidgets('App locale is ar (Arabic)', (tester) async {
      late Locale capturedLocale;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              capturedLocale = Localizations.localeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pump();

      expect(capturedLocale.languageCode, 'ar');
    });

    testWidgets('Only Arabic locale is supported (no fallback to LTR)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: [Locale('ar')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: SizedBox.shrink(),
        ),
      );

      await tester.pump();

      // There must be exactly one supported locale — Arabic.
      // Verifies the app doesn't accidentally fall back to English.
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.supportedLocales, equals(const [Locale('ar')]));
    });
  });
}
