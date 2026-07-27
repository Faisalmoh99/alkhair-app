// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Failure {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String code) auth,
    required TResult Function() network,
    required TResult Function(String action) permission,
    required TResult Function() rateLimit,
    required TResult Function(String field, String reason) validation,
    required TResult Function(String reason) conflict,
    required TResult Function(String? message) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String code)? auth,
    TResult? Function()? network,
    TResult? Function(String action)? permission,
    TResult? Function()? rateLimit,
    TResult? Function(String field, String reason)? validation,
    TResult? Function(String reason)? conflict,
    TResult? Function(String? message)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String code)? auth,
    TResult Function()? network,
    TResult Function(String action)? permission,
    TResult Function()? rateLimit,
    TResult Function(String field, String reason)? validation,
    TResult Function(String reason)? conflict,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthFailure value) auth,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(RateLimitFailure value) rateLimit,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(ConflictFailure value) conflict,
    required TResult Function(UnknownFailure value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthFailure value)? auth,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(RateLimitFailure value)? rateLimit,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(ConflictFailure value)? conflict,
    TResult? Function(UnknownFailure value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthFailure value)? auth,
    TResult Function(NetworkFailure value)? network,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(RateLimitFailure value)? rateLimit,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(ConflictFailure value)? conflict,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailureCopyWith<$Res> {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) then) =
      _$FailureCopyWithImpl<$Res, Failure>;
}

/// @nodoc
class _$FailureCopyWithImpl<$Res, $Val extends Failure>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AuthFailureImplCopyWith<$Res> {
  factory _$$AuthFailureImplCopyWith(
    _$AuthFailureImpl value,
    $Res Function(_$AuthFailureImpl) then,
  ) = __$$AuthFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String code});
}

/// @nodoc
class __$$AuthFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$AuthFailureImpl>
    implements _$$AuthFailureImplCopyWith<$Res> {
  __$$AuthFailureImplCopyWithImpl(
    _$AuthFailureImpl _value,
    $Res Function(_$AuthFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? code = null}) {
    return _then(
      _$AuthFailureImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$AuthFailureImpl implements AuthFailure {
  const _$AuthFailureImpl({required this.code});

  @override
  final String code;

  @override
  String toString() {
    return 'Failure.auth(code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthFailureImpl &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, code);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthFailureImplCopyWith<_$AuthFailureImpl> get copyWith =>
      __$$AuthFailureImplCopyWithImpl<_$AuthFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String code) auth,
    required TResult Function() network,
    required TResult Function(String action) permission,
    required TResult Function() rateLimit,
    required TResult Function(String field, String reason) validation,
    required TResult Function(String reason) conflict,
    required TResult Function(String? message) unknown,
  }) {
    return auth(code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String code)? auth,
    TResult? Function()? network,
    TResult? Function(String action)? permission,
    TResult? Function()? rateLimit,
    TResult? Function(String field, String reason)? validation,
    TResult? Function(String reason)? conflict,
    TResult? Function(String? message)? unknown,
  }) {
    return auth?.call(code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String code)? auth,
    TResult Function()? network,
    TResult Function(String action)? permission,
    TResult Function()? rateLimit,
    TResult Function(String field, String reason)? validation,
    TResult Function(String reason)? conflict,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthFailure value) auth,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(RateLimitFailure value) rateLimit,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(ConflictFailure value) conflict,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return auth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthFailure value)? auth,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(RateLimitFailure value)? rateLimit,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(ConflictFailure value)? conflict,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return auth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthFailure value)? auth,
    TResult Function(NetworkFailure value)? network,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(RateLimitFailure value)? rateLimit,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(ConflictFailure value)? conflict,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(this);
    }
    return orElse();
  }
}

abstract class AuthFailure implements Failure {
  const factory AuthFailure({required final String code}) = _$AuthFailureImpl;

