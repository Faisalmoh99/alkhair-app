// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'donation_report_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DonationReportDraft {
  FoodCategory get foodCategory => throw _privateConstructorUsedError;
  num get quantity => throw _privateConstructorUsedError;
  DateTime get readinessTime => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  bool get safetyConfirmed => throw _privateConstructorUsedError;

  /// Create a copy of DonationReportDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DonationReportDraftCopyWith<DonationReportDraft> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DonationReportDraftCopyWith<$Res> {
  factory $DonationReportDraftCopyWith(
    DonationReportDraft value,
    $Res Function(DonationReportDraft) then,
  ) = _$DonationReportDraftCopyWithImpl<$Res, DonationReportDraft>;
  @useResult
  $Res call({
    FoodCategory foodCategory,
    num quantity,
    DateTime readinessTime,
    double latitude,
    double longitude,
    bool safetyConfirmed,
  });
}

/// @nodoc
class _$DonationReportDraftCopyWithImpl<$Res, $Val extends DonationReportDraft>
    implements $DonationReportDraftCopyWith<$Res> {
  _$DonationReportDraftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DonationReportDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foodCategory = null,
    Object? quantity = null,
    Object? readinessTime = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? safetyConfirmed = null,
  }) {
    return _then(
      _value.copyWith(
            foodCategory: null == foodCategory
                ? _value.foodCategory
                : foodCategory // ignore: cast_nullable_to_non_nullable
                      as FoodCategory,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as num,
            readinessTime: null == readinessTime
                ? _value.readinessTime
                : readinessTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            safetyConfirmed: null == safetyConfirmed
                ? _value.safetyConfirmed
                : safetyConfirmed // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DonationReportDraftImplCopyWith<$Res>
    implements $DonationReportDraftCopyWith<$Res> {
  factory _$$DonationReportDraftImplCopyWith(
    _$DonationReportDraftImpl value,
    $Res Function(_$DonationReportDraftImpl) then,
  ) = __$$DonationReportDraftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    FoodCategory foodCategory,
    num quantity,
    DateTime readinessTime,
    double latitude,
    double longitude,
    bool safetyConfirmed,
  });
}

/// @nodoc
class __$$DonationReportDraftImplCopyWithImpl<$Res>
    extends _$DonationReportDraftCopyWithImpl<$Res, _$DonationReportDraftImpl>
    implements _$$DonationReportDraftImplCopyWith<$Res> {
  __$$DonationReportDraftImplCopyWithImpl(
    _$DonationReportDraftImpl _value,
    $Res Function(_$DonationReportDraftImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DonationReportDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foodCategory = null,
    Object? quantity = null,
    Object? readinessTime = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? safetyConfirmed = null,
  }) {
    return _then(
      _$DonationReportDraftImpl(
        foodCategory: null == foodCategory
            ? _value.foodCategory
            : foodCategory // ignore: cast_nullable_to_non_nullable
                  as FoodCategory,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as num,
        readinessTime: null == readinessTime
            ? _value.readinessTime
            : readinessTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        safetyConfirmed: null == safetyConfirmed
            ? _value.safetyConfirmed
            : safetyConfirmed // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$DonationReportDraftImpl extends _DonationReportDraft {
  const _$DonationReportDraftImpl({
    required this.foodCategory,
    required this.quantity,
    required this.readinessTime,
    required this.latitude,
    required this.longitude,
    required this.safetyConfirmed,
  }) : super._();

  @override
  final FoodCategory foodCategory;
  @override
  final num quantity;
  @override
  final DateTime readinessTime;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final bool safetyConfirmed;

  @override
  String toString() {
    return 'DonationReportDraft(foodCategory: $foodCategory, quantity: $quantity, readinessTime: $readinessTime, latitude: $latitude, longitude: $longitude, safetyConfirmed: $safetyConfirmed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DonationReportDraftImpl &&
            (identical(other.foodCategory, foodCategory) ||
                other.foodCategory == foodCategory) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.readinessTime, readinessTime) ||
                other.readinessTime == readinessTime) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.safetyConfirmed, safetyConfirmed) ||
                other.safetyConfirmed == safetyConfirmed));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    foodCategory,
    quantity,
    readinessTime,
    latitude,
    longitude,
    safetyConfirmed,
  );

  /// Create a copy of DonationReportDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DonationReportDraftImplCopyWith<_$DonationReportDraftImpl> get copyWith =>
      __$$DonationReportDraftImplCopyWithImpl<_$DonationReportDraftImpl>(
        this,
        _$identity,
      );
}

abstract class _DonationReportDraft extends DonationReportDraft {
  const factory _DonationReportDraft({
    required final FoodCategory foodCategory,
    required final num quantity,
    required final DateTime readinessTime,
    required final double latitude,
    required final double longitude,
    required final bool safetyConfirmed,
  }) = _$DonationReportDraftImpl;
  const _DonationReportDraft._() : super._();

  @override
  FoodCategory get foodCategory;
  @override
  num get quantity;
  @override
  DateTime get readinessTime;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  bool get safetyConfirmed;

  /// Create a copy of DonationReportDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DonationReportDraftImplCopyWith<_$DonationReportDraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
