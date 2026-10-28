/// Why a one-time code was sent.
///
/// Not an enum on purpose: adapters `switch` with a default case, so
/// purposes added to brix later never break them.
class OtpPurpose {
  const OtpPurpose(this.name);

  /// Stable id, e.g. for logs or tests.
  final String name;

  /// Verify the account right after signup.
  static const signup = OtpPurpose('signup');

  /// Set a new password (`ResetMode.otp`).
  static const passwordReset = OtpPurpose('passwordReset');

  static const values = [signup, passwordReset];

  @override
  String toString() => 'OtpPurpose($name)';
}
