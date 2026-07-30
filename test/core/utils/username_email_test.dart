import 'package:alkhair_app/core/utils/username_email.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a username to the synthetic email domain', () {
    expect(usernameToEmail('faisal'), 'faisal@alkhair-app.internal');
  });
}
