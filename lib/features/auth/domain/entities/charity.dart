import 'package:freezed_annotation/freezed_annotation.dart';

part 'charity.freezed.dart';

/// Reference data from the `Charities` collection (Table 4.5). Used to populate
/// the volunteer registration dropdown; `charity_id` is written immutably onto
/// the volunteer's sub-doc at create.
@freezed
class Charity with _$Charity {
  const factory Charity({
    required String id,
    required String name,
  }) = _Charity;
}
