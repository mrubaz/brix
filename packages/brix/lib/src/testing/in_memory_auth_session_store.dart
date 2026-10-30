import '../../auth.dart';

/// Store that keeps everything in fields, for tests.
class InMemoryAuthSessionStore<TUser> extends AuthSessionStore<TUser> {
  AuthSession<TUser>? session;
  String? pendingIdentifier;
  RememberedCredentials? rememberedCredentials;

  @override
  Future<void> saveSession(AuthSession<TUser> session) async =>
      this.session = session;

  @override
  Future<AuthSession<TUser>?> readSession() async => session;

  @override
  Future<void> clearSession() async {
    session = null;
    pendingIdentifier = null;
  }

  @override
  Future<void> savePendingIdentifier(String identifier) async =>
      pendingIdentifier = identifier;

  @override
  Future<String?> readPendingIdentifier() async => pendingIdentifier;

  @override
  Future<void> clearPendingIdentifier() async => pendingIdentifier = null;

  @override
  Future<void> saveRememberedCredentials(
    RememberedCredentials credentials,
  ) async => rememberedCredentials = credentials;

  @override
  Future<RememberedCredentials?> readRememberedCredentials() async =>
      rememberedCredentials;

  @override
  Future<void> clearRememberedCredentials() async =>
      rememberedCredentials = null;
}
