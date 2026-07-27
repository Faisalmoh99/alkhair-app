import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:alkhair_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

// Cairo font files (Regular/Medium/SemiBold/Bold) are bundled at assets/fonts/
// and listed in pubspec.yaml assets so google_fonts can find them without
// network access. allowRuntimeFetching = false enforces the bundle-only mode.

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppTheme Cairo font weights', () {
    late ThemeData theme;

    setUpAll(() {
      theme = AppTheme.light;
    });

    test('displayLarge is Bold (w700)', () {
      expect(theme.textTheme.displayLarge?.fontWeight, FontWeight.w700);
    });

    test('displayMedium is Bold (w700)', () {
      expect(theme.textTheme.displayMedium?.fontWeight, FontWeight.w700);
    });

    test('headlineMedium is Bold (w700)', () {
      expect(theme.textTheme.headlineMedium?.fontWeight, FontWeight.w700);
    });

    test('titleLarge is SemiBold (w600)', () {
      expect(theme.textTheme.titleLarge?.fontWeight, FontWeight.w600);
    });

    test('titleMedium is Medium (w500)', () {
      expect(theme.textTheme.titleMedium?.fontWeight, FontWeight.w500);
    });

    test('bodyLarge is Regular (w400)', () {
      expect(theme.textTheme.bodyLarge?.fontWeight, FontWeight.w400);
    });

    test('bodyMedium is Regular (w400)', () {
      expect(theme.textTheme.bodyMedium?.fontWeight, FontWeight.w400);
    });

    test('labelLarge is SemiBold (w600) — button text', () {
      expect(theme.textTheme.labelLarge?.fontWeight, FontWeight.w600);
    });
  });

  group('AppTheme colour scheme', () {
    testWidgets('primary is primaryNavy', (tester) async {
      late ColorScheme scheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(builder: (context) {
            scheme = Theme.of(context).colorScheme;
            return const SizedBox.shrink();
          }),
        ),
      );
      expect(scheme.primary, AppColors.primaryNavy);
    });

    testWidgets('secondary is gold', (tester) async {
      late ColorScheme scheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(builder: (context) {
            scheme = Theme.of(context).colorScheme;
            return const SizedBox.shrink();
          }),
        ),
      );
      expect(scheme.secondary, AppColors.gold);
    });

    testWidgets('scaffoldBackgroundColor is background', (tester) async {
      late ThemeData capturedTheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(builder: (context) {
            capturedTheme = Theme.of(context);
            return const SizedBox.shrink();
          }),
        ),
      );
      expect(capturedTheme.scaffoldBackgroundColor, AppColors.background);
    });
  });
}
