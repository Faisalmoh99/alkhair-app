import 'package:alkhair_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

/// Shared mock of the single auth seam. Used to drive controllers in unit tests
/// without touching Firebase.
class MockAuthRepository extends Mock implements AuthRepository {}

/// Mocks of the raw Firestore handle chain, for unit-testing
/// FirebaseAuthRepository's methods directly (Phase 7 Part A1/B) without an
/// emulator. cloud_firestore marks these classes `sealed` to keep its own
/// implementation hierarchy exhaustive; mocktail's noSuchMethod dispatch
/// still works fine for tests, so the lint is suppressed rather than avoided.
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// ignore: subtype_of_sealed_class, mocktail's noSuchMethod dispatch works fine for sealed Firestore classes
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class, mocktail's noSuchMethod dispatch works fine for sealed Firestore classes
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class, mocktail's noSuchMethod dispatch works fine for sealed Firestore classes
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class, mocktail's noSuchMethod dispatch works fine for sealed Firestore classes
class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class, mocktail's noSuchMethod dispatch works fine for sealed Firestore classes
class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}
