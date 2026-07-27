// Sole entry point — connects to the single real Firebase project
// (alkhair-bisha-dev). See SECURITY.md §6 for the USE_EMULATOR/environment setup.
import 'package:alkhair_app/bootstrap.dart';
import 'package:alkhair_app/firebase_options.dart';

void main() => bootstrap(DefaultFirebaseOptions.currentPlatform);
