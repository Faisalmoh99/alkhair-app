import 'package:alkhair_app/core/constants/app_constants.dart';

/// Firebase Auth has no native username provider, so a username is mapped to
/// a synthetic email for Email/Password sign-up/sign-in. Never shown in UI.
String usernameToEmail(String username) => '$username$kSyntheticEmailDomain';
