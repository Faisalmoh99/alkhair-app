import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/app_error_messages.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/charity_admin/presentation/controllers/admin_controllers.dart';
import 'package:alkhair_app/features/charity_admin/presentation/widgets/pending_volunteer_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen 7 (Fig 5.7, FR10) — lists pending volunteers with accept/reject
/// actions that set `approval_status` to approved/revoked.
class VolunteerApprovalScreen extends ConsumerWidget {
  const VolunteerApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingVolunteersProvider);
    final actionState = ref.watch(approvalActionControllerProvider);

    ref.listen(approvalActionControllerProvider, (previous, next) {
      if (next.phase == ApprovalActionPhase.error && next.failure != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(arabicErrorMessage(next.failure!))));
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.adminDashboard),
        ),
        title: const Text('اعتماد المتطوعين'),
      ),
      body: SafeArea(
        child: pendingAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('تعذّر تحميل قائمة المتطوعين.')),
          data: (pending) {
            if (pending.isEmpty) {
              return const Center(child: Text('لا يوجد متطوعون بانتظار الاعتماد.'));
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final volunteer in pending)
                  PendingVolunteerTile(
                    volunteer: volunteer,
                    isSubmitting: actionState.phase ==
                            ApprovalActionPhase.submitting &&
                        actionState.targetUid == volunteer.uid,
                    onApprove: () => ref
                        .read(approvalActionControllerProvider.notifier)
                        .setApproval(volunteer.uid, ApprovalStatus.approved),
                    onReject: () => ref
                        .read(approvalActionControllerProvider.notifier)
                        .setApproval(volunteer.uid, ApprovalStatus.revoked),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
