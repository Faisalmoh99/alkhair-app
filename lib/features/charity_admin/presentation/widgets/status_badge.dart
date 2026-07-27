import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/charity_admin/presentation/status_badge_style.dart';
import 'package:alkhair_app/features/donor/presentation/screens/donor_status_screen.dart'
    show statusLabel;
import 'package:flutter/material.dart';

/// A colored pill showing a [DonationStatus]'s Arabic label (recent-donations
/// table, Screen 6).
class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});

  final DonationStatus status;

  @override
  Widget build(BuildContext context) {
    final color = statusBadgeColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
