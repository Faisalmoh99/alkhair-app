import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Branded splash screen — the first thing every user sees (all roles).
/// Visual identity: navy gradient background, gold logo centred, Arabic app name below.
/// See Chapter Five §5.2.1 and the AlKhair_Logo_Icon_1024.png asset.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.navyGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo icon
              Image.asset(
                'assets/images/logo_icon.png',
                width: 160,
                height: 160,
              ),
              const SizedBox(height: 24),
              // Arabic app name
              Text(
                'الخير',
                style: textTheme.displayMedium?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              // Arabic tagline
              Text(
                'منصة توزيع الفائض الغذائي',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.lightGold.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(flex: 2),
              // Loading indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
