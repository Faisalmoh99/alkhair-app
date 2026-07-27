import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Verifies the exact hex palette from Chapter Five (visual identity).
// If any value drifts, this test will catch it before a screen is painted wrong.
void main() {
  group('AppColors palette matches Chapter Five spec', () {
    test('primaryNavy is #16294F', () {
      expect(AppColors.primaryNavy, const Color(0xFF16294F));
    });

    test('darkNavy is #0D1F3C', () {
      expect(AppColors.darkNavy, const Color(0xFF0D1F3C));
    });

    test('gold is #C89A4E', () {
      expect(AppColors.gold, const Color(0xFFC89A4E));
    });

    test('lightGold is #E8C888', () {
      expect(AppColors.lightGold, const Color(0xFFE8C888));
    });

    test('green (success/delivered) is #3E8E5C', () {
      expect(AppColors.green, const Color(0xFF3E8E5C));
    });

    test('background is #F7F8FA', () {
      expect(AppColors.background, const Color(0xFFF7F8FA));
    });

    test('navyGradient starts primaryNavy and ends darkNavy', () {
      expect(AppColors.navyGradient.colors.first, AppColors.primaryNavy);
      expect(AppColors.navyGradient.colors.last, AppColors.darkNavy);
    });

    test('goldGradient starts gold and ends lightGold', () {
      expect(AppColors.goldGradient.colors.first, AppColors.gold);
      expect(AppColors.goldGradient.colors.last, AppColors.lightGold);
    });
  });
}
