import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Donor landing (Phase 3): entry points to Screen 2 (report surplus) and
/// Screen 3 (status/notifications).
class DonorHomeScreen extends ConsumerWidget {
  const DonorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المتبرّع'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              FilledButton.icon(
                onPressed: () => context.go(Routes.donorReport),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('إبلاغ عن فائض غذائي'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go(Routes.donorStatus),
                icon: const Icon(Icons.list_alt),
                label: const Text('حالة البلاغات والإشعارات'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
