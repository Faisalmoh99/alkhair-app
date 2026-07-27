// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'volunteer_ranking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VolunteerRanking {
  String get uid => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get deliveredCount => throw _privateConstructorUsedError;
  bool get isLeader => throw _privateConstructorUsedError;

  /// Create a copy of VolunteerRanking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VolunteerRankingCopyWith<VolunteerRanking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VolunteerRankingCopyWith<$Res> {
  factory $VolunteerRankingCopyWith(
    VolunteerRanking value,
    $Res Function(VolunteerRanking) then,
  ) = _$VolunteerRankingCopyWithImpl<$Res, VolunteerRanking>;
  @useResult
  $Res call({String uid, String name, int deliveredCount, bool isLeader});
}

/// @nodoc
class _$VolunteerRankingCopyWithImpl<$Res, $Val extends VolunteerRanking>
    implements $VolunteerRankingCopyWith<$Res> {
  _$VolunteerRankingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VolunteerRanking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? name = null,
    Object? deliveredCount = null,
    Object? isLeader = null,
  }) {
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
            deliveredCount: null == deliveredCount
                ? _value.deliveredCount
                : deliveredCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isLeader: null == isLeader
                ? _value.isLeader
                : isLeader // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VolunteerRankingImplCopyWith<$Res>
    implements $VolunteerRankingCopyWith<$Res> {
  factory _$$VolunteerRankingImplCopyWith(
    _$VolunteerRankingImpl value,
    $Res Function(_$VolunteerRankingImpl) then,
  ) = __$$VolunteerRankingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String uid, String name, int deliveredCount, bool isLeader});
}

/// @nodoc
class __$$VolunteerRankingImplCopyWithImpl<$Res>
    extends _$VolunteerRankingCopyWithImpl<$Res, _$VolunteerRankingImpl>
    implements _$$VolunteerRankingImplCopyWith<$Res> {
  __$$VolunteerRankingImplCopyWithImpl(
    _$VolunteerRankingImpl _value,
    $Res Function(_$VolunteerRankingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VolunteerRanking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? name = null,
    Object? deliveredCount = null,
    Object? isLeader = null,
  }) {
    return _then(
      _$VolunteerRankingImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        deliveredCount: null == deliveredCount
            ? _value.deliveredCount
            : deliveredCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isLeader: null == isLeader
            ? _value.isLeader
            : isLeader // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$VolunteerRankingImpl implements _VolunteerRanking {
  const _$VolunteerRankingImpl({
    required this.uid,
    required this.name,
    required this.deliveredCount,
    required this.isLeader,
  });

  @override
  final String uid;
  @override
  final String name;
  @override
  final int deliveredCount;
  @override
  final bool isLeader;

  @override
  String toString() {
    return 'VolunteerRanking(uid: $uid, name: $name, deliveredCount: $deliveredCount, isLeader: $isLeader)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VolunteerRankingImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.deliveredCount, deliveredCount) ||
                other.deliveredCount == deliveredCount) &&
            (identical(other.isLeader, isLeader) ||
                other.isLeader == isLeader));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, uid, name, deliveredCount, isLeader);

  /// Create a copy of VolunteerRanking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VolunteerRankingImplCopyWith<_$VolunteerRankingImpl> get copyWith =>
      __$$VolunteerRankingImplCopyWithImpl<_$VolunteerRankingImpl>(
        this,
        _$identity,
      );
}

abstract class _VolunteerRanking implements VolunteerRanking {
  const factory _VolunteerRanking({
    required final String uid,
    required final String name,
    required final int deliveredCount,
    required final bool isLeader,
  }) = _$VolunteerRankingImpl;

  @override
  String get uid;
  @override
  String get name;
  @override
  int get deliveredCount;
  @override
  bool get isLeader;

  /// Create a copy of VolunteerRanking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VolunteerRankingImplCopyWith<_$VolunteerRankingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
