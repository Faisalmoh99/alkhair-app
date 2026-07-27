// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlySummaryHash() => r'7c0cda8f2506eaf2bd92c91e52e1a0f8c16e8414';

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

/// Screens 9 & 10's shared aggregation (FR12) — both watch this with the
/// same [month] so their totals always reconcile (see monthly_summary.dart).
///
/// Copied from [monthlySummary].
@ProviderFor(monthlySummary)
const monthlySummaryProvider = MonthlySummaryFamily();

/// Screens 9 & 10's shared aggregation (FR12) — both watch this with the
/// same [month] so their totals always reconcile (see monthly_summary.dart).
///
/// Copied from [monthlySummary].
class MonthlySummaryFamily extends Family<AsyncValue<MonthlySummary>> {
  /// Screens 9 & 10's shared aggregation (FR12) — both watch this with the
  /// same [month] so their totals always reconcile (see monthly_summary.dart).
  ///
  /// Copied from [monthlySummary].
  const MonthlySummaryFamily();

  /// Screens 9 & 10's shared aggregation (FR12) — both watch this with the
  /// same [month] so their totals always reconcile (see monthly_summary.dart).
  ///
  /// Copied from [monthlySummary].
  MonthlySummaryProvider call({required DateTime month}) {
    return MonthlySummaryProvider(month: month);
  }

  @override
  MonthlySummaryProvider getProviderOverride(
    covariant MonthlySummaryProvider provider,
  ) {
    return call(month: provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthlySummaryProvider';
}

/// Screens 9 & 10's shared aggregation (FR12) — both watch this with the
/// same [month] so their totals always reconcile (see monthly_summary.dart).
///
/// Copied from [monthlySummary].
class MonthlySummaryProvider extends AutoDisposeStreamProvider<MonthlySummary> {
  /// Screens 9 & 10's shared aggregation (FR12) — both watch this with the
  /// same [month] so their totals always reconcile (see monthly_summary.dart).
  ///
  /// Copied from [monthlySummary].
  MonthlySummaryProvider({required DateTime month})
    : this._internal(
        (ref) => monthlySummary(ref as MonthlySummaryRef, month: month),
        from: monthlySummaryProvider,
        name: r'monthlySummaryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$monthlySummaryHash,
        dependencies: MonthlySummaryFamily._dependencies,
        allTransitiveDependencies:
            MonthlySummaryFamily._allTransitiveDependencies,
        month: month,
      );

  MonthlySummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final DateTime month;

  @override
  Override overrideWith(
    Stream<MonthlySummary> Function(MonthlySummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlySummaryProvider._internal(
        (ref) => create(ref as MonthlySummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<MonthlySummary> createElement() {
    return _MonthlySummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlySummaryProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthlySummaryRef on AutoDisposeStreamProviderRef<MonthlySummary> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _MonthlySummaryProviderElement
    extends AutoDisposeStreamProviderElement<MonthlySummary>
    with MonthlySummaryRef {
  _MonthlySummaryProviderElement(super.provider);

  @override
  DateTime get month => (origin as MonthlySummaryProvider).month;
}

String _$volunteerPerformanceHash() =>
    r'dd997cee186d355429c946e13f52a4466e49182b';

/// Screen 11's all-time volunteer leaderboard (FR12).
///
/// Copied from [volunteerPerformance].
@ProviderFor(volunteerPerformance)
final volunteerPerformanceProvider =
    AutoDisposeStreamProvider<List<VolunteerRanking>>.internal(
      volunteerPerformance,
      name: r'volunteerPerformanceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$volunteerPerformanceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VolunteerPerformanceRef =
    AutoDisposeStreamProviderRef<List<VolunteerRanking>>;
String _$generatedReportsHash() => r'85773680e954bc2bdb06b4d806a07b280c7ee3fa';

/// Screen 8's directory of previously generated reports (FR12). The
/// `charity_id` filter is mandatory, not optional — see the doc comment on
/// `CharityAdminRepository.watchGeneratedReports` (Phase 7 follow-up fix).
/// Emits an empty list (mirrors the "not yet generated" empty state) while
/// the admin's charity_id is still resolving, rather than an error state.
///
/// Copied from [generatedReports].
@ProviderFor(generatedReports)
final generatedReportsProvider =
    AutoDisposeStreamProvider<List<GeneratedReport>>.internal(
      generatedReports,
      name: r'generatedReportsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$generatedReportsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GeneratedReportsRef =
    AutoDisposeStreamProviderRef<List<GeneratedReport>>;
String _$selectedMonthHash() => r'9e101c6aa9960eb91d6e5869df190be689fdad9b';

/// The month selected on Screen 9/10 (FR12). `keepAlive` is deliberate: the
/// selection must survive navigation from Screen 10 to the Screen 12 export
/// so the exported PDF's period matches what the admin was looking at — the
/// same ref.watch/ref.read lesson from this project's E2E bug (a value only
/// ever `ref.read` in a callback doesn't survive a screen transition).
///
/// Copied from [SelectedMonth].
@ProviderFor(SelectedMonth)
final selectedMonthProvider =
    NotifierProvider<SelectedMonth, DateTime>.internal(
      SelectedMonth.new,
      name: r'selectedMonthProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedMonthHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedMonth = Notifier<DateTime>;
String _$exportReportControllerHash() =>
    r'1eefe2be33338f9d4d4691b99da9f9d501f451a4';

/// Drives Screen 12's export action (FR12): calls the server-only
/// `generateReport` callable, then builds the client-side PDF. The result and
/// PDF bytes live in watched controller state — not a local variable read
/// once in a callback — so they survive rebuilds/navigation (ref.watch/
/// ref.read lesson).
///
/// Copied from [ExportReportController].
@ProviderFor(ExportReportController)
final exportReportControllerProvider =
    AutoDisposeNotifierProvider<
      ExportReportController,
      ExportReportState
    >.internal(
      ExportReportController.new,
      name: r'exportReportControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$exportReportControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExportReportController = AutoDisposeNotifier<ExportReportState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
