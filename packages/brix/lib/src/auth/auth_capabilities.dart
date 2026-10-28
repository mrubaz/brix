/// How a backend lets the user set a new password.
enum ResetMode {
  /// Backend emails a code; the app asks for it with the new password.
  otp,

  /// Backend emails a link; the app only asks for the email.
  link,

  /// No password reset.
  none,
}

/// What the backend's auth flow looks like. The flows pick the next screen
/// from this instead of checking which backend is used.
///
/// New options are always added with a default, so existing apps keep
/// compiling.
class AuthCapabilities {
  const AuthCapabilities({
    this.otpAfterSignup = false,
    this.resetMode = ResetMode.none,
    this.otpLength = 6,
  }) : assert(otpLength > 0, 'otpLength must be positive');

  /// Signup sends a code that must be verified before login.
  final bool otpAfterSignup;

  final ResetMode resetMode;

  /// Digits in every code the backend sends.
  final int otpLength;
}
