import 'package:alkhair_app/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_mocks.dart';

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
}

class _NoopFirebaseAuth extends Mock implements FirebaseAuth {}
