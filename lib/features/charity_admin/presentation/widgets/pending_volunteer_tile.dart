import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/pending_volunteer.dart';
import 'package:flutter/material.dart';

/// One row in Screen 7's pending-approval list (FR10): volunteer identity +
/// Approve/Reject actions.
class PendingVolunteerTile extends StatelessWidget {
  const PendingVolunteerTile({
    required this.volunteer,
    required this.onApprove,
    required this.onReject,
    super.key,
    this.isSubmitting = false,
  });

  final PendingVolunteer volunteer;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(volunteer.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(volunteer.phone),
                  Text(volunteer.vehicleType),
                ],
              ),
            ),
            if (isSubmitting)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else ...[
              IconButton(
                tooltip: 'قبول',
                icon: const Icon(Icons.check_circle, color: AppColors.green),
                onPressed: onApprove,
              ),
              IconButton(
                tooltip: 'رفض',
                icon: const Icon(Icons.cancel, color: AppColors.error),
                onPressed: onReject,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
