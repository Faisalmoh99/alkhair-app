import 'package:alkhair_app/core/utils/phone_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeSaudiPhone', () {
    test('already E.164 → unchanged', () {
      expect(normalizeSaudiPhone('+966500000000'), '+966500000000');
    });

    test('E.164 with spaces → stripped', () {
      expect(normalizeSaudiPhone('+966 50 000 0000'), '+966500000000');
    });

    test('00 international prefix → normalized', () {
      expect(normalizeSaudiPhone('00966500000000'), '+966500000000');
    });

    test('bare country code (no +) → normalized', () {
      expect(normalizeSaudiPhone('966500000000'), '+966500000000');
    });

    test('local format with leading 0 → normalized', () {
      expect(normalizeSaudiPhone('0500000000'), '+966500000000');
    });

    test('local format with leading 0 and dashes → normalized', () {
      expect(normalizeSaudiPhone('050-000-0000'), '+966500000000');
    });

    test('9-digit mobile without leading 0 → normalized', () {
      expect(normalizeSaudiPhone('500000000'), '+966500000000');
    });

    test('too short → null', () {
      expect(normalizeSaudiPhone('50000'), isNull);
    });

    test('too long → null', () {
      expect(normalizeSaudiPhone('+9665000000000'), isNull);
    });

    test('non-mobile prefix (not starting with 5) → null', () {
      expect(normalizeSaudiPhone('+966100000000'), isNull);
    });

    test('letters → null', () {
      expect(normalizeSaudiPhone('+96650abc0000'), isNull);
    });

    test('empty string → null', () {
      expect(normalizeSaudiPhone(''), isNull);
    });
  });
}
