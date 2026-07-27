import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// OTP flow phases — the SECURITY.md §1.2 state machine.
enum OtpPhase { idle, requestingOtp, otpSent, verifying, success, error, locked }

/// Immutable snapshot of the OTP flow.
class AuthFlowState {
  const AuthFlowState({
    this.phase = OtpPhase.idle,
    this.phone,
    this.verificationId,
    this.errorCode,
    this.attempts = 0,
    this.signedInUid,
  });

  final OtpPhase phase;
  final String? phone;
  final String? verificationId;
  final String? errorCode;
  final int attempts;
  final String? signedInUid;

  AuthFlowState copyWith({
    OtpPhase? phase,
    String? phone,
    String? verificationId,
    String? errorCode,
    int? attempts,
    String? signedInUid,
    bool clearError = false,
  }) {
    return AuthFlowState(
      phase: phase ?? this.phase,
      phone: phone ?? this.phone,
      verificationId: verificationId ?? this.verificationId,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      attempts: attempts ?? this.attempts,
      signedInUid: signedInUid ?? this.signedInUid,
    );
  }
}

@riverpod
class AuthController extends _$AuthController {
  /// Wrong-code attempts allowed before a temporary lock (SECURITY.md §1.2).
  static const int maxAttempts = 3;

  @override
  AuthFlowState build() => const AuthFlowState();

  /// IDLE → REQUESTING_OTP → OTP_SENT | ERROR.
  Future<void> requestOtp(String phone) async {
    state = state.copyWith(
      phase: OtpPhase.requestingOtp,
      phone: phone,
      clearError: true,
    );
    final result = await ref.read(authRepositoryProvider).requestOtp(phone);
    state = result.fold(
      (failure) =>
          state.copyWith(phase: OtpPhase.error, errorCode: _codeOf(failure)),
      (verificationId) => state.copyWith(
        phase: OtpPhase.otpSent,
        verificationId: verificationId,
        attempts: 0,
        clearError: true,
      ),
    );
  }

  /// OTP_SENT → VERIFYING → SUCCESS | OTP_SENT(retry) | LOCKED.
  Future<void> confirmOtp(String smsCode) async {
    final verificationId = state.verificationId;
    if (verificationId == null) {
      state = state.copyWith(phase: OtpPhase.error, errorCode: 'session-expired');
      return;
    }
    state = state.copyWith(phase: OtpPhase.verifying, clearError: true);
    final result = await ref.read(authRepositoryProvider).confirmOtp(
          verificationId: verificationId,
          smsCode: smsCode,
        );
    state = result.fold(
      (failure) {
        final attempts = state.attempts + 1;
        final locked = attempts >= maxAttempts;
        return state.copyWith(
          phase: locked ? OtpPhase.locked : OtpPhase.otpSent,
          attempts: attempts,
          errorCode: _codeOf(failure),
        );
      },
      (uid) => state.copyWith(
        phase: OtpPhase.success,
        signedInUid: uid,
        clearError: true,
      ),
    );
  }

  /// Back to a clean IDLE state (e.g. changing the phone number).
  void reset() => state = const AuthFlowState();

  String _codeOf(Failure failure) => switch (failure) {
        AuthFailure(:final code) => code,
        NetworkFailure() => 'network-request-failed',
        _ => 'unknown',
      };
}
