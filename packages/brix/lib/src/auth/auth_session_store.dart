import 'auth_session.dart';
import 'remembered_credentials.dart';

/// Where the app keeps the session between launches. Each app writes one
/// subclass on its own storage.
///
/// Tokens and passwords must go to secure storage (Keychain / Keystore),
/// never to plain preferences, and never to a log.
///
/// Only the session calls must be written. The pending identifier and
/// "remember me" are optional: until overridden they store nothing and read
/// `null`. Calls added to brix later arrive with a default the same way.
abstract class AuthSessionStore<TUser> {
  const AuthSessionStore();

  Future<void> saveSession(AuthSession<TUser> session);

  /// The saved session, or `null` when nobody is logged in.
  Future<AuthSession<TUser>?> readSession();

  /// Removes the session and the pending identifier. Keeps the remembered
  /// credentials, "remember me" must survive a logout.
  Future<void> clearSession();

  /// The identifier waiting for its signup code, so the code screen still
  /// knows it after a restart.
  Future<void> savePendingIdentifier(String identifier) async {}

  Future<String?> readPendingIdentifier() async => null;

  Future<void> clearPendingIdentifier() async {}

  Future<void> saveRememberedCredentials(
    RememberedCredentials credentials,
  ) async {}

  Future<RememberedCredentials?> readRememberedCredentials() async => null;

  Future<void> clearRememberedCredentials() async {}

  /// Removes everything this store keeps (account deleted): session,
  /// pending identifier and "remember me".
  Future<void> clearAll() async {
    await clearSession();
    await clearPendingIdentifier();
    await clearRememberedCredentials();
  }
}
