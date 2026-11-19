/// Helpers that exist only in debug builds on the local test backend
/// (`lib/dev`): hints on the login and code screens, skipping the login and
/// resetting the backend. A release build never has them, so the screens
/// show none of it.
abstract class DevTools {
  /// Shown on the login screen, e.g. the demo account.
  String get loginHint;

  /// Shown on code screens, e.g. the demo code.
  String get codeHint;

  /// Opens the home screen as a test user, to work on screens without
  /// logging in.
  Future<void> skipLogin();

  /// Puts this device's local backend back to its first state.
  Future<void> resetLocalBackend();
}
