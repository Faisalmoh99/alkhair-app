import 'package:alkhair_app/core/constants/app_constants.dart';
import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/utils/username_email.dart';
import 'package:alkhair_app/features/auth/domain/entities/app_user.dart';
import 'package:alkhair_app/features/auth/domain/entities/charity.dart';
import 'package:alkhair_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

/// Firebase-concrete [AuthRepository]: username+password Auth + Firestore
/// Users/Volunteers/Charities. Raw exceptions are translated into [Failure]
/// at this boundary (SECURITY.md §7); this class is exercised end-to-end in
/// Track B / Phase 7.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  })  : _auth = auth,
        _db = firestore,
        _functions = functions;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  @override
  Stream<String?> authStateChanges() =>
      _auth.authStateChanges().map((user) => user?.uid);

  @override
  Future<Either<Failure, bool>> checkPhoneRegistered(String phone) async {
    try {
      final callable = _functions.httpsCallable('checkPhoneRegistered');
      final result = await callable.call<dynamic>({'phone': phone});
      final data = Map<String, dynamic>.from(result.data as Map);
      return right(data['registered'] as bool? ?? false);
    } on FirebaseFunctionsException catch (e) {
      return left(_mapFunctions(e));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> loadProfile(String uid) async {
    try {
      final userDoc = await _db.collection(Collections.users).doc(uid).get();
      if (!userDoc.exists) {
        return right(null);
      }
      final data = userDoc.data()!;
      final role = UserRole.fromFirestore(data['role'] as String);

      ApprovalStatus? approvalStatus;
      String? charityId;
      if (role == UserRole.volunteer) {
        final volDoc =
            await _db.collection(Collections.volunteers).doc(uid).get();
        if (volDoc.exists) {
          final v = volDoc.data()!;
          approvalStatus =
              ApprovalStatus.fromFirestore(v['approval_status'] as String);
          charityId = v['charity_id'] as String?;
        }
      } else if (role == UserRole.charityAdmin) {
        final adminDoc =
            await _db.collection(Collections.charityAdmins).doc(uid).get();
        if (adminDoc.exists) {
          charityId = adminDoc.data()!['charity_id'] as String?;
        }
      }

      return right(
        AppUser(
          uid: uid,
          name: (data['name'] as String?) ?? '',
          phone: (data['phone'] as String?) ?? '',
          role: role,
          email: data['email'] as String?,
          approvalStatus: approvalStatus,
          charityId: charityId,
        ),
      );
    } on FirebaseException catch (e) {
      return left(_mapFirestore(e));
    }
  }

  @override
  Future<Either<Failure, void>> createUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String username,
    required UserRole role,
  }) async {
    try {
      await _db.collection(Collections.users).doc(uid).set({
        'user_id': uid,
        'name': name,
        'phone': phone,
        'username': username,
        'role': role.firestoreValue,
        'created_at': FieldValue.serverTimestamp(),
      });
      return right(null);
    } on FirebaseException catch (e) {
      return left(_mapFirestore(e));
    }
  }

  @override
  Future<Either<Failure, String>> createUserWithUsernamePassword({
    required String username,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: usernameToEmail(username),
        password: password,
      );
      final uid = result.user?.uid;
      if (uid == null) {
        return left(const Failure.auth(code: 'sign-in-failed'));
      }
      return right(uid);
    } on FirebaseAuthException catch (e) {
      return left(Failure.auth(code: _mapUsernamePasswordCode(e.code)));
    }
  }

  @override
  Future<Either<Failure, String>> signInWithUsernamePassword({
    required String username,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: usernameToEmail(username),
        password: password,
      );
      final uid = result.user?.uid;
      if (uid == null) {
        return left(const Failure.auth(code: 'sign-in-failed'));
      }
      return right(uid);
    } on FirebaseAuthException catch (e) {
      return left(Failure.auth(code: _mapUsernamePasswordCode(e.code)));
    }
  }

  // email-already-in-use: create-time — username taken (error case 7).
  // wrong-password/user-not-found/invalid-credential: sign-in — bad credentials.
  // weak-password: password too short (error case 8, also inline-validated).
  String _mapUsernamePasswordCode(String code) => switch (code) {
        'email-already-in-use' ||
        'credential-already-in-use' =>
          'username-already-in-use',
        'weak-password' => 'weak-password',
        'wrong-password' ||
        'user-not-found' ||
        'invalid-credential' =>
          'invalid-credentials',
        _ => code,
      };

  Failure _mapFunctions(FirebaseFunctionsException e) => switch (e.code) {
        'resource-exhausted' => const Failure.rateLimit(),
        'unavailable' => const Failure.network(),
        _ => Failure.unknown(message: e.code),
      };

  @override
  Future<Either<Failure, void>> completeVolunteerRegistration({
    required String uid,
    required String email,
    required String vehicleType,
    required String charityId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final batch = _db.batch()
        ..update(_db.collection(Collections.users).doc(uid), {'email': email})
        ..set(_db.collection(Collections.volunteers).doc(uid), {
          'user_id': uid,
          'charity_id': charityId,
          'approval_status': ApprovalStatus.pending.firestoreValue,
          'vehicle_type': vehicleType,
          'current_lat': latitude,
          'current_lng': longitude,
        });
      await batch.commit();
      return right(null);
    } on FirebaseException catch (e) {
      return left(_mapFirestore(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateVolunteerLocation({
    required String uid,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _db.collection(Collections.volunteers).doc(uid).update({
        'current_lat': latitude,
        'current_lng': longitude,
      });
      return right(null);
    } on FirebaseException catch (e) {
      return left(_mapFirestore(e));
    }
  }

  @override
  Future<Either<Failure, List<Charity>>> fetchCharities() async {
    try {
      final snap = await _db.collection(Collections.charities).get();
      final charities = snap.docs
          .map((d) => Charity(id: d.id, name: (d.data()['name'] as String?) ?? ''))
          .toList();
      return right(charities);
    } on FirebaseException catch (e) {
      return left(_mapFirestore(e));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  Failure _mapFirestore(FirebaseException e) => switch (e.code) {
        'permission-denied' => const Failure.permission(action: 'firestore'),
        'unavailable' || 'network-request-failed' => const Failure.network(),
        _ => Failure.unknown(message: e.code),
      };
}
