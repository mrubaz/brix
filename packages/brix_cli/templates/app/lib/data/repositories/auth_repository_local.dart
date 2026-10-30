import 'package:brix/auth.dart';

import '../../domain/models/signup_request.dart';
import '../../domain/models/user.dart';
import '../services/local_accounts_service.dart';

/// Auth on a backend that lives on this device, so the app runs before your
/// API exists. Only `main_development.dart` uses it, never a release build.
class AuthRepositoryLocal extends AuthProvider<SignupRequest, User> {
  AuthRepositoryLocal(this._accounts);

  final LocalAccountsService _accounts;

  static const _code = LocalAccountsService.demoCode;

  @override
  AuthCapabilities get capabilities =>
      const AuthCapabilities(otpAfterSignup: true, resetMode: ResetMode.otp);

  @override
  Future<Result<AuthSession<User>>> login({
    required String identifier,
    required String password,
  }) async {
    await _wait();
    final account = await _accounts.find(identifier);
    if (account == null || account.password != password) {
      return Failed(ValidationFailure(messages: ['Wrong email or password.']));
    }
    if (!account.verified) {
      return Failed(ValidationFailure(messages: ['Verify your email first.']));
    }
    return Success(
      AuthSession(
        accessToken: 'local-token',
        user: User(id: identifier, name: account.name, email: identifier),
      ),
      message: 'Welcome back!',
    );
  }

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Future<Result<void>> register(SignupRequest request) async {
    await _wait();
    if (await _accounts.find(request.email) != null) {
      return Failed(
        ValidationFailure(messages: ['This email is already registered.']),
      );
    }
    await _accounts.put(
      request.email,
      LocalAccount(
        name: request.name,
        password: request.password,
        verified: false,
      ),
    );
    return const Success(null, message: 'We sent you a code: $_code');
  }

  @override
  Future<Result<void>> verifyOtp({
    required String identifier,
    required String code,
    required OtpPurpose purpose,
  }) async {
    await _wait();
    if (code != _code) {
      return Failed(ValidationFailure(messages: ['Wrong code. Try $_code.']));
    }
    final account = await _accounts.find(identifier);
    if (account != null) {
      await _accounts.put(identifier, account.copyWith(verified: true));
    }
    return const Success(null, message: 'Email verified. Please log in.');
  }

  @override
  Future<Result<void>> resendOtp({
    required String identifier,
    required OtpPurpose purpose,
  }) async {
    await _wait();
    return const Success(null, message: 'New code sent: $_code');
  }

  @override
  Future<Result<void>> forgotPassword({required String identifier}) async {
    await _wait();
    if (await _accounts.find(identifier) == null) {
      return Failed(
        ValidationFailure(messages: ['No account with this email.']),
      );
    }
    return const Success(null, message: 'We sent you a code: $_code');
  }

  @override
  Future<Result<void>> resetPassword({
    required String identifier,
    required String newPassword,
    String? code,
  }) async {
    await _wait();
    if (code != _code) {
      return Failed(ValidationFailure(messages: ['Wrong code. Try $_code.']));
    }
    final account = await _accounts.find(identifier);
    if (account != null) {
      await _accounts.put(identifier, account.copyWith(password: newPassword));
    }
    return const Success(null, message: 'Password changed. Please log in.');
  }

  // Looks like a real request, so the loaders show.
  static Future<void> _wait() =>
      Future<void>.delayed(const Duration(milliseconds: 600));
}
