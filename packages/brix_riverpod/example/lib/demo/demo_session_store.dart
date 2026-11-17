import 'package:brix/auth.dart';

/// Where the session lives between launches. This demo keeps it in memory
/// (a restart logs out); a real app uses secure storage
/// (`flutter_secure_storage`) for tokens and passwords.
class DemoSessionStore extends AuthSessionStore<String> {
  static AuthSession<String>? _session;
  static String? _pending;
  static RememberedCredentials? _remembered;

  @override
  Future<void> saveSession(AuthSession<String> session) async =>
      _session = session;

  @override
  Future<AuthSession<String>?> readSession() async => _session;

  @override
  Future<void> clearSession() async {
    _session = null;
    _pending = null;
  }

  @override
  Future<void> savePendingIdentifier(String identifier) async =>
      _pending = identifier;

  @override
  Future<String?> readPendingIdentifier() async => _pending;

  @override
  Future<void> clearPendingIdentifier() async => _pending = null;

  @override
  Future<void> saveRememberedCredentials(
    RememberedCredentials credentials,
  ) async => _remembered = credentials;

  @override
  Future<RememberedCredentials?> readRememberedCredentials() async =>
      _remembered;

  @override
  Future<void> clearRememberedCredentials() async => _remembered = null;
}