  String get code;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthFailureImplCopyWith<_$AuthFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NetworkFailureImplCopyWith<$Res> {
  factory _$$NetworkFailureImplCopyWith(
    _$NetworkFailureImpl value,
    $Res Function(_$NetworkFailureImpl) then,
  ) = __$$NetworkFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NetworkFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NetworkFailureImpl>
    implements _$$NetworkFailureImplCopyWith<$Res> {
  __$$NetworkFailureImplCopyWithImpl(
    _$NetworkFailureImpl _value,
    $Res Function(_$NetworkFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$NetworkFailureImpl implements NetworkFailure {
  const _$NetworkFailureImpl();

  @override
  String toString() {
    return 'Failure.network()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NetworkFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String code) auth,
    required TResult Function() network,
    required TResult Function(String action) permission,
    required TResult Function() rateLimit,
    required TResult Function(String field, String reason) validation,
    required TResult Function(String reason) conflict,
    required TResult Function(String? message) unknown,
  }) {
    return network();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String code)? auth,
    TResult? Function()? network,
    TResult? Function(String action)? permission,
    TResult? Function()? rateLimit,
    TResult? Function(String field, String reason)? validation,
    TResult? Function(String reason)? conflict,
    TResult? Function(String? message)? unknown,
  }) {
    return network?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String code)? auth,
    TResult Function()? network,
    TResult Function(String action)? permission,
    TResult Function()? rateLimit,
    TResult Function(String field, String reason)? validation,
    TResult Function(String reason)? conflict,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthFailure value) auth,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(RateLimitFailure value) rateLimit,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(ConflictFailure value) conflict,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthFailure value)? auth,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(RateLimitFailure value)? rateLimit,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(ConflictFailure value)? conflict,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthFailure value)? auth,
    TResult Function(NetworkFailure value)? network,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(RateLimitFailure value)? rateLimit,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(ConflictFailure value)? conflict,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkFailure implements Failure {
  const factory NetworkFailure() = _$NetworkFailureImpl;
}

/// @nodoc
abstract class _$$PermissionFailureImplCopyWith<$Res> {
  factory _$$PermissionFailureImplCopyWith(
    _$PermissionFailureImpl value,
    $Res Function(_$PermissionFailureImpl) then,
  ) = __$$PermissionFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String action});
}

/// @nodoc
class __$$PermissionFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$PermissionFailureImpl>
    implements _$$PermissionFailureImplCopyWith<$Res> {
  __$$PermissionFailureImplCopyWithImpl(
    _$PermissionFailureImpl _value,
    $Res Function(_$PermissionFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? action = null}) {
    return _then(
      _$PermissionFailureImpl(
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PermissionFailureImpl implements PermissionFailure {
  const _$PermissionFailureImpl({required this.action});

  @override
  final String action;

  @override
  String toString() {
    return 'Failure.permission(action: $action)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionFailureImpl &&
            (identical(other.action, action) || other.action == action));
  }

  @override
  int get hashCode => Object.hash(runtimeType, action);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionFailureImplCopyWith<_$PermissionFailureImpl> get copyWith =>
      __$$PermissionFailureImplCopyWithImpl<_$PermissionFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String code) auth,
    required TResult Function() network,
    required TResult Function(String action) permission,
    required TResult Function() rateLimit,
    required TResult Function(String field, String reason) validation,
    required TResult Function(String reason) conflict,
    required TResult Function(String? message) unknown,
  }) {
    return permission(action);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String code)? auth,
    TResult? Function()? network,
    TResult? Function(String action)? permission,
    TResult? Function()? rateLimit,
    TResult? Function(String field, String reason)? validation,
    TResult? Function(String reason)? conflict,
    TResult? Function(String? message)? unknown,
  }) {
    return permission?.call(action);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String code)? auth,
    TResult Function()? network,
    TResult Function(String action)? permission,
    TResult Function()? rateLimit,
    TResult Function(String field, String reason)? validation,
    TResult Function(String reason)? conflict,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(action);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthFailure value) auth,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(RateLimitFailure value) rateLimit,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(ConflictFailure value) conflict,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return permission(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthFailure value)? auth,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(RateLimitFailure value)? rateLimit,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(ConflictFailure value)? conflict,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return permission?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthFailure value)? auth,
    TResult Function(NetworkFailure value)? network,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(RateLimitFailure value)? rateLimit,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(ConflictFailure value)? conflict,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(this);
    }
    return orElse();
  }
}

abstract class PermissionFailure implements Failure {
  const factory PermissionFailure({required final String action}) =
      _$PermissionFailureImpl;

