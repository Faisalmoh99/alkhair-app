// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appRouterHash() => r'35c4755fdb19727627f6fbb2d04bf6327370967d';

/// The app router. Redirects are driven by [authStatusControllerProvider]: the
/// stage is bridged into a [ValueNotifier] that GoRouter listens to, so the
/// router is created once and re-evaluates guards whenever the stage changes.
///
/// Copied from [appRouter].
@ProviderFor(appRouter)
final appRouterProvider = Provider<GoRouter>.internal(
  appRouter,
  name: r'appRouterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppRouterRef = ProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
