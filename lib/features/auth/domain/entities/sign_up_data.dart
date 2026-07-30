import 'package:alkhair_app/core/constants/enums.dart';

/// The sign-up form, held in memory only until submit (ARCHITECTURE.md §6).
/// No Firebase Auth account or Firestore doc exists before that point.
class SignUpData {
  const SignUpData({
    required this.username,
    required this.password,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.vehicleType,
    this.charityId,
  });

  final String username;
  final String password;
  final String name;
  final String phone;
  final UserRole role;
  // Volunteer-only fields.
  final String? email;
  final String? vehicleType;
  final String? charityId;
}
