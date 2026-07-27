import 'package:alkhair_app/features/charity_admin/data/repositories/firebase_charity_admin_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_mocks.dart';

// Phase 7 follow-up: watchGeneratedReports must filter by charity_id — the
// Reports read rule requires resource.data.charity_id to match on every
// document with no unconditional admin branch, and Firestore rejects an
// entire list query when it can't prove that holds without a matching
// `where`. This was a real bug (reports directory showed "تعذّر تحميل
// التقارير") caused by the filter being missing entirely.
void main() {
  late MockFirebaseFirestore firestore;
  late MockCollectionReference collection;
  late MockQuery filtered;
  late MockQuery ordered;
  late FirebaseCharityAdminRepository repo;

  setUp(() {
    firestore = MockFirebaseFirestore();
    collection = MockCollectionReference();
    filtered = MockQuery();
    ordered = MockQuery();
    when(() => firestore.collection('Reports')).thenReturn(collection);
    repo = FirebaseCharityAdminRepository(
      firestore: firestore,
      functions: _NoopFirebaseFunctions(),
    );
  });

  test('watchGeneratedReports filters by charity_id before ordering', () async {
    when(
      () => collection.where('charity_id', isEqualTo: 'charity1'),
    ).thenReturn(filtered);
    when(
      () => filtered.orderBy('generated_at', descending: true),
    ).thenReturn(ordered);
    final snapshot = MockQuerySnapshot();
    when(() => snapshot.docs).thenReturn(const []);
    when(() => ordered.snapshots()).thenAnswer((_) => Stream.value(snapshot));

    final result = await repo.watchGeneratedReports('charity1').first;

    expect(result, isEmpty);
    verify(() => collection.where('charity_id', isEqualTo: 'charity1')).called(1);
    verify(() => filtered.orderBy('generated_at', descending: true)).called(1);
  });
}

class _NoopFirebaseFunctions extends Mock implements FirebaseFunctions {}
