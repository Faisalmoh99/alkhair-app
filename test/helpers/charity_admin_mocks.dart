import 'package:alkhair_app/features/charity_admin/domain/repositories/charity_admin_repository.dart';
import 'package:mocktail/mocktail.dart';

/// Mock of the charity-admin feature's seam. Used to drive controllers and
/// screens in tests without touching Firebase.
class MockCharityAdminRepository extends Mock implements CharityAdminRepository {}
