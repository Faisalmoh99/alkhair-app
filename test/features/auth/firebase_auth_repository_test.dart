import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_mocks.dart';
import '../../helpers/donor_mocks.dart';

// Phase 7 Part A1: updateVolunteerLocation is the concrete write path behind
// the volunteer home screen's manual refresh — the only write shape it may
// send is {current_lat, current_lng}, matching firestore.rules' owner-update
// path.
void main() {
  late MockFirebaseFirestore firestore;
  late MockCollectionReference volunteers;
  late MockDocumentReference doc;
  late FirebaseAuthRepository repo;

  setUp(() {
    firestore = MockFirebaseFirestore();
    volunteers = MockCollectionReference();
    doc = MockDocumentReference();
    when(() => firestore.collection('Volunteers')).thenReturn(volunteers);
    when(() => volunteers.doc('vol1')).thenReturn(doc);
    repo = FirebaseAuthRepository(
      auth: _NoopFirebaseAuth(),
      firestore: firestore,
      functions: MockFirebaseFunctions(),
    );
  });

  test("writes only current_lat/current_lng on the caller's own doc", () async {
    when(() => doc.update(any())).thenAnswer((_) async {});

    final result = await repo.updateVolunteerLocation(
      uid: 'vol1',
      latitude: 20.5,
      longitude: 42.75,
    );

    expect(result.isRight(), isTrue);
    verify(() => doc.update({'current_lat': 20.5, 'current_lng': 42.75})).called(1);
  });

  test('maps a Firestore exception to a Failure', () async {
    when(() => doc.update(any())).thenThrow(
      FirebaseException(plugin: 'firestore', code: 'permission-denied'),
    );

    final result = await repo.updateVolunteerLocation(
      uid: 'vol1',
      latitude: 20.5,
      longitude: 42.75,
    );

    expect(result.isLeft(), isTrue);
  });

  // No phone/OTP verification (ARCHITECTURE.md §6): the account is created
  // directly with the chosen username+password, mapped to a synthetic email.
  group('createUserWithUsernamePassword', () {
    late MockFirebaseAuth auth;
    late MockUser user;
    late MockUserCredential credential;

    setUp(() {
      auth = MockFirebaseAuth();
      user = MockUser();
      credential = MockUserCredential();
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => credential);
      when(() => credential.user).thenReturn(user);
      when(() => user.uid).thenReturn('u1');
      repo = FirebaseAuthRepository(
        auth: auth,
        firestore: firestore,
        functions: MockFirebaseFunctions(),
      );
    });

    test('maps the username to the synthetic email domain', () async {
      final result = await repo.createUserWithUsernamePassword(
        username: 'faisal',
        password: 'secret1',
      );

      expect(result.isRight(), isTrue);
      verify(
        () => auth.createUserWithEmailAndPassword(
          email: 'faisal@alkhair-app.internal',
          password: 'secret1',
        ),
      ).called(1);
    });

    test('maps email-already-in-use to username-already-in-use (duplicate '
        'username)', () async {
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final result = await repo.createUserWithUsernamePassword(
        username: 'taken',
        password: 'secret1',
      );

      expect(
        result.fold((f) => (f as AuthFailure).code, (_) => null),
        'username-already-in-use',
      );
    });

    test('maps weak-password through unchanged', () async {
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'weak-password'));

      final result = await repo.createUserWithUsernamePassword(
        username: 'faisal',
        password: '123',
      );

      expect(
        result.fold((f) => (f as AuthFailure).code, (_) => null),
        'weak-password',
      );
    });
  });

  group('signInWithUsernamePassword', () {
    late MockFirebaseAuth auth;
    late MockUser user;
    late MockUserCredential credential;

    setUp(() {
      auth = MockFirebaseAuth();
      user = MockUser();
      credential = MockUserCredential();
      when(
        () => auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => credential);
      when(() => credential.user).thenReturn(user);
      when(() => user.uid).thenReturn('u1');
      repo = FirebaseAuthRepository(
        auth: auth,
        firestore: firestore,
        functions: MockFirebaseFunctions(),
      );
    });

    test('maps the username to the synthetic email domain', () async {
      final result = await repo.signInWithUsernamePassword(
        username: 'faisal',
        password: 'secret1',
      );

      expect(result.isRight(), isTrue);
      verify(
        () => auth.signInWithEmailAndPassword(
          email: 'faisal@alkhair-app.internal',
          password: 'secret1',
        ),
      ).called(1);
    });

    test('maps wrong-password/user-not-found to invalid-credentials', () async {
      when(
        () => auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      final result = await repo.signInWithUsernamePassword(
        username: 'faisal',
        password: 'wrong',
      );

      expect(
        result.fold((f) => (f as AuthFailure).code, (_) => null),
        'invalid-credentials',
      );
    });
  });

  // Sign-up duplicate-phone pre-check (checkPhoneRegistered): phone numbers
  // must stay unique across Users even though they are no longer verified.
  group('checkPhoneRegistered', () {
    late MockFirebaseFunctions functions;
    late MockHttpsCallable callable;
    late MockHttpsCallableResult callableResult;

    setUp(() {
      functions = MockFirebaseFunctions();
      callable = MockHttpsCallable();
      callableResult = MockHttpsCallableResult();
      when(() => functions.httpsCallable('checkPhoneRegistered')).thenReturn(callable);
      when(() => callable.call<dynamic>(any<Object?>())).thenAnswer((_) async => callableResult);
      repo = FirebaseAuthRepository(
        auth: _NoopFirebaseAuth(),
        firestore: firestore,
        functions: functions,
      );
    });

    test('returns true when the phone is already registered', () async {
      when(() => callableResult.data).thenReturn({'registered': true});

      final result = await repo.checkPhoneRegistered('+966500000000');

      expect(result.fold((_) => null, (registered) => registered), isTrue);
    });

    test('returns false when the phone is not registered', () async {
      when(() => callableResult.data).thenReturn({'registered': false});

      final result = await repo.checkPhoneRegistered('+966500000001');

      expect(result.fold((_) => null, (registered) => registered), isFalse);
    });
  });
}

class _NoopFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockUserCredential extends Mock implements UserCredential {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

// ignore: subtype_of_sealed_class, mocktail's noSuchMethod dispatch works fine for sealed cloud_functions classes
class MockHttpsCallableResult extends Mock implements HttpsCallableResult<dynamic> {}
