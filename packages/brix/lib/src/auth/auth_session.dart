/// A logged-in user and the tokens the backend gave for them.
class AuthSession<TUser> {
  const AuthSession({
    required this.accessToken,
    required this.user,
    this.refreshToken,
    this.expiresAt,
  });

  final String accessToken;
  final TUser user;
  final String? refreshToken;
  final DateTime? expiresAt;

  /// Tokens are left out so a session never ends up in a log.
  @override
  String toString() =>
      'AuthSession(user: $user, hasRefreshToken: ${refreshToken != null}, '
      'expiresAt: $expiresAt)';
}
