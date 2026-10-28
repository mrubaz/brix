import 'package:brix/auth.dart';

/// Signup body of this demo. Your app uses its own typed model.
class DemoSignup {
  const DemoSignup({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;
}

/// The backend adapter – the only class that knows your API. This one keeps
/// users in memory; yours calls REST, Firebase, Supabase, …
///
/// Every code is [demoCode].
class DemoAuthProvider extends AuthProvider<DemoSignup, String> {
  static const demoCode = '123456';

  /// email → password, verified or not.
  static final _passwords = <String, String>{'demo@brix.dev': 'Demo@1234'};
  static final _verified = <String>{'demo@brix.dev'};

  @override
  AuthCapabilities get capabilities =>
      const AuthCapabilities(otpAfterSignup: true, resetMode: ResetMode.otp);

  @override
  Future<Result<AuthSession<String>>> login({
    required String identifier,
    required String password,
  }) async {
    await _wait();
    if (_passwords[identifier] != password) {
      return Failed(ValidationFailure(messages: ['Wrong email or password.']));
    }
    if (!_verified.contains(identifier)) {
      return Failed(ValidationFailure(messages: ['Verify your email first.']));
    }
    return Success(
      AuthSession(accessToken: 'demo-token', user: identifier),
      message: 'Welcome back!',
    );
  }

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Future<Result<void>> register(DemoSignup request) async {
    await _wait();
    if (_passwords.containsKey(request.email)) {
      return Failed(
        ValidationFailure(messages: ['This email is already registered.']),
      );
    }
    _passwords[request.email] = request.password;
    return const Success(null, message: 'We sent you a code: $demoCode');
  }

  @override
  Future<Result<void>> verifyOtp({
    required String identifier,
    required String code,
    required OtpPurpose purpose,
  }) async {
    await _wait();
    if (code != demoCode) {
      return Failed(
        ValidationFailure(messages: ['Wrong code. Try $demoCode.']),
      );
    }
    _verified.add(identifier);
    return const Success(null, message: 'Email verified. Please log in.');
  }

  @override
  Future<Result<void>> resendOtp({
    required String identifier,
    required OtpPurpose purpose,
  }) async {
    await _wait();
    return const Success(null, message: 'New code sent: $demoCode');
  }

  @override
  Future<Result<void>> forgotPassword({required String identifier}) async {
    await _wait();
    if (!_passwords.containsKey(identifier)) {
      return Failed(
        ValidationFailure(messages: ['No account with this email.']),
      );
    }
    return const Success(null, message: 'We sent you a code: $demoCode');
  }

  @override
  Future<Result<void>> resetPassword({
    required String identifier,
    required String newPassword,
    String? code,
  }) async {
    await _wait();
    if (code != demoCode) {
      return Failed(
        ValidationFailure(messages: ['Wrong code. Try $demoCode.']),
      );
    }
    _passwords[identifier] = newPassword;
    return const Success(null, message: 'Password changed. Please log in.');
  }

  // Looks like a real request, so the loaders show.
  static Future<void> _wait() =>
      Future<void>.delayed(const Duration(milliseconds: 600));
}
