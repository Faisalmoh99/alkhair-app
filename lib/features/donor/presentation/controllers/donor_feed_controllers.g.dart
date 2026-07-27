// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donor_feed_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myReportsHash() => r'1a221eec10f03c44068d62b9d2cef88b119d6d5f';

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

/// Reverse-chronological stream of the given donor's own reports (Screen 3).
///
/// Copied from [myReports].
@ProviderFor(myReports)
const myReportsProvider = MyReportsFamily();

/// Reverse-chronological stream of the given donor's own reports (Screen 3).
///
/// Copied from [myReports].
class MyReportsFamily extends Family<AsyncValue<List<DonationReport>>> {
  /// Reverse-chronological stream of the given donor's own reports (Screen 3).
  ///
  /// Copied from [myReports].
  const MyReportsFamily();

  /// Reverse-chronological stream of the given donor's own reports (Screen 3).
  ///
  /// Copied from [myReports].
  MyReportsProvider call(String donorId) {
    return MyReportsProvider(donorId);
  }

  @override
  MyReportsProvider getProviderOverride(covariant MyReportsProvider provider) {
    return call(provider.donorId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'myReportsProvider';
}

/// Reverse-chronological stream of the given donor's own reports (Screen 3).
///
/// Copied from [myReports].
class MyReportsProvider
    extends AutoDisposeStreamProvider<List<DonationReport>> {
  /// Reverse-chronological stream of the given donor's own reports (Screen 3).
  ///
  /// Copied from [myReports].
  MyReportsProvider(String donorId)
    : this._internal(
        (ref) => myReports(ref as MyReportsRef, donorId),
        from: myReportsProvider,
        name: r'myReportsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myReportsHash,
        dependencies: MyReportsFamily._dependencies,
        allTransitiveDependencies: MyReportsFamily._allTransitiveDependencies,
        donorId: donorId,
      );

  MyReportsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.donorId,
  }) : super.internal();

  final String donorId;

  @override
  Override overrideWith(
    Stream<List<DonationReport>> Function(MyReportsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MyReportsProvider._internal(
        (ref) => create(ref as MyReportsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        donorId: donorId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<DonationReport>> createElement() {
    return _MyReportsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyReportsProvider && other.donorId == donorId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, donorId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MyReportsRef on AutoDisposeStreamProviderRef<List<DonationReport>> {
  /// The parameter `donorId` of this provider.
  String get donorId;
}

class _MyReportsProviderElement
    extends AutoDisposeStreamProviderElement<List<DonationReport>>
    with MyReportsRef {
  _MyReportsProviderElement(super.provider);

  @override
  String get donorId => (origin as MyReportsProvider).donorId;
}

String _$myNotificationsHash() => r'064b875e9830663b52e676f0de9027810f046348';

/// Reverse-chronological notifications feed for the given user (FR5).
///
/// Copied from [myNotifications].
@ProviderFor(myNotifications)
const myNotificationsProvider = MyNotificationsFamily();

/// Reverse-chronological notifications feed for the given user (FR5).
///
/// Copied from [myNotifications].
class MyNotificationsFamily extends Family<AsyncValue<List<AppNotification>>> {
  /// Reverse-chronological notifications feed for the given user (FR5).
  ///
  /// Copied from [myNotifications].
  const MyNotificationsFamily();

  /// Reverse-chronological notifications feed for the given user (FR5).
  ///
  /// Copied from [myNotifications].
  MyNotificationsProvider call(String userId) {
    return MyNotificationsProvider(userId);
  }

  @override
  MyNotificationsProvider getProviderOverride(
    covariant MyNotificationsProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'myNotificationsProvider';
}

/// Reverse-chronological notifications feed for the given user (FR5).
///
/// Copied from [myNotifications].
class MyNotificationsProvider
    extends AutoDisposeStreamProvider<List<AppNotification>> {
  /// Reverse-chronological notifications feed for the given user (FR5).
  ///
  /// Copied from [myNotifications].
  MyNotificationsProvider(String userId)
    : this._internal(
        (ref) => myNotifications(ref as MyNotificationsRef, userId),
        from: myNotificationsProvider,
        name: r'myNotificationsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myNotificationsHash,
        dependencies: MyNotificationsFamily._dependencies,
        allTransitiveDependencies:
            MyNotificationsFamily._allTransitiveDependencies,
        userId: userId,
      );

  MyNotificationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<List<AppNotification>> Function(MyNotificationsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MyNotificationsProvider._internal(
        (ref) => create(ref as MyNotificationsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<AppNotification>> createElement() {
    return _MyNotificationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyNotificationsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MyNotificationsRef
    on AutoDisposeStreamProviderRef<List<AppNotification>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _MyNotificationsProviderElement
    extends AutoDisposeStreamProviderElement<List<AppNotification>>
    with MyNotificationsRef {
  _MyNotificationsProviderElement(super.provider);

  @override
  String get userId => (origin as MyNotificationsProvider).userId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
