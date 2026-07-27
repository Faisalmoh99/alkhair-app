// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_volunteer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PendingVolunteer {
  String get uid => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get vehicleType => throw _privateConstructorUsedError;
  ApprovalStatus get approvalStatus => throw _privateConstructorUsedError;
  String get charityId => throw _privateConstructorUsedError;

  /// Create a copy of PendingVolunteer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PendingVolunteerCopyWith<PendingVolunteer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PendingVolunteerCopyWith<$Res> {
  factory $PendingVolunteerCopyWith(
    PendingVolunteer value,
    $Res Function(PendingVolunteer) then,
  ) = _$PendingVolunteerCopyWithImpl<$Res, PendingVolunteer>;
  @useResult
  $Res call({
    String uid,
    String name,
    String phone,
    String vehicleType,
    ApprovalStatus approvalStatus,
    String charityId,
  });
}

/// @nodoc
class _$PendingVolunteerCopyWithImpl<$Res, $Val extends PendingVolunteer>
    implements $PendingVolunteerCopyWith<$Res> {
  _$PendingVolunteerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PendingVolunteer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? name = null,
    Object? phone = null,
    Object? vehicleType = null,
    Object? approvalStatus = null,
    Object? charityId = null,
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
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicleType: null == vehicleType
                ? _value.vehicleType
                : vehicleType // ignore: cast_nullable_to_non_nullable
                      as String,
            approvalStatus: null == approvalStatus
                ? _value.approvalStatus
                : approvalStatus // ignore: cast_nullable_to_non_nullable
                      as ApprovalStatus,
            charityId: null == charityId
                ? _value.charityId
                : charityId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PendingVolunteerImplCopyWith<$Res>
    implements $PendingVolunteerCopyWith<$Res> {
  factory _$$PendingVolunteerImplCopyWith(
    _$PendingVolunteerImpl value,
    $Res Function(_$PendingVolunteerImpl) then,
  ) = __$$PendingVolunteerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uid,
    String name,
    String phone,
    String vehicleType,
    ApprovalStatus approvalStatus,
    String charityId,
  });
}

/// @nodoc
class __$$PendingVolunteerImplCopyWithImpl<$Res>
    extends _$PendingVolunteerCopyWithImpl<$Res, _$PendingVolunteerImpl>
    implements _$$PendingVolunteerImplCopyWith<$Res> {
  __$$PendingVolunteerImplCopyWithImpl(
    _$PendingVolunteerImpl _value,
    $Res Function(_$PendingVolunteerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PendingVolunteer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? name = null,
    Object? phone = null,
    Object? vehicleType = null,
    Object? approvalStatus = null,
    Object? charityId = null,
  }) {
    return _then(
      _$PendingVolunteerImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleType: null == vehicleType
            ? _value.vehicleType
            : vehicleType // ignore: cast_nullable_to_non_nullable
                  as String,
        approvalStatus: null == approvalStatus
            ? _value.approvalStatus
            : approvalStatus // ignore: cast_nullable_to_non_nullable
                  as ApprovalStatus,
        charityId: null == charityId
            ? _value.charityId
            : charityId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PendingVolunteerImpl implements _PendingVolunteer {
  const _$PendingVolunteerImpl({
    required this.uid,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.approvalStatus,
    required this.charityId,
  });

  @override
  final String uid;
  @override
  final String name;
  @override
  final String phone;
  @override
  final String vehicleType;
  @override
  final ApprovalStatus approvalStatus;
  @override
  final String charityId;

  @override
  String toString() {
    return 'PendingVolunteer(uid: $uid, name: $name, phone: $phone, vehicleType: $vehicleType, approvalStatus: $approvalStatus, charityId: $charityId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PendingVolunteerImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.approvalStatus, approvalStatus) ||
                other.approvalStatus == approvalStatus) &&
            (identical(other.charityId, charityId) ||
                other.charityId == charityId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    uid,
    name,
    phone,
    vehicleType,
    approvalStatus,
    charityId,
  );

  /// Create a copy of PendingVolunteer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PendingVolunteerImplCopyWith<_$PendingVolunteerImpl> get copyWith =>
      __$$PendingVolunteerImplCopyWithImpl<_$PendingVolunteerImpl>(
        this,
        _$identity,
      );
}

abstract class _PendingVolunteer implements PendingVolunteer {
  const factory _PendingVolunteer({
    required final String uid,
    required final String name,
    required final String phone,
    required final String vehicleType,
    required final ApprovalStatus approvalStatus,
    required final String charityId,
  }) = _$PendingVolunteerImpl;

  @override
  String get uid;
  @override
  String get name;
  @override
  String get phone;
  @override
  String get vehicleType;
  @override
  ApprovalStatus get approvalStatus;
  @override
  String get charityId;

  /// Create a copy of PendingVolunteer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PendingVolunteerImplCopyWith<_$PendingVolunteerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
