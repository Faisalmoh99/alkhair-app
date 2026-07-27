// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volunteer_feed_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$openReportsHash() => r'475ba69c93f2e9458555d0878db60869b248718e';

/// Reverse-chronological stream of open (unassigned) reports (Screen 4,
/// FR6/FR7).
///
/// Copied from [openReports].
@ProviderFor(openReports)
final openReportsProvider =
    AutoDisposeStreamProvider<List<DonationReport>>.internal(
      openReports,
      name: r'openReportsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$openReportsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OpenReportsRef = AutoDisposeStreamProviderRef<List<DonationReport>>;
String _$myAssignmentsHash() => r'1731f61163094705414833aa8dda59ec1054b6f7';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Every report ever assigned to [volunteerId] — the volunteer home's "my
/// active pickups" entry point filters this to assigned/collected.
///
/// Copied from [myAssignments].
@ProviderFor(myAssignments)
const myAssignmentsProvider = MyAssignmentsFamily();

/// Every report ever assigned to [volunteerId] — the volunteer home's "my
/// active pickups" entry point filters this to assigned/collected.
///
/// Copied from [myAssignments].
class MyAssignmentsFamily extends Family<AsyncValue<List<DonationReport>>> {
  /// Every report ever assigned to [volunteerId] — the volunteer home's "my
  /// active pickups" entry point filters this to assigned/collected.
  ///
  /// Copied from [myAssignments].
  const MyAssignmentsFamily();

  /// Every report ever assigned to [volunteerId] — the volunteer home's "my
  /// active pickups" entry point filters this to assigned/collected.
  ///
  /// Copied from [myAssignments].
  MyAssignmentsProvider call(String volunteerId) {
    return MyAssignmentsProvider(volunteerId);
  }

  @override
  MyAssignmentsProvider getProviderOverride(
    covariant MyAssignmentsProvider provider,
  ) {
    return call(provider.volunteerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'myAssignmentsProvider';
}

/// Every report ever assigned to [volunteerId] — the volunteer home's "my
/// active pickups" entry point filters this to assigned/collected.
///
/// Copied from [myAssignments].
class MyAssignmentsProvider
    extends AutoDisposeStreamProvider<List<DonationReport>> {
  /// Every report ever assigned to [volunteerId] — the volunteer home's "my
  /// active pickups" entry point filters this to assigned/collected.
  ///
  /// Copied from [myAssignments].
  MyAssignmentsProvider(String volunteerId)
    : this._internal(
        (ref) => myAssignments(ref as MyAssignmentsRef, volunteerId),
        from: myAssignmentsProvider,
        name: r'myAssignmentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myAssignmentsHash,
        dependencies: MyAssignmentsFamily._dependencies,
        allTransitiveDependencies:
            MyAssignmentsFamily._allTransitiveDependencies,
        volunteerId: volunteerId,
      );

  MyAssignmentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.volunteerId,
  }) : super.internal();

  final String volunteerId;

  @override
  Override overrideWith(
    Stream<List<DonationReport>> Function(MyAssignmentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MyAssignmentsProvider._internal(
        (ref) => create(ref as MyAssignmentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        volunteerId: volunteerId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<DonationReport>> createElement() {
    return _MyAssignmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyAssignmentsProvider && other.volunteerId == volunteerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, volunteerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MyAssignmentsRef on AutoDisposeStreamProviderRef<List<DonationReport>> {
  /// The parameter `volunteerId` of this provider.
  String get volunteerId;
}

class _MyAssignmentsProviderElement
    extends AutoDisposeStreamProviderElement<List<DonationReport>>
    with MyAssignmentsRef {
  _MyAssignmentsProviderElement(super.provider);

  @override
  String get volunteerId => (origin as MyAssignmentsProvider).volunteerId;
}

String _$watchedReportHash() => r'5fd048efda23c32a6016a2762e3e3dd3661d9a23';

/// Live single-report stream backing Screen 5's status gate (FR9).
///
/// Copied from [watchedReport].
@ProviderFor(watchedReport)
const watchedReportProvider = WatchedReportFamily();

/// Live single-report stream backing Screen 5's status gate (FR9).
///
/// Copied from [watchedReport].
class WatchedReportFamily extends Family<AsyncValue<DonationReport?>> {
  /// Live single-report stream backing Screen 5's status gate (FR9).
  ///
  /// Copied from [watchedReport].
  const WatchedReportFamily();

  /// Live single-report stream backing Screen 5's status gate (FR9).
  ///
  /// Copied from [watchedReport].
  WatchedReportProvider call(String reportId) {
    return WatchedReportProvider(reportId);
  }

  @override
  WatchedReportProvider getProviderOverride(
    covariant WatchedReportProvider provider,
  ) {
    return call(provider.reportId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'watchedReportProvider';
}

/// Live single-report stream backing Screen 5's status gate (FR9).
///
/// Copied from [watchedReport].
class WatchedReportProvider extends AutoDisposeStreamProvider<DonationReport?> {
  /// Live single-report stream backing Screen 5's status gate (FR9).
  ///
  /// Copied from [watchedReport].
  WatchedReportProvider(String reportId)
    : this._internal(
        (ref) => watchedReport(ref as WatchedReportRef, reportId),
        from: watchedReportProvider,
        name: r'watchedReportProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$watchedReportHash,
        dependencies: WatchedReportFamily._dependencies,
        allTransitiveDependencies:
            WatchedReportFamily._allTransitiveDependencies,
        reportId: reportId,
      );

  WatchedReportProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reportId,
  }) : super.internal();

  final String reportId;

  @override
  Override overrideWith(
    Stream<DonationReport?> Function(WatchedReportRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchedReportProvider._internal(
        (ref) => create(ref as WatchedReportRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reportId: reportId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<DonationReport?> createElement() {
    return _WatchedReportProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchedReportProvider && other.reportId == reportId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reportId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WatchedReportRef on AutoDisposeStreamProviderRef<DonationReport?> {
  /// The parameter `reportId` of this provider.
  String get reportId;
}

class _WatchedReportProviderElement
    extends AutoDisposeStreamProviderElement<DonationReport?>
    with WatchedReportRef {
  _WatchedReportProviderElement(super.provider);

  @override
  String get reportId => (origin as WatchedReportProvider).reportId;
}

String _$volunteerLocationHash() => r'f39b7cd5ecc9fa13bc296bfdc213c5e5e734122e';

/// The volunteer's current GPS fix, used for the distance shown on Screen 4's
/// alert cards and Screen 5's navigation header. `null` on failure (permission
/// denied / service disabled) rather than propagating a failure — the
/// screens degrade to hiding the distance rather than blocking the list.
///
/// Copied from [volunteerLocation].
@ProviderFor(volunteerLocation)
final volunteerLocationProvider =
    AutoDisposeFutureProvider<GeoPosition?>.internal(
      volunteerLocation,
      name: r'volunteerLocationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$volunteerLocationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VolunteerLocationRef = AutoDisposeFutureProviderRef<GeoPosition?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