  String get action;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PermissionFailureImplCopyWith<_$PermissionFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RateLimitFailureImplCopyWith<$Res> {
  factory _$$RateLimitFailureImplCopyWith(
    _$RateLimitFailureImpl value,
    $Res Function(_$RateLimitFailureImpl) then,
  ) = __$$RateLimitFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RateLimitFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$RateLimitFailureImpl>
    implements _$$RateLimitFailureImplCopyWith<$Res> {
  __$$RateLimitFailureImplCopyWithImpl(
    _$RateLimitFailureImpl _value,
    $Res Function(_$RateLimitFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RateLimitFailureImpl implements RateLimitFailure {
  const _$RateLimitFailureImpl();

  @override
  String toString() {
    return 'Failure.rateLimit()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RateLimitFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String code) auth,
    required TResult Function() network,
    required TResult Function(String action) permission,
    required TResult Function() rateLimit,
    required TResult Function(String field, String reason) validation,
    required TResult Function(String reason) conflict,
    required TResult Function(String? message) unknown,
  }) {
    return rateLimit();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String code)? auth,
    TResult? Function()? network,
    TResult? Function(String action)? permission,
    TResult? Function()? rateLimit,
    TResult? Function(String field, String reason)? validation,
    TResult? Function(String reason)? conflict,
    TResult? Function(String? message)? unknown,
  }) {
    return rateLimit?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String code)? auth,
    TResult Function()? network,
    TResult Function(String action)? permission,
    TResult Function()? rateLimit,
    TResult Function(String field, String reason)? validation,
    TResult Function(String reason)? conflict,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (rateLimit != null) {
      return rateLimit();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthFailure value) auth,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(RateLimitFailure value) rateLimit,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(ConflictFailure value) conflict,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return rateLimit(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthFailure value)? auth,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(RateLimitFailure value)? rateLimit,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(ConflictFailure value)? conflict,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return rateLimit?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthFailure value)? auth,
    TResult Function(NetworkFailure value)? network,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(RateLimitFailure value)? rateLimit,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(ConflictFailure value)? conflict,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (rateLimit != null) {
      return rateLimit(this);
    }
    return orElse();
  }
}

abstract class RateLimitFailure implements Failure {
  const factory RateLimitFailure() = _$RateLimitFailureImpl;
}

/// @nodoc
abstract class _$$ValidationFailureImplCopyWith<$Res> {
  factory _$$ValidationFailureImplCopyWith(
    _$ValidationFailureImpl value,
    $Res Function(_$ValidationFailureImpl) then,
  ) = __$$ValidationFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field, String reason});
}

/// @nodoc
class __$$ValidationFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ValidationFailureImpl>
    implements _$$ValidationFailureImplCopyWith<$Res> {
  __$$ValidationFailureImplCopyWithImpl(
    _$ValidationFailureImpl _value,
    $Res Function(_$ValidationFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field = null, Object? reason = null}) {
    return _then(
      _$ValidationFailureImpl(
        field: null == field
            ? _value.field
            : field // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ValidationFailureImpl implements ValidationFailure {
  const _$ValidationFailureImpl({required this.field, required this.reason});

  @override
  final String field;
  @override
  final String reason;

  @override
  String toString() {
    return 'Failure.validation(field: $field, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationFailureImpl &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field, reason);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      __$$ValidationFailureImplCopyWithImpl<_$ValidationFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String code) auth,
    required TResult Function() network,
    required TResult Function(String action) permission,
    required TResult Function() rateLimit,
    required TResult Function(String field, String reason) validation,
    required TResult Function(String reason) conflict,
    required TResult Function(String? message) unknown,
  }) {
    return validation(field, reason);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String code)? auth,
    TResult? Function()? network,
    TResult? Function(String action)? permission,
    TResult? Function()? rateLimit,
    TResult? Function(String field, String reason)? validation,
    TResult? Function(String reason)? conflict,
    TResult? Function(String? message)? unknown,
  }) {
    return validation?.call(field, reason);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String code)? auth,
    TResult Function()? network,
    TResult Function(String action)? permission,
    TResult Function()? rateLimit,
    TResult Function(String field, String reason)? validation,
    TResult Function(String reason)? conflict,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(field, reason);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthFailure value) auth,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(RateLimitFailure value) rateLimit,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(ConflictFailure value) conflict,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthFailure value)? auth,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(RateLimitFailure value)? rateLimit,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(ConflictFailure value)? conflict,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthFailure value)? auth,
    TResult Function(NetworkFailure value)? network,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(RateLimitFailure value)? rateLimit,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(ConflictFailure value)? conflict,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationFailure implements Failure {
  const factory ValidationFailure({
    required final String field,
    required final String reason,
  }) = _$ValidationFailureImpl;

  String get field;
  String get reason;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConflictFailureImplCopyWith<$Res> {
  factory _$$ConflictFailureImplCopyWith(
    _$ConflictFailureImpl value,
    $Res Function(_$ConflictFailureImpl) then,
  ) = __$$ConflictFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String reason});
}

