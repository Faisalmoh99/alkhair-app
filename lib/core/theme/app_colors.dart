import 'package:flutter/material.dart';

// Visual identity palette — sourced from Chapter Five + kickoff brief.
abstract final class AppColors {
  // Primary navy
  static const Color primaryNavy = Color(0xFF16294F);
  // Dark navy (gradient end)
  static const Color darkNavy = Color(0xFF0D1F3C);
  // Gold
  static const Color gold = Color(0xFFC89A4E);
  // Light gold (gradient end)
  static const Color lightGold = Color(0xFFE8C888);
  // Green — success / delivered status
  static const Color green = Color(0xFF3E8E5C);
  // Screen background
  static const Color background = Color(0xFFF7F8FA);
  // Surface (cards, sheets)
  static const Color surface = Color(0xFFFFFFFF);
  // Error
  static const Color error = Color(0xFFD32F2F);
  // On-primary (text/icons on navy)
  static const Color onPrimary = Color(0xFFFFFFFF);
  // On-background (body text)
  static const Color onBackground = Color(0xFF1A1A2E);
  // Subtle divider / disabled
  static const Color divider = Color(0xFFE0E0E0);

  // Gradient — navy splash / header
  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryNavy, darkNavy],
  );

  // Gradient — gold accent
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, lightGold],
  );
}
