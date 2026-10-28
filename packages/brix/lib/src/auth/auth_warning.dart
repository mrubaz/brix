/// A local problem the flows report before any backend call, with a plain
/// English [message] the app can show as it is.
///
/// Not an enum on purpose: apps `switch` with a default case (or just show
/// [message]), so warnings added to brix later never break them. An app can
/// also make its own: `const AuthWarning('termsNotAccepted', 'Accept the
/// terms first.')`.
class AuthWarning {
  const AuthWarning(this.name, this.message);

  /// Stable id, e.g. for logs or tests.
  final String name;

  /// Default text. Apps show their own wording or language instead when
  /// they want to.
  final String message;

  /// Fewer digits entered than the code length.
  static const otpIncomplete = AuthWarning(
    'otpIncomplete',
    'Enter the full code.',
  );

  /// The code screen opened, but no identifier is waiting for a code.
  static const pendingIdentifierMissing = AuthWarning(
    'pendingIdentifierMissing',
    'Your sign up was not found. Please sign up again.',
  );

  /// A new password does not meet the `PasswordPolicy` (signup, reset,
  /// change password).
  static const weakPassword = AuthWarning(
    'weakPassword',
    'The password does not meet all the rules.',
  );

  /// Change password: the new password is the same as the current one.
  static const samePassword = AuthWarning(
    'samePassword',
    'The new password must be different from the current one.',
  );

  /// An account action needs a logged-in user, but none is known.
  static const notLoggedIn = AuthWarning(
    'notLoggedIn',
    'You are not logged in. Please log in again.',
  );

  /// Every warning brix itself reports.
  static const values = [
    otpIncomplete,
    pendingIdentifierMissing,
    weakPassword,
    samePassword,
    notLoggedIn,
  ];

  @override
  String toString() => 'AuthWarning($name)';
}
