import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/features/charity_admin/presentation/status_badge_style.dart';
import 'package:flutter_test/flutter_test.dart';

// Status-badge color mapping (TEST_PLAN.md Phase 5 Unit).
void main() {
  test('every DonationStatus maps to a distinct badge color', () {
    final colors = {for (final s in DonationStatus.values) s: statusBadgeColor(s)};
    expect(colors.values.toSet().length, DonationStatus.values.length);
  });
}