/// @nodoc
class __$$ConflictFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ConflictFailureImpl>
    implements _$$ConflictFailureImplCopyWith<$Res> {
  __$$ConflictFailureImplCopyWithImpl(
    _$ConflictFailureImpl _value,
    $Res Function(_$ConflictFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = null}) {
    return _then(
      _$ConflictFailureImpl(
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ConflictFailureImpl implements ConflictFailure {
  const _$ConflictFailureImpl({required this.reason});

  @override
  final String reason;

  @override
  String toString() {
    return 'Failure.conflict(reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConflictFailureImpl &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConflictFailureImplCopyWith<_$ConflictFailureImpl> get copyWith =>
      __$$ConflictFailureImplCopyWithImpl<_$ConflictFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String code) auth,
    required TResult Function() network,
    required TResult Function(String action) permission,
    required TResult Function() rateLimit,
    required TResult Function(String field, String reason) validation,
    required TResult Function(String reason) conflict,
    required TResult Function(String? message) unknown,
  }) {
    return conflict(reason);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String code)? auth,
    TResult? Function()? network,
    TResult? Function(String action)? permission,
    TResult? Function()? rateLimit,
    TResult? Function(String field, String reason)? validation,
    TResult? Function(String reason)? conflict,
    TResult? Function(String? message)? unknown,
  }) {
    return conflict?.call(reason);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String code)? auth,
    TResult Function()? network,
    TResult Function(String action)? permission,
    TResult Function()? rateLimit,
    TResult Function(String field, String reason)? validation,
    TResult Function(String reason)? conflict,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (conflict != null) {
      return conflict(reason);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthFailure value) auth,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(RateLimitFailure value) rateLimit,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(ConflictFailure value) conflict,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return conflict(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthFailure value)? auth,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(RateLimitFailure value)? rateLimit,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(ConflictFailure value)? conflict,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return conflict?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthFailure value)? auth,
    TResult Function(NetworkFailure value)? network,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(RateLimitFailure value)? rateLimit,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(ConflictFailure value)? conflict,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (conflict != null) {
      return conflict(this);
    }
    return orElse();
  }
}

abstract class ConflictFailure implements Failure {
  const factory ConflictFailure({required final String reason}) =
      _$ConflictFailureImpl;

  String get reason;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConflictFailureImplCopyWith<_$ConflictFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownFailureImplCopyWith<$Res> {
  factory _$$UnknownFailureImplCopyWith(
    _$UnknownFailureImpl value,
    $Res Function(_$UnknownFailureImpl) then,
  ) = __$$UnknownFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$UnknownFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$UnknownFailureImpl>
    implements _$$UnknownFailureImplCopyWith<$Res> {
  __$$UnknownFailureImplCopyWithImpl(
    _$UnknownFailureImpl _value,
    $Res Function(_$UnknownFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$UnknownFailureImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$UnknownFailureImpl implements UnknownFailure {
  const _$UnknownFailureImpl({this.message});

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.unknown(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      __$$UnknownFailureImplCopyWithImpl<_$UnknownFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String code) auth,
    required TResult Function() network,
    required TResult Function(String action) permission,
    required TResult Function() rateLimit,
    required TResult Function(String field, String reason) validation,
    required TResult Function(String reason) conflict,
    required TResult Function(String? message) unknown,
  }) {
    return unknown(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String code)? auth,
    TResult? Function()? network,
    TResult? Function(String action)? permission,
    TResult? Function()? rateLimit,
    TResult? Function(String field, String reason)? validation,
    TResult? Function(String reason)? conflict,
    TResult? Function(String? message)? unknown,
  }) {
    return unknown?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String code)? auth,
    TResult Function()? network,
    TResult Function(String action)? permission,
    TResult Function()? rateLimit,
    TResult Function(String field, String reason)? validation,
    TResult Function(String reason)? conflict,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthFailure value) auth,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(RateLimitFailure value) rateLimit,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(ConflictFailure value) conflict,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthFailure value)? auth,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(RateLimitFailure value)? rateLimit,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(ConflictFailure value)? conflict,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthFailure value)? auth,
    TResult Function(NetworkFailure value)? network,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(RateLimitFailure value)? rateLimit,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(ConflictFailure value)? conflict,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownFailure implements Failure {
  const factory UnknownFailure({final String? message}) = _$UnknownFailureImpl;

  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
