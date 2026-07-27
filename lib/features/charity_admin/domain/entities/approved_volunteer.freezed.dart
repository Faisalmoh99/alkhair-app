// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'approved_volunteer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ApprovedVolunteer {
  String get uid => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Create a copy of ApprovedVolunteer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApprovedVolunteerCopyWith<ApprovedVolunteer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApprovedVolunteerCopyWith<$Res> {
  factory $ApprovedVolunteerCopyWith(
    ApprovedVolunteer value,
    $Res Function(ApprovedVolunteer) then,
  ) = _$ApprovedVolunteerCopyWithImpl<$Res, ApprovedVolunteer>;
  @useResult
  $Res call({String uid, String name});
}

/// @nodoc
class _$ApprovedVolunteerCopyWithImpl<$Res, $Val extends ApprovedVolunteer>
    implements $ApprovedVolunteerCopyWith<$Res> {
  _$ApprovedVolunteerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApprovedVolunteer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? uid = null, Object? name = null}) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApprovedVolunteerImplCopyWith<$Res>
    implements $ApprovedVolunteerCopyWith<$Res> {
  factory _$$ApprovedVolunteerImplCopyWith(
    _$ApprovedVolunteerImpl value,
    $Res Function(_$ApprovedVolunteerImpl) then,
  ) = __$$ApprovedVolunteerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String uid, String name});
}

/// @nodoc
class __$$ApprovedVolunteerImplCopyWithImpl<$Res>
    extends _$ApprovedVolunteerCopyWithImpl<$Res, _$ApprovedVolunteerImpl>
    implements _$$ApprovedVolunteerImplCopyWith<$Res> {
  __$$ApprovedVolunteerImplCopyWithImpl(
    _$ApprovedVolunteerImpl _value,
    $Res Function(_$ApprovedVolunteerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApprovedVolunteer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? uid = null, Object? name = null}) {
    return _then(
      _$ApprovedVolunteerImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ApprovedVolunteerImpl implements _ApprovedVolunteer {
  const _$ApprovedVolunteerImpl({required this.uid, required this.name});

  @override
  final String uid;
  @override
  final String name;

  @override
  String toString() {
    return 'ApprovedVolunteer(uid: $uid, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApprovedVolunteerImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, uid, name);

  /// Create a copy of ApprovedVolunteer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApprovedVolunteerImplCopyWith<_$ApprovedVolunteerImpl> get copyWith =>
      __$$ApprovedVolunteerImplCopyWithImpl<_$ApprovedVolunteerImpl>(
        this,
        _$identity,
      );
}

abstract class _ApprovedVolunteer implements ApprovedVolunteer {
  const factory _ApprovedVolunteer({
    required final String uid,
    required final String name,
  }) = _$ApprovedVolunteerImpl;

  @override
  String get uid;
  @override
  String get name;

  /// Create a copy of ApprovedVolunteer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApprovedVolunteerImplCopyWith<_$ApprovedVolunteerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
