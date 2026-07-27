import 'package:alkhair_app/features/donor/data/services/location_service.dart';
import 'package:alkhair_app/features/donor/domain/repositories/donation_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

/// Shared mock of the donor feature's two seams. Used to drive controllers
/// and screens in tests without touching Firebase or device location.
class MockDonationRepository extends Mock implements DonationRepository {}

class MockLocationService extends Mock implements LocationService {}

/// Mocks of the Firebase Auth types the status screen reads `currentUser`
/// from directly (no dedicated "current uid" provider exists yet).
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockIdTokenResult extends Mock implements IdTokenResult {}
