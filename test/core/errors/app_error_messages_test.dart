import 'package:alkhair_app/core/errors/app_error_messages.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

// New auth error/status cases for the username+password migration
// (ARCHITECTURE.md §6) — every code the sign-up/login/forgot-password flows
// can surface must map to a non-empty, distinct Arabic message.
void main() {
  test('every new auth error code maps to a message', () {
    const codes = [
      'resend-cooldown',
      'username-already-in-use',
      'weak-password',
      'invalid-credentials',
      'account-not-found',
      'phone-already-registered',
    ];
    final messages = {
      for (final code in codes) code: arabicErrorMessage(Failure.auth(code: code)),
    };

    for (final entry in messages.entries) {
      expect(entry.value, isNotEmpty, reason: entry.key);
    }
    expect(messages.values.toSet().length, codes.length, reason: 'messages must be distinct');
  });
}
