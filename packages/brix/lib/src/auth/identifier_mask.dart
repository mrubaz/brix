/// Hides most of an email or phone number for display, e.g. on the code
/// screen ("code sent to ru•••@gmail.com").
///
/// Email: first two letters of the name (one if it is short) and the full
/// domain. Anything else: only the last three characters.
String maskIdentifier(String identifier) {
  final value = identifier.trim();
  final at = value.indexOf('@');
  if (at > 0) {
    final name = value.substring(0, at);
    final shown = name.length > 2 ? 2 : 1;
    return '${name.substring(0, shown)}•••${value.substring(at)}';
  }
  if (value.length <= 4) return value;
  return '•••${value.substring(value.length - 3)}';
}
