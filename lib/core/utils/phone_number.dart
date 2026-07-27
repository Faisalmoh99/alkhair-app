/// Normalizes user-entered Saudi mobile input to E.164 (+9665XXXXXXXX), or
/// returns null if it cannot be interpreted as a valid Saudi mobile number.
///
/// Firebase phone auth compares the sent string byte-for-byte against the
/// registered test number, so any stray spaces/dashes or a missing country
/// code sent from the UI won't match and can crash the native SDK.
String? normalizeSaudiPhone(String raw) {
  final stripped = raw.replaceAll(RegExp(r'[\s\-()]'), '');

  String? digits;
  if (stripped.startsWith('+966')) {
    digits = stripped.substring(4);
  } else if (stripped.startsWith('00966')) {
    digits = stripped.substring(5);
  } else if (stripped.startsWith('966')) {
    digits = stripped.substring(3);
  } else if (stripped.startsWith('05')) {
    digits = stripped.substring(1);
  } else if (stripped.startsWith('5')) {
    digits = stripped;
  } else {
    return null;
  }

  if (!RegExp(r'^5\d{8}$').hasMatch(digits)) return null;
  return '+966$digits';
}
