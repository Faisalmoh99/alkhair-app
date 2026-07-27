import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Unified Failure union — every repository returns Either(Failure, T).
/// See SECURITY.md §6 (logging) and §7 (Arabic error layer).
@freezed
sealed class Failure with _$Failure {
  const factory Failure.auth({required String code}) = AuthFailure;
  const factory Failure.network() = NetworkFailure;
  const factory Failure.permission({required String action}) = PermissionFailure;
  const factory Failure.rateLimit() = RateLimitFailure;
  const factory Failure.validation({required String field, required String reason}) = ValidationFailure;
  const factory Failure.conflict({required String reason}) = ConflictFailure;
  const factory Failure.unknown({String? message}) = UnknownFailure;
}
