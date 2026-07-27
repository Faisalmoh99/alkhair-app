// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardStatsHash() => r'054012a0a822906b13bfb2b57211dd6ca9a91850';

/// Screen 6's aggregates (FR11), derived client-side from the DonationReports
/// stream (see [computeDashboardStats]).
///
/// Copied from [dashboardStats].
@ProviderFor(dashboardStats)
final dashboardStatsProvider =
    AutoDisposeStreamProvider<DashboardStats>.internal(
      dashboardStats,
      name: r'dashboardStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardStatsRef = AutoDisposeStreamProviderRef<DashboardStats>;
String _$currentCharityIdHash() => r'6da6bc53e1deb9b191419d0ddf09ed3bec3f7c72';

/// Resolves the signed-in charity admin's own `charity_id` (Table 4.4) via
/// `CharityAdmins.charity_id`. Shared by [currentCharityName] and any query
/// that must filter on the admin's own charity to satisfy firestore.rules
/// (e.g. `Reports` — see `watchGeneratedReports`, Phase 7 follow-up).
///
/// Copied from [currentCharityId].
@ProviderFor(currentCharityId)
final currentCharityIdProvider = AutoDisposeFutureProvider<String?>.internal(
  currentCharityId,
  name: r'currentCharityIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentCharityIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentCharityIdRef = AutoDisposeFutureProviderRef<String?>;
String _$currentCharityNameHash() =>
    r'3541476a0c391b2bcabdae7eaa32b4cc17def3dc';

/// Resolves the signed-in charity admin's own charity name (Table 4.5).
/// Single source of truth for both the dashboard header (Screen 6) and the
/// PDF export header (Screen 12, Phase 7 Part A2) — null while unresolved or
/// if no match is found; callers fall back to a neutral label, never a
/// hardcoded name.
///
/// Copied from [currentCharityName].
@ProviderFor(currentCharityName)
final currentCharityNameProvider = AutoDisposeFutureProvider<String?>.internal(
  currentCharityName,
  name: r'currentCharityNameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentCharityNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentCharityNameRef = AutoDisposeFutureProviderRef<String?>;
String _$pendingVolunteersHash() => r'e8e87a017342e2e1ac0693592f2d074cf8dffa63';

/// Screen 7's pending-approval list (FR10).
///
/// Copied from [pendingVolunteers].
@ProviderFor(pendingVolunteers)
final pendingVolunteersProvider =
    AutoDisposeStreamProvider<List<PendingVolunteer>>.internal(
      pendingVolunteers,
      name: r'pendingVolunteersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingVolunteersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingVolunteersRef =
    AutoDisposeStreamProviderRef<List<PendingVolunteer>>;
String _$approvalActionControllerHash() =>
    r'd1be3491336353a99ab535019393b90ee1969dd2';

/// Drives Screen 7's approve/reject actions (FR10): a direct client write
/// authorized by firestore.rules' same-charity admin update path.
///
/// Copied from [ApprovalActionController].
@ProviderFor(ApprovalActionController)
final approvalActionControllerProvider =
    AutoDisposeNotifierProvider<
      ApprovalActionController,
      ApprovalActionState
    >.internal(
      ApprovalActionController.new,
      name: r'approvalActionControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$approvalActionControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ApprovalActionController = AutoDisposeNotifier<ApprovalActionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
