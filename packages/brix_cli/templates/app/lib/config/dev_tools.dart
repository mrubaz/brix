/// Helpers that exist only while developing (`main_development.dart`):
/// the login hint, the code hint and resetting the local backend. A release
/// build never registers them, so the screens show none of it.
abstract class DevTools {
  /// Shown on the login screen, e.g. the demo account.
  String get loginHint;

  /// Shown on code screens, e.g. the demo code.
  String get codeHint;

  /// Puts this device's local backend back to its first state.
  Future<void> resetLocalBackend();
}
