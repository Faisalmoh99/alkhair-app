import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/charity_admin/presentation/controllers/reports_controllers.dart';
import 'package:alkhair_app/features/charity_admin/presentation/widgets/volunteer_ranking_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen 11 (Fig 5.11, FR12) — approved volunteers ranked by all-time
/// delivered-donation count, with a badge on the top volunteer.
class VolunteerPerformanceScreen extends ConsumerWidget {
  const VolunteerPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(volunteerPerformanceProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.reportsDirectory),
        ),
        title: const Text('أداء المتطوعين'),
      ),
      body: SafeArea(
        child: rankingAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('تعذّر تحميل الترتيب.')),
          data: (ranking) {
            if (ranking.isEmpty) {
              return const Center(child: Text('لا يوجد متطوعون معتمدون بعد.'));
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (var i = 0; i < ranking.length; i++)
                  VolunteerRankingTile(rank: i + 1, ranking: ranking[i]),
              ],
            );
          },
        ),
      ),
    );
  }
}
