import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// DonationStatus -> badge color (TEST_PLAN.md Phase 5 Unit: "status-badge
/// color mapping"). Kept separate from the widget so it's unit-testable
/// without pumping a widget tree. The Arabic label is the existing
/// `statusLabel` from Screen 3 (donor_status_screen.dart) — reused, not
/// redefined.
Color statusBadgeColor(DonationStatus status) => switch (status) {
      DonationStatus.reported => AppColors.primaryNavy,
      DonationStatus.assigned => AppColors.gold,
      DonationStatus.collected => Colors.teal,
      DonationStatus.delivered => AppColors.green,
      DonationStatus.expired => AppColors.error,
    };
