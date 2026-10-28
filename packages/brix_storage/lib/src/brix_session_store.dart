import 'package:brix/auth.dart';

import 'brix_storage.dart';

/// Where [BrixSessionStore] keeps each item. Pass the keys an older app
/// version used, so its users stay logged in after the switch.
class SessionKeys {
  const SessionKeys({
    this.token = 'brix.token',
    this.refreshToken = 'brix.refreshToken',
    this.user = 'brix.user',
    this.pendingIdentifier = 'brix.pendingIdentifier',
    this.rememberedIdentifier = 'brix.rememberedIdentifier',
    this.rememberedPassword = 'brix.rememberedPassword',
  });

  final String token;
  final String refreshToken;
  final String user;
  final String pendingIdentifier;
  final String rememberedIdentifier;
  final String rememberedPassword;
}

/// A ready [AuthSessionStore] on [BrixStorage]: tokens and the remembered
/// password as secrets, the user as JSON, the rest as plain values.
///
/// ```dart
/// final store = BrixSessionStore<User>(
///   storage: BrixStorage(),
///   userToJson: (user) => user.toJson(),
///   userFromJson: User.fromJson,
/// );
/// ```
class BrixSessionStore<TUser> extends AuthSessionStore<TUser> {
  const BrixSessionStore({
    required this.storage,
    required this.userToJson,
    required this.userFromJson,
    this.keys = const SessionKeys(),
  });

  final BrixStorage storage;
  final Map<String, dynamic> Function(TUser user) userToJson;
  final TUser Function(Map<String, dynamic> json) userFromJson;
  final SessionKeys keys;

  @override
  Future<void> saveSession(AuthSession<TUser> session) async {
    await storage.writeSecret(keys.token, session.accessToken);
    final refresh = session.refreshToken;
    if (refresh != null) await storage.writeSecret(keys.refreshToken, refresh);
    await storage.writeJson(keys.user, userToJson(session.user));
  }

  /// `null` when the token or the user is missing or unreadable.
  @override
  Future<AuthSession<TUser>?> readSession() async {
    final token = await storage.readSecret(keys.token);
    if (token == null || token.isEmpty) return null;
    final json = await storage.readJson(keys.user);
    if (json == null) return null;
    final TUser user;
    try {
      user = userFromJson(json);
    } catch (error, stackTrace) {
      storage.onError?.call(error, stackTrace);
      return null;
    }
    return AuthSession(
      accessToken: token,
      user: user,
      refreshToken: await storage.readSecret(keys.refreshToken),
    );
  }

  /// Token, user and pending identifier go; "remember me" stays.
  @override
  Future<void> clearSession() async {
    await storage.deleteSecret(keys.token);
    await storage.deleteSecret(keys.refreshToken);
    await storage.delete(keys.user);
    await storage.delete(keys.pendingIdentifier);
  }

  @override
  Future<void> savePendingIdentifier(String identifier) =>
      storage.write(keys.pendingIdentifier, identifier);

  @override
  Future<String?> readPendingIdentifier() =>
      storage.read(keys.pendingIdentifier);

  @override
  Future<void> clearPendingIdentifier() =>
      storage.delete(keys.pendingIdentifier);

  @override
  Future<void> saveRememberedCredentials(
    RememberedCredentials credentials,
  ) async {
    await storage.write(keys.rememberedIdentifier, credentials.identifier);
    await storage.writeSecret(keys.rememberedPassword, credentials.password);
  }

  @override
  Future<RememberedCredentials?> readRememberedCredentials() async {
    final identifier = await storage.read(keys.rememberedIdentifier);
    final password = await storage.readSecret(keys.rememberedPassword);
    if (identifier == null || password == null) return null;
    return RememberedCredentials(identifier: identifier, password: password);
  }

  @override
  Future<void> clearRememberedCredentials() async {
    await storage.delete(keys.rememberedIdentifier);
    await storage.deleteSecret(keys.rememberedPassword);
  }

  @override
  Future<void> clearAll() => storage.clear();
}
