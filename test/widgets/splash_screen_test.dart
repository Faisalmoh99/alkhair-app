import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:alkhair_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SplashScreen renders with navy gradient background', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Logo asset widget is present.
    expect(find.byType(Image), findsOneWidget);
    // Arabic app name is rendered.
    expect(find.text('الخير'), findsOneWidget);
    // Background container uses the navy gradient.
    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.gradient, AppColors.navyGradient);
  });
}
